# Claude Code Mastery — Curriculum + Evaluation

> Claude Code を「動かせる」から「**戦力として使い倒せる**」に引き上げるための学習教材＋自己評価フレームワーク。9ドメイン × 826ルールで体系化、Orchestrator + 9 Evaluator で自動採点。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 何ができるか

- **9 ドメインの学習教材**（基礎・コンテキスト・コア機能・拡張・自動化・ワークフロー・業務活用・セキュリティ・コスト）を 826 ルールで体系化
- **自己評価**: 自分のプロジェクトを 9 観点で 100 点満点採点 → 改善優先順位を提示
- **23 リポジトリの自動監視**: anthropics/claude-code 等のアップストリーム更新を `repo_monitor` で追跡し、教材の更新提案を自動生成

## こういう人向け

- 個人で Claude Code を使い始めたが「もっと高度な使い方があるはず」と感じている
- チームに Claude Code を導入したいが、メンバー間のレベル差が大きい
- 自社の Claude Code 利用が「ベストプラクティスから外れていないか」客観評価したい
- 教育担当として体系化された教材を探している

## 9 ドメイン教材

| # | ドメイン | 内容 |
|---|---|---|
| 01 | [基礎と設定](01_基礎と設定.md) | インストール、API キー、ワークスペース構成 |
| 02 | [コンテキストエンジニアリング](02_コンテキストエンジニアリング.md) | CLAUDE.md、メモリ、コンパクト戦略 |
| 03 | [コア機能](03_コア機能.md) | ツール使用、サブエージェント、Skill |
| 04 | [拡張機能](04_拡張機能.md) | MCP、Hooks、カスタムコマンド |
| 05 | [自動化と並列実行](05_自動化と並列実行.md) | Headless モード、worktree 並列、Cron |
| 06 | [ワークフローと方法論](06_ワークフローと方法論.md) | Plan-First、TDD、Fresh Context |
| 07 | [業務別活用](07_業務別活用.md) | 開発・調査・運用・教育シーンでの実例 |
| 08 | [セキュリティ](08_セキュリティ.md) | deny ルール、CVE 対応、二重防御 |
| 09 | [コストと運用](09_コストと運用.md) | Prompt Caching、トークン予算、ccusage |

学習計画は [00_全体マップ.md](00_全体マップ.md) を参照（8 週間プログラム）。

## クイックスタート

### 学習目的で使う

```bash
git clone <このリポジトリのURL>
cd claudecode-checker
```

[00_全体マップ.md](00_全体マップ.md) を開いて、自分のレベルに応じたスタート地点を選ぶ:

| 状態 | 開始ドメイン |
|---|---|
| Claude Code を初めて使う | 01 → 02 → 03 |
| 基本は分かるが効率が悪い | 02 → 06 → 09 |
| 中規模チーム導入を進めたい | 04 → 05 → 08 |

### 自分のプロジェクトを評価する

前提: Claude Code v1.0.111+, jq, gh CLI

```bash
claude
> /path/to/your-project を Claude Code 利用観点で評価して
```

`eval_system/agents/orchestrator.md` の Orchestrator が起動し、9 つの Evaluator が並行評価を実施します。

## 同梱コンテンツ

| ディレクトリ | 内容 |
|---|---|
| `01_基礎と設定.md` 〜 `09_コストと運用.md` | 9ドメインの学習教材 |
| `00_全体マップ.md` | 8週間学習計画・ロードマップ |
| `eval_system/scoring_model.md` | 1000点満点の評価基準 |
| `eval_system/agents/` | Orchestrator + 9 Evaluator のエージェント定義 |
| `eval_system/business_templates/` | 業務適用テンプレート（週報・月次レポート等） |
| `eval_system/scripts/` | 評価実行・スケジュール・セキュリティ監査スクリプト |
| `reference/` | MCPカタログ・プロンプトキャッシュ・脅威モデルの速引きリファレンス |
| `research/` | 各ドメインの元ソース（公式ドキュメント・ブログ等） |
| `scripts/repo_monitor/` | 23リポジトリの更新監視スクリプト |
| `templates/` | エージェント組織定義テンプレート |

## 関連

- [agent-checker](https://github.com/ChumTech-Team/agent-checker) — マルチエージェント組織の品質を 1000 点で評価する姉妹ツール
- [system-dev-framework](https://github.com/ChumTech-Team/system-dev-framework) — Claude Code 上で要件定義から実装まで進める開発フレームワーク

## ライセンス

[MIT License](LICENSE)

## クレジット

このカリキュラムは [ChumTech Inc.](https://chumtech.jp) が社内研修用に整備したものを、汎用化して公開しています。
