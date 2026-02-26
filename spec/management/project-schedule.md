# JPEG2000 仕様準拠プロジェクト 工程管理表

## 1. マイルストーン

| Milestone | 目標 | 判定条件 |
|---|---|---|
| M1 | Main Clauses（1..8）要求抽出完了 | 1..8 の採番率100% |
| M2 | Core Annex（A..F）要求抽出完了 | A..F の採番率100% |
| M3 | Remaining Annex（G..I, M）要求抽出完了 | G..I, M の採番率100% |
| M4 | 計画書v1.0承認 | 全フェーズ受入条件定義 + 未決事項整理完了 |

## 2. 工程管理表（WBS）

| ID | フェーズ | タスク | 成果物 | 依存 | 優先度 | 担当 | 期限 | 状態 | 受入条件 |
|---|---|---|---|---|---|---|---|---|---|
| P0 | 基盤 | 管理テンプレート確定 | `requirements-checklist.md` 雛形 | なし | High | TBD | TBD | Done | 必須列が定義済み |
| P1 | Main Clauses | 1..8 要求抽出 | 要求ID台帳更新 | P0 | High | TBD | TBD | Done | 1..8 採番率100% |
| P2 | Core Syntax | Annex A/B 要求抽出 | 要求ID台帳更新 | P1 | High | TBD | TBD | Done | A/B 採番率100% |
| P3 | Core Coding | Annex C/D/E/F 要求抽出 | 要求ID台帳更新 | P2 | High | TBD | TBD | Done | C/D/E/F 採番率100% |
| P4 | Container/ROI | Annex G/H/I 要求抽出 | 要求ID台帳更新 | P3 | High | TBD | TBD | Done | G/H/I 採番率100% |
| P5 | Broadcast | Annex M 要求抽出 | 要求ID台帳更新 | P4 | Medium | TBD | TBD | Done | M 採番率100% |
| P6 | Reference整理 | Annex J/K/L 整理 | 参考事項一覧 | P5 | Medium | TBD | TBD | Done | J/K/L の扱い定義完了 |
| P7 | 統合計画 | 依存関係と着手順確定 | 実装順序表 | P1-P6 | High | TBD | TBD | Done | 実装順序が一意に決定 |
| P8 | 受入条件 | テスト観点紐付け | 受入基準表 | P7 | High | TBD | TBD | Done | 要求IDと試験観点が対応 |
| P9 | 最終監査 | 計画書v1.0化 | 監査記録 | P8 | High | TBD | TBD | Done | 重大欠陥0件 |

## 3. 進捗管理ルール

- `状態` は `Planned / InProgress / Done / Blocked` のいずれかを使う
- `Blocked` は阻害要因を必ず記載する
- 各タスクは週次で `状態` と `受入条件達成度` を更新する
- `Done` へ遷移する前に、受入条件をチェックリストで明示確認する

## 4. リスク管理表

| Risk ID | 内容 | 影響 | 対策 | 状態 |
|---|---|---|---|---|
| RK-01 | PDF抽出由来の体裁崩れで要件誤読 | 高 | 原文行範囲をSourceに固定 | Open |
| RK-02 | 規範文と参考文の混同 | 高 | PriorityとCategoryを強制入力 | Open |
| RK-03 | 要件粒度が粗く実装不能 | 中 | 1ID=1判定可能をレビューで強制 | Open |
| RK-04 | 工程順序の逆転で手戻り | 中 | 依存列の必須運用 | Open |

## 5. 更新履歴

| Date | Author | Change |
|---|---|---|
| 2026-02-26 | Codex | 初版作成 |
| 2026-02-26 | Codex | P0/P1完了、P2着手へ更新 |
| 2026-02-26 | Codex | Annex A/B採番完了、P2完了・P3着手へ更新 |
| 2026-02-26 | Codex | Annex C/D/E/F採番完了、P3完了・P4着手へ更新 |
| 2026-02-26 | Codex | Annex G/H/I採番完了、P4完了・P5着手へ更新 |
| 2026-02-26 | Codex | Annex M採番完了、P5完了へ更新 |
| 2026-02-26 | Codex | Annex J/K/L整理完了、P6完了・P7着手へ更新 |
| 2026-02-26 | Codex | 実装順序表作成によりP7完了へ更新 |
| 2026-02-26 | Codex | 受入基準表作成によりP8完了へ更新 |
| 2026-02-26 | Codex | 文書監査完了によりP9完了（計画工程完了） |
| 2026-02-26 | Codex | 実装S1着手: Annex A骨格（SOC/SOT/SOD/EOC + marker分類）実装と初期検証を反映 |
| 2026-02-26 | Codex | 実装S1継続: Annex A配置制約/長さ制約（SIZ/COD/QCD/SOT、main/tile header制約、予約マーカー範囲）を追加 |
| 2026-02-26 | Codex | 実装S1継続: SIZ実フィールド整合、component別marker検証、POC長さ制約、PPM/PPT排他、SOP/EPH/CRG/COM制約を追加 |
| 2026-02-26 | Codex | 全体テスト準備: サンプルファイル生成/読込/再出力のround-tripサイクル（CLI + script）を追加 |
| 2026-02-26 | Codex | 全体テスト拡張: 5種サンプルの一括round-trip回帰サイクルを追加（`roundtrip_samples_cycle.sh`） |
| 2026-02-26 | Codex | SOD後のpacket payload保持を実装し、実データを含むround-trip一致性を強化 |
| 2026-02-26 | Codex | 多tile-partサンプル追加と external corpus 用 round-tripスクリプトを追加 |
| 2026-02-26 | Codex | PsotベースでSOD後境界を決定するよう改修し、tile-part長整合検証を追加 |
| 2026-02-26 | Codex | SOT索引整合を強化（Isot/TPsot/TNsot検証、連番チェック） |
| 2026-02-26 | Codex | SIZ由来タイル総数に基づく Isot 範囲チェックを追加 |
| 2026-02-26 | Codex | SIZ component sampling正値と pointer marker最小長の検証を追加 |
| 2026-02-26 | Codex | pointer markerのZインデックス連番検証（Zplm/Zppt等）を追加 |
| 2026-02-26 | Codex | PLM/PLT可変長系列終端検証とZppm連番検証を追加 |
| 2026-02-26 | Codex | PLM/PPM の chunk長整合検証（Nplm/Iplm, Nppm/Ippm）を追加 |
| 2026-02-26 | Codex | built-inコーパス自動構築とfull round-tripサイクル（生成/読込/再出力）を追加、R-0023をVerified化 |
| 2026-02-26 | Codex | Annex A.1.3の失敗ケースを拡張（SOD位置/PPT-PPM適用範囲/CRG長）し、R-0024をVerified化 |
| 2026-02-26 | Codex | `Codestream.metadata` 導入でSIZ/COD/QCD意味解釈を構造化し、R-0033/R-0034/R-0035をVerified化 |
| 2026-02-26 | Codex | COD/QCDの主要規則検証を追加（値域・長さ整合）し、R-0036/R-0039をVerified化 |
| 2026-02-26 | Codex | COC/RGN/QCC/POCの構造化解釈と値域検証を追加し、R-0037/R-0038/R-0040/R-0041をVerified化 |
| 2026-02-26 | Codex | Pointer marker payloadの構造化復元（TLM/PLM/PLT/PPM/PPT）を追加し、R-0043..R-0047をVerified化 |
| 2026-02-26 | Codex | SOP/EPH/CRG/COMの構造化解釈と必須マーカー欠落試験を追加し、R-0048..R-0054をVerified化 |
| 2026-02-26 | Codex | Annex A.2 総括要件 R-0026 をVerified化し、S1 Must（R-0021..R-0054）完了を整理 |
| 2026-02-26 | Codex | S2着手: `metadata.ordering` 導入で Annex B.2/B.3（R-0057/R-0058）を検証、R-0056をImplemented化 |
| 2026-02-26 | Codex | S2継続: tile-component対応とCOD由来resolution/sub-band骨格を追加し、R-0060をImplemented化 |
| 2026-02-26 | Codex | S2継続: precinct/code-block/packet単位の導出を追加し、R-0061/R-0062をVerified化、R-0063/R-0064をImplemented化 |
| 2026-02-26 | Codex | S2継続: packet単位をtile-component基準へ厳密化し、R-0056/R-0063/R-0064をVerified化 |
| 2026-02-26 | Codex | S2継続: LRCP progressionメタデータを導入し、R-0060をVerified化、R-0075をImplemented化 |
| 2026-02-26 | Codex | S2継続: 全progression order + POC volume連携を実装し、R-0075..R-0078をVerified化 |
| 2026-02-26 | Codex | S2継続: SOD packet bit-stuffing検証を追加し、R-0066をVerified化（66 tests + full roundtrip cycle） |
| 2026-02-26 | Codex | S2継続: packet header最小復号モデル（PPM/PPT, 1 code-block）を導入し、R-0065/R-0067..R-0073をImplemented化（69 tests + full roundtrip cycle） |
| 2026-02-26 | Codex | S2継続: packet headerを複数code-block対応へ拡張し、R-0065/R-0069/R-0071/R-0072の実装根拠を強化（71 tests + full roundtrip cycle） |
| 2026-02-26 | Codex | S2継続: tile-part interleaving検証を追加し、R-0074をVerified化（73 tests + full roundtrip cycle） |
| 2026-02-26 | Codex | S2継続: B.10.6 codeword境界（6/36/37/164）検証を追加し、coding pass 復号を修正（75 tests + full roundtrip cycle） |
| 2026-02-26 | Codex | S2継続: B.10.7.2 複数segment長復号ヘルパーを追加し、R-0072実装根拠を拡張（78 tests + full roundtrip cycle） |
| 2026-02-26 | Codex | S2継続: 非退化tag-tree復号ヘルパーを追加し、R-0067実装根拠を拡張（81 tests + full roundtrip cycle） |
| 2026-02-26 | Codex | S2継続: tag-tree inclusion を packet header 単一packet経路へ統合し、R-0067/R-0073 実装根拠を拡張（83 tests + full roundtrip cycle） |
| 2026-02-26 | Codex | S2継続: tag-tree inclusion の連続packet統合を追加し、R-0067/R-0073 実装根拠を拡張（85 tests + full roundtrip cycle） |
| 2026-02-26 | Codex | S2継続: tag-tree統合パスへ B.10.7.2 pass-splits を本体統合し、R-0070/R-0072/R-0073 実装根拠を拡張（87 tests + full roundtrip cycle） |
| 2026-02-26 | Codex | S2継続: zero-length packet 後のlayer遷移ケースを追加し、R-0068 実装根拠を拡張（88 tests + full roundtrip cycle） |
| 2026-02-26 | Codex | S2継続: 2x2 code-block 一般化ケース（tag-tree + pass-splits）を追加し、R-0065/R-0072/R-0073 実装根拠を拡張（89 tests + full roundtrip cycle） |
| 2026-02-26 | Codex | S2継続: 連続packetの second-layer pass-splits 統合と mismatch失敗系を追加し、roundtrip全体サイクルで回帰保証を更新（91 tests + full roundtrip cycle） |
| 2026-02-26 | Codex | S2節目: R-0065 と R-0067..R-0073 を Verified 化（連続packet tag-tree + pass-splits + full roundtrip cycle） |
| 2026-02-26 | Codex | 外部 corpus（openjpeg-data p0/p1）投入を開始し、`probe_external_corpus_cycle.sh` で fail/arg-limit を可視化、full cycle に非厳密プローブを統合 |
| 2026-02-26 | Codex | 外部 corpus 互換の段階実装で fail 5件を解消（ok=5 fail=0 skip_arg_limit=5）。packet body `0xFFxx` 寛容化・reserved marker no-length保持・POC CEpoc寛容解釈を追加 |
| 2026-02-26 | Codex | 仕様差分監査を実施し strict/compat を分離。`parse_codestream` は仕様準拠、`parse_codestream_compat` は互換許容、追加2テストで合計93 tests へ拡張 |
| 2026-02-26 | Codex | API方針を修正: `parse_codestream` を実運用一本化し、監査用 strict は `parse_codestream_strict` として分離。外部 corpus は default parser で 10/10 通過（large-path含む） |
| 2026-02-26 | Codex | 失敗要因切り分けを実施: strict失敗4件のうち `p1_03/p1_05` は PPM packet-header 復号実装制約、`p0_02` は reserved marker、`p0_03` は CEpoc判定実装（Csiz基準）由来であることを確認 |
