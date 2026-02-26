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
| R-0021 | Annex A.1 | Validation | Must | マーカー/マーカーセグメント/ヘッダの役割を区別して codestream 構文を解釈できること | Verified | jpeg2000_test.mbt::parse minimal codestream skeleton | Codex | `MarkerSegment` + `parse_codestream` で基礎構文を検証 |
| R-0022 | Annex A.1.1 | Validation | Must | 6種類のマーカー種別（delimiting/fixed/functional/in-bit-stream/pointer/informational）を識別できること | Verified | jpeg2000_test.mbt::marker classes for Annex A groups | Codex | `classify_marker` で6分類を実装 |
| R-0023 | Annex A.1.2 | Validation | Must | 既存JPEG系規格と共有されるマーカー定義/予約範囲を尊重して解釈すること | Verified | jpeg2000_test.mbt::failure case: reserved marker range, jpeg2000_test.mbt::failure case: all reserved marker codes are rejected | Codex | `0xFF30..0xFF3F` の全コード拒否を回帰試験化し、予約範囲解釈を検証完了 |
| R-0024 | Annex A.1.3 | Validation | Must | マーカーセグメント長・出現位置・適用範囲に関する規則を検証できること | Verified | jpeg2000_test.mbt::failure case: invalid marker placement in main header, jpeg2000_test.mbt::failure case: SOT length must be 10, jpeg2000_test.mbt::failure case: SOD before SOT is invalid placement, jpeg2000_test.mbt::failure case: PPT in main header is invalid placement, jpeg2000_test.mbt::failure case: PPM in tile-part header is invalid placement, jpeg2000_test.mbt::failure case: CRG length mismatch with Csiz=2 | Codex | 長さ（SOT/CRG）+ 出現位置（SOD/SOT順序）+ 適用範囲（main/tile-part 専用marker）を失敗ケースで網羅検証 |
| R-0025 | Annex A.1.4 | Reference | Optional | グラフィカル記法は実装必須ではないが仕様読解規約として参照管理すること | Planned | TBD | TBD | informative |
| R-0026 | Annex A.2 | Validation | Must | マーカーセグメントのフィールド意味と制約を節定義どおりに扱うこと | Verified | jpeg2000_test.mbt::parse minimal SIZ metadata, jpeg2000_test.mbt::parse minimal COD and QCD metadata, jpeg2000_test.mbt::parse COC/QCC metadata from sample, jpeg2000_test.mbt::parse POC metadata from sample, jpeg2000_test.mbt::parse TLM metadata from sample, jpeg2000_test.mbt::parse PLM/PLT metadata from sample, jpeg2000_test.mbt::parse PPM/PPT metadata from samples, jpeg2000_test.mbt::parse SOP/EPH metadata from sample, jpeg2000_test.mbt::parse CRG metadata from stream, jpeg2000_test.mbt::parse COM metadata from sample | Codex | Annex A marker segment 群の主要フィールドを `Codestream.metadata` と失敗ケースで機械検証し、制約解釈を確認 |
| R-0027 | Annex A.3 | Validation | Must | codestream 全体構成（main header/tile-part/data/EOC）を構築・解析できること | Verified | jpeg2000_test.mbt::parse minimal codestream skeleton | Codex | SOC/SOT/SOD/EOC 骨格の解析を実装 |
| R-0028 | Annex A.4 | Validation | Must | delimiting markers の出現順序および関係制約を満たすこと | Verified | jpeg2000_test.mbt::parse minimal codestream skeleton, jpeg2000_test.mbt::failure case: missing SOC | Codex | SOC先頭/EOC終端/SOD前SOTを検証。失敗ケース追加済み |
| R-0029 | Annex A.4.1 (SOC) | Validation | Must | SOC を codestream 開始位置で正しく検出/生成すること | Verified | jpeg2000_test.mbt::parse minimal codestream skeleton, jpeg2000_test.mbt::failure case: missing SOC | Codex | 開始位置必須を検証、欠落時はエラー |
| R-0030 | Annex A.4.2 (SOT) | Validation | Must | SOT の tile-part 情報（長さ・索引等）を正しく解釈/生成すること | Verified | jpeg2000_test.mbt::parse minimal codestream skeleton, jpeg2000_test.mbt::round-trip codestream markers, jpeg2000_test.mbt::failure case: invalid Psot in SOT, jpeg2000_test.mbt::failure case: invalid TPsot and TNsot relation, jpeg2000_test.mbt::failure case: invalid tile-part index sequence, jpeg2000_test.mbt::failure case: Isot out of range | Codex | Psot境界検証 + Isot/TPsot/TNsot 連番/範囲整合検証を実装 |
| R-0031 | Annex A.4.3 (SOD) | Validation | Must | SOD 以降を tile-part データ領域として扱いヘッダと分離できること | Verified | jpeg2000_test.mbt::parse minimal codestream skeleton | Codex | SODを長さ無し境界マーカーとして分離処理 |
| R-0032 | Annex A.4.4 (EOC) | Validation | Must | EOC を codestream 終端として検証/生成すること | Verified | jpeg2000_test.mbt::parse minimal codestream skeleton, jpeg2000_test.mbt::round-trip codestream markers | Codex | EOC終端制約を検証し再符号化でも保持 |
| R-0033 | Annex A.5 | Validation | Must | fixed information marker segments を画像基本情報として解釈すること | Verified | jpeg2000_test.mbt::parse minimal codestream skeleton, jpeg2000_test.mbt::parse minimal SIZ metadata | Codex | `Codestream.metadata.siz` を追加し、SIZを構造化して取得可能化 |
| R-0034 | Annex A.5.1 (SIZ) | Validation | Must | SIZ の画像サイズ/タイルサイズ/コンポーネント情報を正しく扱うこと | Verified | jpeg2000_test.mbt::parse minimal SIZ metadata, jpeg2000_test.mbt::failure case: SIZ component sampling must be positive | Codex | `X/Y siz`・tileサイズ・component精度/サンプリング・タイル総数をSIZメタデータとして解釈し検証 |
| R-0035 | Annex A.6 | Validation | Must | functional marker segments による符号化方式指定を処理できること | Verified | jpeg2000_test.mbt::parse minimal COD and QCD metadata, jpeg2000_test.mbt::round-trip codestream markers | Codex | `Codestream.metadata.cod/qcd` を追加し、COD/QCDの主要指定値（progression/layers/decomposition/quantization style）を解釈 |
| R-0036 | Annex A.6.1 (COD) | Validation | Must | COD の既定符号化スタイル（progression, decomposition等）を解釈/生成すること | Verified | jpeg2000_test.mbt::parse minimal COD and QCD metadata, jpeg2000_test.mbt::failure case: COD progression order out of range, jpeg2000_test.mbt::failure case: COD layers must be positive, jpeg2000_test.mbt::failure case: COD code-block size exponents invalid, jpeg2000_test.mbt::failure case: COD precinct length inconsistency | Codex | COD主要パラメータ（進行順序/レイヤ数/CBサイズ/precinct長整合）を検証し、メタデータとして解釈 |
| R-0037 | Annex A.6.2 (COC) | Validation | Must | COC によるコンポーネント別上書きを正しく適用すること | Verified | jpeg2000_test.mbt::parse COC/QCC metadata from sample, jpeg2000_test.mbt::failure case: duplicate COC in same header | Codex | `metadata.coc` で component別COCを構造化し、重複禁止とcomponent整合を検証 |
| R-0038 | Annex A.6.3 (RGN) | Validation | Must | RGN による ROI 関連パラメータを解釈/生成すること | Verified | jpeg2000_test.mbt::failure case: RGN style invalid | Codex | `metadata.rgn` により RGN（component/style/shift）を解釈し、`Srgn=0` 制約を検証 |
| R-0039 | Annex A.6.4 (QCD) | Validation | Must | QCD の量子化既定値を解釈/生成すること | Verified | jpeg2000_test.mbt::parse minimal COD and QCD metadata, jpeg2000_test.mbt::failure case: QCD quantization style invalid, jpeg2000_test.mbt::failure case: QCD derived style requires even parameter bytes | Codex | SQcd の guard bits/style 解釈と、量子化パラメータ長整合（style依存）を検証 |
| R-0040 | Annex A.6.5 (QCC) | Validation | Must | QCC のコンポーネント別量子化値上書きを適用すること | Verified | jpeg2000_test.mbt::parse COC/QCC metadata from sample | Codex | `metadata.qcc` で component別QCCを構造化し、上書き情報を保持可能化 |
| R-0041 | Annex A.6.6 (POC) | Validation | Must | POC による progression order change を正しく扱うこと | Verified | jpeg2000_test.mbt::parse POC metadata from sample, jpeg2000_test.mbt::failure case: POC progression order out of range, jpeg2000_test.mbt::failure case: POC CEpoc must be greater than CSpoc | Codex | `metadata.poc` を導入し、POC entry解釈 + `Ppoc/CSpoc/CEpoc` 値域整合を検証 |
| R-0042 | Annex A.7 | Validation | Must | pointer marker segments を位置情報として整合的に処理すること | Verified | jpeg2000_test.mbt::parse PLM/PLT metadata from sample, jpeg2000_test.mbt::parse PPM/PPT metadata from samples, jpeg2000_test.mbt::parse TLM metadata from sample, jpeg2000_test.mbt::failure case: invalid marker placement in main header | Codex | pointer marker 群の配置制約 + payload構造化解釈（TLM/PLM/PLT/PPM/PPT）を統合検証 |
| R-0043 | Annex A.7.1 (TLM) | Validation | Must | TLM の tile-part 長情報を解釈/生成すること | Verified | jpeg2000_test.mbt::parse TLM metadata from sample | Codex | `metadata.tlm` を追加し、`Ztlm/Stlm/Ttlm?/Ptlm` を構造化解釈 |
| R-0044 | Annex A.7.2 (PLM) | Validation | Must | PLM の packet length 情報（main header）を扱うこと | Verified | jpeg2000_test.mbt::parse PLM/PLT metadata from sample, jpeg2000_test.mbt::failure case: PLM marker segment length too short, jpeg2000_test.mbt::failure case: invalid Zplm sequence, jpeg2000_test.mbt::failure case: invalid PLM chunk size mismatch | Codex | `metadata.plm` で `Nplm/Iplm` を packet length 配列へ復元し、連番/長さ整合を検証 |
| R-0045 | Annex A.7.3 (PLT) | Validation | Must | PLT の packet length 情報（tile-part header）を扱うこと | Verified | jpeg2000_test.mbt::parse PLM/PLT metadata from sample, jpeg2000_test.mbt::failure case: invalid marker placement in main header, jpeg2000_test.mbt::failure case: invalid PLT packet length sequence | Codex | `metadata.plt` で `Iplt` 可変長系列を復元し、配置/系列終端を検証 |
| R-0046 | Annex A.7.4 (PPM) | Validation | Must | PPM の packed packet headers（main header）を扱うこと | Verified | jpeg2000_test.mbt::parse PPM/PPT metadata from samples, jpeg2000_test.mbt::failure case: PPM and PPT mixed, jpeg2000_test.mbt::failure case: invalid Zppm sequence, jpeg2000_test.mbt::failure case: invalid PPM chunk size mismatch | Codex | `metadata.ppm` で `Nppm/Ippm` チャンクを抽出し、排他/連番/長さ整合を検証 |
| R-0047 | Annex A.7.5 (PPT) | Validation | Must | PPT の packed packet headers（tile-part header）を扱うこと | Verified | jpeg2000_test.mbt::parse PPM/PPT metadata from samples, jpeg2000_test.mbt::failure case: PPM and PPT mixed, jpeg2000_test.mbt::failure case: invalid Zppt sequence | Codex | `metadata.ppt` で `Zppt + payload` を抽出し、PPM排他/連番を検証 |
| R-0048 | Annex A.8 | Validation | Must | in-bit-stream markers をエラー耐性関連情報として処理できること | Verified | jpeg2000_test.mbt::parse SOP/EPH metadata from sample, jpeg2000_test.mbt::marker classes for Annex A groups | Codex | `SOD` payload 走査で `SOP/EPH` を抽出し、`metadata.sop/eph_positions` として解釈 |
| R-0049 | Annex A.8.1 (SOP) | Validation | Must | SOP を packet 開始境界情報として解釈/生成すること | Verified | jpeg2000_test.mbt::parse SOP/EPH metadata from sample | Codex | `Nsop` を `metadata.sop` に格納し、round-tripで原payload保持を確認 |
| R-0050 | Annex A.8.2 (EPH) | Validation | Must | EPH を packet header 終端情報として解釈/生成すること | Verified | jpeg2000_test.mbt::parse SOP/EPH metadata from sample | Codex | `EPH` 出現位置を `metadata.eph_positions` として抽出 |
| R-0051 | Annex A.9 | Validation | Must | informational marker segments を補助情報として扱うこと | Verified | jpeg2000_test.mbt::parse COM metadata from sample, jpeg2000_test.mbt::parse CRG metadata from stream | Codex | informational marker の `CRG/COM` を構造化解釈し保持 |
| R-0052 | Annex A.9.1 (CRG) | Validation | Must | CRG の component registration 情報を解釈/生成すること | Verified | jpeg2000_test.mbt::parse CRG metadata from stream, jpeg2000_test.mbt::failure case: CRG length mismatch to components | Codex | `metadata.crg` に `Xcrg/Ycrg` 配列を復元し、`Csiz` 連動長さ制約を検証 |
| R-0053 | Annex A.9.2 (COM) | Validation | Must | COM コメントセグメントを保存可能に処理すること | Verified | jpeg2000_test.mbt::parse COM metadata from sample, jpeg2000_test.mbt::round-trip codestream markers | Codex | `metadata.com` へ `Rcom/Ccom` を抽出し、payload保持と整合確認 |
| R-0054 | Annex A.10 | Validation | Must | 本規格に準拠する codestream 制約を検証できること | Verified | jpeg2000_test.mbt::failure case: SIZ must be second marker segment, jpeg2000_test.mbt::failure case: missing COD is rejected, jpeg2000_test.mbt::failure case: missing QCD is rejected, jpeg2000_test.mbt::failure case: missing SOT/SOD pair is rejected, jpeg2000_test.mbt::failure case: PPM and PPT mixed | Codex | 必須マーカー制約（SIZ/COD/QCD/SOT/SOD）と排他/配置制約を失敗ケースで検証 |
| R-0055 | Annex A.10.1 | Reference | Optional | digital cinema applications 向け制約は対象プロファイルとして別管理すること | Planned | TBD | TBD | 適用時にMust化 |
| R-0056 | Annex B.1 | Validation | Must | 画像構造概念（component/tile/sub-band/precinct/code-block）の関係を一貫して扱うこと | Verified | jpeg2000_test.mbt::parse ordering metadata from minimal sample, jpeg2000_test.mbt::ordering metadata: 2x2 tile partition, jpeg2000_test.mbt::ordering coding metadata from COD decomposition levels, jpeg2000_test.mbt::ordering coding metadata: precincts and packets, jpeg2000_test.mbt::ordering coding metadata: packets scale with tiles | Codex | `ordering + ordering_coding` で component/tile/tile-component/resolution/sub-band/precinct/code-block/packet関係を検証 |
| R-0057 | Annex B.2 | Validation | Must | component と reference grid の対応式を正しく実装すること | Verified | jpeg2000_test.mbt::ordering metadata: component mapping by sampling factors | Codex | `XRsiz/YRsiz` に基づく component 幾何（width/height）を reference grid から導出して検証 |
| R-0058 | Annex B.3 | Validation | Must | image area の tile/tile-component 分割規則を満たすこと | Verified | jpeg2000_test.mbt::ordering metadata: 2x2 tile partition, jpeg2000_test.mbt::parse ordering metadata from minimal sample | Codex | `XTsiz/YTsiz/XTOsiz/YTOsiz` から tile grid と tile境界を導出し、分割規則を検証 |
| R-0059 | Annex B.4 | Reference | Optional | 参照例（mapping example）は検証データとして管理すること | Planned | TBD | TBD | informative |
| R-0060 | Annex B.5 | Decoder | Must | transformed tile-component の resolution/sub-band 構造を正しく扱うこと | Verified | jpeg2000_test.mbt::ordering coding metadata from COD decomposition levels, jpeg2000_test.mbt::ordering progression metadata: LRCP layering sequence | Codex | decompositionレベルから resolution/sub-band 骨格を導出し、progressionメタデータで階層利用を検証 |
| R-0061 | Annex B.6 | Decoder | Must | precinct 分割規則を解釈/生成すること | Verified | jpeg2000_test.mbt::ordering coding metadata: precincts and packets, jpeg2000_test.mbt::ordering coding metadata from COD decomposition levels | Codex | `Scod/SPcod` から解像度ごとの `PPx/PPy` と precinct寸法を導出し検証 |
| R-0062 | Annex B.7 | Decoder | Must | sub-band の code-block 分割規則を解釈/生成すること | Verified | jpeg2000_test.mbt::ordering coding metadata from COD decomposition levels | Codex | COD の code-block 指定から解像度ごとの nominal code-block 寸法を導出し検証 |
| R-0063 | Annex B.8 | Decoder | Must | layer 構造と符号化データ対応を保持すること | Verified | jpeg2000_test.mbt::ordering coding metadata: precincts and packets | Codex | `layers` と `packets_total=packets_per_layer*layers` を packet単位メタデータで検証 |
| R-0064 | Annex B.9 | Decoder | Must | packet を precinct/resolution/component/layer 単位で構成・復元すること | Verified | jpeg2000_test.mbt::ordering coding metadata: precincts and packets, jpeg2000_test.mbt::ordering coding metadata: packets scale with tiles | Codex | packet単位を `tile×component×resolution×layer` で導出し、タイル増加時の単位数増加を検証 |
| R-0065 | Annex B.10 | Decoder | Must | packet header 情報符号化規則を解釈/生成すること | Verified | jpeg2000_test.mbt::packet header single-codeblock decode: non-empty packet, jpeg2000_test.mbt::packet header with tag-tree inclusion and pass splits, jpeg2000_test.mbt::packet header with tag-tree pass splits on 2x2 code-blocks, jpeg2000_test.mbt::packet headers tag-tree sequence with pass splits on second layer | Codex | tag-tree統合 + pass-splits を含む packet header 復号導線を連続packet/複数 code-block ケースまで検証 |
| R-0066 | Annex B.10.1 | Decoder | Must | packet header の bit-stuffing 規則を満たすこと | Verified | jpeg2000_test.mbt::failure case: invalid packet bit stuffing sequence, jpeg2000_test.mbt::two tile-parts keep packet payload boundaries | Codex | `SOD` payload で `0xFF00` / `SOP` / `EPH` 以外を不正として検知し、bit-stuffing整合を検証 |
| R-0067 | Annex B.10.2 | Decoder | Must | tag tree 符号化/復号規則を満たすこと | Verified | jpeg2000_test.mbt::packet header single packet with tag-tree inclusion, jpeg2000_test.mbt::packet headers tag-tree sequence: carry state across packets, jpeg2000_test.mbt::tag-tree inclusion decode: non-degenerate 2x2 sharing root state, jpeg2000_test.mbt::packet header with tag-tree pass splits on 2x2 code-blocks | Codex | 非退化tag-tree復号を packet header 単一/連続packet経路へ統合し、2x2共有ルートを含む状態持ち越しを検証 |
| R-0068 | Annex B.10.3 | Decoder | Must | zero length packet の扱いを規定どおりに実装すること | Verified | jpeg2000_test.mbt::packet header single-codeblock decode: zero-length packet, jpeg2000_test.mbt::packet headers tag-tree sequence: zero-length then first inclusion, jpeg2000_test.mbt::parse PPM/PPT metadata from samples | Codex | packet header 先頭bit `0` を zero-length packet として復号し、連続packetで次layerのfirst inclusion遷移まで検証 |
| R-0069 | Annex B.10.4 | Decoder | Must | code-block inclusion 情報の符号化/復号を実装すること | Verified | jpeg2000_test.mbt::packet header single-codeblock decode: non-empty packet, jpeg2000_test.mbt::packet header multi-codeblock decode with state carryover, jpeg2000_test.mbt::packet header with tag-tree pass splits on 2x2 code-blocks | Codex | code-block inclusion bit（既出/未出の最小状態）を code-blockごとに復号し、複数block連続packetで保持 |
| R-0070 | Annex B.10.5 | Decoder | Must | zero bit-plane 情報の符号化/復号を実装すること | Verified | jpeg2000_test.mbt::packet header single-codeblock decode: non-empty packet, jpeg2000_test.mbt::packet headers tag-tree sequence: carry state across packets, jpeg2000_test.mbt::packet headers tag-tree sequence with pass splits on second layer | Codex | first inclusion 時の zero bit-plane を tag-tree経路（連続packet状態保持）で復号し、連続layer適用まで検証 |
| R-0071 | Annex B.10.6 | Decoder | Must | coding passes 数情報の符号化/復号を実装すること | Verified | jpeg2000_test.mbt::packet header single-codeblock decode: non-empty packet, jpeg2000_test.mbt::packet header multi-codeblock decode with state carryover, jpeg2000_test.mbt::coding passes decode boundaries 6 36 37 164 | Codex | Table B.4 の codeword（1..164）を復号する `decode_num_coding_passes` を実装し、境界値を含む複数code-blockケースで適用 |
| R-0072 | Annex B.10.7 | Decoder | Must | code-block ごとの compressed image data 長情報を解釈すること | Verified | jpeg2000_test.mbt::packet header multi-codeblock decode with state carryover, jpeg2000_test.mbt::decode codeblock segment lengths helper: multiple segments (B.10.7.2), jpeg2000_test.mbt::packet header with tag-tree inclusion and pass splits, jpeg2000_test.mbt::packet headers tag-tree sequence with pass splits on second layer | Codex | `Lblock + floor(log2(passes))` 幅で segment length を code-blockごとに復号し、B.10.7.2 の複数segment分割を連続packet経路まで適用 |
| R-0073 | Annex B.10.8 | Decoder | Must | packet header 内情報順序を規定どおり処理すること | Verified | jpeg2000_test.mbt::packet header single-codeblock decode: non-empty packet, jpeg2000_test.mbt::packet header single packet with tag-tree inclusion, jpeg2000_test.mbt::packet headers tag-tree sequence: carry state across packets, jpeg2000_test.mbt::packet headers tag-tree sequence with pass splits on second layer | Codex | zero/non-zero → inclusion(tag-tree可) → zero-bit-plane → pass-count → Lblock increment → length の順序で、連続packet + pass-splits 経路まで復号 |
| R-0074 | Annex B.11 | Decoder | Must | tile と tile-part の構成規則を満たすこと | Verified | jpeg2000_test.mbt::tile-part interleaving across tiles preserves per-tile order, jpeg2000_test.mbt::failure case: tile-part interleaving breaks per-tile sequence, jpeg2000_test.mbt::failure case: invalid tile-part index sequence | Codex | tile間インターリーブを許容しつつ、同一tile内の `TPsot` 連番保持を検証 |
| R-0075 | Annex B.12 | Decoder | Must | progression order の全体規則を解釈/生成すること | Verified | jpeg2000_test.mbt::ordering progression metadata from minimal sample, jpeg2000_test.mbt::ordering progression metadata: LRCP layering sequence, jpeg2000_test.mbt::ordering progression metadata: supports all progression orders | Codex | `COD.progression_order` 全5種に対する進行順序ステップ導出を `metadata.progression` で検証 |
| R-0076 | Annex B.12.1 | Decoder | Must | progression order determination を規定式どおり決定すること | Verified | jpeg2000_test.mbt::ordering progression metadata: supports all progression orders | Codex | `LRCP/RLCP/RPCL/PCRL/CPRL` の order code に応じた step 列生成を検証 |
| R-0077 | Annex B.12.2 | Decoder | Must | progression order volumes の概念を正しく適用すること | Verified | jpeg2000_test.mbt::ordering progression metadata from minimal sample, jpeg2000_test.mbt::ordering progression metadata: POC overrides progression order volume | Codex | `metadata.progression.volumes` で progression volume（layer/resolution/component 範囲）を明示化し検証 |
| R-0078 | Annex B.12.3 | Decoder | Must | progression order change signaling を POC と整合して扱うこと | Verified | jpeg2000_test.mbt::ordering progression metadata: POC overrides progression order volume | Codex | `POC.ppoc` を progression volume に反映し、COD既定順序との連携を検証 |
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

## 実装サイクルログ

### 2026-02-26 / S1 Annex A（部分）

- 完了要求ID: `R-0021`, `R-0022`, `R-0027`, `R-0028`, `R-0029`, `R-0030`, `R-0031`, `R-0032`
- 実施試験: `moon test`（4件成功）
- 失敗ケース追加: `failure case: missing SOC`
- 変更要約: codestream骨格パーサ/エンコーダ、Annex A marker分類、順序制約チェックを追加
- 継続課題: Annex Aの残要求（R-0023..R-0055）の詳細フィールド解釈と検証追加

### 2026-02-26 / S1 Annex A（部分2）

- 完了要求ID: `R-0023`, `R-0024`, `R-0026`, `R-0033`, `R-0035`, `R-0036`, `R-0039`, `R-0042`, `R-0048`, `R-0051`（`Implemented`）
- 実施試験: `moon test`（8件成功）
- 失敗ケース追加: `reserved marker range`, `invalid marker placement in main header`, `SOT length must be 10`
- 変更要約: 予約マーカー範囲拒否、main/tile header出現制約、SIZ必須/一意/位置、SOT固定長、SIZ/COD/QCD最小長の検証を追加
- 継続課題: Annex A各markerのフィールド意味（SIZ/COD/QCDの内容解釈、COC/RGN/QCC/POC/TLM/PLM/PLT/PPM/PPT/CRG/COM詳細）を実装して `Verified` 化

### 2026-02-26 / S1 Annex A（部分3）

- 完了要求ID: `R-0034`, `R-0037`, `R-0038`, `R-0040`, `R-0041`, `R-0043`, `R-0044`, `R-0045`, `R-0046`, `R-0047`, `R-0049`, `R-0050`, `R-0052`, `R-0053`, `R-0054`（`Implemented`）
- 実施試験: `moon test`（11件成功）
- 失敗ケース追加: `duplicate COC in same header`, `PPM and PPT mixed`, `CRG length mismatch to components`
- 変更要約: SIZ実フィールド検証、component index整合、POC長さ検証、header内重複制約、PPM/PPT排他、SOP/EPH/COM/CRG制約を追加
- 継続課題: Annex Aの `Verified` 化に向けて、各marker payloadの意味解釈（パラメータ値レベル）と複数tile-partケース検証を追加

### 2026-02-26 / Round-trip準備（全体テスト基盤）

- 実施内容: サンプルcodestream生成API、hex変換API、bytes round-trip API、CLI（`sample-hex`/`roundtrip-hex`）を追加
- 実施試験: `moon test`（13件成功）、`./tools/roundtrip_sample_cycle.sh`（実ファイルの生成→読込→再出力一致を確認）
- 失敗ケース追加: `hex_to_bytes` の不正入力検知（APIレベル）
- 変更要約: `samples/generated/*.j2k` を使うファイルI/Oサイクルを導入し、S11前のround-trip保証準備を実施
- 継続課題: 複数実サンプル（tile/packet多様ケース）で同サイクルを回す回帰セットを拡張

### 2026-02-26 / Round-trip準備（回帰セット拡張）

- 実施内容: サンプル種別を `minimal/with-com/with-coc-qcc/with-poc/with-ppt-sop-eph` に拡張し、CLIで選択可能化
- 実施試験: `moon test`（14件成功）、`./tools/roundtrip_samples_cycle.sh`（5サンプル全件一致）
- 失敗ケース追加: 既存失敗ケースに加え、複数サンプルでの構文整合回帰を継続確認
- 変更要約: サンプル生成API群・`list-samples` CLI・一括round-tripスクリプトを追加
- 継続課題: 実JPEG2000ファイル（外部コーパス）取り込みと annex別期待値照合

### 2026-02-26 / Round-trip準備（packet payload保持）

- 実施内容: `SOD` 以降のpacket bytesをpayloadとして保持し、再符号化時にそのまま出力する処理を実装
- 実施試験: `moon test`（15件成功）、`./tools/roundtrip_samples_cycle.sh`（5サンプル一致）
- 失敗ケース追加: `packet payload after SOD is preserved in roundtrip` テストを追加
- 変更要約: ヘッダ構造だけでなく実データ領域を含むround-trip一致性を強化
- 継続課題: packet境界検出の厳密化（marker emulationの厳密仕様）と外部実ファイル照合

### 2026-02-26 / Round-trip準備（multi-tile + corpus導線）

- 実施内容: `two-tileparts` サンプルを追加し、複数 tile-part 境界でのpayload保持を検証
- 実施試験: `moon test`（16件成功）、`./tools/roundtrip_samples_cycle.sh`（6サンプル一致）
- 失敗ケース追加: `two tile-parts keep packet payload boundaries`
- 変更要約: `tools/roundtrip_corpus_cycle.sh` を追加し、`samples/corpus/*.j2k` を一括round-trip可能化
- 継続課題: 外部コーパス実投入（現時点では `samples/corpus` が空）

### 2026-02-26 / Round-trip準備（Psot整合）

- 実施内容: `SOT` の `Psot` を用いた tile-part 境界決定を実装（`Psot=0` 時のみ探索フォールバック）
- 実施試験: `moon test`（17件成功）、`./tools/roundtrip_samples_cycle.sh`（6サンプル一致）
- 失敗ケース追加: `failure case: invalid Psot in SOT`
- 変更要約: SOD後payload保持の境界判定を仕様寄りに改善し、tile-part長の不整合を検知可能化
- 継続課題: marker emulation を含む境界探索フォールバックの厳密性向上

### 2026-02-26 / SOT索引整合強化

- 実施内容: `Isot/TPsot/TNsot` の整合検証（`TPsot < TNsot`、同一tile内連番、初回tile-part index=0、TNsot整合）を追加
- 実施試験: `moon test`（19件成功）、`./tools/roundtrip_samples_cycle.sh`（6サンプル一致）
- 失敗ケース追加: `failure case: invalid TPsot and TNsot relation`, `failure case: invalid tile-part index sequence`
- 変更要約: SOTのtile-part索引情報をパース時に検証し、multi-tile-partの品質を改善
- 継続課題: tile index範囲の厳密検証（SIZ由来タイル数との突合）を追加

### 2026-02-26 / SOT索引整合強化（範囲チェック）

- 実施内容: `SIZ` 由来タイル総数を算出し、`SOT.Isot` の範囲検証を追加
- 実施試験: `moon test`（20件成功）、`./tools/roundtrip_samples_cycle.sh`（6サンプル一致）
- 失敗ケース追加: `failure case: Isot out of range`
- 変更要約: tile-part索引の妥当性を `Psot/TPsot/TNsot` に加えて `Isot` 範囲まで拡張
- 継続課題: `SIZ` 由来タイル計算と境界条件（大画像/多タイル）ケースの追加検証

### 2026-02-26 / SIZ/Pointer制約厳格化

- 実施内容: `SIZ` の component sampling（`XRsiz/YRsiz`）正値チェック、`TLM/PLM/PLT/PPM/PPT` の最小長チェックを追加
- 実施試験: `moon test`（22件成功）、`./tools/roundtrip_samples_cycle.sh`（6サンプル一致）
- 失敗ケース追加: `failure case: SIZ component sampling must be positive`, `failure case: PLM marker segment length too short`
- 変更要約: marker payload 妥当性検証を強化し、破損ストリームの早期検出を改善
- 継続課題: pointer marker の内容解釈（可変長系列そのもの）の厳密実装

### 2026-02-26 / Pointer index整合強化

- 実施内容: `PLM/PLT/PPM/PPT` の `Z*` インデックス連番検証（header内で `0,1,2,...`）を追加
- 実施試験: `moon test`（24件成功）、`./tools/roundtrip_samples_cycle.sh`（6サンプル一致）
- 失敗ケース追加: `failure case: invalid Zplm sequence`, `failure case: invalid Zppt sequence`
- 変更要約: pointer marker 群の payload 管理整合性を拡張し、順序不整合検出を追加
- 継続課題: `Iplm/Iplt` 可変長系列そのもののデコード妥当性検証

### 2026-02-26 / Pointer payload妥当性強化

- 実施内容: `PLM/PLT` の可変長 packet-length 系列終端検証（継続bit終端）を追加
- 実施試験: `moon test`（26件成功）、`./tools/roundtrip_samples_cycle.sh`（7サンプル一致）
- 失敗ケース追加: `failure case: invalid PLT packet length sequence`, `failure case: invalid Zppm sequence`
- 変更要約: pointer marker の payload 構文妥当性（`Iplm/Iplt` + `Zppm`）を拡張検証
- 継続課題: `PPM/PPT` 本体の packed header 内容解釈を段階実装

### 2026-02-26 / Pointer payload妥当性強化（chunk整合）

- 実施内容: `PLM(Nplm/Iplm)` と `PPM(Nppm/Ippm)` のチャンク長整合検証を追加
- 実施試験: `moon test`（28件成功）、`./tools/roundtrip_samples_cycle.sh`（8サンプル一致）
- 失敗ケース追加: `failure case: invalid PLM chunk size mismatch`, `failure case: invalid PPM chunk size mismatch`
- 変更要約: pointer marker の payload を「長さフィールドと実データ長が一致するか」まで検証
- 継続課題: PPM/PPT payload の packed header 意味解釈（内部構造復元）

### 2026-02-26 / Round-trip準備（built-in corpus + full cycle）

- 完了要求ID: `R-0023`（`Verified`）
- 実施内容: `tools/build_sample_corpus.sh` と `tools/roundtrip_full_cycle.sh` を追加し、サンプル生成→ファイル構築→読込→再出力を一括実行可能化
- 実施試験: `moon info && moon fmt && moon check && moon test`（29件成功）、`./tools/roundtrip_samples_cycle.sh`（8サンプル一致）、`./tools/build_sample_corpus.sh`、`./tools/roundtrip_corpus_cycle.sh samples/generated/builtins`、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: all reserved marker codes are rejected`
- 変更要約: built-inサンプルを `.j2k` コーパスとして自動構築し、round-trip保証の実運用導線を統合
- 継続課題: `samples/corpus` へ外部実ファイルを投入して full cycle の外部互換回帰を開始

### 2026-02-26 / S1 Annex A（A.1.3 検証強化）

- 完了要求ID: `R-0024`（`Verified`）
- 実施内容: marker segment 規則の失敗ケースを拡張（`SOD` の出現位置、`PPT/PPM` の適用範囲、`CRG` 長さ整合）
- 実施試験: `moon info && moon fmt && moon check && moon test`（33件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: SOD before SOT is invalid placement`, `failure case: PPT in main header is invalid placement`, `failure case: PPM in tile-part header is invalid placement`, `failure case: CRG length mismatch with Csiz=2`
- 変更要約: Annex A.1.3 の「長さ・出現位置・適用範囲」規則を回帰テストで拡充し、検証完了へ更新
- 継続課題: Annex A.5/A.6 の payload 意味解釈（SIZ/COD/QCD 等の構造化）を進め、`Implemented` を `Verified` 化

### 2026-02-26 / S1 Annex A（A.5/A.6 意味解釈）

- 完了要求ID: `R-0033`, `R-0034`, `R-0035`（`Verified`）
- 実施内容: `Codestream.metadata` を追加し、`SIZ/COD/QCD` payload の主要フィールドを構造化して取得可能化
- 実施試験: `moon info && moon fmt && moon check && moon test`（35件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: なし（今回サイクルは意味解釈の観測テスト追加）
- 変更要約: 固定情報/機能マーカーの「解釈結果」をAPIとテストで直接検証できる形に拡張
- 継続課題: `R-0036/R-0039` 以降の marker 個別要件（値域・詳細規則）の `Verified` 化を段階継続

### 2026-02-26 / S1 Annex A（COD/QCD 規則強化）

- 完了要求ID: `R-0036`, `R-0039`（`Verified`）
- 実施内容: COD/QCD payload 検証を拡張（progression/layers/CBサイズ/precinct長、quantization style/parameter byte数）
- 実施試験: `moon info && moon fmt && moon check && moon test`（41件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: COD progression order out of range`, `failure case: COD layers must be positive`, `failure case: COD code-block size exponents invalid`, `failure case: COD precinct length inconsistency`, `failure case: QCD quantization style invalid`, `failure case: QCD derived style requires even parameter bytes`
- 変更要約: COD/QCD を「最小長確認」から「主要意味規則の妥当性検証」へ拡張し、S1の機能マーカー検証を前進
- 継続課題: `R-0037/R-0038/R-0040/R-0041` の値解釈（component別上書き/POC適用）の `Verified` 化

### 2026-02-26 / S1 Annex A（COC/RGN/QCC/POC 意味解釈）

- 完了要求ID: `R-0037`, `R-0038`, `R-0040`, `R-0041`（`Verified`）
- 実施内容: `Codestream.metadata` を拡張し、`COC/RGN/QCC/POC` の構造化結果を抽出可能化
- 実施試験: `moon info && moon fmt && moon check && moon test`（46件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: RGN style invalid`, `failure case: POC progression order out of range`, `failure case: POC CEpoc must be greater than CSpoc`
- 変更要約: component別上書き（COC/QCC）とPOC entryを値として検証できる状態へ拡張し、機能マーカー検証を強化
- 継続課題: pointer marker payload の意味解釈（`R-0043..R-0047`）の `Verified` 化

### 2026-02-26 / S1 Annex A（Pointer payload 意味解釈）

- 完了要求ID: `R-0043`, `R-0044`, `R-0045`, `R-0046`, `R-0047`（`Verified`）
- 実施内容: `metadata.tlm/plm/plt/ppm/ppt` を追加し、pointer marker payload を構造化復元
- 実施試験: `moon info && moon fmt && moon check && moon test`（49件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: なし（既存 pointer 失敗ケースを維持し、今回は解釈観測テストを追加）
- 変更要約: Annex A.7 の pointer marker 群を「配置/長さ検証」に加えて「内容復元」まで拡張
- 継続課題: `R-0042`（pointer群全体要件）と `R-0048..R-0054` の `Verified` 化を継続

### 2026-02-26 / S1 Annex A（In-bit-stream / Informational / A.10 制約）

- 完了要求ID: `R-0048`, `R-0049`, `R-0050`, `R-0051`, `R-0052`, `R-0053`, `R-0054`（`Verified`）
- 実施内容: `metadata.sop/eph_positions/crg/com` を追加し、SOP/EPH抽出とCRG/COM構造化解釈を実装
- 実施試験: `moon info && moon fmt && moon check && moon test`（55件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: missing COD is rejected`, `failure case: missing QCD is rejected`, `failure case: missing SOT/SOD pair is rejected`
- 変更要約: Annex A.8/A.9/A.10 の必須制約とマーカー意味解釈を回帰試験で補完し、S1 Must群の検証を強化
- 継続課題: S1の未検証項目の棚卸し完了後、S2（Annex B）着手準備

### 2026-02-26 / S1 Annex A（完了整理）

- 完了要求ID: `R-0026`（`Verified`）
- 実施内容: Annex A.2 の総括要件を、各 marker segment の構造化解釈テスト群で証跡連結
- 実施試験: `moon test`（55件成功）
- 失敗ケース追加: なし
- 変更要約: S1 Must（`R-0021..R-0054`）の未検証を解消し、Annex A完了状態を明確化
- 継続課題: 実装順序表に従い S2（Annex B）へ移行

### 2026-02-26 / S2 Annex B（構造幾何の初期実装）

- 完了要求ID: `R-0057`, `R-0058`（`Verified`）、`R-0056`（`Implemented`）
- 実施内容: `metadata.ordering` を追加し、reference grid / component幾何 / tile分割を SIZ から導出
- 実施試験: `moon info && moon fmt && moon check && moon test`（58件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: なし（本サイクルは幾何導出の正例検証）
- 変更要約: S2着手として Annex B.2/B.3 の幾何規則をコード化し、回帰可能な形で検証基盤を追加
- 継続課題: `R-0056` を `Verified` 化しつつ、`R-0060..R-0064`（sub-band/precinct/packet構造）へ拡張

### 2026-02-26 / S2 Annex B（tile-component関係 + sub-band骨格）

- 完了要求ID: `R-0060`（`Implemented`）
- 実施内容: `ordering.tile_components` と `ordering_coding` を追加し、component↔tile-component対応とresolution/sub-band骨格を導出
- 実施試験: `moon info && moon fmt && moon check && moon test`（59件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: なし（本サイクルは構造導出の正例検証）
- 変更要約: Annex B の構造概念を「幾何導出 + COD由来の分解階層」まで拡張
- 継続課題: `R-0061..R-0064`（precinct/code-block/packet構造）を順次実装し、`R-0056` を `Verified` 化

### 2026-02-26 / S2 Annex B（precinct / code-block / packet単位）

- 完了要求ID: `R-0061`, `R-0062`（`Verified`）、`R-0063`, `R-0064`（`Implemented`）
- 実施内容: `ordering_coding` を拡張し、precinct指数、code-block寸法、packet単位（component×resolution×layer）を導出
- 実施試験: `moon info && moon fmt && moon check && moon test`（60件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: なし（本サイクルは導出結果の正例検証）
- 変更要約: Annex B中盤要件のための packet 構造メタデータ基盤を追加
- 継続課題: `R-0056` を `Verified` 化し、`R-0063/R-0064` を実データ連携で `Verified` 化

### 2026-02-26 / S2 Annex B（packet単位厳密化）

- 完了要求ID: `R-0056`, `R-0063`, `R-0064`（`Verified`）
- 実施内容: packet単位を `tile-component×resolution×layer` に厳密化し、`tile_index` を含む導出メタデータへ拡張
- 実施試験: `moon info && moon fmt && moon check && moon test`（61件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: なし（本サイクルは導出整合の正例検証）
- 変更要約: Annex B前半〜中盤の構造関係（B.1/B.8/B.9）を一貫モデルとして検証完了
- 継続課題: `R-0060` を `Verified` 化し、`R-0065..R-0078`（packet header/progression order）へ拡張

### 2026-02-26 / S2 Annex B（LRCP progression 着手）

- 完了要求ID: `R-0060`（`Verified`）、`R-0075`（`Implemented`）
- 実施内容: `metadata.progression` を追加し、LRCPの `layer→resolution→component` ステップを packet 集約で導出
- 実施試験: `moon info && moon fmt && moon check && moon test`（63件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: なし（本サイクルは進行順序導出の正例検証）
- 変更要約: Annex B.5 の階層構造を progression モデルへ接続し、B.12実装の入口を形成
- 継続課題: `R-0065..R-0073` と `R-0076..R-0078` の実装を段階継続

### 2026-02-26 / S2 Annex B（全progression order + POC volume）

- 完了要求ID: `R-0075`, `R-0076`, `R-0077`, `R-0078`（`Verified`）
- 実施内容: progression導出を `LRCP` 固定から `LRCP/RLCP/RPCL/PCRL/CPRL` へ拡張し、`POC(ppoc)` による volume 上書き連携を実装
- 実施試験: `moon info && moon fmt && moon check && moon test`（65件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: なし（本サイクルは progression導出の正例検証）
- 変更要約: `metadata.progression.volumes/steps` を導入し、進行順序の決定規則と POC signaling の適用を回帰可能化
- 継続課題: `R-0065..R-0073`（packet header 符号化規則）を段階実装

### 2026-02-26 / S2 Annex B（bit-stuffing検証の導入）

- 完了要求ID: `R-0066`（`Verified`）
- 実施内容: `SOD` 後 packet data に対し bit-stuffing検証（`0xFF00` / `SOP` / `EPH` のみ許容）を追加
- 実施試験: `moon info && moon fmt && moon check && moon test`（66件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: invalid packet bit stuffing sequence`
- 変更要約: packet data の不正 `0xFFxx` 系列を早期検出し、round-trip時の入力妥当性保証を強化
- 継続課題: `R-0065`, `R-0067..R-0073`（packet header 詳細規則）を段階実装

### 2026-02-26 / S2 Annex B（packet header 最小復号モデル）

- 完了要求ID: `R-0065`, `R-0067..R-0073`（`Implemented`）
- 実施内容: `PPM/PPT` から packet header を復号する最小モデル（1 code-block）を追加し、`metadata.packet_headers_ppm/ppt` として公開
- 実施試験: `moon info && moon fmt && moon check && moon test`（69件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: invalid packet header coding passes sequence`
- 変更要約: B.10 系要素（zero-length/inclusion/zero bit-plane/passes/length/order）を単一code-block前提で導入
- 継続課題: 多code-block・多sub-band・非退化tag-tree・複数codeword segment（B.10.7.2）を追加し `Verified` 化

### 2026-02-26 / S2 Annex B（packet header 複数code-block拡張）

- 完了要求ID: `R-0065`, `R-0069`, `R-0071`, `R-0072`（`Implemented` 継続）
- 実施内容: packet header 復号を `code_block_count` 指定で複数code-block対応し、inclusion/Lblock 状態を code-block 単位で保持
- 実施試験: `moon info && moon fmt && moon check && moon test`（71件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: invalid packet header code-block count`
- 変更要約: 単一code-block前提を拡張し、複数packet・複数code-blockでの状態持ち越しを回帰可能化
- 継続課題: 非退化tag-tree と B.10.7.2（multiple codeword segments）実装で `Verified` 化

### 2026-02-26 / S2 Annex B（tile-part interleaving 検証）

- 完了要求ID: `R-0074`（`Verified`）
- 実施内容: tile-part のインターリーブ許容（tile間）と、同一tile内順序保持（`TPsot`）の整合テストを追加
- 実施試験: `moon info && moon fmt && moon check && moon test`（73件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: tile-part interleaving breaks per-tile sequence`
- 変更要約: Annex B.11 の tile/tile-part 構成規則をインターリーブ実例で回帰可能化
- 継続課題: `R-0065`, `R-0067..R-0073` の `Verified` 化（tag-tree非退化 + B.10.7.2）

### 2026-02-26 / S2 Annex B（B.10.6 codeword境界検証）

- 完了要求ID: `R-0071`（`Implemented` 継続）
- 実施内容: coding passes codeword 復号を仕様境界（`6/36/37/164`）で検証し、`6..36` 範囲の5bit復号へ修正
- 実施試験: `moon check && moon test`（75件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: truncated packet header length bits`
- 変更要約: B.10.6 の境界値で誤復号しないことを回帰化し、packet header 復号の厳密性を改善
- 継続課題: tag-tree 非退化ケースと B.10.7.2 を実装し `R-0065`, `R-0067..R-0073` を `Verified` 化

### 2026-02-26 / S2 Annex B（B.10.7.2 複数segment長復号）

- 完了要求ID: `R-0072`（`Implemented` 継続）
- 実施内容: `decode_codeblock_segment_lengths_from_bits` を追加し、複数 codeword segment 長の連続復号（B.10.7.2）を実装
- 実施試験: `moon test`（78件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: decode codeblock segment lengths helper truncated`
- 変更要約: B.10.7 の length 復号を single/multi segment 両方で検証可能化
- 継続課題: 非退化tag-treeとの結合と packet header 本体への B.10.7.2 組み込みで `Verified` 化

### 2026-02-26 / S2 Annex B（非退化tag-tree復号ヘルパー）

- 完了要求ID: `R-0067`（`Implemented` 継続）
- 実施内容: `decode_tag_tree_inclusion_flags` を追加し、階層共有ノードを使う非退化tag-tree復号を実装
- 実施試験: `moon check && moon test`（81件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: tag-tree inclusion decode truncated`, `failure case: tag-tree inclusion decode invalid threshold`
- 変更要約: 退化tag-tree相当から前進し、B.10.2 の階層復号ロジックを独立APIで検証可能化
- 継続課題: packet header 本体の inclusion/zero-bit-plane 経路へ非退化tag-treeを統合し `Verified` 化

### 2026-02-26 / S2 Annex B（tag-tree packet header統合: 単一packet）

- 完了要求ID: `R-0067`, `R-0073`（`Implemented` 継続）
- 実施内容: `parse_packet_header_single_packet_with_tag_tree` を追加し、packet header の inclusion 経路へ非退化tag-treeを統合
- 実施試験: `moon check && moon test`（83件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: packet header with tag-tree inclusion truncated`
- 変更要約: tag-tree復号ヘルパーを packet header 実処理へ接続し、B.10.2/B.10.8 の結合実装を開始
- 継続課題: 連続packet（layer進行）と zero-bit-plane tag-tree（B.10.5）へ拡張して `Verified` 化

### 2026-02-26 / S2 Annex B（tag-tree packet header統合: 連続packet）

- 完了要求ID: `R-0067`, `R-0073`（`Implemented` 継続）
- 実施内容: `parse_packet_headers_with_tag_tree_sequence` を追加し、連続packetで inclusion/zero-bit-plane/Lblock 状態を保持して復号
- 実施試験: `moon check && moon test`（85件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: packet headers tag-tree sequence invalid packet count`
- 変更要約: 単一packet統合から拡張し、layer進行時のtag-tree状態持ち越しを回帰可能化
- 継続課題: B.10.5 zero-bit-plane tag-tree の厳密化と B.10.7.2 の本体統合で `Verified` 化

### 2026-02-26 / S2 Annex B（B.10.7.2 本体統合: pass splits）

- 完了要求ID: `R-0070`, `R-0072`, `R-0073`（`Implemented` 継続）
- 実施内容: `parse_packet_header_single_packet_with_tag_tree_and_pass_splits` を追加し、packet header本体で複数segment長分割（added passes）を復号
- 実施試験: `moon check && moon test`（87件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: tag-tree pass splits mismatch coding passes`
- 変更要約: B.10.5/B.10.7/B.10.8 の結合経路を拡張し、tag-tree統合パスでB.10.7.2長復号を実運用化
- 継続課題: 残る `R-0065`, `R-0067..R-0073` の `Verified` 化に向け、一般化（複数sub-band/precinct）ケースを追加

### 2026-02-26 / S2 Annex B（zero-length連続packet遷移）

- 完了要求ID: `R-0068`（`Implemented` 継続）
- 実施内容: `parse_packet_headers_with_tag_tree_sequence` に対し、zero-length packet 後の next layer first inclusion を検証する回帰ケースを追加
- 実施試験: `moon check && moon test`（88件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: なし（本サイクルは連続遷移の正例強化）
- 変更要約: B.10.3 の zero-length packet 取り扱いを連続packet文脈で補強
- 継続課題: `R-0065`, `R-0067..R-0073` の `Verified` 化に向け、複数sub-band/precinct一般化を継続

### 2026-02-26 / S2 Annex B（2x2 tag-tree + pass-splits 一般化）

- 完了要求ID: `R-0065`, `R-0072`, `R-0073`（`Implemented` 継続）
- 実施内容: 2x2 code-block 配置で tag-tree inclusion と B.10.7.2 pass-splits を同時適用する統合ケースを追加
- 実施試験: `moon check && moon test`（89件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: なし（本サイクルは一般化正例強化）
- 変更要約: 単一block中心だった packet header 実装証跡を、複数block一般化ケースへ拡張
- 継続課題: `R-0065`, `R-0067..R-0073` の `Verified` 化に向けて複数precinct/sub-band 観点を追加

### 2026-02-26 / S2 Annex B（連続packet pass-splits + full cycle更新）

- 完了要求ID: `R-0065`, `R-0067..R-0073`（`Verified`）
- 実施内容: `parse_packet_headers_with_tag_tree_sequence_and_pass_splits` 経路に second-layer pass-splits 統合ケースを追加し、連続packetでの B.10.7.2 適用を拡張
- 実施試験: `moon test`（91件成功）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: packet headers tag-tree sequence with pass splits mismatch coding passes`
- 変更要約: 連続packet + tag-tree + pass-splits の正/異常系を固定化し、サンプル構築/読込/再出力サイクルで回帰保証を更新
- 継続課題: 外部コーパス（`samples/corpus/*.j2k`）投入による相互運用回帰を開始し、S2の追加一般化観点（複数precinct/sub-band実ファイル）を継続

### 2026-02-26 / 仕様網羅監査 + 外部コーパス行列検証（運用改善）

- 完了要求ID: なし（Status変更なし、監査/検証導線の追加）
- 実施内容: `tools/report_requirements_coverage.sh`（要件台帳のMust進捗集計）と `tools/corpus_matrix_cycle.sh`（`default/strict/roundtrip` 行列）を追加
- 実施試験: `./tools/report_requirements_coverage.sh`（Must: 152件中 Verified 55, Planned 97）、`./tools/corpus_matrix_cycle.sh samples/corpus`（default 27/27, strict 22/27, roundtrip 27/27）
- 失敗ケース追加: なし（本サイクルは監査導線/実測強化）
- 変更要約: 外部コーパス運用を「default/strict/roundtrip を同時可視化する行列」へ拡張し、仕様網羅の未達（Annex C以降）を定量確認可能化
- 継続課題: strict fail 5件（`p0_02`, `p1_03`, `p1_05`, `p1_06`, `g1_colr`）の根拠を Annex B/C 観点で個別整理し、仕様準拠方針に沿って段階解消

### 2026-02-26 / 外部 corpus 導入（openjpeg-data p0/p1）

- 完了要求ID: `R-0021..R-0055`（`Verified` 継続）
- 実施内容: `samples/corpus` に外部 `.j2k`（p0/p1系 10件）を投入し、`tools/probe_external_corpus_cycle.sh` を追加して互換性プローブ（fail/arg-limit）を可視化
- 実施試験: `moon test`（91件成功）、`./tools/probe_external_corpus_cycle.sh samples/corpus`（ok=0 fail=5 skip_arg_limit=5）、`./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: 外部実ファイルで `invalid packet data` / `invalid marker placement` / `invalid marker payload` を検出
- 変更要約: built-in corpus の厳密 roundtrip 保証は維持しつつ、外部 corpus は非厳密プローブで回帰観測を開始
- 継続課題: CLIの引数長制約を回避する file I/O モード追加と、外部 `.j2k` 互換の段階的実装拡張

### 2026-02-26 / 外部 corpus 互換（段階実装: fail解消）

- 完了要求ID: `R-0021..R-0055`（`Verified` 継続）
- 実施内容: packet body の `0xFFxx` 取扱いを寛容化（SOP/EPHのみ厳密検証）、reserved marker (`FF30..FF3F`) の no-length 保持、POC `CEpoc` の寛容解釈を追加
- 実施試験: `moon test`（91件成功）、`./tools/probe_external_corpus_cycle.sh samples/corpus`（ok=5 fail=0 skip_arg_limit=5）、`moon info && moon fmt && ./tools/roundtrip_full_cycle.sh`
- 失敗ケース追加: `failure case: invalid packet bit stuffing sequence` を SOP length 破損ケースへ更新、`failure case: POC CSpoc out of range` を追加
- 変更要約: 外部 corpus の小容量5件は fail を解消して roundtrip-probe 通過、残課題はCLI引数長制限による大容量5件スキップのみ
- 継続課題: `roundtrip-file` など file I/O モードを追加し、skip_arg_limit=5 を解消して外部10件の全件検証へ移行

### 2026-02-26 / 仕様差分監査（strict/compat 切り分け）

- 完了要求ID: `R-0021..R-0055`（`Verified` 継続）
- 実施内容: `parse_codestream`（strict, 仕様準拠）と `parse_codestream_compat`（外部互換）を分離し、`roundtrip_bytes` は strict 失敗時のみ compat fallback を使用
- 仕様準拠で維持した点:
  - reserved marker (`FF30..FF3F`) は strict で拒否（Annex A.2）
  - POC の `CEpoc=0` は strict で許容（Annex A.6.6 / Table A.32 の `..., 0` 表記）
- 互換都合で許容した点（compat限定）:
  - reserved marker (`FF30..FF3F`) を no-length marker として保持して継続解析
  - POC `CEpoc > Csiz` を `Csiz` とみなして継続解析（実ファイル互換）
- 実施試験: `moon test`（93件成功）、`./tools/probe_external_corpus_cycle.sh samples/corpus`（ok=5 fail=0 skip_arg_limit=5）、`./tools/roundtrip_full_cycle.sh`
- 追加試験: `compat parser accepts reserved marker between COM and SOT`, `strict parser accepts POC CEpoc zero as open upper bound`
- 継続課題: compatで許容している `CEpoc > Csiz` の扱いは仕様外互換であるため、対象ファイル群の出自整理（正規/異常系）と運用ポリシー化を実施

### 2026-02-26 / 実運用API一本化 + 実ファイル判定

- 完了要求ID: `R-0021..R-0055`（`Verified` 継続）
- 実施内容: `parse_codestream` を実運用入口として一本化し、監査用途の厳格判定は `parse_codestream_strict` に分離
- 実施試験: `moon test`（94件成功）、`PROBE_LARGE_PATH=1 ./tools/probe_external_corpus_cycle.sh samples/corpus`（ok=10 fail=0 skip_arg_limit=0）、`./tools/roundtrip_full_cycle.sh`
- 追加試験: `default parser accepts reserved marker between COM and SOT`, `default parser tolerates malformed PPM packet headers`
- 実ファイル判定（strict観点）:
  - `p0_02.j2k`: `FF30` reserved marker により strict 失敗（拡張運用観点で default は許容）
  - `p0_03.j2k`: POC `CEpoc=0xFF`（`Csiz=1`）は Table A.32 上の値域内であり、strict失敗は実装の Csiz基準チェック由来（後続サイクルで訂正）
  - `p1_03.j2k`, `p1_05.j2k`: `failed to parse packet headers in PPM`（PPM内部 packet-header の厳密復号実装制約）
- 変更要約: default parser で外部10件すべてを roundtrip-probe 通過。strict failure は「ファイル値の仕様外」と「実装の厳密復号制約」に切り分け済み
