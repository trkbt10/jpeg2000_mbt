#!/usr/bin/env bash
set -euo pipefail

# Validate codestream compatibility using test assets from the upstream OpenJPEG repository.
# Expected source repo: https://github.com/uclouvain/openjpeg

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OPENJPEG_REPO_DIR="${1:-${OPENJPEG_REPO_DIR:-}}"
OUT_CSV="${2:-$ROOT_DIR/samples/generated/corpus/openjpeg-repo-matrix.csv}"
MAX_FILES="${MAX_FILES:-0}" # 0 means no cap
STRICT_ENFORCE_EXPECTED="${STRICT_ENFORCE_EXPECTED:-0}"
STRICT_EXPECTED_FILE="${STRICT_EXPECTED_FILE:-$ROOT_DIR/samples/corpus/strict-expected-failures.txt}"

if [ -z "$OPENJPEG_REPO_DIR" ]; then
  echo "usage: $0 <openjpeg_repo_dir> [out_csv]" >&2
  exit 1
fi

if [ ! -d "$OPENJPEG_REPO_DIR" ]; then
  echo "openjpeg repo directory not found: $OPENJPEG_REPO_DIR" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT_CSV")"
cd "$ROOT_DIR"

echo "file,default,strict,roundtrip" > "$OUT_CSV"

found=0
count=0
ok_default=0
ok_strict=0
ok_roundtrip=0
strict_fail=0
strict_fail_files=()

while IFS= read -r in_bin; do
  [ -e "$in_bin" ] || continue
  found=1
  count=$((count + 1))
  if [ "$MAX_FILES" -gt 0 ] && [ "$count" -gt "$MAX_FILES" ]; then
    break
  fi

  rel="${in_bin#$OPENJPEG_REPO_DIR/}"

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
    strict_fail_files+=("$(basename "$in_bin")")
  fi
  if [ "$out_rt" = "ok" ]; then
    r="ok"
    ok_roundtrip=$((ok_roundtrip + 1))
  fi

  echo "${rel},${d},${s},${r}" >> "$OUT_CSV"
  printf '[%s] default=%s strict=%s roundtrip=%s\n' "$rel" "$d" "$s" "$r"
done < <(find "$OPENJPEG_REPO_DIR" -type f \( -name '*.j2k' -o -name '*.j2c' \) | LC_ALL=C sort)

if [ "$found" -eq 0 ]; then
  echo "no .j2k/.j2c files found under $OPENJPEG_REPO_DIR" >&2
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

echo "openjpeg repo matrix summary: files=$count default_ok=$ok_default strict_ok=$ok_strict roundtrip_ok=$ok_roundtrip strict_fail=$strict_fail unexpected_strict_fail=$unexpected recovered_strict=$recovered csv=$OUT_CSV"

if [ "$STRICT_ENFORCE_EXPECTED" = "1" ] && [ "$unexpected" -gt 0 ]; then
  echo "error: unexpected strict failures detected" >&2
  exit 1
fi
