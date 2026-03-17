#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CORPUS_DIR="$ROOT_DIR/samples/corpus"
OUT_TSV="$ROOT_DIR/reference/decode_samples_cycle_latest.tsv"
COUNT_LOG="$ROOT_DIR/reference/decode_samples_cycle_counts.tsv"
NOW_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

cd "$ROOT_DIR"

if [ ! -d "$CORPUS_DIR" ]; then
  echo "error: corpus directory not found: $CORPUS_DIR" >&2
  exit 1
fi

total=0
ok_real_decode=0
ok_zero_recon=0
unsupported_profile=0
hard_fail=0

tmp_tsv="$(mktemp)"
echo -e "fixture\tcategory\treason\trepro_command" >"$tmp_tsv"

while IFS= read -r file; do
  [ -z "$file" ] && continue
  total=$((total + 1))
  name="$(basename "$file")"
  cmd="moon run cmd/main -- decode-file $file"
  out="$(moon run cmd/main -- decode-file "$file" 2>/dev/null | tr -d '\r')"
  ok_line="$(printf '%s\n' "$out" | grep '^ok:' | head -1)"

  category=""
  reason=""
  if [[ -n "$ok_line" ]]; then
    layout="$(printf '%s' "$ok_line" | sed -nE 's/.* layout=([^ ]+) .*/\1/p')"
    if [[ "$layout" == *":real_decode:"* ]]; then
      category="ok_real_decode"
      reason="$layout"
      ok_real_decode=$((ok_real_decode + 1))
    elif [[ "$layout" == *":zero_recon:"* ]]; then
      category="ok_zero_recon"
      reason="$layout"
      ok_zero_recon=$((ok_zero_recon + 1))
    else
      category="hard_fail"
      reason="unclassified_ok_layout:$layout"
      hard_fail=$((hard_fail + 1))
    fi
  elif [[ "$out" == *"unsupported profile"* ]]; then
    category="unsupported_profile"
    reason="$(printf '%s\n' "$out" | tr '\t' ' ' )"
    unsupported_profile=$((unsupported_profile + 1))
  else
    category="hard_fail"
    reason="$(printf '%s\n' "$out" | tr '\t' ' ' )"
    hard_fail=$((hard_fail + 1))
  fi

  printf "%s\t%s\t%s\t%s\n" "$name" "$category" "$reason" "$cmd" >>"$tmp_tsv"
  echo "[$name] $category | $reason"
done < <(find "$CORPUS_DIR" -type f \( -name "*.j2k" -o -name "*.j2c" \) | sort)

mv "$tmp_tsv" "$OUT_TSV"

mkdir -p "$(dirname "$COUNT_LOG")"
if [ ! -f "$COUNT_LOG" ]; then
  echo -e "timestamp_utc\ttotal\tok_real_decode\tok_zero_recon\tunsupported_profile\thard_fail" >"$COUNT_LOG"
fi

prev_line="$(tail -n 1 "$COUNT_LOG" || true)"
prev_total=0
prev_ok_real=0
prev_ok_zero=0
prev_unsupported=0
prev_hard=0
if [[ -n "$prev_line" && "$prev_line" != timestamp_utc* ]]; then
  prev_total="$(printf '%s' "$prev_line" | awk -F '\t' '{print $2}')"
  prev_ok_real="$(printf '%s' "$prev_line" | awk -F '\t' '{print $3}')"
  prev_ok_zero="$(printf '%s' "$prev_line" | awk -F '\t' '{print $4}')"
  prev_unsupported="$(printf '%s' "$prev_line" | awk -F '\t' '{print $5}')"
  prev_hard="$(printf '%s' "$prev_line" | awk -F '\t' '{print $6}')"
fi

echo -e "$NOW_UTC\t$total\t$ok_real_decode\t$ok_zero_recon\t$unsupported_profile\t$hard_fail" >>"$COUNT_LOG"

echo
echo "decode_samples corpus summary:"
echo "  total                : $total"
echo "  ok_real_decode       : $ok_real_decode (delta $((ok_real_decode - prev_ok_real)))"
echo "  ok_zero_recon        : $ok_zero_recon (delta $((ok_zero_recon - prev_ok_zero)))"
echo "  unsupported_profile  : $unsupported_profile (delta $((unsupported_profile - prev_unsupported)))"
echo "  hard_fail            : $hard_fail (delta $((hard_fail - prev_hard)))"
echo "  details_tsv          : $OUT_TSV"
echo "  counts_log           : $COUNT_LOG"
