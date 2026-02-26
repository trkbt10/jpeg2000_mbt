# JPEG2000 T.800 要求IDチェックリスト

本ファイルは要求IDの管理台帳。初期状態ではテンプレートのみを定義し、要求抽出フェーズで逐次追加する。

## ステータス定義

- `Planned`: 要件定義済み、未着手
- `InProgress`: 分析/実装中
- `Implemented`: 実装完了（未検証）
- `Verified`: 検証完了
- `N-A`: 非適用（理由必須）

## 台帳

| ReqID | Source | Category | Priority | Requirement | Status | TestLink | Owner | Notes |
|---|---|---|---|---|---|---|---|---|
| R-0001 | 1 Scope | Validation | Must | ライブラリは lossless と lossy の両圧縮方式を対象範囲に含めること | Planned | TBD | TBD | bi-level/greyscale/palletized/colour を対象 |
| R-0002 | 1 Scope | Decoder | Must | デコード過程（compressed image data -> reconstructed image data）を提供すること | Planned | TBD | TBD | 公開API要件 |
| R-0003 | 1 Scope | Validation | Must | codestream syntax の解釈に必要な情報を扱えること | Planned | TBD | TBD | Annex Aとの接続要件 |
| R-0004 | 1 Scope | Container | Should | file format（JP2）を処理できること | Planned | TBD | TBD | Annex Iで必須化される項目と連携 |
| R-0005 | 2 References | Reference | Must | 外部参照規格の依存関係を管理文書上で追跡可能にすること | Planned | TBD | TBD | 実装時に参照先の適用有無を明示 |
| R-0006 | 3 Definitions | Validation | Must | 用語定義を実装仕様語彙へマッピングし、曖昧さなく運用すること | Planned | TBD | TBD | glossary運用要件 |
| R-0007 | 3 Definitions | Validation | Must | floor/ceiling/mod の数式意味を実装規約で固定すること | Planned | TBD | TBD | 係数処理の境界条件に影響 |
| R-0008 | 3 Definitions | Decoder | Must | 5-3 reversible filter の語義を可逆経路仕様として固定すること | Planned | TBD | TBD | Annex F実装の前提 |
| R-0009 | 3 Definitions | Decoder | Must | 9-7 irreversible filter の語義を非可逆経路仕様として固定すること | Planned | TBD | TBD | Annex F実装の前提 |
| R-0010 | 4.1 Abbreviations | Validation | Must | 略語表を内部ドキュメント/コードコメントで一貫して使用すること | Planned | TBD | TBD | LRCP/RLCPなど進行順序語を含む |
| R-0011 | 4.2 Symbols | Validation | Must | 記号表（マーカー記号・パラメータ記号）を実装仕様に対応付けること | Planned | TBD | TBD | SIZ/COD/QCDなど |
| R-0012 | 5 General description | Validation | Must | 空間・変換・圧縮の3ドメイン分離を設計上明確化すること | Planned | TBD | TBD | アーキテクチャ要件 |
| R-0013 | 5.3 Coding principles | Decoder | Must | tiling, DWT, quantization, entropy coding, packet/layer 構造を段階実装対象として管理すること | Planned | TBD | TBD | Annex A-Hへ分解される上位要件 |
| R-0014 | 6 Encoder requirements | Encoder | Must | エンコーダは Annex A に適合する codestream を生成すること | Planned | TBD | TBD | conformance中核要件 |
| R-0015 | 6 Encoder requirements | Encoder | Must | エンコード記述が informative であることを前提に、出力適合性で検証すること | Planned | TBD | TBD | 手続一致より出力適合を優先 |
| R-0016 | 7 Decoder requirements | Decoder | Must | デコード過程（Annex A-H）を normative 要件として扱うこと | Planned | TBD | TBD | decoder conformance軸 |
| R-0017 | 7 Decoder requirements | Decoder | Must | デコーダは Annex A 適合 codestream の全体または部分復号を提供すること | Planned | TBD | TBD | 部分抽出復号を含む |
| R-0018 | 7.1 Codestream syntax requirements | Validation | Must | 任意の compressed image data は Annex A の syntax/code assignment に適合すること | Planned | TBD | TBD | 入力検証要件 |
| R-0019 | 7.2 Optional file format requirements | Container | Must | optional file format を使用する場合は Annex I の syntax/code assignment に適合すること | Planned | TBD | TBD | JP2適合性要件 |
| R-0020 | 8 Implementation requirements | Validation | Must | 特定実装技法を規範要件とせず、観測可能な入出力整合で適合性を判断すること | Planned | TBD | TBD | 実装自由度を維持 |
| R-0021 | Annex A.1 | Validation | Must | マーカー/マーカーセグメント/ヘッダの役割を区別して codestream 構文を解釈できること | Planned | TBD | TBD | 構文基盤要件 |
| R-0022 | Annex A.1.1 | Validation | Must | 6種類のマーカー種別（delimiting/fixed/functional/in-bit-stream/pointer/informational）を識別できること | Planned | TBD | TBD | 種別分類 |
| R-0023 | Annex A.1.2 | Validation | Must | 既存JPEG系規格と共有されるマーカー定義/予約範囲を尊重して解釈すること | Planned | TBD | TBD | 予約値衝突防止 |
| R-0024 | Annex A.1.3 | Validation | Must | マーカーセグメント長・出現位置・適用範囲に関する規則を検証できること | Planned | TBD | TBD | ヘッダ整合性 |
| R-0025 | Annex A.1.4 | Reference | Optional | グラフィカル記法は実装必須ではないが仕様読解規約として参照管理すること | Planned | TBD | TBD | informative |
| R-0026 | Annex A.2 | Validation | Must | マーカーセグメントのフィールド意味と制約を節定義どおりに扱うこと | Planned | TBD | TBD | パラメータ辞書 |
| R-0027 | Annex A.3 | Validation | Must | codestream 全体構成（main header/tile-part/data/EOC）を構築・解析できること | Planned | TBD | TBD | ストリーム骨格 |
| R-0028 | Annex A.4 | Validation | Must | delimiting markers の出現順序および関係制約を満たすこと | Planned | TBD | TBD | SOC/SOT/SOD/EOC |
| R-0029 | Annex A.4.1 (SOC) | Validation | Must | SOC を codestream 開始位置で正しく検出/生成すること | Planned | TBD | TBD | 開始マーカー |
| R-0030 | Annex A.4.2 (SOT) | Validation | Must | SOT の tile-part 情報（長さ・索引等）を正しく解釈/生成すること | Planned | TBD | TBD | tile-partヘッダ |
| R-0031 | Annex A.4.3 (SOD) | Validation | Must | SOD 以降を tile-part データ領域として扱いヘッダと分離できること | Planned | TBD | TBD | データ境界 |
| R-0032 | Annex A.4.4 (EOC) | Validation | Must | EOC を codestream 終端として検証/生成すること | Planned | TBD | TBD | 終端マーカー |
| R-0033 | Annex A.5 | Validation | Must | fixed information marker segments を画像基本情報として解釈すること | Planned | TBD | TBD | 固定情報群 |
| R-0034 | Annex A.5.1 (SIZ) | Validation | Must | SIZ の画像サイズ/タイルサイズ/コンポーネント情報を正しく扱うこと | Planned | TBD | TBD | 最重要必須項目 |
| R-0035 | Annex A.6 | Validation | Must | functional marker segments による符号化方式指定を処理できること | Planned | TBD | TBD | 機能情報群 |
| R-0036 | Annex A.6.1 (COD) | Validation | Must | COD の既定符号化スタイル（progression, decomposition等）を解釈/生成すること | Planned | TBD | TBD | 既定設定 |
| R-0037 | Annex A.6.2 (COC) | Validation | Must | COC によるコンポーネント別上書きを正しく適用すること | Planned | TBD | TBD | component override |
| R-0038 | Annex A.6.3 (RGN) | Validation | Must | RGN による ROI 関連パラメータを解釈/生成すること | Planned | TBD | TBD | ROI signaling |
| R-0039 | Annex A.6.4 (QCD) | Validation | Must | QCD の量子化既定値を解釈/生成すること | Planned | TBD | TBD | quant default |
| R-0040 | Annex A.6.5 (QCC) | Validation | Must | QCC のコンポーネント別量子化値上書きを適用すること | Planned | TBD | TBD | quant override |
| R-0041 | Annex A.6.6 (POC) | Validation | Must | POC による progression order change を正しく扱うこと | Planned | TBD | TBD | progression切替 |
| R-0042 | Annex A.7 | Validation | Must | pointer marker segments を位置情報として整合的に処理すること | Planned | TBD | TBD | 位置参照群 |
| R-0043 | Annex A.7.1 (TLM) | Validation | Must | TLM の tile-part 長情報を解釈/生成すること | Planned | TBD | TBD | 長さ索引 |
| R-0044 | Annex A.7.2 (PLM) | Validation | Must | PLM の packet length 情報（main header）を扱うこと | Planned | TBD | TBD | optional signaling |
| R-0045 | Annex A.7.3 (PLT) | Validation | Must | PLT の packet length 情報（tile-part header）を扱うこと | Planned | TBD | TBD | optional signaling |
| R-0046 | Annex A.7.4 (PPM) | Validation | Must | PPM の packed packet headers（main header）を扱うこと | Planned | TBD | TBD | header packing |
| R-0047 | Annex A.7.5 (PPT) | Validation | Must | PPT の packed packet headers（tile-part header）を扱うこと | Planned | TBD | TBD | header packing |
| R-0048 | Annex A.8 | Validation | Must | in-bit-stream markers をエラー耐性関連情報として処理できること | Planned | TBD | TBD | resilience |
| R-0049 | Annex A.8.1 (SOP) | Validation | Must | SOP を packet 開始境界情報として解釈/生成すること | Planned | TBD | TBD | packet boundary |
| R-0050 | Annex A.8.2 (EPH) | Validation | Must | EPH を packet header 終端情報として解釈/生成すること | Planned | TBD | TBD | packet header end |
| R-0051 | Annex A.9 | Validation | Must | informational marker segments を補助情報として扱うこと | Planned | TBD | TBD | 補助情報群 |
| R-0052 | Annex A.9.1 (CRG) | Validation | Must | CRG の component registration 情報を解釈/生成すること | Planned | TBD | TBD | component alignment |
| R-0053 | Annex A.9.2 (COM) | Validation | Must | COM コメントセグメントを保存可能に処理すること | Planned | TBD | TBD | コメント保持 |
| R-0054 | Annex A.10 | Validation | Must | 本規格に準拠する codestream 制約を検証できること | Planned | TBD | TBD | conformance restrictions |
| R-0055 | Annex A.10.1 | Reference | Optional | digital cinema applications 向け制約は対象プロファイルとして別管理すること | Planned | TBD | TBD | 適用時にMust化 |
| R-0056 | Annex B.1 | Validation | Must | 画像構造概念（component/tile/sub-band/precinct/code-block）の関係を一貫して扱うこと | Planned | TBD | TBD | 構造概念 |
| R-0057 | Annex B.2 | Validation | Must | component と reference grid の対応式を正しく実装すること | Planned | TBD | TBD | 幾何マッピング |
| R-0058 | Annex B.3 | Validation | Must | image area の tile/tile-component 分割規則を満たすこと | Planned | TBD | TBD | タイル分割 |
| R-0059 | Annex B.4 | Reference | Optional | 参照例（mapping example）は検証データとして管理すること | Planned | TBD | TBD | informative |
| R-0060 | Annex B.5 | Decoder | Must | transformed tile-component の resolution/sub-band 構造を正しく扱うこと | Planned | TBD | TBD | 変換構造 |
| R-0061 | Annex B.6 | Decoder | Must | precinct 分割規則を解釈/生成すること | Planned | TBD | TBD | precinct geometry |
| R-0062 | Annex B.7 | Decoder | Must | sub-band の code-block 分割規則を解釈/生成すること | Planned | TBD | TBD | code-block geometry |
| R-0063 | Annex B.8 | Decoder | Must | layer 構造と符号化データ対応を保持すること | Planned | TBD | TBD | layer管理 |
| R-0064 | Annex B.9 | Decoder | Must | packet を precinct/resolution/component/layer 単位で構成・復元すること | Planned | TBD | TBD | packet基本単位 |
| R-0065 | Annex B.10 | Decoder | Must | packet header 情報符号化規則を解釈/生成すること | Planned | TBD | TBD | header coding |
| R-0066 | Annex B.10.1 | Decoder | Must | packet header の bit-stuffing 規則を満たすこと | Planned | TBD | TBD | bitstream整合性 |
| R-0067 | Annex B.10.2 | Decoder | Must | tag tree 符号化/復号規則を満たすこと | Planned | TBD | TBD | inclusion/zero-plane |
| R-0068 | Annex B.10.3 | Decoder | Must | zero length packet の扱いを規定どおりに実装すること | Planned | TBD | TBD | 境界ケース |
| R-0069 | Annex B.10.4 | Decoder | Must | code-block inclusion 情報の符号化/復号を実装すること | Planned | TBD | TBD | inclusion signaling |
| R-0070 | Annex B.10.5 | Decoder | Must | zero bit-plane 情報の符号化/復号を実装すること | Planned | TBD | TBD | zerobitplane |
| R-0071 | Annex B.10.6 | Decoder | Must | coding passes 数情報の符号化/復号を実装すること | Planned | TBD | TBD | pass count |
| R-0072 | Annex B.10.7 | Decoder | Must | code-block ごとの compressed image data 長情報を解釈すること | Planned | TBD | TBD | segment length |
| R-0073 | Annex B.10.8 | Decoder | Must | packet header 内情報順序を規定どおり処理すること | Planned | TBD | TBD | order constraints |
| R-0074 | Annex B.11 | Decoder | Must | tile と tile-part の構成規則を満たすこと | Planned | TBD | TBD | tile-part organization |
| R-0075 | Annex B.12 | Decoder | Must | progression order の全体規則を解釈/生成すること | Planned | TBD | TBD | LRCP等 |
| R-0076 | Annex B.12.1 | Decoder | Must | progression order determination を規定式どおり決定すること | Planned | TBD | TBD | progression calc |
| R-0077 | Annex B.12.2 | Decoder | Must | progression order volumes の概念を正しく適用すること | Planned | TBD | TBD | progression scope |
| R-0078 | Annex B.12.3 | Decoder | Must | progression order change signaling を POC と整合して扱うこと | Planned | TBD | TBD | Annex A.6.6連携 |
| R-0079 | Annex C.1 | Reference | Optional | 二値符号化の説明節は実装補助情報として管理すること | Planned | TBD | TBD | informative |
| R-0080 | Annex C.1.1 | Reference | Optional | 区間再帰分割の説明を演算根拠として参照管理すること | Planned | TBD | TBD | informative |
| R-0081 | Annex C.1.2 | Reference | Optional | 符号化近似規約を近似実装時の説明根拠として保持すること | Planned | TBD | TBD | informative |
| R-0082 | Annex C.2 | Reference | Optional | arithmetic encoder 記述は実装参考情報として管理すること | Planned | TBD | TBD | informative |
| R-0083 | Annex C.2.1 | Reference | Optional | encoder code register 規約を内部設計ノートで追跡すること | Planned | TBD | TBD | informative |
| R-0084 | Annex C.2.2 | Reference | Optional | ENCODE 手順は参考手順として管理すること | Planned | TBD | TBD | informative |
| R-0085 | Annex C.2.3 | Reference | Optional | CODE1/CODE0 手順は参考手順として管理すること | Planned | TBD | TBD | informative |
| R-0086 | Annex C.2.4 | Reference | Optional | CODEMPS/CODELPS 手順は参考手順として管理すること | Planned | TBD | TBD | informative |
| R-0087 | Annex C.2.5 | Decoder | Must | 確率推定状態遷移を規定どおりに扱うこと | Planned | TBD | TBD | probability estimation |
| R-0088 | Annex C.2.6 | Reference | Optional | encoder renormalization 説明を実装補助情報として保持すること | Planned | TBD | TBD | informative |
| R-0089 | Annex C.2.7 | Reference | Optional | BYTEOUT 説明をビットストリーム出力設計で参照可能にすること | Planned | TBD | TBD | informative |
| R-0090 | Annex C.2.8 | Reference | Optional | INITENC 説明を初期化設計の参考情報として管理すること | Planned | TBD | TBD | informative |
| R-0091 | Annex C.2.9 | Reference | Optional | FLUSH 説明を終端処理設計の参考情報として管理すること | Planned | TBD | TBD | informative |
| R-0092 | Annex C.3 | Decoder | Must | arithmetic decoding procedure を規定どおり実装すること | Planned | TBD | TBD | normative中心要件 |
| R-0093 | Annex C.3.1 | Decoder | Must | decoder code register 規約を守ること | Planned | TBD | TBD | register convention |
| R-0094 | Annex C.3.2 | Decoder | Must | DECODE 手順に従って decision 復号を行うこと | Planned | TBD | TBD | core decode |
| R-0095 | Annex C.3.3 | Decoder | Must | RENORMD 手順で decoder renormalization を実装すること | Planned | TBD | TBD | renorm |
| R-0096 | Annex C.3.4 | Decoder | Must | BYTEIN 手順で compressed image data 入力を処理すること | Planned | TBD | TBD | byte input |
| R-0097 | Annex C.3.5 | Decoder | Must | INITDEC 手順で decoder 初期化を行うこと | Planned | TBD | TBD | decoder init |
| R-0098 | Annex C.3.6 | Decoder | Must | arithmetic coding statistics のリセットを実装すること | Planned | TBD | TBD | stats reset |
| R-0099 | Annex C.3.7 | Decoder | Must | arithmetic coding statistics の保存を実装すること | Planned | TBD | TBD | stats save |
| R-0100 | Annex D.1 | Decoder | Must | code-block scan pattern を規定順序で処理すること | Planned | TBD | TBD | stripe scan |
| R-0101 | Annex D.2 | Decoder | Must | 係数ビットと有意性状態の規則を正しく扱うこと | Planned | TBD | TBD | significance basis |
| R-0102 | Annex D.2.1 | Decoder | Must | 一般ケース記法に従って有意性判定を行うこと | Planned | TBD | TBD | notation general |
| R-0103 | Annex D.2.2 | Decoder | Must | ROIケース記法に従って有意性判定を行うこと | Planned | TBD | TBD | notation roi |
| R-0104 | Annex D.3 | Decoder | Must | bit-planeごとの decoding passes を規定順で処理すること | Planned | TBD | TBD | pass sequence |
| R-0105 | Annex D.3.1 | Decoder | Must | significance propagation pass を実装すること | Planned | TBD | TBD | pass type 1 |
| R-0106 | Annex D.3.2 | Decoder | Must | sign bit decoding を実装すること | Planned | TBD | TBD | sign decode |
| R-0107 | Annex D.3.3 | Decoder | Must | magnitude refinement pass を実装すること | Planned | TBD | TBD | pass type 2 |
| R-0108 | Annex D.3.4 | Decoder | Must | cleanup pass を実装すること | Planned | TBD | TBD | pass type 3 |
| R-0109 | Annex D.3.5 | Reference | Optional | coding pass 例は回帰試験データ候補として管理すること | Planned | TBD | TBD | informative |
| R-0110 | Annex D.4 | Decoder | Must | 初期化および終端処理を規定どおり実装すること | Planned | TBD | TBD | init/term |
| R-0111 | Annex D.4.1 | Decoder | Must | expected codestream termination 条件を満たすこと | Planned | TBD | TBD | termination check |
| R-0112 | Annex D.4.2 | Decoder | Must | arithmetic coder termination を規定どおり扱うこと | Planned | TBD | TBD | coder term |
| R-0113 | Annex D.4.3 | Reference | Optional | length computation は実装補助情報として管理すること | Planned | TBD | TBD | informative |
| R-0114 | Annex D.5 | Decoder | Must | error resilience segmentation symbol を処理すること | Planned | TBD | TBD | resilience |
| R-0115 | Annex D.6 | Decoder | Must | selective arithmetic coding bypass を処理すること | Planned | TBD | TBD | bypass mode |
| R-0116 | Annex D.7 | Decoder | Must | vertically causal context formation を規定どおり適用すること | Planned | TBD | TBD | context rule |
| R-0117 | Annex D.8 | Reference | Optional | code-block coding flow 図は設計レビュー資料として保持すること | Planned | TBD | TBD | informative |
| R-0118 | Annex E.1 | Decoder | Must | inverse quantization procedure を実装すること | Planned | TBD | TBD | dequant core |
| R-0119 | Annex E.1.1 | Decoder | Must | irreversible transformation の逆量子化を規定どおり実装すること | Planned | TBD | TBD | lossy path |
| R-0120 | Annex E.1.2 | Decoder | Must | reversible transformation の逆量子化を規定どおり実装すること | Planned | TBD | TBD | lossless path |
| R-0121 | Annex E.2 | Reference | Optional | scalar coefficient quantization の説明を符号化設計の参考情報として管理すること | Planned | TBD | TBD | informative |
| R-0122 | Annex F.1 | Decoder | Must | tile-component parameters を規定どおり扱うこと | Planned | TBD | TBD | parameter basis |
| R-0123 | Annex F.2 | Decoder | Must | discrete wavelet transformations の分解規則を実装すること | Planned | TBD | TBD | DWT framework |
| R-0124 | Annex F.2.1 | Reference | Optional | low/high-pass filtering 説明をフィルタ実装補助情報として保持すること | Planned | TBD | TBD | informative |
| R-0125 | Annex F.2.2 | Decoder | Must | decomposition levels を規定どおり構成すること | Planned | TBD | TBD | level topology |
| R-0126 | Annex F.2.3 | Reference | Optional | wavelet filter 説明を係数定義の参照情報として管理すること | Planned | TBD | TBD | informative |
| R-0127 | Annex F.3 | Decoder | Must | inverse DWT 全体手順を実装すること | Planned | TBD | TBD | IDWT framework |
| R-0128 | Annex F.3.1 | Decoder | Must | IDWT procedure を規定どおり実装すること | Planned | TBD | TBD | core procedure |
| R-0129 | Annex F.3.2 | Decoder | Must | 2D_SR procedure を実装すること | Planned | TBD | TBD | subroutine |
| R-0130 | Annex F.3.3 | Decoder | Must | 2D_INTERLEAVE procedure を実装すること | Planned | TBD | TBD | subroutine |
| R-0131 | Annex F.3.4 | Decoder | Must | HOR_SR procedure を実装すること | Planned | TBD | TBD | subroutine |
| R-0132 | Annex F.3.5 | Decoder | Must | VER_SR procedure を実装すること | Planned | TBD | TBD | subroutine |
| R-0133 | Annex F.3.6 | Decoder | Must | 1D_SR procedure を実装すること | Planned | TBD | TBD | subroutine |
| R-0134 | Annex F.3.7 | Decoder | Must | 1D_EXTR procedure を実装すること | Planned | TBD | TBD | subroutine |
| R-0135 | Annex F.3.8 | Decoder | Must | 1D_FILTR procedure を実装すること | Planned | TBD | TBD | subroutine |
| R-0136 | Annex F.4 | Reference | Optional | forward transformation 全体説明を encoder 設計の参考情報として管理すること | Planned | TBD | TBD | informative |
| R-0137 | Annex F.4.1 | Reference | Optional | FDWT procedure を参照実装根拠として管理すること | Planned | TBD | TBD | informative |
| R-0138 | Annex F.4.2 | Reference | Optional | 2D_SD procedure を参照情報として管理すること | Planned | TBD | TBD | informative |
| R-0139 | Annex F.4.3 | Reference | Optional | VER_SD procedure を参照情報として管理すること | Planned | TBD | TBD | informative |
| R-0140 | Annex F.4.4 | Reference | Optional | HOR_SD procedure を参照情報として管理すること | Planned | TBD | TBD | informative |
| R-0141 | Annex F.4.5 | Reference | Optional | 2D_DEINTERLEAVE procedure を参照情報として管理すること | Planned | TBD | TBD | informative |
| R-0142 | Annex F.4.6 | Reference | Optional | 1D_SD procedure を参照情報として管理すること | Planned | TBD | TBD | informative |
| R-0143 | Annex F.4.7 | Reference | Optional | 1D_EXTD procedure を参照情報として管理すること | Planned | TBD | TBD | informative |
| R-0144 | Annex F.4.8 | Reference | Optional | 1D_FILTD procedure を参照情報として管理すること | Planned | TBD | TBD | informative |
| R-0145 | Annex G.1 | Decoder | Must | tile-component の DC level shifting を規定どおり処理すること | Planned | TBD | TBD | level shift framework |
| R-0146 | Annex G.1.1 | Reference | Optional | forward DC level shifting は encoder設計の参考情報として管理すること | Planned | TBD | TBD | informative |
| R-0147 | Annex G.1.2 | Decoder | Must | inverse DC level shifting を規定どおり実装すること | Planned | TBD | TBD | decoder path |
| R-0148 | Annex G.2 | Decoder | Must | reversible multiple component transformation (RCT) を処理すること | Planned | TBD | TBD | lossless MCT |
| R-0149 | Annex G.2.1 | Reference | Optional | forward RCT は encoder設計の参考情報として管理すること | Planned | TBD | TBD | informative |
| R-0150 | Annex G.2.2 | Decoder | Must | inverse RCT を規定どおり実装すること | Planned | TBD | TBD | decoder path |
| R-0151 | Annex G.3 | Decoder | Must | irreversible multiple component transformation (ICT) を処理すること | Planned | TBD | TBD | lossy MCT |
| R-0152 | Annex G.3.1 | Reference | Optional | forward ICT は encoder設計の参考情報として管理すること | Planned | TBD | TBD | informative |
| R-0153 | Annex G.3.2 | Decoder | Must | inverse ICT を規定どおり実装すること | Planned | TBD | TBD | decoder path |
| R-0154 | Annex G.4 | Decoder | Must | 色差成分サブサンプリングと参照グリッド整合を維持すること | Planned | TBD | TBD | sampling alignment |
| R-0155 | Annex H.1 | Decoder | Must | ROI 復号手順を規定どおり実装すること | Planned | TBD | TBD | ROI decode |
| R-0156 | Annex H.2 | Decoder | Must | Maxshift method の処理規則を扱うこと | Planned | TBD | TBD | maxshift framework |
| R-0157 | Annex H.2.1 | Reference | Optional | ROI encoding 手順は encoder設計の参考情報として管理すること | Planned | TBD | TBD | informative |
| R-0158 | Annex H.2.2 | Reference | Optional | scaling value s の選択指針は参考情報として管理すること | Planned | TBD | TBD | informative |
| R-0159 | Annex H.3 | Reference | Optional | ROI coding に関する remarks を設計上の注意点として管理すること | Planned | TBD | TBD | informative |
| R-0160 | Annex H.3.1 | Reference | Optional | ROI mask generation の説明をテストデータ設計に活用すること | Planned | TBD | TBD | informative |
| R-0161 | Annex H.3.2 | Reference | Optional | multi-component に関する注意事項を参照情報として管理すること | Planned | TBD | TBD | informative |
| R-0162 | Annex H.3.3 | Reference | Optional | disjoint regions に関する注意事項を参照情報として管理すること | Planned | TBD | TBD | informative |
| R-0163 | Annex H.3.4 | Reference | Optional | implementation precision に関する注意事項を参照情報として管理すること | Planned | TBD | TBD | informative |
| R-0164 | Annex H.3.5 | Reference | Optional | Maxshift usage example を回帰試験候補として管理すること | Planned | TBD | TBD | informative |
| R-0165 | Annex I.1 | Container | Must | JP2 file format scope を実装対象として固定すること | Planned | TBD | TBD | file format scope |
| R-0166 | Annex I.2 | Container | Must | JP2 file format の導入規則を全体設計へ反映すること | Planned | TBD | TBD | intro |
| R-0167 | Annex I.2.1 | Container | Must | file identification を規定ボックスで検証/生成すること | Planned | TBD | TBD | signature path |
| R-0168 | Annex I.2.2 | Container | Must | file organization（box順序と構成）を規定どおり扱うこと | Planned | TBD | TBD | organization |
| R-0169 | Annex I.2.3 | Container | Must | greyscale/colour/palette/multi-component 指定を処理すること | Planned | TBD | TBD | image specification |
| R-0170 | Annex I.2.4 | Container | Must | opacity channels の包含規則を処理すること | Planned | TBD | TBD | alpha handling |
| R-0171 | Annex I.2.5 | Container | Must | metadata ボックスの取り扱いを定義すること | Planned | TBD | TBD | metadata policy |
| R-0172 | Annex I.2.6 | Container | Must | JP2 file format conformance 条件を検証できること | Planned | TBD | TBD | conformance |
| R-0173 | Annex I.3 | Container | Must | 画像仕様アーキテクチャ（colour/palette/multi-component）を実装に反映すること | Planned | TBD | TBD | architecture |
| R-0174 | Annex I.3.1 | Container | Must | enumerated method を規定どおり処理すること | Planned | TBD | TBD | method enum |
| R-0175 | Annex I.3.2 | Container | Must | restricted ICC profile method を規定どおり処理すること | Planned | TBD | TBD | ICC restricted |
| R-0176 | Annex I.3.3 | Container | Must | multiple methods 併用時の規則を満たすこと | Planned | TBD | TBD | method interaction |
| R-0177 | Annex I.3.4 | Container | Must | palettized images の規則を処理すること | Planned | TBD | TBD | palette handling |
| R-0178 | Annex I.3.5 | Container | Must | MCT との相互作用規則を満たすこと | Planned | TBD | TBD | MCT interaction |
| R-0179 | Annex I.3.6 | Reference | Optional | グラフィカル記法は読解補助情報として管理すること | Planned | TBD | TBD | informative |
| R-0180 | Annex I.4 | Container | Must | box 定義（LBox/TBox/XLBox/DBox）を規定どおり実装すること | Planned | TBD | TBD | box grammar |
| R-0181 | Annex I.5 | Container | Must | 定義済み box 群を規定どおり処理すること | Planned | TBD | TBD | defined boxes |
| R-0182 | Annex I.5.1 | Container | Must | JPEG 2000 Signature box を検証/生成すること | Planned | TBD | TBD | signature box |
| R-0183 | Annex I.5.2 | Container | Must | File Type box を検証/生成すること | Planned | TBD | TBD | ftyp box |
| R-0184 | Annex I.5.3 | Container | Must | JP2 Header box（superbox）配下要素を規定どおり処理すること | Planned | TBD | TBD | jp2h superbox |
| R-0185 | Annex I.5.4 | Container | Must | Contiguous Codestream box を検証/生成すること | Planned | TBD | TBD | jp2c box |
| R-0186 | Annex I.6 | Container | Should | intellectual property rights 情報追加規則を扱えること | Planned | TBD | TBD | ipr metadata |
| R-0187 | Annex I.7 | Container | Should | vendor-specific information 追加規則を扱えること | Planned | TBD | TBD | extension policy |
| R-0188 | Annex I.7.1 | Container | Should | XML boxes を拡張情報として処理できること | Planned | TBD | TBD | xml extension |
| R-0189 | Annex I.7.2 | Container | Should | UUID boxes を拡張情報として処理できること | Planned | TBD | TBD | uuid extension |
| R-0190 | Annex I.7.3 | Container | Should | UUID Info boxes（superbox）を処理できること | Planned | TBD | TBD | uuid info |
| R-0191 | Annex I.8 | Container | Must | unknown boxes をスキップしつつ整合性を維持すること | Planned | TBD | TBD | forward compatibility |
| R-0192 | Annex M.1 | Validation | Must | broadcast application profiles の適用範囲を実装プロファイルとして定義すること | Planned | TBD | TBD | profile gating |
| R-0193 | Annex M.2 | Validation | Must | access unit 定義を語彙・型定義に反映すること | Planned | TBD | TBD | terminology |
| R-0194 | Annex M.3 | Container | Must | access unit の box 構造を I.4 と整合して処理すること | Planned | TBD | TBD | ES header structure |
| R-0195 | Annex M.4 | Container | Must | Elementary stream marker box（superbox）を規定どおり処理すること | Planned | TBD | TBD | superbox |
| R-0196 | Annex M.4.1 | Container | Must | Frame Rate Coding box（required）を検証/生成すること | Planned | TBD | TBD | required box |
| R-0197 | Annex M.4.2 | Container | Must | Maximum Bit Rate box（required）を検証/生成すること | Planned | TBD | TBD | required box |
| R-0198 | Annex M.4.3 | Container | Should | Field Coding box（optional）を処理可能にすること | Planned | TBD | TBD | optional box |
| R-0199 | Annex M.4.4 | Container | Must | Time Code box（required）を検証/生成すること | Planned | TBD | TBD | required box |
| R-0200 | Annex M.4.5 | Container | Must | Broadcast Colour Specification box（required）を検証/生成すること | Planned | TBD | TBD | required box |
| R-0201 | Annex M.4.6 | Container | Must | Mastering Display Metadata Box（required）を検証/生成すること | Planned | TBD | TBD | required box |
| R-0202 | Annex J.1 | Reference | Optional | adaptive entropy decoder のソフトウェア規約を参考情報として管理すること | Planned | TBD | TBD | informative guidance |
| R-0203 | Annex J.2 | Reference | Optional | 量子化ステップサイズ選定指針を参考情報として管理すること | Planned | TBD | TBD | informative guidance |
| R-0204 | Annex J.3 | Reference | Optional | lifting-based irreversible filtering の impulse response を参考管理すること | Planned | TBD | TBD | informative guidance |
| R-0205 | Annex J.4 | Reference | Optional | DWT例を回帰試験データ候補として管理すること | Planned | TBD | TBD | informative examples |
| R-0206 | Annex J.5 | Reference | Optional | row-based wavelet transform 手順群を参照実装比較用に管理すること | Planned | TBD | TBD | informative procedures |
| R-0207 | Annex J.6 | Reference | Optional | scan-based coding の運用指針を参考情報として管理すること | Planned | TBD | TBD | informative guidance |
| R-0208 | Annex J.7 | Reference | Optional | error resilience の実装指針を参考情報として管理すること | Planned | TBD | TBD | informative guidance |
| R-0209 | Annex J.8 | Reference | Optional | Restricted ICC method の実装指針を参考情報として管理すること | Planned | TBD | TBD | informative guidance |
| R-0210 | Annex J.9/J.10 | Reference | Optional | 多成分解釈例および逐次デコード例を検証観点として管理すること | Planned | TBD | TBD | informative examples |
| R-0211 | Annex J.11/J.12/J.13/J.14/J.15 | Reference | Optional | 視覚重み付け・サブサンプリング・レート制御・YCC・D-cinema指針を参考管理すること | Planned | TBD | TBD | informative guidance |
| R-0212 | Annex K.1 | Reference | Optional | bibliography general を参照文献群として管理すること | Planned | TBD | TBD | bibliography |
| R-0213 | Annex K.2 | Reference | Optional | quantization/entropy coding 文献群を参照管理すること | Planned | TBD | TBD | bibliography |
| R-0214 | Annex K.3 | Reference | Optional | wavelet transformation 文献群を参照管理すること | Planned | TBD | TBD | bibliography |
| R-0215 | Annex K.4 | Reference | Optional | ROI coding 文献群を参照管理すること | Planned | TBD | TBD | bibliography |
| R-0216 | Annex K.5 | Reference | Optional | visual frequency weighting 文献群を参照管理すること | Planned | TBD | TBD | bibliography |
| R-0217 | Annex K.6 | Reference | Optional | error resilience 文献群を参照管理すること | Planned | TBD | TBD | bibliography |
| R-0218 | Annex K.7 | Reference | Optional | scan-based coding 文献群を参照管理すること | Planned | TBD | TBD | bibliography |
| R-0219 | Annex K.8 | Reference | Optional | colour 文献群を参照管理すること | Planned | TBD | TBD | bibliography |
| R-0220 | Annex K.9 | Reference | Optional | digital cinema applications 文献群を参照管理すること | Planned | TBD | TBD | bibliography |
| R-0221 | Annex L | Reference | Optional | 特許声明を法的前提事項として参照管理すること | Planned | TBD | TBD | non-normative patent note |

## 章別カバレッジサマリ

| Section | Required | Identified | Coverage |
|---|---|---|---|
| 1 Scope | 4 | 4 | 100% |
| 2 References | 1 | 1 | 100% |
| 3 Definitions | 4 | 4 | 100% |
| 4 Abbreviations and symbols | 2 | 2 | 100% |
| 5 General description | 2 | 2 | 100% |
| 6 Encoder requirements | 2 | 2 | 100% |
| 7 Decoder requirements | 4 | 4 | 100% |
| 8 Implementation requirements | 1 | 1 | 100% |
| Annex A | 35 | 35 | 100% |
| Annex B | 23 | 23 | 100% |
| Annex C | 21 | 21 | 100% |
| Annex D | 18 | 18 | 100% |
| Annex E | 4 | 4 | 100% |
| Annex F | 23 | 23 | 100% |
| Annex G | 10 | 10 | 100% |
| Annex H | 10 | 10 | 100% |
| Annex I | 27 | 27 | 100% |
| Annex J | 10 | 10 | 100% |
| Annex K | 9 | 9 | 100% |
| Annex L | 1 | 1 | 100% |
| Annex M | 10 | 10 | 100% |
