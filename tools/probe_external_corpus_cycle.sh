#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CORPUS_DIR="${1:-$ROOT_DIR/samples/corpus}"
STRICT_EXTERNAL_PROBE="${STRICT_EXTERNAL_PROBE:-0}"
PROBE_ROUNDTRIP="${PROBE_ROUNDTRIP:-1}"
INCLUDE_HTJ2K="${INCLUDE_HTJ2K:-0}"

# Spec basis (T.800 Annex B): packet headers may be relocated via PPM/PPT.
# Operational implication: probe must use real-file decode path.

if [ ! -d "$CORPUS_DIR" ]; then
  echo "corpus directory not found: $CORPUS_DIR" >&2
  exit 1
fi

iter_external_corpus_files() {
  local corpus_dir="$1"
  if [ "$INCLUDE_HTJ2K" = "1" ]; then
    find "$corpus_dir" -type f \( \
      -name '*.j2k' -o -name '*.j2c' -o -name '*.jph' -o -name '*.jhc' \
    \) | LC_ALL=C sort
  else
    find "$corpus_dir" -type f \( \
      -name '*.j2k' -o -name '*.j2c' \
    \) ! -path '*/htj2k/*' | LC_ALL=C sort
  fi
}

cd "$ROOT_DIR"

found=0
ok=0
fail=0
strict_fail=0
roundtrip_fail=0

while IFS= read -r in_bin; do
  found=1
  rel="${in_bin#$CORPUS_DIR/}"

  if [ "$STRICT_EXTERNAL_PROBE" = "1" ]; then
    out_strict="$(moon run cmd/main -- parse-file-strict "$in_bin" | tr -d '\r\n')"
    if [ "$out_strict" != "ok" ]; then
      echo "[$rel] fail(strict): $out_strict"
      strict_fail=$((strict_fail + 1))
      fail=$((fail + 1))
      continue
    fi
  fi

  if [ "$PROBE_ROUNDTRIP" = "1" ]; then
    out_rt="$(moon run cmd/main -- roundtrip-file-verify "$in_bin" | tr -d '\r\n')"
    if [ "$out_rt" != "ok" ]; then
      echo "[$rel] fail(roundtrip): $out_rt"
      roundtrip_fail=$((roundtrip_fail + 1))
      fail=$((fail + 1))
      continue
    fi
  else
    out_default="$(moon run cmd/main -- parse-file "$in_bin" | tr -d '\r\n')"
    if [ "$out_default" != "ok" ]; then
      echo "[$rel] fail(default): $out_default"
      fail=$((fail + 1))
      continue
    fi
  fi

  echo "[$rel] ok"
  ok=$((ok + 1))
done < <(iter_external_corpus_files "$CORPUS_DIR")

if [ "$found" -eq 0 ]; then
  echo "no .j2k/.j2c files found in $CORPUS_DIR" >&2
  exit 1
fi

echo "external probe summary: ok=$ok fail=$fail strict_fail=$strict_fail roundtrip_fail=$roundtrip_fail"

if [ "$STRICT_EXTERNAL_PROBE" = "1" ] && [ "$fail" -gt 0 ]; then
  exit 1
fi
