# JPEG2000 自律実装エージェント向け エントリーポイント指示書

## 0. ミッション

`T.800-2015` 準拠の JPEG2000 ライブラリ（Encoder + Decoder + JP2 + Annex M）を、既存の管理資料に従って最後まで実装・検証し、完了状態まで到達すること。

## 1. 最初に読むファイル（順序厳守）

1. ``
2. `spec/management/work-procedure.md`
3. `spec/management/project-schedule.md`
4. `spec/management/requirements-checklist.md`
5. `spec/management/implementation-order.md`
6. `spec/management/acceptance-matrix.md`

## 2. 実行原則

- 要求ID駆動で実装する（実装単位は要求ID群）
- `Must` を先に完了し、`Should`、`Optional` を後続に回す
- 1ステップ完了ごとに `requirements-checklist.md` の `Status/TestLink/Notes` を更新する
- 受入基準を満たさない限り `Verified` にしてはいけない
- 仕様解釈で迷った場合は、`/sections/*.md` の該当節を唯一の一次根拠にする

## 3. 作業順序（固定）

`spec/management/implementation-order.md` の `S1 -> S12` をそのまま順番に実施する。

- S1: Annex A
- S2: Annex B
- S3: Annex C
- S4: Annex D
- S5: Annex E
- S6: Annex F
- S7: Annex G
- S8: Annex H
- S9: Annex I
- S10: Annex M
- S11: Encoder対称化（round-trip成立）
- S12: Annex J/K/L 反映漏れ確認

前ステップが `Verified` になるまで次へ進まないこと。

## 4. 各ステップの必須アウトプット

各ステップ終了時に必ず以下を実施する。

1. 対象要求IDの `Status` を `Implemented` 以上へ更新
2. `TestLink` に実行済みテスト（または試験ID）を記録
3. `acceptance-matrix.md` の該当グループ受入基準を満たした証跡を `Notes` に記録
4. 失敗ケースを1件以上追加（再発防止）
5. ステップ単位で変更要約を残す

## 5. 完了判定（Definition of Done）

以下をすべて満たしたときのみ完了。

1. `requirements-checklist.md` の `Must` が全件 `Verified`
2. `Should` は `Verified` または妥当理由つき `N-A`
3. `Optional/Reference` は反映メモがあり、未処理は理由つき
4. `decode(encode(image))` round-trip が対象プロファイルで成立
5. `project-schedule.md` の P0〜P9 が `Done`
6. 既知の blocker が 0 件

## 6. 例外時ルール

- 仕様矛盾/解釈不能箇所を検出したら、実装を止めずに次を実施:
  1. `requirements-checklist.md` の該当ID `Notes` に矛盾内容を記録
  2. 暫定解釈を明記
  3. 影響範囲（要求ID）を列挙
  4. 暫定解釈で作業継続

- 重大破壊（互換性破壊）を伴う場合:
  - 変更前後差分を記録し、互換戦略を `Notes` に明示する

## 7. 報告フォーマット（各実行サイクル）

各サイクルで次を短く報告する。

1. 完了したステップ/要求ID範囲
2. 実施した試験と結果
3. 新規リスクまたは blocker
4. 次サイクルの着手範囲

## 8. 最終提出物

- 実装コード一式
- 更新済み `requirements-checklist.md`
- 更新済み `project-schedule.md`
- 受入基準に対する証跡一覧
- 既知制約と未対応事項リスト

## 9. 開始コマンド前チェック

開始前に次を確認する。

1. `` の参照リンクが有効
2. 対象要求ID範囲が確定
3. ステップ依存が未破壊

この3点を満たしたら `S1` から開始すること。
