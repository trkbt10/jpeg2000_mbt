#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CORPUS_DIR="${1:-$ROOT_DIR/samples/corpus}"
OUT_CSV="${2:-$ROOT_DIR/samples/generated/corpus/compat-matrix.csv}"

if [ ! -d "$CORPUS_DIR" ]; then
  echo "corpus directory not found: $CORPUS_DIR" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT_CSV")"

cd "$ROOT_DIR"

echo "file,default,strict,roundtrip" > "$OUT_CSV"

found=0
ok_default=0
ok_strict=0
ok_roundtrip=0
strict_fail=0
for in_bin in "$CORPUS_DIR"/*.j2k "$CORPUS_DIR"/*.j2c; do
  [ -e "$in_bin" ] || continue
  found=1
  base="$(basename "$in_bin")"

  out_default="$(moon run cmd/main -- parse-file "$in_bin" | tr -d '\r\n')"
  out_strict="$(moon run cmd/main -- parse-file-strict "$in_bin" | tr -d '\r\n')"
  out_rt="$(moon run cmd/main -- roundtrip-file-verify "$in_bin" | tr -d '\r\n')"

  d="fail"
  s="fail"
  r="fail"

  if [ "$out_default" = "ok" ]; then
    d="ok"
    ok_default=$((ok_default + 1))
  fi
  if [ "$out_strict" = "ok" ]; then
    s="ok"
    ok_strict=$((ok_strict + 1))
  else
    strict_fail=$((strict_fail + 1))
  fi
  if [ "$out_rt" = "ok" ]; then
    r="ok"
    ok_roundtrip=$((ok_roundtrip + 1))
  fi

  echo "${base},${d},${s},${r}" >> "$OUT_CSV"
  printf '[%s] default=%s strict=%s roundtrip=%s\n' "$base" "$d" "$s" "$r"
done

if [ "$found" -eq 0 ]; then
  echo "no .j2k/.j2c files found in $CORPUS_DIR" >&2
  exit 1
fi

echo "matrix summary: default_ok=$ok_default strict_ok=$ok_strict roundtrip_ok=$ok_roundtrip strict_fail=$strict_fail csv=$OUT_CSV"
