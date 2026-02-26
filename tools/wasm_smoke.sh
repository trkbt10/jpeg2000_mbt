#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WASM_BIN=""

cd "$ROOT_DIR"

moon build --target wasm >/dev/null

if [ -d "$ROOT_DIR/_build/wasm/debug/build/cmd/wasm" ]; then
  WASM_BIN="$(find "$ROOT_DIR/_build/wasm/debug/build/cmd/wasm" -maxdepth 1 -type f -name '*.wasm' | head -n 1)"
elif [ -d "$ROOT_DIR/_build/wasm-gc/debug/build/cmd/wasm" ]; then
  WASM_BIN="$(find "$ROOT_DIR/_build/wasm-gc/debug/build/cmd/wasm" -maxdepth 1 -type f -name '*.wasm' | head -n 1)"
fi

if [ "$WASM_BIN" = "" ]; then
  echo "wasm binary not found under _build/wasm*/debug/build/cmd/wasm/*.wasm" >&2
  exit 1
fi

# Smoke 1: can list built-in sample names.
out_list="$(moonrun "$WASM_BIN" -- list-samples | tr -d '\r')"
if ! printf '%s\n' "$out_list" | rg -q '^minimal$'; then
  echo "wasm smoke failed: minimal sample not listed" >&2
  exit 1
fi

# Smoke 2: parse built-in minimal sample.
out_parse="$(moonrun "$WASM_BIN" -- parse-sample minimal | tr -d '\r\n')"
if [ "$out_parse" != "ok" ]; then
  echo "wasm smoke failed: parse-sample minimal => $out_parse" >&2
  exit 1
fi

# Smoke 3: hex roundtrip path works.
hex_in="$(moonrun "$WASM_BIN" -- sample-hex minimal | tr -d '\r\n')"
if [ "$hex_in" = "" ] || printf '%s' "$hex_in" | rg -q '^error:'; then
  echo "wasm smoke failed: sample-hex minimal => $hex_in" >&2
  exit 1
fi
out_rt="$(moonrun "$WASM_BIN" -- roundtrip-hex "$hex_in" | tr -d '\r\n')"
if [ "$out_rt" = "" ] || printf '%s' "$out_rt" | rg -q '^error:'; then
  echo "wasm smoke failed: roundtrip-hex => $out_rt" >&2
  exit 1
fi

echo "wasm smoke: ok"
