# JPEG2000 受入基準表（P8）

## 1. 判定ルール

- `Implemented`: 実装済み、未検証
- `Verified`: 受入基準を満たし、回帰確認済み

## 2. 受入基準マトリクス

| Group | 対象要求ID | 受入基準 | 証跡 |
|---|---|---|---|
| Core syntax | R-0021..R-0055 | marker構文検証が通る | parserテスト |
| Ordering | R-0056..R-0078 | packet/progression順序整合 | orderingテスト |
| Arithmetic | R-0087,R-0092..R-0099 | MQ復号一致 | decodingテスト |
| Bit modelling | R-0100..R-0116 | coding passes再構成一致 | code-blockテスト |
| Quantization | R-0118..R-0120 | reversible/irreversible両経路一致 | quantizationテスト |
| DWT | R-0122..R-0135 | 逆変換結果が期待値一致 | transformテスト |
| MCT/Shift | R-0145..R-0154 (Must対象) | 成分変換復元一致 | componentテスト |
| ROI | R-0155..R-0156 | ROI復号の優先復元成立 | roiテスト |
| JP2 | R-0165..R-0185,R-0191 | box構文と不明boxスキップ整合 | jp2テスト |
| Broadcast | R-0192..R-0201 | required box群検証通過 | annex-mテスト |
| Reference | R-0202..R-0221 | 参照反映メモが存在 | design notes |

## 3. 失敗時の扱い

- 受入基準未達は `Status=InProgress` に戻す
- 失敗原因と再発防止試験を `Notes/TestLink` に追記
