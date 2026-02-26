# JPEG2000 仕様準拠プロジェクト 作業手順書

## 1. 目的と適用範囲

本手順書は、`T.800-2015` に沿った JPEG2000 ライブラリ実装に向けて、仕様網羅チェックリストを運用しながら段階的に開発を進めるための標準手順を定義する。

本手順書の対象は計画・管理であり、実装の成否判定を可能にするためのトレーサビリティ整備を主眼とする。

## 2. 管理対象ドキュメント

- ``: 仕様全体のハブ、全体チェックリスト、索引
- `/sections/*.md`: 章・附属書分割済みの一次参照
- `spec/management/work-procedure.md`: 本手順書
- `spec/management/project-schedule.md`: 工程管理表
- `spec/management/requirements-checklist.md`: 要求ID台帳

## 3. 要求ID運用ルール

### 3.1 採番規則

- 要求ID形式: `R-0001` から連番
- 1つの要求IDは1つの判定可能要件に分割する
- 複数節にまたがる場合は主根拠節を1つに固定し、補足節をNotesに記載する

### 3.2 要求IDの必須列

`requirements-checklist.md` の各行は次の列を必須とする。

- `ReqID`: 要求ID
- `Source`: 章/節（例: `Annex A.5.2`）
- `Category`: `Decoder` / `Encoder` / `Container` / `Validation` / `Reference`
- `Priority`: `Must` / `Should` / `Optional`
- `Requirement`: 検証可能な要件文
- `Status`: `Planned` / `InProgress` / `Implemented` / `Verified` / `N-A`
- `TestLink`: 試験IDまたは将来テストへのリンク
- `Owner`: 担当
- `Notes`: 解釈・前提・保留事項

### 3.3 ステータス遷移

- 許可遷移:
  - `Planned -> InProgress`
  - `InProgress -> Implemented`
  - `Implemented -> Verified`
  - 任意状態 `-> N-A`（理由必須）
- 禁止遷移:
  - `Planned -> Verified`
  - 根拠・試験リンクなしの `Implemented/Verified`

## 4. 章別チェック運用

- 実装必須（標準トラック）:
  - `1..8`, `Annex A`, `B`, `C`, `D`, `E`, `F`, `G`, `H`, `I`, `M`
- 参考情報（実装必須外）:
  - `Annex J`, `K`, `L`
- ただし、参考情報でも要件解釈に影響する事項は `Category=Reference` で記録する

## 5. 更新手順

1. 対象節を `/sections/` で確認する
2. 要件を判定可能単位に分割し、要求IDを新規採番する
3. `requirements-checklist.md` に行追加する
4. `` の該当章チェック項目を更新する
5. `project-schedule.md` の対象タスク進捗を更新する
6. 変更履歴（更新者、日付、要点）をコミットメッセージまたはPR説明に記録する

## 6. レビュー基準

### 6.1 網羅性レビュー

- 章/附属書の未採番要求がないこと
- 要求ID重複がないこと
- Sourceが空欄でないこと

### 6.2 実装可能性レビュー

- Requirementがテスト可能な文になっていること
- 曖昧な要件（主語・条件・入出力不明）が残っていないこと
- `N-A` は理由が規範上妥当であること

### 6.3 一貫性レビュー

- 同一要件を複数IDで重複管理していないこと
- Category/Priorityが節の性質と一致すること
- 依存関係が工程管理表と矛盾しないこと

## 7. 完了定義（管理工程）

次をすべて満たした時点で、管理工程を完了とする。

1. 実装必須節の要求ID採番率が100%
2. 要求IDの必須列欠損が0件
3. 工程管理表における全フェーズの受入条件が定義済み
4. 実装着手に必要な未決定事項が0件、または明示的に保留登録済み

## 8. 変更管理

- 本手順書変更時は、影響範囲（採番規則、ステータス規則、受入条件）を先に明記する
- 既存要求IDの意味が変わる変更は避ける
- 意味変更が不可避な場合、旧IDを廃止せず `Notes` で互換履歴を残す
