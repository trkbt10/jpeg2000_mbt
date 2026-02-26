# JPEG2000 実装順序表（P7）

## 1. 方針

- 依存が強い順に実装する
- Decoder適合を先に確立し、Encoderは対称実装で追従する
- 各ステップは要求ID群と1対1対応させる

## 2. 実装順序

| Step | 実装対象 | 主要要求ID | 依存 | 完了条件 |
|---|---|---|---|---|
| S1 | Codestream骨格（Annex A） | R-0021..R-0055 | なし | SOC/SOT/SOD/EOC + 主要markerを解析可能 |
| S2 | Data ordering（Annex B） | R-0056..R-0078 | S1 | packet/layer/progressionを処理可能 |
| S3 | Arithmetic decode（Annex C） | R-0087, R-0092..R-0099 | S1,S2 | MQ復号経路が通る |
| S4 | Bit modelling（Annex D） | R-0100..R-0116 | S3 | pass処理+context処理が通る |
| S5 | Quantization（Annex E） | R-0118..R-0120 | S4 | 可逆/非可逆の逆量子化一致 |
| S6 | IDWT（Annex F） | R-0122..R-0135 | S5 | 5-3/9-7復元経路が通る |
| S7 | MCT/Level shift（Annex G） | R-0145,R-0147,R-0148,R-0150,R-0151,R-0153,R-0154 | S6 | 成分変換・逆変換が通る |
| S8 | ROI（Annex H） | R-0155,R-0156 | S4,S5 | Maxshift系ROI復号が通る |
| S9 | JP2 container（Annex I） | R-0165..R-0185,R-0191 | S1,S2 | JP2読込/書込とunknown box処理が通る |
| S10 | Broadcast profile（Annex M） | R-0192..R-0201 | S9 | Access unit関連boxを処理可能 |
| S11 | Encoder対称化 | R-0014,R-0015 + F/G/H/I/Mのencoder関連 | S1..S10 | round-trip成立 |
| S12 | 参照最終確認 | R-0202..R-0221 | S1..S11 | J/K/L反映漏れなし |

## 3. 実装時の優先度

1. Must
2. Should
3. Optional（Reference含む）

## 4. 凍結ルール

- Step完了後に要求IDの `Status` を更新
- 次Stepへ進む前に受入基準表の該当行を満たす
