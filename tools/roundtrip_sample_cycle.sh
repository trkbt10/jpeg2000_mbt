#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IN_HEX="$ROOT_DIR/samples/generated/minimal.j2k.hex"
IN_BIN="$ROOT_DIR/samples/generated/minimal.j2k"
OUT_HEX="$ROOT_DIR/samples/generated/minimal.roundtrip.hex"
OUT_BIN="$ROOT_DIR/samples/generated/minimal.roundtrip.j2k"

cd "$ROOT_DIR"

moon run cmd/main -- sample-hex | tr -d '\n\r' > "$IN_HEX"
xxd -r -p "$IN_HEX" > "$IN_BIN"

HEX_FROM_FILE="$(xxd -p -c 1000000 "$IN_BIN" | tr -d '\n\r')"
moon run cmd/main -- roundtrip-hex "$HEX_FROM_FILE" | tr -d '\n\r' > "$OUT_HEX"
xxd -r -p "$OUT_HEX" > "$OUT_BIN"

if cmp -s "$IN_BIN" "$OUT_BIN"; then
  echo "roundtrip: OK"
  echo "input : $IN_BIN"
  echo "output: $OUT_BIN"
else
  echo "roundtrip: FAILED" >&2
  exit 1
fi
