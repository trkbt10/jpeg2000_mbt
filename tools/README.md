# Tools

主な入口だけ先に使う前提で整理しています。参照実装比較は `tools/reference_compare.py` 1 本に集約しました。

## 参照実装比較

- `tools/reference_compare.py`
  - 引数なし、または subcommand 省略時は `collect` として動きます。
  - corpus 走査時は `*/htj2k/*` を default で除外し、`--include-htj2k` を付けると `.jph/.jhc` を含めて明示 opt-in します。
  - 例: `python3 tools/reference_compare.py --jobs 4`
  - 例: `python3 tools/reference_compare.py p1_03.j2k p1_05.j2k`
  - 例: `python3 tools/reference_compare.py --corpus-dir /tmp/openjpeg-data/input/conformance --out /tmp/openjpeg-data-conformance.tsv`
  - 例: `python3 tools/reference_compare.py --corpus-dir /tmp/openjpeg-data/input/nonregression/htj2k --include-htj2k --out /tmp/openjpeg-data-htj2k.tsv`
  - 例: `python3 tools/reference_compare.py --from-tsv /tmp/baseline.tsv --category fail_mismatch`
  - 例: `python3 tools/reference_compare.py fixture samples/corpus/p1_05.j2k`
  - 例: `python3 tools/reference_compare.py mismatch-report --compare-tsv /tmp/baseline.tsv`
  - 例: `python3 tools/reference_compare.py diff before.tsv after.tsv`
  - 例: `python3 tools/reference_compare.py priority`

## Decode / Roundtrip

- `tools/decode_samples_corpus_cycle.sh`
  - decode の corpus 集計を更新します。
- `tools/decode_to_pgm.sh`
  - 単一 fixture を MoonBit decoder で `pgm/ppm` に落とします。
- `tools/decode_to_roundtrip.sh`
  - 参照実装 expected と MoonBit actual の最新比較画像を `roundtrip/reference-compare-latest/` に並べます。
  - 中身は `python3 tools/reference_compare.py render ...` の wrapper です。
- `reference/decode_samples_reference_compare_latest.tsv`
  - 参照実装比較の authoritative な最新結果です。
- `tools/roundtrip_cycle.sh`
  - `sample` / `samples` / `build-builtins` / `corpus` / `decode-fixture` / `decode-corpus` / `full` をまとめた入口です。
  - `decode-fixture samples/corpus/p1_05.j2k` は debug 用で、`roundtrip/decode-roundtrip/` に original / roundtrip の dump と `pgm` を並べます。
  - `decode-corpus` は `decode(original)` と `decode(roundtrip(codestream))` の一致だけを見ます。失敗時だけ `roundtrip/decode-roundtrip/failures/` に debug artifact を落とします。

## Corpus / Validation

- `tools/corpus_matrix_cycle.sh`
  - default/strict/roundtrip の互換 matrix を更新します。
- `tools/corpus_strict_failure_report.sh`
  - strict failure の分類レポートを出します。
- `tools/external_corpus_cycle.sh`
  - openjpeg-data upstream corpus に対する matrix です。
- `tools/probe_external_corpus_cycle.sh`
  - external corpus の軽量 probe です。再帰走査します。
  - `INCLUDE_HTJ2K=0` が default で、`*/htj2k/*` と `.jph/.jhc` は除外します。

## Sources

- `reference/corpus-sources.md`
  - 追加で取るべき corpus と現時点の検証結果です。

## Misc

- `tools/check_public_api.sh`
  - `pkg.generated.mbti` の guardrail です。
- `tools/report_requirements_coverage.sh`
  - requirements checklist の集計です。
- `tools/export_wasm_npm_package.sh`
  - wasm package を export します。
- `tools/wasm_smoke.sh`
  - wasm smoke test です。

## Debug / Handoff

- 調査専用スクリプトは `reference/debug-tools/` に退避しています。
