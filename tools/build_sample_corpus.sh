#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${1:-$ROOT_DIR/samples/generated/builtins}"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

moon run cmd/main -- list-samples | while IFS= read -r name; do
  [ -z "$name" ] && continue
  out_hex="$OUT_DIR/${name}.j2k.hex"
  out_bin="$OUT_DIR/${name}.j2k"

  moon run cmd/main -- sample-hex "$name" | tr -d '\n\r' > "$out_hex"
  xxd -r -p "$out_hex" > "$out_bin"

  echo "[$name] built: $out_bin"
done

echo "built-in sample corpus ready: $OUT_DIR"
