#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CORPUS_DIR="${1:-$ROOT_DIR/samples/corpus}"
HEX_ARG_LIMIT_BYTES="${HEX_ARG_LIMIT_BYTES:-120000}"
STRICT_EXTERNAL_PROBE="${STRICT_EXTERNAL_PROBE:-0}"
PROBE_LARGE_PATH="${PROBE_LARGE_PATH:-1}"
TMP_TEST_FILE="$ROOT_DIR/.tmp_external_probe_$$._test.mbt"

# Spec basis (T.800 Annex B):
# - /sections/annex-b-image-and-compressed-image-data-ordering.md:742-747
#   "The packet headers appear in the codestream ... unless one of the PPM or PPT marker segments has been used."
#   "If the PPM marker segment is used ... all of the packet headers are relocated to the main header ..."
#   "If the PPM is not used, then a PPT marker segment may be used ... relocated to tile-part headers ..."
# Operational implication:
# - external files may carry legal packet-header relocation (PPM/PPT), so probe must exercise real-file decode path.
# - large-path temp test exists to avoid shell argument-size limits, not to loosen parser requirements.

if [ ! -d "$CORPUS_DIR" ]; then
  echo "corpus directory not found: $CORPUS_DIR" >&2
  exit 1
fi

cd "$ROOT_DIR"

found=0
ok=0
fail=0
large_path=0
skip_arg_limit=0

probe_large_via_temp_test() {
  local in_bin="$1"
  local base="$2"
  local hex
  hex="$(xxd -p -c 1000000 "$in_bin" | tr -d '\n\r')"
  local chunk_size=2048
  local pos=0
  local total=${#hex}
  {
    echo "///|"
    echo "test \"external corpus large roundtrip: $base\" {"
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
    echo "  let rt1 = @jpeg2000.roundtrip_bytes(bytes)"
    echo "  if rt1 is Err(msg) { fail(\"roundtrip-1 failed: \\{msg}\") }"
    echo "  guard rt1 is Ok(out1) else { fail(\"roundtrip-1 failed\") }"
    echo "  let rt2 = @jpeg2000.roundtrip_bytes(out1)"
    echo "  if rt2 is Err(msg) { fail(\"roundtrip-2 failed: \\{msg}\") }"
    echo "  guard rt2 is Ok(out2) else { fail(\"roundtrip-2 failed\") }"
    echo "  assert_eq(out2, out1)"
    echo "}"
  } > "$TMP_TEST_FILE"

  if moon test --package trkbt10/jpeg2000 --file "$(basename "$TMP_TEST_FILE")" >/tmp/external_probe_large.log 2>&1; then
    return 0
  fi
  return 1
}

cleanup() {
  rm -f "$TMP_TEST_FILE"
}
trap cleanup EXIT

for in_bin in "$CORPUS_DIR"/*.j2k "$CORPUS_DIR"/*.j2c; do
  [ -e "$in_bin" ] || continue
  found=1
  base="$(basename "$in_bin")"
  size_bytes="$(wc -c < "$in_bin" | tr -d ' ')"

  if [ "$size_bytes" -gt "$HEX_ARG_LIMIT_BYTES" ]; then
    if [ "$PROBE_LARGE_PATH" != "1" ]; then
      echo "[$base] skip(arg-limit): size=$size_bytes limit=$HEX_ARG_LIMIT_BYTES"
      skip_arg_limit=$((skip_arg_limit + 1))
      continue
    fi
    # Spec basis (same Annex B quote above): packet headers may be structurally relocated by marker segments,
    # so we must test full file bytes even when command-line hex argument transport is too large.
    large_path=$((large_path + 1))
    if probe_large_via_temp_test "$in_bin" "$base"; then
      echo "[$base] ok (large-path)"
      ok=$((ok + 1))
    else
      echo "[$base] fail (large-path)"
      rg -n "FAILED:|error:|Total tests:" /tmp/external_probe_large.log | tail -n 12 || true
      fail=$((fail + 1))
    fi
    continue
  fi

  hex_from_file="$(xxd -p -c 1000000 "$in_bin" | tr -d '\n\r')"
  out="$(moon run cmd/main -- roundtrip-hex "$hex_from_file" | tr -d '\r')"
  if echo "$out" | rg -q '^error:'; then
    echo "[$base] fail: $out"
    fail=$((fail + 1))
  else
    echo "[$base] ok"
    ok=$((ok + 1))
  fi
done

if [ "$found" -eq 0 ]; then
  echo "no .j2k/.j2c files found in $CORPUS_DIR" >&2
  exit 1
fi

echo "external probe summary: ok=$ok fail=$fail skip_arg_limit=$skip_arg_limit large_path=$large_path"

if [ "$STRICT_EXTERNAL_PROBE" = "1" ] && [ "$fail" -gt 0 ]; then
  exit 1
fi
