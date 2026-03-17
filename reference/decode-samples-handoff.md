# decode_samples 実装 引き継ぎ (2026-02-27)

注記 (2026-03-10):
- 現在の本流 API/CLI は `decode_samples` / `decode_samples_audit` と
  `decode-file` / `decode-file-dump` / `decode-file-audit` です。
- 本文中の `v2` 付き名称は移行前の記録として残っている箇所があります。

## 目的

`decode_samples` を、要求仕様にある以下の最低ラインまで到達させる。

- raw codestream (`.j2k/.j2c`) と JP2-wrapped payload をサポート
- core decode pipeline (Tier-2/Tier-1/inverse DWT/MCT) を正しく処理
- 決定的な sample-domain 出力を、メモリ/並び順契約付きで返す

## 現在地 (実装済み)

- 公開API:
  - `decode_samples(data : Bytes) -> Result[DecodeSamplesResult, String]`
- 入力:
  - raw codestream / JP2(`jp2c`) 抽出対応済み
- decode パス:
  - simple-profile (`csiz=1` 基本、`csiz>1 && mct in {0,1}` の staged bridge 含む、
    precinct は一般許容、COC/QCC/RGN override は component index が有効なら
    staged 許容)
  - in-band packet header と PPT/PPM relocated header の両方を単一経路で処理
  - SOP/EPH 除去前処理あり
  - non-zero codeword は Step1 事前ゲートあり
    - `COD transformation/qstyle`: `1/{0,1}` または `0/{0,2}`
    - `COD code-block-style subset of {TERMALL,RESET,SEGMARK}`
    - 上記以外は Tier1 未実装として明示停止
  - ゼロ再構成系ケースは deterministic に `Ok` を返す
- strict/compat 分離:
  - codestream strict 側で非規範 fallback を分離済み
- テスト:
  - `moon test` は pass (現時点)

## 未達 (本丸)

- Tier-1 実デコード (非ゼロ codeword)
- inverse DWT (5/3, 9/7)
- MCT (可逆/非可逆)
- multi-component (`csiz>1`) 実処理
- 量子化/逆量子化を含む一般ケースの再構成

## スコープ上の注意

- 現在は `csiz>1` を全面 reject せず、`COD multiple_component_transform in {0,1}`
  の staged bridge で処理する（component-0 path）。
- 「誤って成功」を避けるため、未実装領域は必ず明示エラーで止める方針。

## 仕様根拠

- 基本文書: `reference/T.800-2015.pdf` / `reference/T.800-2015.txt`
- **分割版仕様**: `reference/t800-2015/` (セクション別に分割済み、README.md に索引)
- 実装根拠メモ: `reference/decode_samples-spec-basis.md`
  - `DS-*` ID をコード分岐コメントと対応

## 推奨実装順と仕様リンク

| # | 実装項目 | 仕様セクション | ファイル | 正当性 |
|---|----------|----------------|----------|--------|
| 1 | **Tier-1 (最小可逆サブセット)** | D.1-D.3 | `t800-2015/annex_d_coefficient_bit_modelling.txt` | D.3.1 sigprop, D.3.3 magref, D.3.4 cleanup の3パスで係数ビットを復号 |
| 2 | **inverse DWT 5/3** | F.3 | `t800-2015/annex_f_dwt.txt` | F.3.1 IDWT procedure, F.3.6-F.3.7 で 5-3 フィルタ適用 |
| 3 | **quant/dequant 整備** | E.1 | `t800-2015/annex_e_quantization.txt` | E.1.2 reversible は Δb=1, E.1.1 irreversible は QCD/QCC から step size 算出 |
| 4 | **MCT 可逆 (RCT)** | G.2 | `t800-2015/annex_g_mct.txt` | G.2.2 Inverse RCT (YDbDr → RGB 相当) |
| 5 | **9/7 + 非可逆 MCT (ICT)** | F.3, G.3 | `annex_f_dwt.txt`, `annex_g_mct.txt` | F.3.7 1D_EXTR9-7, G.3.2 Inverse ICT |
| 6 | **multi-component 正式対応** | A.5, G.1 | `annex_a_codestream_syntax.txt`, `annex_g_mct.txt` | A.5.1 SIZ で Csiz 取得, G.1 DC level shift |

### 補助仕様リンク (decode pipeline 共通)

| 領域 | 仕様セクション | ファイル | 用途 |
|------|----------------|----------|------|
| **MQ decoder** | C.3 | `t800-2015/annex_c_arithmetic_coding.txt` | C.3.2 DECODE, C.3.3 RENORMD, C.3.4 BYTEIN, C.3.5 INITDEC |
| **Context table** | C.2.5, Table C.2 | 同上 | Qe/NMPS/NLPS/SWITCH 状態遷移 |
| **Packet structure** | B.9-B.10 | `t800-2015/annex_b_image_data_ordering.txt` | B.10.2 Tag trees, B.10.4 Code-block inclusion |
| **Codestream markers** | A.4-A.6 | `t800-2015/annex_a_codestream_syntax.txt` | A.5.1 SIZ, A.6.1 COD, A.6.4 QCD |
| **JP2 file format** | I.4-I.5 | `t800-2015/annex_i_jp2_format.txt` | I.5.3 Contiguous Codestream box (jp2c) |
| **ROI** | H.2 | `t800-2015/annex_h_roi.txt` | H.2 Max-shift method (RGN marker) |

## 受け入れ判定の大枠

- 既存 parser API 互換を崩さない
- corpus + 追加 fixture で再現性ある数値一致
- `decode_samples` の出力契約 (bytes order/layout) を README とテストで固定

## 2026-02-27 追加引き継ぎメモ (継続着手)

- 進捗観測用に CLI を追加:
  - `moon run cmd/main -- decode-file <path>`
  - 出力:
    - 成功: `ok: bits=... signed=... points=... bytes=...`
    - 失敗: `error: ...` (`decode_samples` のエラー文字列そのまま)
- corpus 一括評価スクリプトを追加:
  - `tools/decode_samples_corpus_cycle.sh`
  - `samples/corpus/*.j2k|*.j2c` を走査し、`ok_real_decode / ok_zero_recon / unsupported_profile / hard_fail` を集計
  - 2026-02-27 最新:
    - `total=27, ok_real_decode=21, ok_zero_recon=6, unsupported_profile=0, hard_fail=0`
- 方針:
  - 誤成功を避けるため、Tier-1 未実装のまま decode 成功範囲は広げない
  - まず上記スクリプトでベースラインを固定し、Tier-1 実装時に集計差分で進捗確認する
- simple-profile gate の追加制約:
  - `siz.tile_count` の単一制約は撤廃（multi-tile を staged で許可）
  - COC/QCC/RGN override は component index の妥当性を満たす場合に staged 許容
  - 目的: 未対応構成（特に component override）で zero 再構成に入る誤成功を防ぐ
- モジュール分割 (`internal/decoder`) と命名方針:
  - `jpeg2000_decode_samples_annex_i_input.mbt` → [Annex I](t800-2015/annex_i_jp2_format.txt) I.5.3 jp2c box 抽出
  - `jpeg2000_decode_samples_annex_a8_packet_parts.mbt` → [Annex A](t800-2015/annex_a_codestream_syntax.txt) A.8.1 SOP, A.8.2 EPH
  - `jpeg2000_decode_samples_annex_c_mq.mbt` → [Annex C](t800-2015/annex_c_arithmetic_coding.txt) C.3 MQ decoder
  - `jpeg2000_decode_samples_annex_d_pass.mbt` → [Annex D](t800-2015/annex_d_coefficient_bit_modelling.txt) D.3 coding passes
  - `jpeg2000_decode_samples_annex_e_dequant.mbt` → [Annex E](t800-2015/annex_e_quantization.txt) E.1 inverse quantization
  - `jpeg2000_decode_samples_annex_f_dwt.mbt` → [Annex F](t800-2015/annex_f_dwt.txt) F.3 IDWT
  - `jpeg2000_decode_samples_annex_g_mct.mbt` → [Annex G](t800-2015/annex_g_mct.txt) G.2 RCT, G.3 ICT
  - `jpeg2000_decode_samples_annex_b10_multi_layer.mbt` → [Annex B](t800-2015/annex_b_image_data_ordering.txt) B.8 Layers, B.10 packet header
  - `jpeg2000_decode_samples_ds_profile_api.mbt` (DS-* profile gate と decode orchestration)
- 共通化方針:
  - `decoder` が `core` 公開APIを消費する形に統一
  - 例: codestream parse は `@core.parse_codestream_bytes` を使用
- 直近の実装追加:
  - `DS-TIER1-REV-SUBSET-GATE` を追加
  - `non-zero codeword` で上記条件を満たさない場合、Tier-1本体に進まず明示エラー
  - `DS-TIER1-MQ-PENDING` を追加
    - reversible subset の `non-zero codeword` では Annex C bootstrap
      (`A=0x8000`, `C` seed) を算出し、MQ本体未実装として明示エラー
  - Annex C context state lifecycle を追加
    - reset/save/restore を decode 経路に配線
    - whitebox test で roundtrip を固定
  - one-decision probe を追加
    - bootstrap の `C` seed + context0 から 1bit 分岐を暫定算出
    - 現在は配線確認用であり、規範的 MQ decode ではない
  - `BYTEIN/RENORMD/DECODE` の最小1-decision配線を追加
    - INITDEC seed -> DECODE 1回 -> pending診断へ結果反映
    - Table C.2 (`Qe/NMPS/NLPS/SWITCH`) を one-decision 経路へ適用済み
    - multi-decision loop は pass同期の single-coeff 経路まで配線済み
  - multi-decision trace を追加
    - cleanup/sigprop/magref に同期した context 系列で DECODE を実行し trace 出力
    - pass統合（D.3系）は single-coeff 範囲で配線済み（一般 block は未実装）
  - staged pass-order trace を追加
    - `cleanup/sigprop/magref` の順序を trace して pending診断へ出力
    - 各pass本体（D.3.1/3.3/3.4）は未実装
  - staged pass-state accumulator を追加
    - pass trace + MQ decision bits から最小状態 (`sig/sign/mag`) を更新
    - 依然として Annex D pass 本体ロジックそのものではない
  - staged pass primitives を追加
    - 単一係数向け `cleanup/sigprop/magref` を個別関数として配線
    - 現在は staged 簡略ロジックで、規範完全実装ではない
  - pass本体の single-coeff 統合コアを追加
    - cleanup/sigprop/magref のループ本体を共通化
    - sigprop 近傍条件のみポリシー（staged/normative）で切替
    - whitebox でポリシー切替の状態差分を固定
  - single-coeff MQ context を追加分離
    - cleanup/sigprop の sign decision を専用 context family へ分離
    - pass同期 trace の context 列に反映
  - single-coeff normative preview を追加
    - sigprop の隣接有意係数条件を反映した preview state を併記
    - staged pass-state と並行表示して差分観測可能
  - 診断の主値を normative pass-state へ切替
    - staged pass-state は `legacy` として併記し、挙動差分を観測
  - single-coeff reconstructed value preview を追加
    - normative pass-state から係数値を算出し pending診断へ出力
  - `sample_count==1` での最小 end-to-end を追加
    - reversible minimal subset かつ単一サンプルの場合、`Ok(samples, ...)` を返却
  - `sample_count<=16` の small-row end-to-end を追加
    - staged preview samples を little-endian bytes で `Ok(samples, ...)` 返却
  - unsigned 出力契約を補強
    - preview 係数が負値でも unsigned の場合は `0` に clamp してから bytes 化
  - mini-block normative preview を追加
    - cleanup/sigprop/magref と近傍有意条件を `w*h<=16` 小ブロックへ拡張
    - SIZ 由来の component `width/height` が一致する場合、small-row `Ok(samples, ...)` に優先反映
  - mini-block MQ context 選択を細分化
    - cleanup/sigprop の有意化判定を近傍カテゴリ（none/few/many）別 context family へ分離
    - sign decision は近傍符号パターン（pos-dominant / neg-dominant / mixed-or-none）別 context family へ分離
    - 近傍符号パターンは重み付き集約（水平/垂直を斜めより強く）で判定
    - 重みプロファイルは pass 種別で分離（cleanup と sigprop で別テーブル）
    - context 選択しきい値も pass 種別で分離（同一 score でも cleanup/sigprop で異なる context を選択可能）
    - しきい値は近傍有意数に応じて可変（近傍密度が高いほど mixed を選びやすい）
    - sign context 選択は 2軸テーブル化（近傍密度バケット × 符号偏りバケット）
    - significance context 選択も 2軸テーブル化（近傍密度バケット × 符号偏りバケット）
    - small-row (`sample_count<=16`) は single-coeff trace ではなく mini-block trace を優先利用
  - Tier-2 first-packet 抽出の仕様寄せ
    - in-band packet-header fallback は `SIZ/COD` から導出した shape 候補のみを使用
    - 広域 brute-force fallback は採用しない
    - `p0_12.j2k` の tier2 pending を解消（現在は tier1 gate へ到達）
    - in-band packet-header decode は `code_block_style` を core API に渡す
      形へ変更（TERMALL の segment split 解釈を含む）
    - 先頭1パケット専用 API
      `@core.parse_packet_header_first_packet_with_code_blocks_and_style`
      を追加し、シリーズ解析が packet body を次ヘッダ誤読する経路を遮断
      （`p0_07.j2k` pending 解消）
  - code-block-style 取り扱いの段階整理
    - `style=4` (TERMALL) は packet-header segment split を保持した staged path に接続
    - staged preview は full component grid まで拡張（`sample_count<=16` 制限を解除）
    - staged preview `Ok(...)` を style `0/4` で許可
  - `p0_12.j2k` / `a1_mono.j2c` / `p0_01.j2k` は `ok` へ改善
  - Tier-1 staged subset の拡張
    - `transformation=1, qstyle=0` に加え、`transformation=0, qstyle=2` を staged bridge として許可
    - `p0_09.j2k` は `ok` へ改善
  - `decode-file-audit` の code-block 監査を拡張
    - `recon-audit:cblk-meta` を追加
    - 各 code-block ごとに `qstyle / roi / kmax / zbp / bpno_plus_one / passes / cb dims`
      を出力
      と付き合わせやすくした
  - 2026-03-06 比較メモ
      は「全崩れ」ではなく少数の `±1` 差まで縮小している
    - 一方 `p0_06 / p1_02 / p1_05 / p0_08` は依然として本質的な差が残る
    - `p0_06` の ROI は `opj_dump` main-header 表示の `roishift=11` だけでは不十分
      - 実 codestream には tile-part header にも `RGN` (`FF5E 0005 000009`) があり、
        MoonBit audit の `roi=9` は tile override を拾った結果
      - したがって `p0_06` の本件は「ROI を 11 と誤読している」問題ではない
        (`opj_dump` が tile-part override を表示していないだけ)
      - pass 復号では `one|half` / `poshalf` を ROI 有無に関係なく積み、
        その後で ROI descaling、最後に `0.5 * band->stepsize` を掛ける
      - MoonBit 側も `decode_single_codeblock_coefficients()` で
        `roishift>0` 時の midpoint suppression を撤去
      - ただし `shift==0` で ROI code-block に 0.5 LSB を再注入すると
        `p0_06` が `mismatch=65025/66177 max_abs_diff=574` の
        「広域な正オフセット」へ崩れるため、この分岐は `roishift==0` に戻した
      - 現在値は再び `mismatch=44790/66177 max_abs_diff=804`
        - 次の疑いは ROI parse ではなく、lossy dequant / 9-7 前後の
          量子化丸め整合
      `bpno_plus_one <= cblk->numbps - 4`
      であり `roishift` を含まないことを確認
      - MoonBit 側の `mq/annex_c_mq.mbt` でも RAW onset を
        `initial_bpno_plus_one - roishift - 4` に修正
    - `internal/decoder/roi/annex_h_roi.mbt` は tile-part `RGN` の component index を
      `Csiz` 依存の 1/2 byte 幅で読むように修正
      - `Csiz >= 257` で `payload[0]` / `payload[2]` を直読む実装だと誤る
      そのまま差し替える実験は失敗
      - `p1_03 / p0_06` が大きく崩れたため、既存 path に戻した
      - helper の値スケールと現行 dequant 契約が一致していない可能性が高い
    - `p0_06` は DWT/dequant より前、ROI descale 後 code-block 係数の段階で
      - `decode-file-audit` に `recon-audit:cblk-values` を追加し、
        MoonBit 側の code-block 係数 preview を出せるようにした
        ROI descale 直後 / dequant 前の code-block 係数を
        `opj-t1-postroi:...` で stderr に出せるようにした
      - `p0_06` component 0 での直接比較では、
        `r=0 sb=0`, `r=2 sb=1/2/3`, `r=3 sb=1/2/3`, `r=4 sb=1/2`
        に `±1` 差が多発している
        - 例: `(r=2,sb=1)` の first[12..15] は MoonBit `[-8,-6,0,-16]` /
      - したがって現時点の本丸は lossy dequant / 9-7 丸めではなく、
        `decode_single_codeblock_coefficients()` が作る
        shift==0 ROI code-block の parity/half-step 整合
      - ただし
        shift==0 だけへ限定して流用する実験も失敗
        - `p0_05` まで `99%` mismatch に崩れたため戻した
      - さらに `roishift>0` の code-block にだけ helper を直接当てる
        実験も失敗
        - `p0_06` が `mismatch=65692/66177 max_abs_diff=1024` まで悪化
        - `p0_05 / p1_03` は無傷なので ROI 限定条件自体は効いているが、
          helper と現在の `norm_decisions` 契約が一致していない可能性が高い
      - ただし helper の `bpno` を `initial_bpno_plus_one - 1` にずらすと
        - `recon-audit:cblk-helper-postroi-bpminus1` を追加して確認
        - `r=0 sb=0` の first は
          `[46,88,36,-22,10,-6,-4,20,17,...]`
        - `r=2 sb=1` でも `[-10,0,0,0,-12,-2,6,0,...,-9,-7,0,-17,...]`
          となり、MoonBit 現行値の欠けていた `±1` を埋める
      - この `bpminus1` helper を `roishift>0 && qstyle!=0` の code-block にだけ
        decode 本体へ適用すると `p0_06` は大きく改善
        - `mismatch=44790/66177 max_abs_diff=804`
          → `mismatch=39/66177 max_abs_diff=1`
        - `p0_05 / p1_03` は引き続き
          `mismatch=56/1048576 max_abs_diff=1`
      - 現在の残差は「全体崩れ」ではなく散発的な `+1` 差だけなので、
        ROI parity の主問題はほぼ解消したと見てよい
      - その後、残差 39 個の切り分けとして raw float 監査を追加
        - MoonBit 側:
          `recon-audit:dwt-pre-deq-float`,
          `recon-audit:dwt-post-float`,
          `recon-audit:final-float`
          `OPJ_TRACE_FINAL_FLOAT=1` による `opj-final-float`
      - `p0_06` では最初の不一致点 `idx=123 (x=123,y=0)` で
        final-float が既にずれていた
        - MoonBit `1917.500732421875`
        - したがって残差は最終 `lrintf` / clamp ではなく、その前の DWT
      - `recon-audit:dwt-pre-deq-float` と `opj-dwt-pre` の比較では、
        - つまり dequantization ではなく 9/7 IDWT が差分源
      - `internal/decoder/dwt/annex_f_dwt.mbt` の `idwt_97_1d()` で、
        lifting `step2` が
        `sum -> to_f32 -> mul -> to_f32 -> add -> to_f32`
        - `delta = to_f32((wavelet[fl] + wavelet[fw]) * c)` へ変更し、
          pair-sum の個別 `to_f32()` を削除
        - edge case も `to_f32(c + c)` を使う形へ整理
      - この変更で fixture 比較はさらに改善
        - `p0_06`: `39/66177` → `34/66177`
        - `p0_05`: `56/1048576` → `53/1048576`
        - `p1_03`: `56/1048576` → `53/1048576`
      - さらに `idwt97_alpha/beta/gamma/delta/k/two_invk` を
        `@math.round_to_f32(...)` で float32 定数化し、
        - これで 9/7 IDWT の全体的な正オフセットがもう一段減少
      - 現在値
        - `p0_06`: `14/66177 max_abs_diff=1`
        - `p0_05`: `22/1048576 max_abs_diff=1`
        - `p1_03`: `22/1048576 max_abs_diff=1`
      - 残差はまだ `max_abs_diff=1` だが、符号が `+1` だけでなく `-1` も混ざる
        - したがって「ROI parity 問題」はほぼ片付き、
          以後は 9/7 IDWT の残る scalar/edge 演算順序を詰める段階
          `OPJ_TRACE_DWT_HORIZ=1` と `OPJ_TRACE_DWT_LEVELS=1` を追加し、
          full-tile 9/7 decode の各 level について
          `opj-dwt-horiz:` / `opj-dwt-level-post:` を出せるようにした
        - これで `opj_dwt_decode_tile_97()` の level ごとの
          horizontal 後 / vertical 後を直接比較可能になった
        - さらに `OPJ_TRACE_DWT_HEX=1` を追加し、
          同じ trace を `%a` の hex-float でも出せるようにした
          - decimal `%.9g` は float32 識別には十分だが、
            ULP 単位の付き合わせでは hex-float のほうが扱いやすい
      - `p0_06` component 0 の追加切り分け結果
          (`opj_dwt_decode_tile_97()` の full-tile setup) なので、
          MoonBit 側の dense row/col 適用方針そのものは本丸ではない
          突き合わせると、
          `level=0` は horizontal 後も vertical 後も実質一致
          - horizontal max diff: `0.0003671875`
          - level-post max diff: `0.0004909766`
        - 最初の本格 drift は `level=1`
            `level=1` horizontal はしきい値 `5e-4` では不一致 0
          - 一方 `level=1` post では 2 点が残る
            - `(x=13,y=7)` 付近で `-0.0006106`
            - `(x=3,y=8)` 付近で `+0.0005336`
          - したがって今の本丸は
            `idwt_97_2d_single_level()` の row pass ではなく、
            `level=1` 以降の vertical 側の丸め整合
        - 参考として、vertical だけ pair-sum を先に `to_f32()` する
          実験も行ったが fixture 全体では悪化したため不採用
          - `p0_06`: `14/66177` → `20/66177`
          - `p0_05 / p1_03`: `22/1048576` → `25/1048576`
          - したがって「vertical だけ pair-sum 丸め」は局所的には近く見えても
            全体解ではない
      - MoonBit 側にも level trace を追加
        - `internal/decoder/dwt/annex_f_dwt.mbt` に
          `recon-audit:dwt-level-horiz-float` /
          `recon-audit:dwt-level-post-float`
          を追加し、`decode-file-audit` から level 単位の
          row pass / level post を採取可能にした
        - `annex_b10_layer.mbt` の float IDWT 呼び出しから
          `packet_audit` 情報を DWT package へ渡すようにした
        - `OPJ_TRACE_DWT_HEX=1` の `opj-dwt-horiz` / `opj-dwt-level-post`
          はこの build では `%a` hex-float として出る
          - raw `0x%08x` 化も試したが、実行ログは依然 `%a` 形式だったので
            parser 側で `float.fromhex()` を使う前提にした
          float32 bit pattern に落として比べると、
          `level=0` の時点で既に多くのサンプルに少数 ULP 差がある
          - 例: `level=0 horiz (x=7,y=0)` は MoonBit `0x40905b00` /
          - 例: `level=0 post (x=15,y=0)` は MoonBit `0x428dcef9` /
        - ただし pixel mismatch を生む主増幅点はやはり `level=1 post`
          - 例: `(x=14,y=0)` は MoonBit `0x41ec6b12` /
          - 例: `(x=13,y=0)` は MoonBit `0x43f1bfaf` /
        - つまり `level=0` は「完全一致」ではなく
          「最終画素へはまだ効かない微小 ULP 差」で、
          その差が `level=1` 以降の vertical 側で閾値越えへ増幅されている
      - MoonBit 側にも raw float32 bit trace を追加
        - `internal/decoder/dwt/annex_f_dwt.mbt` に
          `recon-audit:dwt-level-horiz-f32bits` /
          `recon-audit:dwt-level-post-f32bits`
          を追加し、`Float::from_double(...).reinterpret_as_uint()`
        - `decode-file-audit samples/corpus/p0_06.j2k` の component 0 preview 比較では
          mismatch 件数が以下
          - `level=0 horiz`: `42 / 85`
          - `level=0 post`: `70 / 85`
          - `level=1 horiz`: `179 / 297`
          - `level=1 post`: `255 / 297`
        - 代表例
          - `level=0 horiz (x=1,y=0)`:
          - `level=0 post (x=7,y=0)`:
          - `level=1 horiz (x=13,y=0)`:
          - `level=1 post (x=14,y=0)`:
        - したがって `%a` / decimal parser の誤差ではなく、
          MoonBit 側 9/7 core 自体が `level=0` から既に raw-bit 不一致
      - dequant 後入力の raw-bit も確認した
        - MoonBit 側に `recon-audit:dwt-pre-deq-f32bits` を追加し、
          `OPJ_TRACE_DWT_HEX=1` で `0xXXXXXXXX` 出力できるようにした
        - `p0_06` component 0 の preview 16384 samples では
          `recon-audit:dwt-pre-deq-f32bits` と `opj-dwt-pre`
          が `0 mismatch` で完全一致
        - したがって DWT 入力の dequantized coefficients は
        - `idwt_97_1d()` 入口で low/high を追加で `to_f32()` する
          実験も行ったが fixture 差分は不変だったので戻した
      - 1D 9/7 の stage trace も追加した
        - MoonBit 側は `recon-audit:dwt-1d-stage-f32bits`
          (`scale / delta / gamma / beta / alpha`) を
          `level=0..1` の先頭 row/col vector に対して出すようにした
          `opj-dwt-1d-stage:` を出せるようにした
      - `p0_06` component 0 の stage 比較で、初発点はさらに絞れた
        - `level=0 horizontal scale` は `0 / 85` で完全一致
        - 最初の不一致は `level=0 horizontal delta` で発生
          - total `10 / 85`
          - row0 (`vec=0`) では index `6` と `12` が最初の差
        - `level=0 vertical scale` の不一致 (`38 / 80`) は
          その前段の horizontal alpha 差を引き継いだもの
        - よって現時点の本丸は
          `idwt_97_1d()` の scale ではなく、
          最初の `step2(-delta)` の整合
      - `delta` 限定で pair-sum を先に `to_f32()` する実験も実施
        - `p0_06` は `14/66177` → `13/66177` と 1 個だけ改善したが、
          `p0_05 / p1_03` は `22/1048576` → `23/1048576` に悪化
        - stage trace 上も `level=0 horizontal delta` は
          total `10 / 85` → `9 / 85` に減る一方、
          後段 stage や vertical 側では必ずしも良化しなかった
        - そのためこの変更は戻し、
          現在の baseline は維持している
      - `delta` を fused-style
        (`to_f32(old + to_f32(pair_sum) * c)` へ寄せる) 実験も実施
        - stage trace では `level=0 horizontal delta` が
          `0 mismatch` まで一致した
        - ただし最終出力は `p0_06: 14/66177 → 17/66177` と悪化したため戻した
          `delta` stage 単体の局所式だけではなく、
          後段 `gamma/beta/alpha` との連鎖も含めた更新順にある
      - 追加の失敗実験
        - `idwt_97_1d()` を `Float` 演算ベースへ寄せる
          (`Array[Float]` で更新し最後だけ `Double` 化)
          実験も行ったが fixture 全体では悪化したため不採用
          - `p0_06`: `14/66177` → `20/66177`
          - `p0_05 / p1_03`: `22/1048576` → `23/1048576`
        - つまり「MoonBit の `Float` 型へ直接寄せる」だけでは
          現在の best は引き続き
          `Double + 要所 to_f32` の版
        - `p0_06` row0 / `level=0 horizontal delta` の代表差
        - scale-stage 入力を使った最小再現では
          通常の float32 計算
          `out = round_f32(target + round_f32(pair * c))`
          は MoonBit 側 bit に一致し、
        - したがって MoonBit 側 `idwt_97_1d()` の `step2` を
          「`pair_sum` は f32 に揃えるが、`target + pair_sum * c` は
          最終 store まで 1 回で丸める」形へ修正した
          - helper:
            `step2_contract_update(prev, left, right, c)`
            `step2_contract_edge_update(prev, left, c)`
      - この修正で 9/7 の `±1` 残差は解消した
          - `p0_06.j2k = 0 / 66177`
          - `p0_05.j2k = 0 / 1048576`
          - `p1_03.j2k = 0 / 1048576`
          - `p0_04.j2k = 0 / 307200`
          - `p1_04.j2k = 0 / 1048576`
        - `internal/decoder/dwt/annex_f_dwt.mbt` には
      - ただし別系統の大きい mismatch はまだ残る
        - `p1_02.j2k = 294785 / 307200 (95.96%) max_abs_diff=189`
        - `p1_05.j2k = 148359 / 262144 (56.59%) max_abs_diff=90`
        - `p0_08.j2k = 1241832 / 1575936 (78.80%) max_abs_diff=17`
        - これらは今回の 9/7 `step2` 差では説明できないので、
          次は別経路として切るべき
      - `p0_08` の追跡を更新
        - `decode-file-audit` の `recon-audit:dwt-pre` と
          差は `HL3` 開始位置そのものではなく、
          `r=3 sb=1 cbx=0 cby=0` の code-block 値に既に存在する
          - MoonBit first[8]:
            `[11, 119, 139, 3, -13, 43, 67, -11]`
            `[11, 119, 141, 0, -9, 45, 71, -13]`
        - つまり `subband_origin` や `gx/gy` 配置は主因ではなく、
          reversible Tier-1 / segment handling 側の差
        - ここで一度
          「non-TERMALL multi-segment も segment start ごとに
          MQ re-init を掛ける」
          実験をしたが、
          `segment_lengths` / `segment_passes` は
          packet contribution 列なのでそのまま使うと壊れる
          - `p0_08`: `1241832 / 1575936` → `1575128 / 1575936`
          - `p1_02`: `294785 / 307200` → `297075 / 307200`
          decoder が再初期化するのは packet contribution ごとではなく
          final segment ごとで、
          既存 segment に後続 packet が積み増した `newlen` は
          decode 前に segment 単位で連結される
        - したがって次に直すべき点は
          `all_segment_lengths` / `per_segment_passes` の意味づけで、
          packet contribution 列から final segment 列へ
          畳み直した上で MQ re-init を合わせる必要がある
        - 追加で `qstyle=0` helper の raw 値も監査した
          - MoonBit
            `recon-audit:cblk-helper-reversible-raw`
            first[8]:
            `[46, 478, 558, 14, -54, 174, 270, -46]`
            `opj-t1-postroi`
            first[8]:
            `[23, 239, 283, 0, -19, 91, 143, -27]`
          - これは単純な `2x` や `4x` の正規化ずれではなく、
            helper 自体の pass replay が
        - したがって `p0_08` の本丸は
          `qstyle=0` helper の normalization ではなく、
          reversible Tier-1 reconstruction / decision replay そのもの
    - 2026-03-06: reversible helper のスケール仮説を追加で切った
        reversible 呼び出しを `initial_bpno_plus_one - 1`、
        normalization を `/2` に寄せても
        最終 decode 出力は baseline と不変
        - `p0_08 = 1241832 / 1575936 max_abs_diff=17`
        - `p1_02 = 294785 / 307200 max_abs_diff=189`
        - `p1_05 = 148359 / 262144 max_abs_diff=90`
        - `p1_03 / p0_06 / p0_05 / p0_04 / p1_04 = 0 mismatch`
      - この組み合わせだと
        `recon-audit:cblk-helper-reversible-raw`
        (`p0_08`, `c=0 r=3 sb=1 cbx=0 cby=0`)
        first[8] は
        `[23, 239, 279, 7, -27, 87, 135, -23]`
        `[23, 239, 283, 0, -19, 91, 143, -27]`
        と同じスケールには乗る
      - それでも差分は `[-4, +7, -8, -4, -8, +4]` 系で残るので、
        本丸は bit-plane 起点や最終 divide ではなく、
        helper 内の cleanup / sigprop / magref 更新列そのもの
      - あわせて `sigprop_member` を cleanup 後に clear する
        PI lifetime 修正も入れたが、
        少なくとも現行 corpus では比較値は変わらなかった
      - `p0_08` の target code-block (`c=0 r=3 sb=1 cbx=0 cby=0`) は
        `opj_dump` / `recon-audit:cblk-meta` で `cblksty=0`
        - CAUSAL/VSC ではない
        - BYPASS でもない
        - `pkt-audit:cb` を追うと packet contribution は
          14 本あるが、style=0 なので final segment は 1 本に畳まれる
      - したがって `p0_08` に関しては
        MQ re-init や segment boundary の食い違いは主因ではなく、
        純粋に reversible Tier-1 helper の update semantics を追うべき
      - MoonBit
        `recon-audit:cblk-segs`
        (`c=0 r=3 sb=1 cbx=0 cby=0`) は
        `final_lens=[2094] final_passes=[31]`
        `OPJ_TRACE_T1_SEGS=1` の
        `opj-t1-segs:band=1 cbx=0 cby=0 numbps=11 ... segs=[2094/31]`
        と一致
      - したがって `p0_08` の segment reassembly / `real_num_segs`
    - 2026-03-06: pass 単位 trace の初発点
      - MoonBit 側に
        `recon-audit:cblk-helper-pass-N`
        を target cblk 限定で追加
        `OPJ_TRACE_T1_PASSES=1` の
        `opj-t1-pass:...`
        を追加
      - target:
        `p0_08`, `c=0 r=3 sb=1 cbx=0 cby=0`
      - `pass=0..2` は双方とも first[64] がすべて 0
      - 最初の不一致は `pass=3`
        - MoonBit
          `recon-audit:cblk-helper-pass-3`
          first[64] はまだ全 0
          `opj-t1-pass:band=1 cbx=0 cby=0 pass=3`
          first[64] には
          `... 3072 ... 3072 ... -3072,-3072,3072 ...`
          が既に立つ
      - つまり差の初発点は
        reversible update formula の後段ではなく、
        cleanup pass (`pass=3`, bp11) 時点の decision stream /
        cleanup run-length handling 側
    - 2026-03-06: 上記 `pass=3` 仮説は scale 不一致による誤認
      - `recon-audit:cblk-helper-pass-N` は当初 reversible path でも
        helper 生値のまま出しており、
      - `decode_api.mbt` 側で
        reversible (`qstyle=0`) の `cblk-helper-pass-N` を
        `/2` 正規化してから出すよう修正
      - target:
        `p0_08`, `c=0 r=3 sb=1 cbx=0 cby=0`
      - 正規化後に `OPJ_TRACE_T1_SEGS=1 OPJ_TRACE_T1_PASSES=1`
        と再比較すると
        `pass=0..22` は first[64] が一致
      - 最初の不一致は `pass=23`
        (`next_passtype=2`, `bpno_plus_one=3`, magref pass)
        - MoonBit first 差分例:
          idx2=`276`, idx4=`-28`, idx5=`84`, idx6=`132`
          idx2=`284`, idx4=`-20`, idx5=`92`, idx6=`140`
      - したがって現時点の本丸は
        cleanup/run-length ではなく、
        `pass=23` より前に累積した reversible helper /
        decision replay の cursor ずれ、
        もしくは低 bit-plane magref 周辺の eligibility 整合
    - 2026-03-06: helper replay ではなく actual MQ path を trace
      - MoonBit 側 `tier1_annex_c_decode_mini_block_passes()` に
        `trace_target_pass` / `trace_max_events` を追加し、
        actual decoder の magref pass state を
        `recon-audit:mq-pass-state` で出せるようにした
        `a/c/ct` と `qeval/mps` の before/after を出すよう拡張
      - target:
        `p0_08`, `c=0 r=3 sb=1 cbx=0 cby=0`, `pass=23`
      - これで分かったこと:
        helper の `cblk-helper-pass-event` は actual decoder と一致しない
        (`p0_08` では hidden run-length / SEGMARK 消費があるため、
        helper replay の cursor では actual MQ ordinal に揃わない)
      - ただしこの時点の rerun は fresh context ではなく、
        一度 decode 済みの `contexts0` を再利用していた
      - そのため、ここで見えていた
        `ctx=16 qeval=1` への崩れは audit rerun の artifact だった
    - 2026-03-06: target idx `0` の actual timeline を追加
      - fresh context で rerun し直すと、
        - MoonBit:
          `x=0 rl_bit=0 a_before=32768 c_before=1890713600 ct_before=1 qeval_before=2753`
          `x=0 agg=0 a_before=32768 c_before=1890713600 ct_before=1 qeval_before=2753`
      - したがって `pass=0` cleanup/run-length の first decision は本丸ではない
      - fresh rerun の `idx=0` timeline では、
        MoonBit は `pass=19 stage=sigprop-sig` で初めて significant になる
        `first[0]` は `pass=15` まで `0`、`pass=16` で `96`
        significant 化している
      - さらに `pass=23` magref の先頭 state も
        context class は揃ってきていて、
        MoonBit `ord=0 ctx=15 first_magref=true qeval_before=21505`
        まで戻っている
      - 現時点の本丸は
        cleanup AGG seed や pass23 magref state ではなく、
        `pass=16..19` で `idx=0` を sigprop-eligible にする前段、
        すなわち近傍係数の significant 化タイミングか
        sigprop eligibility の actual path
    - 2026-03-06: target cblk 限定 trace で上記 `pass=16` 仮説を修正
        `OPJ_TRACE_T1_PASSES_TARGET=1` を追加し、
        target:
        `band=1 cbx=0 cby=0 numbps=11 seg[0]=2094/31`
        のみ `opj-t1-pass-target:` を出すようにした
      - MoonBit 側 `tier1_annex_c_decode_mini_block_passes()` には
        `idx=0/right/down/diag` の timeline と
        `sigprop-snapshot/check` を追加
      - target cblk の actual/target trace 結果:
        - `diag (idx=33)` は `pass=9 cleanup-rl-sig`
        - `right (idx=1)` は `pass=10 sigprop-sig`
        - `idx=0` と `down (idx=32)` は
          どちらも `pass=19 sigprop-sig`
      - つまり `idx=0` の significant 化タイミングは
        前回の `pass=16` 見立ては
        非 target `opj-t1-pass` 混線だった
      - `recon-audit:cblk-helper-pass-N` と
        `opj-t1-pass-target` を比較すると、
        `pass=19..22` は first[64] が完全一致
      - 最初の不一致はやはり `pass=23` で、
        `helper pass-23` vs `opj-t1-pass-target pass=23`
        は 35 箇所ずれる
      - event-level では
        最初の bit 差は `ord=4 (x=1 y=1 idx=33)`:
        - MoonBit actual `mq-pass-state`: `ctx=16 bit=0`
      - さらに `ord=0` の時点で
        `a_before=53252, ct_before=6, qeval_before=21505` は揃う一方、
        `c_before` は
        と既にずれている
      - したがって本丸は sigprop timing ではなく、
        `pass=23` 開始前までに蓄積した MQ coder state evolution
        (`C` register / renorm / bytein 周辺) の整合
    - 2026-03-06: target cblk の pass-begin state を追加
      - MoonBit 側 `tier1_annex_c_decode_mini_block_passes()` に
        `recon-audit:mq-pass-begin`
        `OPJ_TRACE_T1_PASS_BEGIN_TARGET=1` /
        `opj-t1-pass-begin-target`
      - target:
        `p0_08`, `c=0 r=3 sb=1 cbx=0 cby=0`
      - `a/c/ct` 比較結果:
        - `pass=19..22` の開始 state は `a/c/ct` が一致
        - 初めて開始 state が割れるのは `pass=23`
          - MoonBit: `a=53252 c=1491598336 ct=6`
      - したがって MQ state drift は `pass=23` の magref 中ではなく、
        直前の `pass=22` sigprop のどこかで導入される
      - 次に追うべきは `pass=22` sigprop の event-level state
        (`sigpass` の renorm / bytein / context evolution)
    - 2026-03-06: `pass=22` drift の根因は MQ 演算ではなく
      packet header trailing stuffed byte だった
      - target cblk の packet contribution trace を追加して
        `r=3 sb=1 cbx=0 cby=0` の codeword 連結元を確認した
      - `contrib_lens=[9, 7, 30, 102, 118, 47, 159, 101, 187, 120, 145, 244, 253, 259, 253, 60]`
        の 14 本目 (`accum_before=1522`, packet idx `117`) 先頭は
        当初 `00 FF 92 23 ...` だった
      - `FF 92` は EPH marker なので、
        MoonBit が `0` を読んでいた理由は
        MQ `BYTEIN` ではなく packet body 開始位置のずれ
      - 原因は `pkt_body_start_offset()` が、
        packet header が `... FF` で終わった直後の
        trailing stuffed byte `00` を body 側へ残していたこと
      - 修正:
        `internal/decoder/packet/packet_bits.mbt`
        `pkt_body_start_offset()` で
        `byte_idx - 1 == 0xFF` の trailing stuffed byte を追加で skip
      - 修正後の target packet trace:
        - packet idx `117` target contribution 先頭は `23 5F 51 35 ...`
        - `recon-audit:cblk-bytes` も
          `1519=199 1520=255 1521=26 1522=35 1523=95 1524=81`
        - `recon-audit:mq-pass-state pass=22 ord=332` は
      - 比較結果:
        - `p0_08 = 0/1575936 max_abs_diff=0`
        - `p0_04 / p1_04 / p0_05 / p0_06 / p1_03` も引き続き `0 mismatch`
        - `p1_02 = 294785/307200 max_abs_diff=189`
        - `p1_05 = 148359/262144 max_abs_diff=90`
