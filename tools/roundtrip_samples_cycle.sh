#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT_DIR/samples/generated"
mkdir -p "$OUT_DIR"

cd "$ROOT_DIR"

moon run cmd/main -- list-samples | while IFS= read -r name; do
  [ -z "$name" ] && continue
  in_hex="$OUT_DIR/${name}.j2k.hex"
  in_bin="$OUT_DIR/${name}.j2k"
  out_hex="$OUT_DIR/${name}.roundtrip.hex"
  out_bin="$OUT_DIR/${name}.roundtrip.j2k"

  moon run cmd/main -- sample-hex "$name" | tr -d '\n\r' > "$in_hex"
  xxd -r -p "$in_hex" > "$in_bin"

  hex_from_file="$(xxd -p -c 1000000 "$in_bin" | tr -d '\n\r')"
  moon run cmd/main -- roundtrip-hex "$hex_from_file" | tr -d '\n\r' > "$out_hex"
  xxd -r -p "$out_hex" > "$out_bin"

  if cmp -s "$in_bin" "$out_bin"; then
    echo "[$name] roundtrip: OK"
  else
    echo "[$name] roundtrip: FAILED" >&2
    exit 1
  fi
done

echo "all samples: OK"
