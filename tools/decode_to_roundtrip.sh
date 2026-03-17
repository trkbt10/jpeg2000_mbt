#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT_DIR/roundtrip/reference-compare-latest"

cd "$ROOT_DIR"

python3 "$ROOT_DIR/tools/reference_compare.py" render --out-dir "$OUT_DIR" "$@"
