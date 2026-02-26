#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CORPUS_DIR="${1:-$ROOT_DIR/samples/corpus}"
WRITE_ROUNDTRIP_ARTIFACTS="${WRITE_ROUNDTRIP_ARTIFACTS:-0}"
OUT_DIR="$ROOT_DIR/samples/generated/corpus"

# Spec basis (T.800 Annex A / Annex B):
# - unknown markers 0xFF30..0xFF3F are skippable
# - packet headers may be relocated via PPM/PPT
# Operational implication:
# - decode -> encode must reproduce identical bytes for each corpus file.

if [ ! -d "$CORPUS_DIR" ]; then
  echo "corpus directory not found: $CORPUS_DIR" >&2
  exit 1
fi

if [ "$WRITE_ROUNDTRIP_ARTIFACTS" = "1" ]; then
  mkdir -p "$OUT_DIR"
fi

cd "$ROOT_DIR"

found=0
for in_bin in "$CORPUS_DIR"/*.j2k "$CORPUS_DIR"/*.j2c; do
  [ -e "$in_bin" ] || continue
  found=1
  base="$(basename "$in_bin")"

  out_hex="$(moon run cmd/main -- roundtrip-file "$in_bin" | tr -d '\r\n')"
  if echo "$out_hex" | rg -q '^error:'; then
    echo "[$base] roundtrip: FAILED ($out_hex)" >&2
    exit 1
  fi
  hex_from_file="$(xxd -p -c 1000000 "$in_bin" | tr -d '\n\r')"
  if [ "$out_hex" != "$hex_from_file" ]; then
    echo "[$base] roundtrip: FAILED (mismatch)" >&2
    exit 1
  fi
  echo "[$base] roundtrip: OK"

  if [ "$WRITE_ROUNDTRIP_ARTIFACTS" = "1" ]; then
    out_hex_file="$OUT_DIR/${base}.roundtrip.hex"
    out_bin_file="$OUT_DIR/${base}.roundtrip.j2k"
    printf '%s' "$out_hex" > "$out_hex_file"
    xxd -r -p "$out_hex_file" > "$out_bin_file"
  fi
done

if [ "$found" -eq 0 ]; then
  echo "no .j2k/.j2c files found in $CORPUS_DIR" >&2
  exit 1
fi

echo "corpus all: OK"
