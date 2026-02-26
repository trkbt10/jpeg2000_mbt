#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CORPUS_DIR="${1:-$ROOT_DIR/samples/corpus}"
OUT_CSV="${2:-$ROOT_DIR/samples/generated/corpus/compat-matrix.csv}"
STRICT_EXPECTED_FILE="${STRICT_EXPECTED_FILE:-$CORPUS_DIR/strict-expected-failures.txt}"
STRICT_ENFORCE_EXPECTED="${STRICT_ENFORCE_EXPECTED:-1}"

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
strict_fail_files=()
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
    strict_fail_files+=("$base")
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

unexpected=0
recovered=0
if [ -f "$STRICT_EXPECTED_FILE" ]; then
  for f in "${strict_fail_files[@]}"; do
    if ! rg -q "^[[:space:]]*${f//./\\.}[[:space:]]*$" "$STRICT_EXPECTED_FILE"; then
      unexpected=$((unexpected + 1))
    fi
  done

  while IFS= read -r expected; do
    expected="$(echo "$expected" | sed 's/[[:space:]]*$//')"
    [ -n "$expected" ] || continue
    if [[ "$expected" =~ ^# ]]; then
      continue
    fi
    matched=0
    for f in "${strict_fail_files[@]}"; do
      if [ "$f" = "$expected" ]; then
        matched=1
        break
      fi
    done
    if [ "$matched" -eq 0 ]; then
      recovered=$((recovered + 1))
    fi
  done < "$STRICT_EXPECTED_FILE"
fi

echo "matrix summary: default_ok=$ok_default strict_ok=$ok_strict roundtrip_ok=$ok_roundtrip strict_fail=$strict_fail unexpected_strict_fail=$unexpected recovered_strict=$recovered csv=$OUT_CSV"

if [ "$STRICT_ENFORCE_EXPECTED" = "1" ] && [ "$unexpected" -gt 0 ]; then
  echo "error: unexpected strict failures detected" >&2
  exit 1
fi
