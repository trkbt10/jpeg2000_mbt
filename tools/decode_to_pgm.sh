#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <input.j2k> <output.pgm|output.ppm>" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INPUT="$1"
OUTPUT="$2"

cd "$ROOT_DIR"

info="$(moon run cmd/main -- decode-file-dump "$INPUT" 2>&1)"
dump_line="$(printf '%s\n' "$info" | grep '^ok-dump:' | head -n1 || true)"
if [ -z "$dump_line" ]; then
  echo "decode failed: $info" >&2
  exit 1
fi

w="$(printf '%s\n' "$dump_line" | sed -nE 's/.* w=([0-9]+) .*/\1/p' | head -n1)"
h="$(printf '%s\n' "$dump_line" | sed -nE 's/.* h=([0-9]+) .*/\1/p' | head -n1)"
comps="$(printf '%s\n' "$dump_line" | sed -nE 's/.* comps=([0-9]+) .*/\1/p' | head -n1)"
bits="$(printf '%s\n' "$dump_line" | sed -nE 's/.* bits=([0-9]+) .*/\1/p' | head -n1)"
hex="$(printf '%s\n' "$dump_line" | sed -nE 's/.* samples_hex=([0-9a-f]+)$/\1/p' | head -n1)"

if [ -z "$w" ] || [ -z "$h" ] || [ -z "$comps" ] || [ -z "$bits" ] || [ -z "$hex" ]; then
  echo "failed to parse decode output" >&2
  exit 1
fi

maxval=$((2**bits - 1))
if [ "$comps" -eq 1 ]; then
  magic="P5"
elif [ "$comps" -eq 3 ]; then
  magic="P6"
else
  echo "unsupported component count: $comps" >&2
  exit 1
fi

{
  printf '%s\n' "$magic"
  printf '%s %s\n' "$w" "$h"
  printf '%s\n' "$maxval"
  printf '%s' "$hex" | xxd -r -p
} >"$OUTPUT"

echo "created: $OUTPUT (${w}x${h}, $comps components, $bits bits)"
