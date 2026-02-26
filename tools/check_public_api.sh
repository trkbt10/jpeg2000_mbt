#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MBTI="$ROOT_DIR/pkg.generated.mbti"

cd "$ROOT_DIR"

moon info >/dev/null

if [ ! -f "$MBTI" ]; then
  echo "pkg.generated.mbti not found" >&2
  exit 1
fi

pub_fns="$(rg '^pub fn ' "$MBTI" | sed -E 's/^pub fn ([^(]+).*/\1/' | sort)"
pub_fn_defs="$(rg -n '^pub fn ' "$ROOT_DIR"/*.mbt || true)"

required_core=(
  parse_codestream
  parse_codestream_strict
  encode_codestream
  roundtrip_bytes
  bytes_to_hex
  hex_to_bytes
)

required_missing=0
for fn in "${required_core[@]}"; do
  if ! printf '%s\n' "$pub_fns" | rg -q "^${fn}$"; then
    echo "missing required public API: $fn" >&2
    required_missing=1
  fi
done

if [ "$required_missing" -ne 0 ]; then
  exit 1
fi

# Guardrail: CLI/file I/O APIs must not leak from library package.
disallowed_patterns=(
  '^parse_file'
  '^roundtrip_file'
  '^main$'
)

for pat in "${disallowed_patterns[@]}"; do
  if printf '%s\n' "$pub_fns" | rg -q "$pat"; then
    echo "unexpected public API matched pattern: $pat" >&2
    exit 1
  fi
done

# Public function entrypoint discipline: keep pub fn definitions in one file.
if [ "$pub_fn_defs" != "" ]; then
  non_entry="$(printf '%s\n' "$pub_fn_defs" | rg -v '^.*/jpeg2000\.mbt:' || true)"
  if [ "$non_entry" != "" ]; then
    echo "public function definitions must stay in jpeg2000.mbt" >&2
    echo "$non_entry" >&2
    exit 1
  fi
fi

echo "public api check: ok"
echo "core APIs present: ${required_core[*]}"
echo "exported function count: $(printf '%s\n' "$pub_fns" | sed '/^$/d' | wc -l | tr -d ' ')"
