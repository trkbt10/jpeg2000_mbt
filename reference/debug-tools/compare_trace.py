#!/usr/bin/env python3
"""Compare MoonBit recon-audit traces against reference implementation trace logs.

Usage:
  python3 reference/debug-tools/compare_trace.py \
    --moon-log /tmp/p1_06_moon_audit_meta.log \
    --ref-log /tmp/p1_06_ref_trace_precise.log
"""

from __future__ import annotations

import argparse
import math
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple

MOON_RE = re.compile(
    r"recon-audit:(dwt-pre|dwt-pre-deq|dwt-post|mct-src|mct-r):label=([^ ]+) c=(\-?\d+) .*?first=\[(.*?)\]"
)
REF_RE = re.compile(
    r"opj-(dwt-pre|dwt-post|mct-src|mct-r):tile=(\d+) c=(\d+) .*?first=([^\n]+)"
)


def parse_num_list(text: str) -> List[float]:
    out: List[float] = []
    for part in text.split(","):
        part = part.strip()
        if not part:
            continue
        out.append(float(part))
    return out


def label_to_tile(label: str) -> int | None:
    if label == "single":
        return 0
    if label.startswith("tile"):
        suffix = label[4:]
        if suffix.isdigit():
            return int(suffix)
        return None
    if label.isdigit():
        return int(label)
    return None


def parse_moon(path: Path) -> Dict[Tuple[str, int, int], List[float]]:
    m: Dict[Tuple[str, int, int], List[float]] = {}
    for kind, label, comp, arr in MOON_RE.findall(path.read_text()):
        tile = label_to_tile(label)
        if tile is None:
            continue
        m[(kind, tile, int(comp))] = parse_num_list(arr)
    return m


def parse_ref(path: Path) -> Dict[Tuple[str, int, int], List[float]]:
    m: Dict[Tuple[str, int, int], List[float]] = {}
    for kind, tile, comp, arr in REF_RE.findall(path.read_text()):
        m[(kind, int(tile), int(comp))] = parse_num_list(arr)
    return m


def to_ints(vals: List[float]) -> List[int]:
    return [int(round(v)) for v in vals]


@dataclass
class StageSummary:
    stage: str
    total_entries: int
    bad_entries_int: int
    max_abs_diff: float
    mean_abs_diff: float


def compare_stage(
    moon: Dict[Tuple[str, int, int], List[float]],
    ref: Dict[Tuple[str, int, int], List[float]],
    moon_stage: str,
    ref_stage: str,
    comps: List[int],
    show_details: int,
) -> Tuple[StageSummary, List[Tuple[int, int]]]:
    bad_keys: List[Tuple[int, int]] = []
    total = 0
    bad = 0
    max_abs = 0.0
    abs_sum = 0.0
    abs_cnt = 0
    details_printed = 0

    candidate_tiles = set()
    for stage, tile, comp in moon.keys():
        if stage == moon_stage and comp in comps:
            candidate_tiles.add(tile)
    for stage, tile, comp in ref.keys():
        if stage == ref_stage and comp in comps:
            candidate_tiles.add(tile)

    for tile in sorted(candidate_tiles):
        for comp in comps:
            mk = (moon_stage, tile, comp)
            rk = (ref_stage, tile, comp)
            if mk not in moon or rk not in ref:
                continue
            total += 1
            moon_vals = moon[mk]
            ref_vals = ref[rk]
            mv = to_ints(moon_vals)
            ov = to_ints(ref_vals)
            n = min(len(mv), len(ov), len(moon_vals), len(ref_vals))
            diffs_int = []
            diffs_float = []
            for i in range(n):
                d_int = mv[i] - ov[i]
                d_float = moon_vals[i] - ref_vals[i]
                diffs_float.append((i, moon_vals[i], ref_vals[i], d_float))
                abs_d = abs(d_float)
                abs_sum += abs_d
                abs_cnt += 1
                if abs_d > max_abs:
                    max_abs = abs_d
                if d_int != 0:
                    diffs_int.append((i, mv[i], ov[i], d_int))
            if diffs_int:
                bad += 1
                bad_keys.append((tile, comp))
                if details_printed < show_details:
                    print(
                        f"  {moon_stage}: tile={tile} c={comp} int_mism={len(diffs_int)} first_int={diffs_int[:4]} first_float={diffs_float[:2]}"
                    )
                    details_printed += 1

    mean_abs = abs_sum / abs_cnt if abs_cnt > 0 else 0.0
    return StageSummary(moon_stage, total, bad, max_abs, mean_abs), bad_keys


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--moon-log", type=Path, required=True)
    ap.add_argument("--ref-log", type=Path, required=True)
    ap.add_argument("--show-details", type=int, default=12)
    args = ap.parse_args()

    moon = parse_moon(args.moon_log)
    ref = parse_ref(args.ref_log)

    stages = [
        ("dwt-pre-deq", "dwt-pre", [0, 1, 2]),
        ("dwt-post", "dwt-post", [0, 1, 2]),
        ("mct-src", "mct-src", [0, 1, 2]),
        ("mct-r", "mct-r", [0]),
    ]

    all_bad: Dict[str, List[Tuple[int, int]]] = {}
    print("trace comparison summary:")
    for moon_stage, ref_stage, comps in stages:
        summary, bad_keys = compare_stage(
            moon,
            ref,
            moon_stage,
            ref_stage,
            comps,
            args.show_details,
        )
        all_bad[moon_stage] = bad_keys
        print(
            f"- {summary.stage:11s} total={summary.total_entries:2d} bad_int={summary.bad_entries_int:2d} max_abs_diff={summary.max_abs_diff:.6g} mean_abs_diff={summary.mean_abs_diff:.6g}"
        )

    pre = set(all_bad.get("dwt-pre-deq", []))
    post = set(all_bad.get("dwt-post", []))
    new_in_post = sorted(post - pre)
    resolved_in_post = sorted(pre - post)
    print(f"- dwt-post new_vs_pre={len(new_in_post)} resolved_vs_pre={len(resolved_in_post)}")
    if new_in_post:
        print(f"  new_in_post: {new_in_post}")
    if resolved_in_post:
        print(f"  resolved_in_post: {resolved_in_post}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
