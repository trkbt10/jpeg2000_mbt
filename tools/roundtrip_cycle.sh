#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GENERATED_DIR="$ROOT_DIR/samples/generated"
DEFAULT_CORPUS_DIR="$ROOT_DIR/samples/corpus"
DEFAULT_BUILTIN_CORPUS_DIR="$ROOT_DIR/samples/generated/builtins"
DEFAULT_DECODE_ROUNDTRIP_DIR="$ROOT_DIR/roundtrip/decode-roundtrip"
INCLUDE_HTJ2K="${INCLUDE_HTJ2K:-0}"

usage() {
  cat <<'EOF'
usage: tools/roundtrip_cycle.sh <command> [args]

commands:
  sample [name]                 roundtrip one built-in sample (default: minimal)
  samples                       roundtrip all built-in samples
  build-builtins [out_dir]      materialize built-in samples as .j2k files
  corpus [corpus_dir]           roundtrip an external corpus directory
  decode-fixture <path> [dir]   write decode(original|roundtrip) artifacts
  decode-corpus [corpus_dir]    verify decode outputs survive codestream roundtrip
  full [external_corpus_dir]    run the full built-in + external roundtrip cycle
EOF
}

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

safe_artifact_name() {
  printf '%s' "$1" | sed 's#[/[:space:]]#_#g'
}

build_builtin_corpus() {
  local out_dir="$1"
  mkdir -p "$out_dir"
  cd "$ROOT_DIR"

  while IFS= read -r name; do
    [ -z "$name" ] && continue
    local out_hex="$out_dir/${name}.j2k.hex"
    local out_bin="$out_dir/${name}.j2k"

    moon run cmd/main -- sample-hex "$name" | tr -d '\n\r' >"$out_hex"
    xxd -r -p "$out_hex" >"$out_bin"

    echo "[$name] built: $out_bin"
  done < <(moon run cmd/main -- list-samples)

  echo "built-in sample corpus ready: $out_dir"
}

roundtrip_sample_named() {
  local sample_name="$1"
  local out_dir="$2"
  mkdir -p "$out_dir"

  local in_hex="$out_dir/${sample_name}.j2k.hex"
  local in_bin="$out_dir/${sample_name}.j2k"
  local out_hex="$out_dir/${sample_name}.roundtrip.hex"
  local out_bin="$out_dir/${sample_name}.roundtrip.j2k"

  cd "$ROOT_DIR"
  moon run cmd/main -- sample-hex "$sample_name" | tr -d '\n\r' >"$in_hex"
  xxd -r -p "$in_hex" >"$in_bin"

  local hex_from_file
  hex_from_file="$(xxd -p -c 1000000 "$in_bin" | tr -d '\n\r')"
  moon run cmd/main -- roundtrip-hex "$hex_from_file" | tr -d '\n\r' >"$out_hex"
  xxd -r -p "$out_hex" >"$out_bin"

  if ! cmp -s "$in_bin" "$out_bin"; then
    echo "[${sample_name}] roundtrip: FAILED" >&2
    exit 1
  fi
}

run_sample_command() {
  local sample_name="${1:-minimal}"
  roundtrip_sample_named "$sample_name" "$GENERATED_DIR"
  echo "roundtrip: OK"
  echo "input : $GENERATED_DIR/${sample_name}.j2k"
  echo "output: $GENERATED_DIR/${sample_name}.roundtrip.j2k"
}

run_samples_command() {
  cd "$ROOT_DIR"
  while IFS= read -r name; do
    [ -z "$name" ] && continue
    roundtrip_sample_named "$name" "$GENERATED_DIR"
    echo "[$name] roundtrip: OK"
  done < <(moon run cmd/main -- list-samples)
  echo "all samples: OK"
}

run_corpus_command() {
  local corpus_dir="${1:-$DEFAULT_CORPUS_DIR}"
  local out_dir="$ROOT_DIR/samples/generated/corpus"

  if [ ! -d "$corpus_dir" ]; then
    echo "corpus directory not found: $corpus_dir" >&2
    exit 1
  fi

  if [ "${WRITE_ROUNDTRIP_ARTIFACTS:-0}" = "1" ]; then
    mkdir -p "$out_dir"
  fi

  cd "$ROOT_DIR"

  local found=0
  while IFS= read -r in_bin; do
    found=1
    local rel
    rel="${in_bin#$corpus_dir/}"
    local safe_rel
    safe_rel="$(safe_artifact_name "$rel")"

    local out_hex
    out_hex="$(moon run cmd/main -- roundtrip-file "$in_bin" | tr -d '\r\n')"
    if echo "$out_hex" | rg -q '^error:'; then
      echo "[$rel] roundtrip: FAILED ($out_hex)" >&2
      exit 1
    fi

    local hex_from_file
    hex_from_file="$(xxd -p -c 1000000 "$in_bin" | tr -d '\n\r')"
    if [ "$out_hex" != "$hex_from_file" ]; then
      echo "[$rel] roundtrip: FAILED (mismatch)" >&2
      exit 1
    fi
    echo "[$rel] roundtrip: OK"

    if [ "${WRITE_ROUNDTRIP_ARTIFACTS:-0}" = "1" ]; then
      local out_hex_file="$out_dir/${safe_rel}.roundtrip.hex"
      local out_bin_file="$out_dir/${safe_rel}.roundtrip.j2k"
      printf '%s' "$out_hex" >"$out_hex_file"
      xxd -r -p "$out_hex_file" >"$out_bin_file"
    fi
  done < <(iter_external_corpus_files "$corpus_dir")

  if [ "$found" -eq 0 ]; then
    echo "no .j2k/.j2c files found in $corpus_dir" >&2
    exit 1
  fi

  echo "corpus all: OK"
}

run_decode_corpus_command() {
  local corpus_dir="${1:-$DEFAULT_CORPUS_DIR}"
  local failure_dir="${DEFAULT_DECODE_ROUNDTRIP_DIR}/failures"

  if [ ! -d "$corpus_dir" ]; then
    echo "corpus directory not found: $corpus_dir" >&2
    exit 1
  fi

  cd "$ROOT_DIR"

  local found=0
  while IFS= read -r in_bin; do
    found=1
    local rel
    rel="${in_bin#$corpus_dir/}"

    local out_verify
    out_verify="$(moon run cmd/main -- decode-roundtrip-file-verify "$in_bin" | tr -d '\r\n')"
    if [ "$out_verify" != "ok" ]; then
      local failure_out_dir="$failure_dir/$(safe_artifact_name "$rel")"
      echo "[$rel] decode-roundtrip: FAILED ($out_verify)" >&2
      if write_decode_roundtrip_artifacts "$in_bin" "$failure_out_dir"; then
        echo "[$rel] debug artifacts: $failure_out_dir" >&2
      else
        echo "[$rel] debug artifacts: failed to write" >&2
      fi
      exit 1
    fi
    echo "[$rel] decode-roundtrip: OK"
  done < <(iter_external_corpus_files "$corpus_dir")

  if [ "$found" -eq 0 ]; then
    echo "no .j2k/.j2c files found in $corpus_dir" >&2
    exit 1
  fi

  echo "decode-corpus all: OK"
}

write_decode_roundtrip_artifacts() {
  local in_bin="$1"
  local out_dir="$2"
  local base
  base="$(basename "$in_bin")"
  local stem="${base%.*}"
  local roundtrip_hex_file="$out_dir/${base}.roundtrip.hex"
  local roundtrip_bin="$out_dir/${base}.roundtrip.j2k"
  local original_dump_file="$out_dir/${stem}_original.dump.txt"
  local roundtrip_dump_file="$out_dir/${stem}_roundtrip.dump.txt"
  local original_image_file="$out_dir/${stem}_original.pgm"
  local roundtrip_image_file="$out_dir/${stem}_roundtrip.pgm"

  mkdir -p "$out_dir"

  local roundtrip_hex
  roundtrip_hex="$(moon run cmd/main -- roundtrip-file "$in_bin" | tr -d '\r\n')"
  if echo "$roundtrip_hex" | rg -q '^error:'; then
    echo "[$base] decode-fixture: FAILED ($roundtrip_hex)" >&2
    return 1
  fi
  printf '%s' "$roundtrip_hex" >"$roundtrip_hex_file"
  xxd -r -p "$roundtrip_hex_file" >"$roundtrip_bin"

  moon run cmd/main -- decode-file-dump "$in_bin" >"$original_dump_file"
  moon run cmd/main -- decode-file-dump "$roundtrip_bin" >"$roundtrip_dump_file"

  local original_image_tmp
  original_image_tmp="$(mktemp "/tmp/${stem}_original.XXXXXX.pgm")"
  local roundtrip_image_tmp
  roundtrip_image_tmp="$(mktemp "/tmp/${stem}_roundtrip.XXXXXX.pgm")"

  if bash "$ROOT_DIR/tools/decode_to_pgm.sh" "$in_bin" "$original_image_tmp" >/dev/null 2>&1; then
    mv "$original_image_tmp" "$original_image_file"
  else
    echo "[$base] note: original image dump skipped (unsupported by decode_to_pgm.sh)"
  fi
  if bash "$ROOT_DIR/tools/decode_to_pgm.sh" "$roundtrip_bin" "$roundtrip_image_tmp" >/dev/null 2>&1; then
    mv "$roundtrip_image_tmp" "$roundtrip_image_file"
  else
    echo "[$base] note: roundtrip image dump skipped (unsupported by decode_to_pgm.sh)"
  fi

  return 0
}

run_decode_fixture_command() {
  if [ "$#" -lt 1 ]; then
    usage >&2
    exit 1
  fi

  local in_bin="$1"
  local out_dir="${2:-$DEFAULT_DECODE_ROUNDTRIP_DIR}"

  if [ ! -f "$in_bin" ]; then
    echo "fixture not found: $in_bin" >&2
    exit 1
  fi

  cd "$ROOT_DIR"

  local out_verify
  out_verify="$(moon run cmd/main -- decode-roundtrip-file-verify "$in_bin" | tr -d '\r\n')"
  if [ "$out_verify" != "ok" ]; then
    echo "[$(basename "$in_bin")] decode-roundtrip: FAILED ($out_verify)" >&2
    exit 1
  fi

  if ! write_decode_roundtrip_artifacts "$in_bin" "$out_dir"; then
    exit 1
  fi

  echo "decode-fixture: OK"
  echo "output: $out_dir"
}

run_full_command() {
  local external_corpus_dir="${1:-$DEFAULT_CORPUS_DIR}"

  cd "$ROOT_DIR"

  "$ROOT_DIR/tools/roundtrip_cycle.sh" sample minimal
  "$ROOT_DIR/tools/roundtrip_cycle.sh" samples
  "$ROOT_DIR/tools/roundtrip_cycle.sh" build-builtins "$DEFAULT_BUILTIN_CORPUS_DIR"
  "$ROOT_DIR/tools/roundtrip_cycle.sh" corpus "$DEFAULT_BUILTIN_CORPUS_DIR"
  "$ROOT_DIR/tools/roundtrip_cycle.sh" decode-corpus "$DEFAULT_BUILTIN_CORPUS_DIR"

  local first_external
  first_external="$(iter_external_corpus_files "$external_corpus_dir" | sed -n '1p')"
  if [ -n "$first_external" ]; then
    "$ROOT_DIR/tools/probe_external_corpus_cycle.sh" "$external_corpus_dir"
    if [ "${STRICT_EXTERNAL_CORPUS:-0}" = "1" ]; then
      "$ROOT_DIR/tools/roundtrip_cycle.sh" corpus "$external_corpus_dir"
    fi
  else
    echo "skip external corpus: no .j2k/.j2c files in $external_corpus_dir"
  fi

  echo "full roundtrip cycle: OK"
}

if [ "$#" -eq 0 ]; then
  usage >&2
  exit 1
fi

command="$1"
shift

case "$command" in
  sample)
    run_sample_command "$@"
    ;;
  samples)
    run_samples_command "$@"
    ;;
  build-builtins)
    build_builtin_corpus "${1:-$DEFAULT_BUILTIN_CORPUS_DIR}"
    ;;
  corpus)
    run_corpus_command "$@"
    ;;
  decode-fixture)
    run_decode_fixture_command "$@"
    ;;
  decode-corpus)
    run_decode_corpus_command "$@"
    ;;
  full)
    run_full_command "$@"
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
