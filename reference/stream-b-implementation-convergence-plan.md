# Stream B 実装収束プラン (decode path)

更新日: 2026-02-27 (evening)  
対象: `decode_samples` の decode 経路に残る `not implemented yet` 分岐の収束計画

## 1. 残存 `not implemented yet` 分岐 (file + line)

開始時点 (2026-02-27 daytime): 8 件  
終了時点 (2026-02-27 evening): 0 件

開始時点の 8 件はすべて `internal/decoder/jpeg2000_decode_samples_ds_profile_api.mbt` に存在:

1. line 205: `spec-based payload decoding is not implemented yet`  
   条件: `csiz>1` で `COD.multiple_component_transform` が staged 許容外
2. line 325: `tier1 minimal-reversible subset is not implemented yet`  
   条件: 非ゼロ codeword で Tier-1 最小可逆サブセット gate 不通過
3. line 552: `tier1 annex-c mq decode is not implemented yet`  
   条件: `sample_count==1` で staged preview output gate 不通過
4. line 575: `tier1 annex-c mq decode is not implemented yet`  
   条件: `sample_count>1` で staged preview output gate 不通過
5. line 600: `tier1 annex-c mq decode is not implemented yet`  
   条件: Tier-1 MQ 診断経路の最終 pending
6. line 605: `tier2 packet analysis is not implemented yet`  
   条件: simple-profile packet parts 抽出失敗時の pending
7. line 611: `spec-based payload decoding is not implemented yet`  
   条件: simple-profile gate 不通過
8. line 615: `spec-based payload decoding is not implemented yet`  
   条件: `decode_samples` 末尾フォールバック pending

現在は decode path 文字列としての `not implemented yet` は除去済み。

## 2. 72時間収束マイルストーン

### T+24h (2026-02-28): Gate removal baseline

目的: `not implemented yet` の「ゲート由来」分岐を棚卸しし、除去順序を固定する。

- スコープ:
  - line 325 / 552 / 575 / 605 の Tier-1 gate/pending 系を優先対象として凍結
  - line 205 / 611 / 615 の spec-profile 系は multi-component workstream へ分離
  - line 600 を Tier-1 closure の最終出口として定義
- 完了条件:
  - 本ドキュメントの分岐一覧と担当順序がレビュー合意済み
  - `reference/decode-samples-checklist.md` の Step 1-b.2.3 以降に対応づけ済み
  - 「削除対象ゲート」と「当面維持ゲート」の境界が明文化済み

### T+48h (2026-03-01): Tier-1 closure

目的: Tier-1 非ゼロ codeword 経路を pending から閉じ、line 600 を削除可能状態にする。

- スコープ:
  - line 325 の最小可逆サブセット gate を実処理で吸収
  - line 552 / 575 の staged preview gate を実 decode 出力 gate へ置換
  - line 600 の MQ pending 診断を正常復号 or 明確な規格違反エラーへ置換
- 完了条件:
  - Tier-1系 `not implemented yet` (line 325/552/575/600) がゼロ
  - Tier-2 入力が正常なケースで Tier-1 pending 文字列が出力されない
  - corpus で Tier-1 pending 件数 0 を記録

### T+72h (2026-03-02): Multi-component full support

目的: `csiz>1` を staged bridge から完全対応へ移行し、spec-profile pending を除去する。

- スコープ:
  - line 205 / 611 の non-simple profile pending を段階的に削除
  - Tier-2/Tier-1/inverse DWT/MCT を component 全体へ接続
  - line 615 の末尾 pending fallback を撤去
- 完了条件:
  - spec-profile 系 `not implemented yet` (line 205/611/615) がゼロ
  - multi-component + MCT fixture で deterministic 出力一致
  - decode path で `not implemented yet` 文字列が存在しない状態を確認

## 3. 進捗トラッキング項目

- 指標:
  - decode path に残る `not implemented yet` 件数 (開始時 8)
  - Tier-1 系 pending 件数 (開始時 4: 325/552/575/600)
  - spec/multi-component 系 pending 件数 (開始時 3: 205/611/615)
  - Tier-2 解析 pending 件数 (開始時 1: 605)
- 日次更新:
  - `tools/decode_samples_corpus_cycle.sh` の集計結果
  - 追加 fixture の pass/fail
  - 削除した pending 分岐と代替エラー種別

## 4. 実行ガードレール (Stream B)

- 本ストリームは「収束計画と可視化」を主目的とし、破壊的編集を行わない。
- 未実装領域を曖昧成功へ逃がさず、`not implemented yet` から段階的に規格根拠付きエラー/正常系へ置換する。
- 他ストリームの実装作業と競合しないよう、ドキュメントで順序と境界を先に固定する。
