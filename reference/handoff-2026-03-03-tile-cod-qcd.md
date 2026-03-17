# 作業引き継ぎ: タイル固有COD/QCD対応 (2026-03-03)

## 実施内容

**タイル固有COD/QCD対応 (T.800-2015 A.4.2)**

マルチタイルデコード破損の原因調査として、タイル固有COD/QCDマーカーの未使用問題を解決した。

### 変更ファイル

| ファイル | 変更内容 |
|---------|---------|
| `internal/core/model.mbt` | `TileCodMetadata`, `TileQcdMetadata` 構造体追加、`CodestreamMetadata` に `tile_cod`, `tile_qcd` 配列追加 |
| `internal/core/codestream_codec.mbt` | タイルヘッダ内COD/QCDの解析・保存処理追加、`current_tile_index` 追跡変数追加 |
| `internal/decoder/decode_api.mbt` | `get_tile_cod()`, `get_tile_qcd()` ヘルパー追加、`decode_dwt_image_from_sequential_packets` に `tile_cod~`, `tile_qcd~` オプション引数追加 |
| `reference/visual-verification-2026-03-03.md` | 調査結果の追記 |

### 検証結果

- **321件の単体テスト**: 全てパス
- **重要発見**: テストフィクスチャにはタイル固有COD/QCDマーカーが**存在しない**

## 残課題: マルチタイルデコード破損


### 排除済みの原因
- ~~タイル固有COD/QCDの無視~~ → フィクスチャにマーカーなし

### 残る疑わしい原因 (優先度順)

1. **PCRL進行順序のパケット順序** (中〜高確率)
   - `annex_b10_layer.mbt` の PCRL 実装 (lines 951-986)
   - 複数解像度でプリシンクトグリッドが異なる場合のパケット列挙順
   - p0_03: PCRL, 8 layers, 1 decomp

2. **多層累積処理** (中確率)
   - `split_sod_accumulate_multi_layer` の8層処理
   - 係数の累積・マージロジック

3. **プリシンクト内CBインデックス計算** (低〜中確率)
   - 絶対座標とプリシンクト相対座標の変換

### 次のステップ提案

1. p0_03 の各タイルを個別にデコードし、単一タイルデコードと結果比較
2. `split_sod_accumulate_multi_layer` にデバッグ出力追加、パケットごとの情報記録

---

## 比較検証手法


```bash
# MoonBit デコード
moon run cmd/main -- decode-file-v2-dump samples/corpus/p0_03.j2k

opj_decompress -i samples/corpus/p0_03.j2k -o /tmp/output.raw

# バイト単位比較
xxd /tmp/output.raw | head -20
```

**出力形式**:
- MoonBit: `samples_hex=...` で16進ダンプ出力

### 2. 自動比較スクリプト

```bash
```

全27件のコーパスフィクスチャを自動比較。結果カテゴリ:
- `pass_real_match`: バイト完全一致
- `fail_mismatch`: バイト不一致
- `hard_fail`: デコードエラー


### 3. 視覚的比較

`tools/decode_to_pgm.sh` でPGM/PPM画像を生成し、ImageMagick で比較:

```bash
# MoonBit 出力
bash tools/decode_to_pgm.sh samples/corpus/p0_03.j2k /tmp/moonbit.pgm


# 差分画像生成
```

比較画像は `roundtrip/` フォルダに保存。

### 4. 一致率計算

```bash
# ピクセル単位一致率
```

### 5. マーカー構造の検証

```bash
# 生のマーカー位置確認
xxd samples/corpus/p0_03.j2k | grep -E "ff90|ff52|ff5c"

# SOT (ff90) の後に COD (ff52) / QCD (ff5c) があればタイル固有マーカー
```

### 6. 単体テストによる仕様準拠確認

```bash
moon test
```

T.800-2015 仕様に基づく321件のテスト。Annex J テストベクトルを含む。

---

## 関連ドキュメント

- `reference/visual-verification-2026-03-03.md` - 視覚的検証の詳細結果
- `~/.claude/projects/.../memory/MEMORY.md` - プロジェクトメモリ (セッション間で引き継ぎ)

---

## 継続作業ログ (2026-03-03 追記)

### 実装した修正

- `internal/decoder/annex_b10_layer.mbt`
  - `split_sod_accumulate_multi_layer` の `RPCL/PCRL/CPRL` パケット順序生成を、
    「最大precinct数のフラット反復」から
    **参照グリッド座標アンカー (x,y) ベース**へ変更。
  - 追加ヘルパー:
    - `PrecinctAnchor`
    - `build_precinct_anchors`
    - `build_packet_order`
  - `build_packet_order` は以下順序を明示実装:
    - RPCL: `(r, y, x, c, l)`
    - PCRL: `(y, x, c, r, l)`
    - CPRL: `(c, y, x, r, l)`

- `internal/decoder/annex_b10_layer_wbtest.mbt` (新規)
  - `packet_order_pcrl_reference_grid_across_resolutions`
  - `packet_order_cprl_component_outermost`
  - 上記2件で、座標アンカー順序が期待どおりであることを検証。

### 検証結果

- `moon test internal/decoder/annex_b10_layer_wbtest.mbt -v`: **2/2 pass**
- `moon check`: **0 errors**
  - `pass_real_match=2`
  - `fail_mismatch=25`
  - 既存の「2 pass / 25 fail」から件数改善なし

### 観測

- `p0_03.j2k` の先頭16サンプルは修正前後で変化し、順序修正の効果は出ている。
- よって主因は **PCRL順序だけではない** 可能性が高い。

### 次の優先調査

1. `split_sod_accumulate_multi_layer` の layer 累積（`per_segment_passes` / `all_segment_lengths`）の整合性確認
3. precinct内CB順序→global CB index の写像 (`global_cb_idx`) をタイル境界ケースで点検

---

## 継続作業ログ (2026-03-03 追記2: POC反映)

### 原因分析 (仕様確認)

- `p0_03.j2k` に `POC (FF5F)` が存在することを確認。
- 実装は `split_sod_accumulate_multi_layer` で `cod.progression_order` のみを使用しており、
  `POC` による進行順序上書きが未反映だった。
- 仕様根拠:
  - T.800-2015 A.6.6: 優先順位 `Tile-part POC > Main POC > Tile-part COD > Main COD`
  - T.800-2015 B.12.2: POC で progression volume を定義し、packet は重複送出しない

### 実装修正

- `internal/decoder/annex_b10_layer.mbt`
  - `build_packet_order_with_poc` を追加。
  - `POC` volume (`RSpoc/CSpoc/LYEpoc/REpoc/CEpoc/Ppoc`) ごとに順序を構築。
  - `next_layer_by_precinct` を導入し、B.12.2 の「重複なし・次レイヤ継続」を実装。
  - `split_sod_accumulate_multi_layer` に `poc_entries` 引数を追加。
- `internal/decoder/decode_api.mbt`
  - main header の `stream.metadata.poc` を抽出し、
    `split_sod_accumulate_multi_layer(..., poc_entries=...)` へ配線。
- `internal/decoder/annex_b10_layer_wbtest.mbt`
  - `packet_order_with_poc_overrides_cod_progression`
  - `packet_order_with_poc_tracks_next_layer_across_volumes`
  - を追加。

### 検証結果

- `moon test internal/decoder/annex_b10_layer_wbtest.mbt -v`: **4/4 pass**
- `moon check`: **0 errors**
  - `pass_real_match=2`
  - `fail_mismatch=25`
  - 件数は変化なし

### 追加観測

- `p0_03` / `p0_15` は `bits=4 signed=true` で、
  バイト生比較だと不一致が過大に見える。
  値比較に直すと `p0_03` は **387/65536 (0.59%)** 不一致で、差分はほぼ `±1`。
- 不一致座標は各タイルの先頭行/列付近（および tile 境界）に偏るため、
  残主因は **POC以外 (境界近傍の復元処理/タイル境界処理)** の可能性が高い。

---

## 継続作業ログ (2026-03-03 追記3: 5/3タイル境界補正)

### 原因分析 (仕様/実装照合)

- `p0_03.j2k` を再調査し、main header にのみ `POC/QCD/QCC` があり、tile header 側に `COD/QCD/POC` が無いことを確認。
- 4-bit signed の **値比較**で `p0_03` は `387/65536` 差分、差分はほぼ `±1`、位置はタイル境界近傍に偏在。
  (`OPJ_D_`, `OPJ_S_` 系マクロ) を使っていることを確認。

### 実装修正

- `internal/decoder/dwt/idwt_53_spec.mbt`
  - 5/3 逆変換の境界参照を、PSEOベース参照から **クランプ参照**へ変更。
  - 変更点は `idwt_53_1d_spec` 内の低域更新/高域予測で使う拡張参照のみ。
- `internal/decoder/dwt/idwt_1d_wbtest.mbt`
  - `idwt_53_1d_boundary_clamp_cas0` を追加し、境界クランプ時の期待値を固定。

### 検証結果

- `moon test internal/decoder/dwt/idwt_1d_wbtest.mbt -v`: **12/12 pass**
- `moon test internal/decoder/dwt/annex_j_spec_wbtest.mbt -v`: pass
  - `annex_j_53_2d_idwt: 13 differences, max_error=1`
  - `annex_j_full_2level_idwt: 6 differences, max_error=1`
- `moon check`: **0 errors**
  - `pass_real_match=10`
  - `fail_mismatch=17`
  - （修正前 `2/25` から大幅改善）

### 追加観測

- `p0_03`, `p0_15` の **値比較**は一致（差分0）まで改善。
- ただし比較スクリプトのカテゴリは 4-bit signed の生バイト比較を使うため、
  `p0_03`, `p0_15` は `fail_mismatch` のまま表示される点に注意。

---

## 継続作業ログ (2026-03-03 追記4: 比較スクリプト検証 + 9/7境界追補)

### 比較スクリプト修正

    「有効ビット幅マスク」から **デコーダ出力と同じ符号拡張LE** へ修正。
  - これにより 4-bit/12-bit signed の「値一致だがバイト不一致」誤判定を解消。

### 追加実装修正 (9/7)

- `internal/decoder/dwt/annex_f_dwt.mbt`
  - `idwt_97_1d` の境界参照を `extend_signal_double` (PSEO) から

### 比較結果

  - 修正前: `pass_real_match=10`, `fail_mismatch=17`
  - スクリプト修正後: `pass_real_match=12`, `fail_mismatch=15`
  - 9/7境界修正後: `pass_real_match=13`, `fail_mismatch=14`
    - 新規pass: `p0_09.j2k`

### 追加調査 (未解決)

- `p1_07` は依然不一致（現状 `21/24` mismatch, max diff 129）。
  - 出力サイズ: `w=2, h=12, comps=2, layout=component0`
  - 現実装先頭値: `127,127,127,127,...`
- `p1_06` も依然不一致（`107/144` mismatch）。
- `decode_api` / `annex_b10_layer` 側でコンポーネント別タイル座標を使う補強を入れたが、
  この2件の `pass_real_match` 改善には未到達。
- ただし差分量は一部減少:
  - `p0_05`: mismatch `863587 -> 330995`, max diff `97 -> 49`
  - `p1_01`: mismatch `6016 -> 5921`, max diff `227 -> 162`
  - `p1_06`: mismatch `107 -> 99`, max diff `255` (据え置き)
  - `p1_07`: mismatch `24 -> 21`, max diff `150 -> 129`

### T.814 リファレンス取り込み

- 参照PDF:
  - `/Users/terukichi/Downloads/T-REC-T.814-201906-I!!PDF-E.pdf`
- 取り込みノート作成:
  - `reference/spec/spec-t814-htj2k-intake.md`
- コーパス27件を走査した時点では `CAP (FF50)` は **0件** で、
  現行 mismatch は引き続き `T.800` 系が主対象。

---

## 継続作業ログ (2026-03-03 追記5: comp別COC配線 + RPCL再実装)

### 原因分析の追加観測

- `p1_07.j2k` を `opj_dump -v` で再確認:
  - `numcomps=2`, `dx/dy = (4,1), (1,1)`
  - `COD` の precinct は `(0,0),(1,1)` だが、`COC` で comp1 が `(1,1),(2,2)` に上書きされる。
- 既存実装は `split_sod_accumulate_multi_layer` 内で precinct/cblksty を実質 `COD` 一律扱いしており、
  comp別 `COC` 反映が不足していた。

### 実装修正

- `internal/decoder/decode_api.mbt`
  - 追加:
    - `get_component_code_block_style`
    - `get_component_precinct_size_bytes`
  - `split_sod_accumulate_multi_layer` 呼び出しに
    - `comp_code_block_styles`
    - `comp_precinct_size_bytes`
    を配線。

- `internal/decoder/annex_b10_layer.mbt`
  - `split_sod_accumulate_multi_layer` に以下オプション引数を追加:
    - `comp_code_block_styles`
    - `comp_precinct_size_bytes`
  - precinct exponent 取得を comp別化 (`get_component_precinct_exponents`)。
  - packet header 解析時の `code_block_style` を comp別適用。
    （`dx/dy` 最小ステップ, `(x,y)` 走査, `prci/prcj` 計算）。

- `internal/decoder/dwt/annex_f_dwt.mbt`
  - float IDWT後の整数化を ties-to-even へ変更
    （`lrintf` に合わせる意図）。

- `internal/decoder/annex_b10_layer_wbtest.mbt`
  - 既存テストを新シグネチャへ更新。
  - 追加:
    - `packet_order_rpcl_p1_07_geometry_packet_count`
      - `p1_07` 幾何相当入力で packet count `30` を検証
      - （SOP marker数 `30` と整合）

### 検証結果

- `moon check`: **0 errors**
- `moon test internal/decoder/annex_b10_layer_wbtest.mbt -v`: **5/5 pass**
  - **pass_real_match=13 / fail_mismatch=14**（件数据え置き）

### 差分量の再計測

- `p1_07`:
  - mismatch `21/24 -> 19/24`（改善）
  - ただし `pass_real_match` には未到達。
- `p1_06`:
  - `99/144`（据え置き）

### 現時点のボトルネック整理

- RPCL/COC配線の補強で packet順序側は改善したが、依然 `p1_*` 群に大差が残る。
- `decode_single_codeblock_coefficients` が
  `tier1_annex_c_decode_mini_block_passes` +
  `tier1_normative_preview_sample_values_mini_block`
  依存であり、**Tier-1本体の完全復元ではなく mini-block preview 系**が主経路。
- ここが `pass_real_match` 停滞（13/27）の主因候補。

### 次ステップ提案（優先順）

1. `decode_single_codeblock_coefficients` を mini-block preview 依存から段階的に脱却し、
   code-block 全体の normative coefficient 復元へ移行。
2. `p1_07` を固定ターゲットに、`packet order -> packet header -> segment lengths -> Tier1 coeff`
3. `p1_06`（9/7 + VSC/SEGSYM + multi-tile）で同様の pass/segment 監査を実施し、
   Tier-1未実装差と progression/order差を切り分ける。

---

## 継続作業ログ (2026-03-03 追記6: Tier-1固定小数点試験 + ロールバック)

### 実装・検証した内容

- `internal/decoder/t1/annex_d_pass.mbt`
      （`bp < 1` を skip）
    - sigprop近傍判定を `Array[Bool]` 直参照ヘルパー化
      (`tier1_mini_block_has_sig_neighbor_flags`)
- `internal/decoder/decode_wbtest.mbt`
  - 追加テスト:
  - `moon test internal/decoder/decode_wbtest.mbt -v`: **25/25 pass**

### 失敗した試行（いずれもロールバック済み）

1. `decode_single_codeblock_coefficients` で `qstyle=0` を
   - 結果: **大幅退行**
     - `pass_real_match=13 -> 3`
     - `fail_mismatch=14 -> 24`
   - 主因メモ:
     - 現在の `norm_decisions` 生成/消費モデル（mini-block preview前提）と
   - 対応: 当該配線を全てロールバック

   - 結果: カテゴリ件数は不変、差分量は悪化
     - 例: `p0_05` 先頭差分が `+1` 系から `+4..+6` 系へ悪化
   - 対応: 分岐をロールバック

### 現在の計測値（ロールバック後）

  - **pass_real_match=13**
  - **fail_mismatch=14**
- `p1_06.j2k`（byte比較）:
  - `mismatch=107/144`, `max_abs_diff=128`
- `p1_07.j2k`（byte比較）:
  - `mismatch=19/24`, `max_abs_diff=255`

### 次の有力調査ポイント

1. `p1_06` は出力がほぼ `0x80` 固定で、実質「係数ゼロ復元」に近い。
   - `split_sod_accumulate_multi_layer` の packet/header/body 消費に対し、
     tileごとの `included / coding_passes / segment_lengths / body_cursor` を
2. `p1_07` は RPCL/COC 補強後も `19/24` で停滞しており、
   packet order 以外（Tier-1係数復元モデル差）の寄与が高い。
     code-block全体復元の段階導入が必要。

## 継続作業ログ (2026-03-03 追記7: SOP境界前進の補正 + 再計測)

### 原因分析メモ

- `p1_06` の flat 出力傾向は、`split_sod_accumulate_multi_layer` の packet 境界推定が
  `uses_sop` 時に「次SOP先読み」に強く依存している点が疑わしかった。
- 仕様/実装整合の観点では、packet header から得られる `consumed_bits` と
  `segment_lengths` で body サイズが確定するため、
  **前進量は header+body 長を優先**し、SOP は再同期用途に留める方が堅牢。

### 実装修正

- `internal/decoder/annex_b10_layer.mbt`
  - `split_sod_accumulate_multi_layer` の `uses_sop` 分岐を修正:
    - 変更前: packet を「現在位置〜次SOP」で切り出し、`offset += remaining.length()`
    - 変更後:
      - `remaining` は現在位置から payload 末尾まで
      - `packet_size = body_offset + body_size` で前進
      - header 失敗/size 不整合時のみ `find_next_sop_offset` で再同期
      - 次 packet 開始位置に SOP が無い場合も再同期
- `internal/decoder/decode_api.mbt`
  - `decode_dwt_image_from_sequential_packets` で
    `split_sod_accumulate_multi_layer` に渡す `tcx0/tcy0` を
    comp0 実原点 (`per_comp_tcx0[0]`, `per_comp_tcy0[0]`) に補正。

### 検証結果

- `moon check`: **0 errors**
- `moon test internal/decoder/annex_b10_layer_wbtest.mbt -v`: **6/6 pass**
  - **pass_real_match=13**
  - **fail_mismatch=14**
  - カテゴリ件数は据え置き

### 差分量の再計測

- `p1_06.j2k`（byte比較）:
  - **mismatch=102/144**（前回 107/144 から改善）
  - **max_abs_diff=255**（据え置き）
- `p1_07.j2k`（byte比較）:
  - **mismatch=19/24**（据え置き）
  - **max_abs_diff=255**（据え置き）

### 観測

- `pass_real_match` は増えていないが、`p1_06` は部分的に改善。
- `p1_07` は改善せず、依然として packet order 以外（Tier-1係数復元/配置）の寄与が高い。

### 次の優先調査

1. `split_sod_accumulate_multi_layer` に packet ごとの `header_fail_count` / `size_recovery_count`
   を可視化する最小デバッグ導線を追加し、`p1_06/p1_07` の失敗率を定量化。
2. `p1_07` について、`(res,comp,prec)` ごとの累積 `total_coding_passes` と
   packet order 問題か Tier-1 復元問題かを切り分ける。

## 継続作業ログ (2026-03-03 追記8: p1_06 の PPT 影響切り分け)

### 計測結果（再確認）

  - **pass_real_match=13**
  - **fail_mismatch=14**
- `p1_06.j2k`（byte比較）: **99/144**, `max_abs_diff=255`
- `p1_07.j2k`（byte比較）: **19/24**, `max_abs_diff=255`

### 実施した切り分け

- `split_sod_accumulate_multi_layer` に一時診断を入れて packet 単位の消費を確認したところ、
  `p1_06` の多くの packet で `body_size=0` 判定となり、SOP 再同期に依存する挙動を確認。
- `p1_06` の実ファイルを直接走査し、`FF61 (PPT)` が各 tile-part に存在することを確認:
  - 16 tile すべてで `SOT -> PPT -> SOD` 構成
  - 例: tile0 `PPT len=106`, `SOD off=266`
- `p1_06` の SOD 先頭 packet をダンプすると、SOP 直後のデータに対し
  現行 in-band header 解析では `nz=0` 判定になる一方、次SOPまで十分なバイト長があり、
  **SOD側を header とみなす前提が崩れている**兆候を確認。

### 試した実装（ロールバック済み）

- tile ごとに PPT ペイロードを収集し、`split_sod_accumulate_multi_layer` に
  「relocated header」入力として与える試作を実装。
- ただし、header ストリーム整合（zero-extent packet 消費、EPH混在、packet境界整合）を
  正しく満たせず、`p1_06` が `99/144 -> 139/144` まで悪化したため**ロールバック**。

### 現時点の結論

- `p1_06` の主因候補は **PPT (packet header relocation) 未対応**。
- 現行 multi-layer 経路は in-band packet header 前提で、PPT を含む tile-part では
  header/body の責務分離が不十分。
- ただし、PPT 対応の中途実装は退行を招くため、現時点では baseline（13/27）維持を優先。

### 次の実装方針（推奨）

1. `SOT` 単位で `PPT(Zppt, Ippt)` を厳密に再構成し、tile-part ごとに header ビット列を確定。
2. `split_sod_accumulate_multi_layer` に「tile-part境界 + relocated header cursor」を導入し、
   zero-extent packet も含めて `Nsop` と header 消費を同期。
3. `EPH` は relocated header 側で消費、SOD 側は body 専用として扱う分岐を明示。
4. `p1_06` 専用の packet 単位監査（`nsop, order tuple, header bytes consumed, body_size, next SOP delta`）
   をテスト化してから本配線。

## 継続作業ログ (2026-03-03 追記9: 計測継続 + 失敗試行の切り戻し)

### 実施した試行

1. `PPT` relocated header の本配線試行
   - `split_sod_accumulate_multi_layer` に `relocated_packet_headers` 入力を追加し、
     header/body 分離消費ロジックを実装。
   - `decode_api` 側で tile別 `PPT` を渡す実装を試行。
   - 結果: `p1_06` が **99/144 -> 126/144** へ悪化。
   - 対応: 実運用経路では `relocated_packet_headers` を渡さない状態へ戻し、
     baseline 挙動を維持（配線土台のみ残置）。

2. 非ゼロ原点を考慮した detail subband 配置補正の試行
   - `decode_component_dwt_from_accumulated` で配置式を変更したが、
     全体比較が **pass_real_match=13 -> 2** まで退行。
   - 対応: 当該変更はロールバック。

3. 9/7 の丸め方式（ties-to-even -> away-from-zero）試行
   - `pass_real_match` 件数に改善なし（13据え置き）。
   - 対応: ties-to-even に戻した。

### 現在の計測値（最新）

  - **pass_real_match=13**
  - **fail_mismatch=14**
- `p1_06.j2k`: **99/144**, `max_abs_diff=255`
- `p1_07.j2k`: **19/24**, `max_abs_diff=255`

### 追加メモ

- `p1_07` 向けに non-MCT 経路の `tcx0/tcy0` 参照を `per_comp_tcx0/tcy0` 優先へ補正したが、
  現行コーパス比較では件数改善に未到達。
- したがって、直近の有効進捗は「baseline維持での失敗試行切り分け完了」まで。

## 継続作業ログ (2026-03-03 追記10: RPCL切り分け)

### 試行と結果

1. `decode_dwt_image_from_sop_packets` への単一タイル分岐試行
   - 条件: `uses_sop && layers==1 && num_tiles==1`
   - 結果: `p1_07` が **19/24 -> 23/24** に悪化
   - 対応: ロールバック

2. `RPCL` を `LRCP` に読み替える A/B 試行
   - 局所（`p1_07`相当）:
     - `19/24 -> 16/24` まで改善
   - 全体:
     - `pass_real_match=13` のまま据え置き（改善なし）
   - 対応: 仕様逸脱回避のためロールバック

3. `build_packet_order` の RPCL を anchor-based に寄せる試行
   - 結果: `p1_07` が **20/24** に悪化
   - 対応: ロールバック

### 現在値（再確認）

  - **pass_real_match=13**
  - **fail_mismatch=14**
- `p1_06`: **99/144**, `max_abs_diff=255`
- `p1_07`: **19/24**, `max_abs_diff=255`

### 今回の確定知見

- `p1_07` は Tier-1 だけでなく **RPCL packet order 実装差**の寄与が高い。
- ただし単純に `LRCP` へ寄せても `pass_real_match` は増えないため、
  packet index レベルで監査して差分点を特定する必要がある。

## 継続作業ログ (2026-03-03 追記11: p1_07 packet監査 + 失敗試行の整理)

### 再計測（基準値）

  - **pass_real_match=13**
  - **fail_mismatch=14**
- `p1_07.j2k`: **19/24**, `max_abs_diff=255`
- `p1_06.j2k`: **99/144**, `max_abs_diff=255`

### 今回の主な監査結果

- `split_sod_accumulate_multi_layer` に一時トレースを入れて `p1_07` を監査。
  - `header_fail=0`, `size_invalid=0`（SOP境界同期は正常）
    Python再現した結果と **一致**。
- ただし `p1_07` の `r=1, c=0` では、
  - non-zero packet が `prec={0,2,4,6,8,10}` 側に偏り、
  - `subband_index=0` のみが寄与（`cb_nonzero=1/3`）
  - 累積 `total_coding_passes=132`
  という偏りを確認。

### 実施したA/B（全て計測済み・切り戻し）

1. **RPCL -> LRCP 強制（p1_07限定A/B）**
   - `p1_07`: `19/24 -> 16/24` に改善
   - ただし仕様逸脱かつ全体 `pass_real_match` は **13据え置き**
   - ロールバック

2. **B.7 precinct→subband 変換で `PPx-1/PPy-1` を使わない試行**
   - `p1_07`: **24/24** へ悪化
   - ロールバック

3. **Tier-1 スケーリング側で `num_bp` 上限を `Kmax-zbp` にクリップ**
   - `p1_07` は件数改善なし（出力傾向のみ変化）
   - 全体 `pass_real_match` も **13据え置き**
   - ロールバック

### 今回残した変更

- `internal/decoder/decode_api.mbt`
  - 単一タイル経路でも `decode_dwt_image_from_sequential_packets` へ
    `tcx0/tcy0`（tile-component absolute origin）を明示渡し。
  - 今回のコーパス件数には影響なし（`13/14`維持）。

### 現時点の結論

- `p1_07` は「SOP境界崩壊」や「RPCL式そのものの不一致」より、
  **packet header解釈（subband/precinct対応）〜Tier-1係数復元の整合**が主因候補。
  **subband走査順と inclusion/ZBP/coding_passes の対照ログ**を取るのが最短。

## 継続作業ログ (2026-03-03 追記12: multi-segment MQ境界A/B)

### 再計測（基準復帰）

  - **pass_real_match=13**
  - **fail_mismatch=14**
- `p1_06.j2k`: **99/144**, `max_abs_diff=255`
- `p1_07.j2k`: **19/24**, `max_abs_diff=255`

### 実施したA/Bと判断

1. **PPT relocated header を DWT経路へ配線**
   - `decode_api` で `collect_ppt_payloads_by_tile` を渡す試行。
   - 結果: `p1_06` が **126/144** へ悪化、全体 `pass_real_match` も増えず。
   - 対応: **ロールバック**（in-band baselineへ復帰）。

2. **precinct→CB 所属を origin基準へ再試行**
   - `compute_precinct_codeblock_range_abs` を `ceil(start)` 化し、`ncb=0` subband を header走査除外する試行。
   - 観測: `p1_07` で累積 passes は減るが、最終差分は **24/24** へ悪化。
   - 対応: **ロールバック**。

3. **Tier-1 multi-segment の MQ再初期化を限定導入（保持）**
   - `internal/decoder/decode_api.mbt` の `decode_single_codeblock_coefficients` で、
     `has_multi_segments && passes > codeword.length()*3` の異常値ケースに限定して
     `tier1_annex_c_decode_mini_block_passes(..., pass_segments=...)` 経路を使用。
   - 広い適用条件（`precision_bits==8` 含む）は `pass_real_match=11` へ退行したため却下。

### 最新結果（保持中の変更で再計測）

  - **pass_real_match=13**（件数据え置き）
  - **fail_mismatch=14**
- 差分量:
  - `p1_07`: **19/24 -> 15/24**（改善）
  - `p1_06`: **99/144**（据え置き）
  - `p1_02`: **300332/307200 -> 300328/307200**（微改善）
  - pass fixture のカテゴリ退行は無し（`p0_10`, `p0_16` などは pass維持）。

### 現状結論

- `pass_real_match` 増加には未到達だが、**退行なしで mismatch 量を縮小**。
- `p1_07` は依然として packet/header と Tier-1 境界条件の複合要因。
- 次は `p1_07` 固定で、
  `per_segment_passes` と `segment_lengths` の妥当性（1-byte segmentで過大passes）を

## 継続作業ログ (2026-03-03 追記13: segment分割の仕様準拠化と効果確認)

### 実施内容（仕様/参照実装ベース）

  packet header 側の segment pass 分割を仕様準拠で実装。
  - `TERMALL(0x04)`: 1 pass/segment
  - `BYPASS(LAZY, 0x01)`: 初回 `10`、以後 `2/1` 交互（segment state を CB 単位で持続）
  - それ以外: `109` 上限
- 変更点:
  - `internal/decoder/annex_a8_packet.mbt`
    - `SubbandCodeBlockInfo` に `segment_passes` を追加
    - `split_packet_passes_and_advance_segment_state` を追加
    - `parse_per_subband_packet_header` で style依存の segment pass 分割を使用
  - `internal/decoder/annex_b10_layer.mbt`
    - `SubbandLayerStateEntry` に CBごとの segment state (`seg_numpasses/maxpasses/count`) を追加
    - `parse_layer_packet_header` で上記 state を使って `added_passes` を算出
    - 累積時 `per_segment_passes` を `info.segment_passes` ベースで保持
  - `internal/decoder/decode_api.mbt`
    - `decode_single_codeblock_coefficients` 呼び出しへ `per_segment_passes=info.segment_passes` を配線
- `T.814` 参照を作業ツリーへ取り込み:
  - `reference/T.814-2019.pdf`
  - `reference/T.814-2019.txt`（`pdftotext -layout`）

### 検証結果

- `moon check`: OK（warningのみ）
- `moon test internal/decoder/decode_wbtest.mbt -v`: **25/25 pass**
  - **pass_real_match=13**
  - **fail_mismatch=14**

### 主要 fixture の再確認

- `p1_06.j2k`: `mismatch=99/144`, `max_abs_diff=255`
- `p1_07.j2k`: `mismatch=15/24`, `max_abs_diff=255`

### 分析（今回の修正が効く範囲）

- `opj_dump -v` による `cblksty`:
  - `p1_06`: `0x28`（SEGSYM+VSC）
  - `p1_07`: `0x00`
- 今回の主修正対象（`BYPASS/Lazy` 分割）は、停滞の主対象 `p1_06/p1_07` には直接適用されにくい。
- よって、`pass_real_match` 件数が増えないことは整合的。

### 次アクション（仕様準拠で優先）

1. `p1_06` 向けに `PPT relocated header` の tile-part 単位再構成（`SOT` 境界で `Ippt` 消費）を再実装。
2. `split_sod_accumulate_multi_layer` の header cursor を `tile-part + Nsop` 同期で監査可能にする。

## 継続作業ログ (2026-03-03 追記14: p1_06本命A/Bの再確認)

### 実施A/B

   - `internal/decoder/mq/annex_c_mq.mbt` の magref 分岐で VSC マスクを外す試行。
   - 結果: corpus件数・主要 mismatch に有意差なし。

2. **PPT relocated header の tile別再配線（再試行）**
   - `decode_api` の multi-tile 経路で `collect_ppt_payloads_by_tile` を使い、
     tileごと `decode_dwt_image_from_sequential_packets(..., relocated_packet_headers=...)` を試行。
   - 結果:
     - `pass_real_match` は **13据え置き**
     - `p1_06` が **99/144 -> 126/144** に悪化
   - 対応: **即ロールバック**（PPT再配線は未採用）

### 最新値（ロールバック後の基準復帰）

  - **pass_real_match=13**
  - **fail_mismatch=14**
- `p1_06.j2k`: **99/144**, `max_abs_diff=255`
- `p1_07.j2k`: **15/24**, `max_abs_diff=255`

### 現時点の判断

- `p1_06` の主因は「PPTを渡す/渡さない」の二値ではなく、
  **relocated header 消費の同期モデル（tile-part内 packet 対応）**にある可能性が高い。
- 次は `split_sod_accumulate_multi_layer` 側で、
  packet単位の `header_bits_consumed` と `body_size` を tile-part/SOP境界と同時に記録し、

## 継続作業ログ (2026-03-04 追記15: SOP境界不一致の実在確認と安全側ガード)

### 背景

- ユーザー指摘どおり、`y`（packet/header/body消費同期）が壊れると `x` 側の調整では前進しないため、
  まず同期崩壊の有無を直接検証した。

### 実施した診断A/B

1. **`global_cb_idx` 範囲外時の即エラー化（短時間診断）**
   - `p1_06/p1_07` では発火せず。
   - 結論: 主要因ではない（ただし恒久的に「範囲外でも body bytes は消費」は維持）。

2. **SOP境界不一致の即エラー化（短時間診断）**
   - `p1_06` で multi-tile 経路が `tile_fail_accum=16` となり、
     SOP境界不一致が実際に発生していることを確認。
   - `p1_07` では同診断で顕著な発火なし。

### 採用した恒久変更

- `split_sod_accumulate_multi_layer` にて:
  - **included code-block の body bytes は、CBインデックス範囲外でも必ず消費**。
  - SOPストリームで `offset + packet_size` が次SOPに一致しない場合のみ、
    **その packet の codeword 消費上限を次SOP境界までに制限**（通常ケースは従来動作維持）。

### 計測結果（追記15時点）

  - **pass_real_match=13**
  - **fail_mismatch=14**
- `p1_06.j2k`: **99/144**, `max_abs_diff=255`
- `p1_07.j2k`: **15/24**, `max_abs_diff=255`

### 今回の判断

- `pass_real_match` 増には未到達だが、
  `p1_06` における「SOP境界不一致が現実に起きている」ことは確認できた。
- 次段は、`p1_06` 固定で packet単位に
  `computed packet_size / next SOP delta / body consumed` を対照化し、
  どの packet で不一致が発生するかを特定するのが最短。

## 継続作業ログ (2026-03-04 追記16: Nsop適用条件A/Bと packet order示唆)

### 実施内容

1. `p1_06` 向けに一時ログで SOP不一致 packet を採取。  
   `packet/order_idx/(r,l,c,p)/offset/expected_next/next_sop` を出力して確認。

2. `Nsop` 適用条件のA/B:
   - A: `Nsop` を **relocated header時のみ適用**（旧条件）
   - B: `Nsop` を **常時適用**（現行）

### 結果

- A（relocated時のみ）:
  - `p1_06`: **104/144**（悪化）
  - `p1_07`: 15/24（同等）
- B（常時適用）へ戻し:
  - `p1_06`: **99/144**（基準復帰）
  - `p1_07`: 15/24

- 全件比較（最終）:
  - `pass_real_match=13`
  - `fail_mismatch=14`

### 今回の示唆

- `p1_06` では SOP境界不一致が多発するが、`Nsop` を無視するとさらに悪化。
- したがって当面は `Nsop` 常時適用を維持し、
  不一致の本丸は `packet_order tuple` と packet header解釈（empty判定/segment長）側の整合。

## 継続作業ログ (2026-03-04 追記17: 単位分割での p1_07 原因特定)

### 方針

- ユーザー指摘どおり、全体一括ではなく以下の処理単位で保証を積み上げ。
  1. packet pipeline（SOP/PPT/header/body）
  2. 累積CB統計（res/compごとの passes/segments/codeword）
  3. DWT前後（recon-audit）

### 単位検証結果

- `python3 reference/debug-tools/analyze_packet_pipeline.py samples/corpus/p1_07.j2k`
  - `S1..S5=ok`, `pipeline_result=ok`
- `python3 reference/debug-tools/analyze_packet_pipeline.py samples/corpus/p1_06.j2k`
  - 16 tile 全て `S1..S5=ok`, `pipeline_result=ok`
- したがって `p1_07` は packet層ではなく DWT/Tier1後段が主因。

### 原因

- `p1_07` の再構成値（DCシフト前）が `[-128, 0, -128, 0, ...]`、
- `internal/decoder/dwt/idwt_53_spec.mbt` の `idwt_53_1d_spec` にて、

### 修正

- `internal/decoder/dwt/idwt_53_spec.mbt`
  - `cas=1` 時の interleave を `even index -> d'`, `odd index -> s'` に修正。
- `internal/decoder/dwt/idwt_1d_wbtest.mbt`
  - `idwt_53_1d_length2_cas1` を期待値固定 (`[105, 95]`) に強化。

### 計測結果（修正後）

  - **pass_real_match=15**
  - **fail_mismatch=12**
  - **hard_fail=0**
- 主な変化:
  - `p1_07.j2k`: `24/24 mismatch -> 0/24 mismatch`（byte一致）
  - `p0_03.j2k`: `pass_real_match` へ復帰
- 残課題:
  - `p1_06.j2k`: `113/144 mismatch`（未解消）

### 参考（T.814 取り込み確認）

- 既存 `reference/T.814-2019.pdf` は
  `/Users/terukichi/Downloads/T-REC-T.814-201906-I!!PDF-E.pdf` と
  SHA-256 一致（同一ファイル）を確認。

## 継続作業ログ (2026-03-04 追記18: PPT自動適用 + 9/7/ICT float経路の単位検証)

### 実装

1. `PPT` リロケートヘッダの自動適用
   - `internal/decoder/decode_api.mbt`
   - 変更前: `force_relocated_ppt=true` のときのみ `collect_ppt_payloads_by_tile` を利用
   - 変更後: `PPT` が存在すれば自動で `relocated_packet_headers` を使用
     - multi-tile 経路
     - single-tile 経路（tile 0）

   - `internal/decoder/dwt/annex_f_dwt.mbt`
     - `apply_inverse_dwt_float` 追加（float出力）
   - `internal/decoder/annex_b10_layer.mbt`
     - `decode_component_dwt_from_accumulated_float` 追加
   - `internal/decoder/mct/annex_g_mct.mbt`
     - `tier1_annex_g_inverse_ict_components_float` 追加
   - `internal/decoder/decode_api.mbt`
     - `trans0==0`（irreversible MCT）時のみ
       `IDWT(float) -> ICT(float) -> round_ties_even -> DC shift -> clamp`
       に切替

3. 検証テスト追加
   - `internal/decoder/mct/mct_wbtest.mbt`
     - `inverse_ict_components_float basic`
     - `inverse_ict_components_float mismatched lengths`

### 計測

- `p1_06.j2k`（dump経路）: **113/144 -> 76/144 mismatch**
- `p1_02.j2k`（dump経路）: **300k台 -> 295846/307200 mismatch**（改善）
- `p1_07.j2k`: **0/24 mismatch** 維持

- 全件比較:
  - `pass_real_match=15`
  - `fail_mismatch=12`
  - `hard_fail=0`

### ロールバック済み試行

- `decode_single_codeblock_coefficients` の lossy経路を
  - `p1_06`: `76 -> 134 mismatch`
  - `p1_02`: 悪化
- 該当変更は即時切り戻し済み（基準値維持）。

## 継続作業ログ (2026-03-04 追記19: bit-plane数式の仕様修正 + 9/7 A/B)

### 単位分析

- `p1_06` を tile単位で再計測し、`76/144` mismatch を再確認。
  - 4x4 tile のうち `tile00` と `tile14` は `0/9` で一致。
  - 残 tile は `-22/-40/-81/-128` など量子化段差状の差分が優勢。
- `reference/debug-tools/analyze_packet_pipeline.py` では `p1_06/p1_07` とも `S1..S5=ok` 維持。
  - よって packet 層（SOP/PPT/header/body）ではなく、Tier-1 係数復元〜後段の整合が主疑い。

### 実装修正（採用）

- `internal/decoder/decode_api.mbt`
  - `decode_single_codeblock_coefficients` の `num_bp` 算出式を修正。
  - 変更前: `ceil(passes/3)` 相当 (`(passes+2)/3`)
  - 変更後: `passes>0` のとき `1 + ceil((passes-1)/3)` 相当
    - 先頭 bit-plane は cleanup 1 pass のみ、以降 3 pass/bit-plane という
      T.800-2015 D.3 系の定義と整合。

### A/B（ロールバック済み）

- `internal/decoder/dwt/annex_f_dwt.mbt` で 9/7 high-pass unscale を
  - 局所: `p1_06` は `76 -> 71` に改善
  - ただし `p0_09` が `pass -> 508/629 mismatch` に悪化
  - 不採用・即時ロールバック。

### 検証結果（追記19時点）

- `moon check`: 0 errors
- `moon test internal/decoder/decode_wbtest.mbt -v`: 25/25 pass
- `moon test internal/decoder/annex_b10_layer_wbtest.mbt -v`: 6/6 pass
  - **pass_real_match=15**
  - **fail_mismatch=12**
  - **hard_fail=0**

### 現状

- `pass_real_match` 件数は据え置きだが、bit-plane 数式の仕様不整合は解消。
- `p1_06` は引き続き未一致（`76/144`）で、次段は
  `VSC+SEGSYM` 条件下の Tier-1 復元差分（特に chroma 寄与）を優先調査。

## 継続作業ログ (2026-03-04 追記20: VSC magref south-mask の再適用)

### 実装修正（採用）

- `internal/decoder/mq/annex_c_mq.mbt`
  - magref pass（Table D.4 の近傍有意判定）に `VSC` south mask を適用。
  - 変更点:
    - `mr_vsc = has_causal && y % 4 == 3`
    - `tier1_spec_neighbor_sig_counts(..., mask_south=mr_vsc)`

### 計測

- 全件比較:
  - **pass_real_match=15**
  - **fail_mismatch=12**（件数据え置き）
- 差分量:
  - `p1_02.j2k`: **295846/307200 -> 294801/307200**（改善）
  - `p1_06.j2k`: **76/144**（据え置き）
  - `p1_07.j2k`: **0/24**（維持）

### 検証

- `moon test internal/decoder/decode_wbtest.mbt -v`: 25/25 pass
- `moon check`: 0 errors

## 継続作業ログ (2026-03-04 追記21: tile-part POC適用で p0_07 解消)

### 原因分析

- `p0_07.j2k` の mismatch は `16384/4194304` で、**tile(0,0) の 128x128 全域のみ**に局在。
- `reference/debug-tools/analyze_packet_pipeline.py samples/corpus/p0_07.j2k` で、
  tile0 に tile-part が2つ（SOP 72 + 24）あることを再確認。
- 生マーカー監査で tile0 の両 tile-part header に `POC (FF5F)` が存在:
  - part0: `RSpoc=0, CSpoc=0, LYEpoc=9, REpoc=3, CEpoc=3, Ppoc=0`
  - part1: `RSpoc=0, CSpoc=0, LYEpoc=9, REpoc=8, CEpoc=3, Ppoc=0`
- 既存実装は `decode_dwt_image_from_sequential_packets` で
  `main header POC` のみ使用しており、tile-part POC を無視していたため、

### 実装修正（採用）

- `internal/decoder/decode_api.mbt`
  - `collect_tile_part_poc_by_tile(stream, csiz)` を追加。
    - codestream segment 走査で `SOT` の `Isot` を追跡し、
      `stream.metadata.poc` を marker順で消費して tileごとに収集。
  - `decode_dwt_image_from_sequential_packets` に
    `poc_entries? : Array[@core.PocMetadata] = []` を追加。
    - 引数があればそれを優先、なければ従来どおり main-header POC を使用。
  - multi-tile 経路で tileごとの `poc_entries` を渡すよう配線。
  - single-tile 経路でも tile0 の tile-part POC を渡すよう配線。

- `internal/decoder/annex_b10_layer.mbt`
  - 追加ガード（前段で実施）を維持:
    - SOPストリームで header由来 `packet_size` が次SOPと不整合な場合、
      SOP境界を優先して `packet_size` を補正。

### 計測結果

- 単体:
  - `p0_07.j2k`: **16384/4194304 -> 0/4194304**（完全一致化）
  - `p1_06.j2k`: **76/144**（据え置き）
  - `p1_07.j2k`: **0/24**（維持）

- 全件比較:
  - **pass_real_match=16**
  - **fail_mismatch=11**
  - **hard_fail=0**

### 検証

- `moon check`: 0 errors（warningsのみ）
- `moon test internal/decoder/decode_wbtest.mbt -v`: 25/25 pass
- `moon test internal/decoder/annex_b10_layer_wbtest.mbt -v`: 6/6 pass
- `moon info && moon fmt`: 実施済み

## 継続作業ログ (2026-03-04 追記22: p1_06 の単位切り分け継続)

### 実施した切り分け

1. **基準再計測**
   - 結果維持: `pass_real_match=16`, `fail_mismatch=11`, `hard_fail=0`

2. **VSC適用行 A/B（非採用・ロールバック済み）**
   - A/B結果:
     - `p1_06`: `76/144 -> 85/144`（悪化）
     - `p1_02`: `294801/307200 -> 301168/307200`（悪化）
   - 現行の `y % 4 == 3` 判定に復帰。

3. **端数ストライプ VSC全行マスク A/B（非採用・ロールバック済み）**
   - 末尾 `<4` 行でのみ全行 `mask_south=true` を試行。
   - A/B結果:
     - `p1_06`: `76/144 -> 85/144`（悪化）
     - `p1_02`: `294801/307200 -> 297000/307200`（悪化）
   - 不採用。

4. **bit-plane 数式 A/B（非採用・ロールバック済み）**
   - `num_bp = (passes + 2) / 3` へ戻す試験。
   - A/B結果:
     - `p0_05`: `296300/1048576 -> 330995/1048576`（悪化）
     - `p1_06`: `76/144`（不変）
   - 不採用。

5. **最終丸め規則 A/B（非採用・ロールバック済み）**
   - `round_ties_even` を ties-away-from-zero に変更して検証。
   - 差分件数は主要 fixture で実質変化なし。
   - 不採用。

### 新規知見（原因位置の絞り込み）

- `p1_06.j2k` を一時的に `COD(mct)=0` にパッチした検証版 (`/tmp/p1_06_nomct.j2k`) で、
  - 結果: `121/144 mismatch`（`max_abs_diff=104`）
- つまり `p1_06` の未一致は **MCT後段だけではなく、MCT前（packet/Tier-1/IDWT）にも残る**。
- 併せて `pkt-audit` で tile別に確認すると、`tile0` は一致傾向で、`tile1` 以降で差分が顕著。
  次段は `tile1+` の code-block 復元差分（特に `VSC+SEGSYM` 条件）を優先追跡する。


### 実施内容

   - `internal/decoder/quant/annex_e_dequant.mbt`
   - 変更:
     - 9/7 (`use_53_filter=false`) の `gain` を `0` 固定へ。
   - 根拠:
       `qmfbid==0` で非LL帯域の `log2_gain` を実質 `0` 扱い。

2. **9/7 high-pass unscale の `two_invK` 化（採用）**
   - `internal/decoder/dwt/annex_f_dwt.mbt`
   - 変更:
     - `idwt_97_1d` で `high / K` の代わりに
       `high * 1.625732422` (`two_invK`) を適用。
   - 根拠:

3. **A/B（非採用・ロールバック済み）**
   - `idwt_97_1d` の `sn==0/dn==0` 早期returnを外し、汎用処理へ寄せる試行。
   - 結果:
     - `p1_06` が `27 -> 81 mismatch` に悪化。
   - 不採用・復帰済み。

4. **A/B（非採用・ロールバック済み）**
   - 最終丸めを ties-even から ties-away に変更する試行。
   - 結果:
     - 全件カテゴリ・`p1_06 mismatch` とも実質不変。
   - 不採用・復帰済み。

### 計測結果

- 全件比較:
  - **pass_real_match=16**
  - **fail_mismatch=11**
  - **hard_fail=0**
  - 件数は据え置き。

- ただし差分量は改善:
  - `p1_06.j2k`: **76/144 -> 27/144 mismatch**（`max_abs_diff=5`）
  - `mct=0` 切り分け版 `/tmp/p1_06_nomct.j2k`:
    **121/144 -> 23/144 mismatch**（`max_abs_diff=4`）

### 解釈

- 今回の改善は `MCT後段` ではなく、主に **9/7前段（dequant + IDWTスケーリング）** の整合で得られた。
- 残差は `p1_06` で小さく（多くが `±1`、一部 `±4/5`）、

## 継続作業ログ (2026-03-04 追記24: パイプライン段階A/Bで原因位置を再絞り込み)

### 実施内容（すべてA/B後にベースラインへ復帰）

1. `mq/annex_c_mq.mbt` の `magref` VSCマスクを無効化 (`mr_vsc=false`)
   - 全件カテゴリ不変（`pass_real_match=16`, `fail_mismatch=11`）
   - `p1_06` も不変（`27/144`, `max_abs_diff=5`）
   - 不採用。

2. PCRL first-position 条件を `ref_x0/ref_y0` から `tcx0/tcy0` に変更
   - `p1_07` が `0/24 -> 24/24` に悪化
   - 全件も `16/11 -> 15/12` に悪化
   - ロールバック。

   - `p0_04` 微改善、`p0_05` 微悪化で相殺
   - 全件カテゴリ不変（`16/11`）
   - ロールバック。

4. ICT(MCT) 演算を `float32` 丸め順へ寄せるA/B
   - `p1_06` 不変
   - 全件カテゴリ不変
   - ロールバック。

### パイプライン段階の切り分け（重要）

- `p1_06` の tile境界差分に対し、段階別に原点依存性を切り分け:
  - **Packet-order段**:
    `packet_tcx0/tcy0=0` にしても `p1_06` 不変（`27/144`）
    -> 主因ではない。
  - **DWT段（component decode）**:
    `decode_component_dwt_from_accumulated(_float)` への `tcx0/tcy0` を 0 固定にすると
    `p1_06: 27/144 -> 126/144` に悪化
    -> 残差は DWT段の非ゼロ tile-origin 取り扱いに強く依存。

### 現在のベースライン（復帰確認）

  - `pass_real_match=16`
  - `fail_mismatch=11`
  - `hard_fail=0`
- `p1_06.j2k`: `27/144`, `max_abs_diff=5`
- `p1_07.j2k`: `0/24`, `max_abs_diff=0`
- `p0_09.j2k`: `0/629`, `max_abs_diff=0`

## 継続作業ログ (2026-03-04 追記25: p1_06 の 0.5 LSB 欠落補正で 18/27 へ改善)

### 原因分析（単位分割）

  `dwt-pre-deq` で `±0.123596`（= `0.5 * step` 相当）の系統差が多数出ることを確認。
- `decode_single_codeblock_coefficients` の lossy 経路は整数係数で保持しており、
  `shift == 0` の block で **0.5 LSB を表現できず欠落**していた。
- そのため `dwt-pre-deq -> dwt-post -> mct-r` に ±1 差が伝播し、`p1_06` で `21/144` mismatch が残っていた。

### 実装修正（採用）

- `internal/decoder/decode_api.mbt`
  - `decode_single_codeblock_coefficients` の係数出力で、
    lossy (`quantization_style != 0`) のみ **x2 fixed-point** 形式へ変更。
  - 具体的には:
    - ROI descaling 後の係数を `<< 1`
    - かつ `shift == 0` かつ非ゼロ係数で `±1` を加算し、0.5 LSB を保持

- `internal/decoder/quant/annex_e_dequant.mbt`
  - dequantization 側で lossy 係数に `coeff_scale=0.5` を適用し、x2 fixed-point を実値へ復元。

- `internal/decoder/decode_api.mbt`
  - `print_audit_sample_stats_float` を実数ログ出力へ変更し、
    監査時に dequant/DWT/MCT の実数差分を直接確認可能化。

### 検証結果

  - `dwt-pre-deq bad=0`
  - `dwt-post bad=0`
  - `mct-src bad=0`
  - `mct-r bad=0`
  - `mismatch=0/144`
  - **pass_real_match=18**
  - **fail_mismatch=9**
  - **hard_fail=0**
  - （前回 `17/10/0` から +1 改善）

### 回帰確認

- `moon test internal/decoder/decode_wbtest.mbt -v`: 25/25 pass
- `moon test internal/decoder/annex_b10_layer_wbtest.mbt -v`: 6/6 pass
- `p0_07`, `p0_09`, `p1_07` は byte一致を維持。

## 継続作業ログ (2026-03-09 追記26: 25/27達成後の残課題分析)

### 計測結果

  - **pass_real_match=25**
  - **fail_mismatch=2**
  - **hard_fail=0**

### 残り2件の fail_mismatch

| Fixture | 差分 | cblksty | 特徴 |
|---------|------|---------|------|
| p1_02.j2k | 294785/307200 (96%), max +11〜13 | 0xa (RESET+CAUSAL) | 系統的正オフセット |
| p1_05.j2k | 148359/262144 (57%), max ±1〜3 | 0x19 (PTERM+BYPASS+CAUSAL) | 散発的小差分 |

### p1_02 分析

- **特徴**: 640x480, 単一タイル, LRCP, 19 layers, PPT使用, qstyle=2
- **差分パターン**: 全ピクセルで系統的に +9〜+13 (主に +11)
- **調査済み**:
  - パケットパイプライン: `S4=ng` だがPPT消費は正常に累積 (`hoff` 正常増加)
  - RESET/CAUSALテスト: 5/5 pass
  - コンテキストリセット実装: T.800-2015 Table D.7 準拠
- **残る仮説**:
  - RESETモードとセグメント再初期化の相互作用
  - 多層(19 layers)での係数累積のスケーリング差
  - PPTストリームのEPHなし時のヘッダー境界認識

### p1_05 分析

- **特徴**: 15x15タイル(225), PCRL, 2 layers, 8 resolutions, cblksty=0x19
- **差分パターン**: ±1〜3 の散発的差分 (半数程度が不一致)
- **調査済み**:
  - パケットパイプライン: 225タイル全て `S1..S5=ok`
- **残る仮説**:
  - BYPASS (raw coding) パスの処理差
  - PTERM (predictable termination) の処理差
  - 非ゼロ原点 (x0=17, y0=12) との組み合わせ効果

### CAUSALフラグ使用ファイル比較

| Fixture | cblksty | 結果 |
|---------|---------|------|
| p1_02 | 0xa (RESET+CAUSAL) | fail |
| p1_05 | 0x19 (PTERM+BYPASS+CAUSAL) | fail |
| p1_06 | 0x28 (SEGSYM+CAUSAL) | pass |

→ CAUSAL単独は問題なし。RESET/BYPASS/PTERMとの組み合わせが問題。

### 次のステップ提案

1. **p1_02 (RESET+CAUSAL)**:
   - 単一レイヤーに制限してデコードし、累積差分を切り分け

2. **p1_05 (PTERM+BYPASS+CAUSAL)**:
   - BYPASSモードのraw bit読み取りロジックを確認
   - PTERMモードのMQターミネーション処理を確認

3. **共通**:
   - CAUSALを使用する成功/失敗ファイル間の処理フローを比較
