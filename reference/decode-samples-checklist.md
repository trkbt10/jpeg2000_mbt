# decode_samples 要求仕様チェックリスト

## A. 受け入れ条件 (必須)

- [x] 公開 decode API が存在する (`decode_samples`)
- [x] raw codestream (`.j2k/.j2c`) を受理
- [x] JP2-wrapped (`jp2c`) を受理
- [x] 出力契約を公開文書化 (bytes, bits/sample, signed, num_points)
- [ ] Tier-2 を一般ケースで処理 (in-band/PPT/PPM)
- [ ] Tier-1 を一般ケースで処理 (非ゼロ codeword)
- [ ] inverse DWT (5/3, 9/7)
- [ ] MCT (reversible/irreversible)
- [ ] multi-component (`csiz>1`) 実デコード
- [ ] deterministic sample-domain output を fixture 比較で保証

## B. 品質ゲート

- [x] strict/compat 方針を分離
- [x] 未実装領域は明示エラーで停止
- [x] `DS-*` 根拠IDを `reference/decode_samples-spec-basis.md` と対応
- [x] Tier-1 Step1 の事前ゲートを明示 (`transformation/qstyle` staged subset と `code-block-style subset of {TERMALL,RESET,SEGMARK}` 以外は停止)
- [ ] 非対応エラーを段階的に削減 (pending の縮小)
  - 現在値 (2026-02-27): `total=27, ok_real_decode=21, ok_zero_recon=6, unsupported_profile=0, hard_fail=0`
- [ ] README に最終的な layout/order を明記

## C. テスト要件

- [x] blackbox: decode_samples 基本ケース
- [x] whitebox: packet extraction / SOP/EPH / relocated header
- [x] corpus: parse + decode determinism
- [ ] multi-component + MCT ケース fixture
- [ ] DWT 5/3 と 9/7 の差分検証 fixture

## D. 実装ステップ (実行順)

- [ ] Step 1: Tier-1 minimal reversible (single-comp, no-precinct, decomp=0)
  - [x] Step 1-a: 対象境界の明示ゲート (reversible/no-quant)
  - [ ] Step 1-b: Tier-1 実デコード本体 (MQ + passes)
  - [x] Step 1-b.1: Annex C bootstrap (A/C初期値シード) を実装
  - [x] Step 1-b.1.1: Annex C context state reset/save/restore
  - [x] Step 1-b.1.2: one-decision probe (暫定) を配線
  - [ ] Step 1-b.2: MQ decision decode + pass処理実装
  - [x] Step 1-b.2.1: `BYTEIN/RENORMD` を1-decision経路へ配線
  - [x] Step 1-b.2.2: Annex C状態遷移/Qe table (Table C.2) を1-decision経路へ適用
  - [ ] Step 1-b.2.3: multi-decision loop と pass統合
  - [x] Step 1-b.2.3-a: multi-decision trace ループを実装
  - [x] Step 1-b.2.3-b1: staged pass-order trace を実装
  - [x] Step 1-b.2.3-b2: staged pass-state accumulator を実装
  - [x] Step 1-b.2.3-b3: staged pass primitives（cleanup/sigprop/magref）を実装
  - [x] Step 1-b.2.3-b4: single-coeff normative preview（sigprop条件）を実装
  - [x] Step 1-b.2.3-b4.1: normative pass-state を主診断値へ昇格（legacy併記）
  - [x] Step 1-b.2.3-b4.2: single-coeff reconstructed value preview を追加
  - [x] Step 1-b.2.3-b4.3: `sample_count==1` での end-to-end `Ok(...)` を追加
  - [x] Step 1-b.2.3-b4.4: `sample_count<=16` の small-row `Ok(...)` を追加
  - [x] Step 1-b.2.3-b5: pass本体統合（規範ロジック）
- [ ] Step 2: inverse DWT 5/3
- [ ] Step 3: quant/dequant 配線
- [ ] Step 4: reversible MCT
- [ ] Step 5: 9/7 + irreversible MCT
- [ ] Step 6: `csiz>1` を reject から decode へ置換
- [ ] Step 7: 最終API契約とREADME更新

## E. 完了定義 (DoD)

- [ ] A の未完了項目がすべて完了
- [ ] `moon test` 全通
- [ ] `moon info && moon fmt` 実行済み
- [ ] 仕様根拠と実装分岐の対応が崩れていない
