#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
EXTERNAL_CORPUS_DIR="${1:-$ROOT_DIR/samples/corpus}"
BUILTIN_CORPUS_DIR="$ROOT_DIR/samples/generated/builtins"

# Spec basis (T.800 Annex A):
# - /sections/annex-a-codestream-syntax.md:82-83
#   "All markers with the marker code between 0xFF30 and 0xFF3F have no marker segment parameters. They shall be skipped by the decoder."
# Operational implication:
# - default cycle always runs interoperable external probe first.
# - byte-identical strict cycle for external corpus is optional via STRICT_EXTERNAL_CORPUS=1,
#   because many conformance/probe files are valid for decode but not guaranteed to re-emit identical bytes.

cd "$ROOT_DIR"

./tools/roundtrip_sample_cycle.sh
./tools/roundtrip_samples_cycle.sh
./tools/build_sample_corpus.sh "$BUILTIN_CORPUS_DIR"
./tools/roundtrip_corpus_cycle.sh "$BUILTIN_CORPUS_DIR"

if ls "$EXTERNAL_CORPUS_DIR"/*.j2k "$EXTERNAL_CORPUS_DIR"/*.j2c >/dev/null 2>&1; then
  ./tools/probe_external_corpus_cycle.sh "$EXTERNAL_CORPUS_DIR"
  if [ "${STRICT_EXTERNAL_CORPUS:-0}" = "1" ]; then
    ./tools/roundtrip_corpus_cycle.sh "$EXTERNAL_CORPUS_DIR"
  fi
else
  echo "skip external corpus: no .j2k/.j2c files in $EXTERNAL_CORPUS_DIR"
fi

echo "full roundtrip cycle: OK"
