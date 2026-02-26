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
