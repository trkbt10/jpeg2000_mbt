#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CORPUS_DIR="${1:-$ROOT_DIR/samples/corpus}"
OUT_CSV="${2:-$ROOT_DIR/samples/generated/corpus/strict-failure-report.csv}"
OUT_MD="${3:-$ROOT_DIR/samples/generated/corpus/strict-failure-report.md}"

if [ ! -d "$CORPUS_DIR" ]; then
  echo "corpus directory not found: $CORPUS_DIR" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT_CSV")"

classify_reason() {
  local msg="$1"
  if echo "$msg" | rg -q "failed to parse packet headers in PPM"; then
    echo "PPM packet-header metadata decode limitation"
    return
  fi
  if echo "$msg" | rg -q "failed to parse packet headers in PPT"; then
    echo "PPT packet-header metadata decode limitation"
    return
  fi
  if echo "$msg" | rg -q "invalid marker placement"; then
    echo "marker placement violation (strict)"
    return
  fi
  echo "other"
}

spec_hint() {
  local msg="$1"
  if echo "$msg" | rg -q "packet headers in PPM|packet headers in PPT"; then
    echo "Annex B.10/A.7.4/A.7.5"
    return
  fi
  if echo "$msg" | rg -q "invalid marker placement"; then
    echo "Annex A.1.3"
    return
  fi
  echo "TBD"
}

cd "$ROOT_DIR"

echo "file,error,reason,spec_hint" > "$OUT_CSV"

found=0
fail_count=0
for in_bin in "$CORPUS_DIR"/*.j2k "$CORPUS_DIR"/*.j2c; do
  [ -e "$in_bin" ] || continue
  found=1
  base="$(basename "$in_bin")"
  out="$(moon run cmd/main -- parse-file-strict "$in_bin" | tr -d '\r\n')"
  if [ "$out" = "ok" ]; then
    continue
  fi
  fail_count=$((fail_count + 1))
  msg="${out#error: }"
  reason="$(classify_reason "$msg")"
  hint="$(spec_hint "$msg")"
  esc_msg="$(printf '%s' "$msg" | sed 's/"/""/g')"
  esc_reason="$(printf '%s' "$reason" | sed 's/"/""/g')"
  echo "$base,\"$esc_msg\",\"$esc_reason\",$hint" >> "$OUT_CSV"
done

if [ "$found" -eq 0 ]; then
  echo "no .j2k/.j2c files found in $CORPUS_DIR" >&2
  exit 1
fi

{
  echo "# Strict Failure Report"
  echo
  echo "- corpus: \`$CORPUS_DIR\`"
  echo "- strict failures: $fail_count"
  echo "- generated: $(date '+%Y-%m-%d %H:%M:%S')"
  echo
  echo "| file | error | reason | spec hint |"
  echo "|---|---|---|---|"
  tail -n +2 "$OUT_CSV" | while IFS=',' read -r file error reason hint; do
    error="${error#\"}"; error="${error%\"}"
    reason="${reason#\"}"; reason="${reason%\"}"
    echo "| $file | $error | $reason | $hint |"
  done
} > "$OUT_MD"

echo "strict-failure report: fail_count=$fail_count csv=$OUT_CSV md=$OUT_MD"
