#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CORPUS_DIR="${1:-$ROOT_DIR/samples/corpus}"
OUT_DIR="$ROOT_DIR/samples/generated/corpus"
HEX_ARG_LIMIT_BYTES="${HEX_ARG_LIMIT_BYTES:-120000}"
TMP_TEST_FILE="$ROOT_DIR/.tmp_roundtrip_corpus_$$._test.mbt"

# Spec basis (T.800 Annex A / Annex B):
# - annex-a-codestream-syntax.md:82-83
#   "All markers ... 0xFF30 and 0xFF3F ... shall be skipped by the decoder."
# - annex-b-image-and-compressed-image-data-ordering.md:744-747
#   packet headers may be relocated via PPM/PPT marker segments.
# Operational implication:
# - this script is the strictest evidence: decode -> encode must reproduce identical bytes for each corpus file.
# - failures here indicate encoder symmetry gaps or intentionally non-canonical source streams.

roundtrip_large_via_temp_test() {
  local in_bin="$1"
  local base="$2"
  local hex
  hex="$(xxd -p -c 1000000 "$in_bin" | tr -d '\n\r')"
  local chunk_size=2048
  local pos=0
  local total=${#hex}
  {
    echo "///|"
    echo "test \"external corpus strict roundtrip: $base\" {"
    echo "  let hex ="
    while [ "$pos" -lt "$total" ]; do
      local chunk="${hex:$pos:$chunk_size}"
      pos=$((pos + chunk_size))
      if [ "$pos" -lt "$total" ]; then
        echo "    \"$chunk\" +"
      else
        echo "    \"$chunk\""
      fi
    done
    echo "  let decoded = @jpeg2000.hex_to_bytes(hex)"
    echo "  guard decoded is Ok(bytes) else { fail(\"hex decode failed\") }"
    echo "  let rt = @jpeg2000.roundtrip_bytes(bytes)"
    echo "  if rt is Err(msg) { fail(\"roundtrip failed: \\{msg}\") }"
    echo "  guard rt is Ok(out) else { fail(\"roundtrip failed\") }"
    echo "  assert_eq(out, bytes)"
    echo "}"
  } > "$TMP_TEST_FILE"

  if moon test --package trkbt10/jpeg2000 --file "$(basename "$TMP_TEST_FILE")" >/tmp/roundtrip_corpus_large.log 2>&1; then
    return 0
  fi
  return 1
}

cleanup() {
  rm -f "$TMP_TEST_FILE"
}
trap cleanup EXIT

if [ ! -d "$CORPUS_DIR" ]; then
  echo "corpus directory not found: $CORPUS_DIR" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

found=0
for in_bin in "$CORPUS_DIR"/*.j2k "$CORPUS_DIR"/*.j2c; do
  [ -e "$in_bin" ] || continue
  found=1
  base="$(basename "$in_bin" .j2k)"
  out_hex="$OUT_DIR/${base}.roundtrip.hex"
  out_bin="$OUT_DIR/${base}.roundtrip.j2k"
  size_bytes="$(wc -c < "$in_bin" | tr -d ' ')"

  if [ "$size_bytes" -gt "$HEX_ARG_LIMIT_BYTES" ]; then
    if roundtrip_large_via_temp_test "$in_bin" "$base"; then
      echo "[$base] roundtrip: OK (large-path)"
      continue
    fi
    echo "[$base] roundtrip: FAILED (large-path)" >&2
    rg -n "FAILED:|error:|Total tests:" /tmp/roundtrip_corpus_large.log | tail -n 12 || true
    exit 1
  fi

  hex_from_file="$(xxd -p -c 1000000 "$in_bin" | tr -d '\n\r')"
  moon run cmd/main -- roundtrip-hex "$hex_from_file" | tr -d '\n\r' > "$out_hex"
  xxd -r -p "$out_hex" > "$out_bin"

  if cmp -s "$in_bin" "$out_bin"; then
    echo "[$base] roundtrip: OK"
  else
    echo "[$base] roundtrip: FAILED" >&2
    exit 1
  fi
done

if [ "$found" -eq 0 ]; then
  echo "no .j2k/.j2c files found in $CORPUS_DIR" >&2
  exit 1
fi

echo "corpus all: OK"
