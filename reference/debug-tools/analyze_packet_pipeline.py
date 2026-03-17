#!/usr/bin/env python3
"""Fixture-level packet pipeline analyzer.

Stages:
1) codestream marker structure (SOT/PPT/SOD)
2) packet count from SOP markers in SOD
3) packet-header count from PPT (split by EPH)
4) decoder audit packet-header consumption (hbytes) vs PPT segments
"""

from __future__ import annotations

import argparse
import re
import subprocess
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Tuple


@dataclass
class TilePart:
    tile: int
    psot: int
    sot_pos: int
    tpsot: int
    tnsot: int
    ppt_chunks: List[Tuple[int, bytes]] = field(default_factory=list)
    sod: bytes = b""
    sop_nsop: List[int] = field(default_factory=list)
    sop_offsets: List[int] = field(default_factory=list)

    def merged_ppt(self) -> bytes:
        merged = bytearray()
        for _, chunk in sorted(self.ppt_chunks, key=lambda x: x[0]):
            merged.extend(chunk)
        return bytes(merged)


def extract_codestream(data: bytes) -> bytes:
    if data.startswith(b"\xFF\x4F"):
        return data
    offset = 0
    n = len(data)
    while offset + 8 <= n:
        lbox = int.from_bytes(data[offset : offset + 4], "big")
        tbox = data[offset + 4 : offset + 8]
        header = 8
        if lbox == 0:
            box_size = n - offset
        elif lbox == 1:
            if offset + 16 > n:
                raise ValueError("truncated XLBox")
            box_size = int.from_bytes(data[offset + 8 : offset + 16], "big")
            header = 16
        else:
            box_size = lbox
        if box_size < header or offset + box_size > n:
            raise ValueError("invalid JP2 box size")
        if tbox == b"jp2c":
            payload = data[offset + header : offset + box_size]
            if not payload.startswith(b"\xFF\x4F"):
                raise ValueError("jp2c does not start with SOC")
            return payload
        offset += box_size
    raise ValueError("jp2c box not found")


def find_next_sot_or_eoc(data: bytes, start: int) -> int:
    i = start
    n = len(data)
    while i + 1 < n:
        if data[i] == 0xFF and data[i + 1] in (0x90, 0xD9):
            return i
        i += 1
    return n


def parse_sop_markers(payload: bytes) -> List[Tuple[int, int]]:
    markers: List[Tuple[int, int]] = []
    i = 0
    n = len(payload)
    while i + 5 < n:
        if (
            payload[i] == 0xFF
            and payload[i + 1] == 0x91
            and payload[i + 2] == 0x00
            and payload[i + 3] == 0x04
        ):
            markers.append((i, (payload[i + 4] << 8) | payload[i + 5]))
            i += 6
        else:
            i += 1
    return markers


def split_by_eph(ppt: bytes) -> List[bytes]:
    segments: List[bytes] = []
    start = 0
    i = 0
    n = len(ppt)
    while i + 1 < n:
        if ppt[i] == 0xFF and ppt[i + 1] == 0x92:
            segments.append(ppt[start:i])
            start = i + 2
            i += 2
        else:
            i += 1
    if start != n:
        segments.append(ppt[start:n])
    return segments


def parse_tile_parts(codestream: bytes) -> List[TilePart]:
    if not codestream.startswith(b"\xFF\x4F"):
        raise ValueError("codestream does not start with SOC")
    i = 2
    n = len(codestream)
    parts: List[TilePart] = []
    current: Optional[TilePart] = None
    while i + 1 < n:
        if codestream[i] != 0xFF:
            raise ValueError(f"invalid marker prefix at {i}")
        code = (codestream[i] << 8) | codestream[i + 1]
        if code == 0xFFD9:
            break
        if code == 0xFF93:
            if current is None:
                raise ValueError("SOD without preceding SOT")
            start = i + 2
            end = (
                current.sot_pos + current.psot
                if current.psot > 0
                else find_next_sot_or_eoc(codestream, start)
            )
            if end < start or end > n:
                raise ValueError("invalid SOD payload bounds")
            current.sod = codestream[start:end]
            sop = parse_sop_markers(current.sod)
            current.sop_offsets = [off for off, _ in sop]
            current.sop_nsop = [nsop for _, nsop in sop]
            i = end
            continue
        if i + 3 >= n:
            raise ValueError("truncated marker length")
        length = (codestream[i + 2] << 8) | codestream[i + 3]
        if length < 2:
            raise ValueError("invalid marker segment length")
        payload_start = i + 4
        payload_end = payload_start + (length - 2)
        if payload_end > n:
            raise ValueError("marker segment exceeds codestream")
        payload = codestream[payload_start:payload_end]
        if code == 0xFF90:
            if len(payload) < 8:
                raise ValueError("short SOT payload")
            current = TilePart(
                tile=(payload[0] << 8) | payload[1],
                psot=int.from_bytes(payload[2:6], "big"),
                sot_pos=i,
                tpsot=payload[6],
                tnsot=payload[7],
            )
            parts.append(current)
        elif code == 0xFF61:
            if current is None:
                raise ValueError("PPT without SOT context")
            if len(payload) >= 1:
                current.ppt_chunks.append((payload[0], payload[1:]))
        i = payload_end
    return parts


@dataclass
class AuditPacket:
    idx: int
    outcome: str = "unknown"
    hbytes: Optional[int] = None
    reason: Optional[str] = None
    start_off: Optional[int] = None
    packet_size: Optional[int] = None


def parse_audit_output(text: str) -> Dict[str, Dict[int, AuditPacket]]:
    by_label: Dict[str, Dict[int, AuditPacket]] = {}
    start_re = re.compile(r"pkt-audit:start .*label=([^ ]+) idx=(\d+).* off=(\d+)")
    ok_re = re.compile(
        r"pkt-audit:ok .*label=([^ ]+) idx=(\d+).* hbytes=(\d+).* packet_size=(\d+)"
    )
    eph_re = re.compile(
        r"pkt-audit:eph_fail .*label=([^ ]+) idx=(\d+).* hbytes=(\d+)"
    )
    header_fail_re = re.compile(
        r"pkt-audit:header_fail .*label=([^ ]+) idx=(\d+)"
    )
    size_invalid_re = re.compile(
        r"pkt-audit:size_invalid .*label=([^ ]+) idx=(\d+)"
    )
    skip_re = re.compile(
        r"pkt-audit:skip .*label=([^ ]+) idx=(\d+) reason=([a-z_]+)"
    )

    for line in text.splitlines():
        m = start_re.search(line)
        if m:
            label = m.group(1)
            idx = int(m.group(2))
            pkt = by_label.setdefault(label, {}).setdefault(idx, AuditPacket(idx=idx))
            pkt.start_off = int(m.group(3))
            continue
        m = ok_re.search(line)
        if m:
            label = m.group(1)
            idx = int(m.group(2))
            pkt = by_label.setdefault(label, {}).setdefault(idx, AuditPacket(idx=idx))
            pkt.outcome = "ok"
            pkt.hbytes = int(m.group(3))
            pkt.packet_size = int(m.group(4))
            continue
        m = eph_re.search(line)
        if m:
            label = m.group(1)
            idx = int(m.group(2))
            pkt = by_label.setdefault(label, {}).setdefault(idx, AuditPacket(idx=idx))
            pkt.outcome = "eph_fail"
            pkt.hbytes = int(m.group(3))
            continue
        m = header_fail_re.search(line)
        if m:
            label = m.group(1)
            idx = int(m.group(2))
            pkt = by_label.setdefault(label, {}).setdefault(idx, AuditPacket(idx=idx))
            pkt.outcome = "header_fail"
            continue
        m = size_invalid_re.search(line)
        if m:
            label = m.group(1)
            idx = int(m.group(2))
            pkt = by_label.setdefault(label, {}).setdefault(idx, AuditPacket(idx=idx))
            pkt.outcome = "size_invalid"
            continue
        m = skip_re.search(line)
        if m:
            label = m.group(1)
            idx = int(m.group(2))
            pkt = by_label.setdefault(label, {}).setdefault(idx, AuditPacket(idx=idx))
            pkt.outcome = "skip"
            pkt.reason = m.group(3)
    return by_label


def run_audit(path: Path, moon_cmd: str, limit: int) -> str:
    cmd = [
        moon_cmd,
        "run",
        "cmd/main",
        "--",
        "decode-file-audit",
        str(path),
        "ppt",
        str(limit),
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
    return proc.stdout + proc.stderr


def audit_needs_more_limit(
    parts: List[TilePart],
    audit: Dict[str, Dict[int, AuditPacket]],
) -> bool:
    """Heuristic: audit likely truncated when SOP packets exceed audited packets."""
    for part in parts:
        sop_count = len(part.sop_nsop)
        if sop_count <= 0:
            continue
        label = f"tile{part.tile}"
        if label not in audit and len(parts) == 1:
            if "single" in audit:
                label = "single"
            elif len(audit) == 1:
                label = next(iter(audit.keys()))
        audit_count = len(audit.get(label, {}))
        # Allow one missing packet at tail (empty last packet at stream end).
        if audit_count + 1 < sop_count:
            return True
    return False


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("fixture", type=Path)
    parser.add_argument("--moon", default="moon")
    parser.add_argument("--audit-limit", type=int, default=5000)
    parser.add_argument("--max-audit-limit", type=int, default=2_000_000)
    args = parser.parse_args()

    data = args.fixture.read_bytes()
    codestream = extract_codestream(data)
    parts = parse_tile_parts(codestream)
    if not parts:
        print("no tile-parts found")
        return 1

    current_limit = args.audit_limit
    audit_text = run_audit(args.fixture, args.moon, current_limit)
    audit = parse_audit_output(audit_text)
    while (
        audit_needs_more_limit(parts, audit)
        and current_limit < args.max_audit_limit
    ):
        next_limit = min(current_limit * 8, args.max_audit_limit)
        if next_limit <= current_limit:
            break
        print(
            f"audit_limit_insufficient: rerun limit {current_limit} -> {next_limit}"
        )
        current_limit = next_limit
        audit_text = run_audit(args.fixture, args.moon, current_limit)
        audit = parse_audit_output(audit_text)

    print(f"fixture={args.fixture}")
    print(f"audit_limit_used={current_limit}")
    print(f"tile_parts={len(parts)}")
    all_ok = True

    for part in parts:
        tile = part.tile
        sop_count = len(part.sop_nsop)
        ppt = part.merged_ppt()
        ppt_segs = split_by_eph(ppt)
        label = f"tile{tile}"
        if label not in audit and len(parts) == 1:
            if "single" in audit:
                label = "single"
            elif len(audit) == 1:
                label = next(iter(audit.keys()))
        audit_pkts = audit.get(label, {})
        audit_count = len(audit_pkts)
        has_ppt = len(ppt) > 0
        has_sop = sop_count > 0

        stage1_ok = len(part.sod) > 0
        # SOP is optional (csty SOP flag not set streams are valid).
        stage2_ok = True
        if has_ppt:
            # With SOP present, PPT packet-header chunks should align with packets.
            # Without SOP, header relocation may still be valid but unverifiable here.
            stage3_ok = (len(ppt_segs) == sop_count) if has_sop else True
        else:
            # Without relocated headers and SOP markers, skip count check.
            # Allow one missing audit packet at tail (common when the final SOP
            # packet is empty and the decoder exits exactly at payload end).
            stage3_ok = (abs(audit_count - sop_count) <= 1) if has_sop else True
        stage4_ok = True
        stage5_ok = True
        first_mismatch = None
        first_size_mismatch = None
        first_header_fail = None

        if has_ppt:
            for idx in range(min(len(ppt_segs), audit_count)):
                pkt = audit_pkts.get(idx)
                if pkt is None or pkt.hbytes is None:
                    continue
                expected_hbytes = len(ppt_segs[idx]) + 2
                if pkt.hbytes != expected_hbytes:
                    stage4_ok = False
                    first_mismatch = (
                        idx,
                        pkt.outcome,
                        pkt.hbytes,
                        expected_hbytes,
                        ppt_segs[idx].hex(),
                    )
                    break
        else:
            for idx in sorted(audit_pkts.keys()):
                pkt = audit_pkts[idx]
                if pkt.outcome in ("header_fail", "eph_fail", "size_invalid"):
                    stage4_ok = False
                    first_header_fail = (idx, pkt.outcome)
                    break

        # Validate packet-size continuity against the next audit packet start offset.
        # This avoids false positives from accidental FF91 patterns inside entropy data.
        start_offsets = {
            idx: pkt.start_off
            for idx, pkt in audit_pkts.items()
            if pkt.start_off is not None
        }
        ordered_starts = sorted(start_offsets.keys())
        for idx in sorted(audit_pkts.keys()):
            pkt = audit_pkts[idx]
            if pkt.outcome != "ok" or pkt.packet_size is None or pkt.start_off is None:
                continue
            next_off = len(part.sod)
            has_next = False
            for cand in ordered_starts:
                if cand > idx:
                    next_off = start_offsets[cand]
                    has_next = True
                    break
            if has_sop and not has_ppt and not has_next:
                # Cannot reliably validate the last audited packet when the
                # following SOP packet may exist but was not audited.
                continue
            expected_packet_size = next_off - pkt.start_off
            if has_sop and not has_ppt and has_next:
                # start_off is after SOP bytes, so adjacent packet starts differ
                # by (packet_size + 6-byte SOP marker of the next packet).
                expected_packet_size -= 6
                if expected_packet_size < 0:
                    expected_packet_size = 0
            if pkt.packet_size != expected_packet_size:
                stage5_ok = False
                first_size_mismatch = (
                    idx,
                    pkt.packet_size,
                    expected_packet_size,
                    pkt.start_off,
                    next_off,
                )
                break

        print(
            f"tile={tile:2d} "
            f"label={label:>6s} "
            f"S1={'ok' if stage1_ok else 'ng'} "
            f"S2={'ok' if stage2_ok else 'ng'} "
            f"S3={'ok' if stage3_ok else 'ng'} "
            f"S4={'ok' if stage4_ok else 'ng'} "
            f"S5={'ok' if stage5_ok else 'ng'} "
            f"sop={sop_count} ppt_eph={len(ppt_segs)} audit={audit_count}"
        )
        if first_mismatch is not None:
            idx, outcome, hbytes, expected, hdr_hex = first_mismatch
            print(
                "  first_mismatch: "
                f"idx={idx} outcome={outcome} hbytes={hbytes} expected={expected} "
                f"ppt_header={hdr_hex}"
            )
        if first_header_fail is not None:
            idx, outcome = first_header_fail
            print(
                "  first_header_fail: "
                f"idx={idx} outcome={outcome}"
            )
        if first_size_mismatch is not None:
            idx, got, expected, start_off, next_off = first_size_mismatch
            print(
                "  first_size_mismatch: "
                f"idx={idx} packet_size={got} expected={expected} "
                f"start_off={start_off} next_sop_off={next_off}"
            )

        if not (stage1_ok and stage2_ok and stage3_ok and stage4_ok and stage5_ok):
            all_ok = False

    print("pipeline_result=ok" if all_ok else "pipeline_result=ng")
    return 0 if all_ok else 2


if __name__ == "__main__":
    raise SystemExit(main())
