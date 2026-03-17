# Project Policy (established 2026-02-28)

## Scope
JPEG2000 汎用デコーダとして開発する。GRIB2 等の特定上位用途の前提を持ち込まない。

## 優先順位・評価軸

## 必須ルール

### 1. 網羅マトリクス (JPEG2000 軸)
- 管理ファイル: `reference/jpeg2000_coverage_matrix.md`
- 軸: DWT(なし/5-3/9-7), bits(4/8/12/16), signed, tile数, code-block数,
  component数, progression order, SOP/EPH, ROI, quantization style, layers, MCT
- Status 列で pass/fail/skip を追跡

### 2. 変更ごとに仕様トレース
- T.800 節番号 / 実装箇所 / 対象fixture / before-after 結果を記録

### 3. 品質ゲート
- hard_fail=0 維持
- pass_real_match を継続増加
- matrix・TSV・差分ログの同期を必須化

### 4. 禁止事項
- 特定上位用途向けの近道実装
- 評価指標を都合よく変更すること
