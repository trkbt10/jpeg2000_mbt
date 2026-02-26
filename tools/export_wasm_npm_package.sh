#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT_DIR/npm/wasm/dist"
WASM_BIN=""

cd "$ROOT_DIR"

moon build --target wasm >/dev/null

if [ -f "$ROOT_DIR/_build/wasm/debug/build/cmd/wasm/wasm.wasm" ]; then
  WASM_BIN="$ROOT_DIR/_build/wasm/debug/build/cmd/wasm/wasm.wasm"
elif [ -f "$ROOT_DIR/_build/wasm-gc/debug/build/cmd/wasm/wasm.wasm" ]; then
  WASM_BIN="$ROOT_DIR/_build/wasm-gc/debug/build/cmd/wasm/wasm.wasm"
else
  echo "wasm binary not found under _build/wasm*/debug/build/cmd/wasm/wasm.wasm" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
cp "$WASM_BIN" "$OUT_DIR/jpeg2000.wasm"

SHA256=""
if command -v shasum >/dev/null 2>&1; then
  SHA256="$(shasum -a 256 "$OUT_DIR/jpeg2000.wasm" | awk '{print $1}')"
fi

GIT_REV="unknown"
if command -v git >/dev/null 2>&1; then
  if git rev-parse --short HEAD >/dev/null 2>&1; then
    GIT_REV="$(git rev-parse --short HEAD)"
  fi
fi

cat > "$OUT_DIR/manifest.json" <<EOF
{
  "name": "@trkbt10/jpeg2000-wasm",
  "source": "cmd/wasm",
  "gitRevision": "$GIT_REV",
  "sha256": "$SHA256"
}
EOF

echo "npm wasm export: ok"
echo "source: $WASM_BIN"
echo "output: $OUT_DIR/jpeg2000.wasm"
