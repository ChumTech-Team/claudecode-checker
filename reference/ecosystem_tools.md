# Claude Code エコシステムツールカタログ

> 作成日: 2026-03-28
> ソース: research/05, 09, 10 に記載された情報のみ

---

## 1. オーケストレーター

複数のClaude Codeインスタンスやエージェントを統括管理し、並列タスク実行を制御するツール群。

| ツール | 説明 | ソース |
|---|---|---|
| **Claude Squad** | 複数のClaude Codeインスタンスを統括管理。チーム単位でエージェントを管理し、タスク分配・進捗監視を行う | research/05 |
| **Ruflo** | タスクベースのエージェントオーケストレーター。プロジェクト管理とエージェント実行を統合 | research/05 |
| **Vibe Kanban** | カンバンボード形式でエージェントタスクを視覚的に管理。タスクの進捗をボード上で追跡 | research/05 |
| **TSK** | タスク管理に特化したオーケストレーションツール | research/05 |
| **agent-orchestrator** | 汎用的なエージェントオーケストレーションフレームワーク | research/05 |
| **`/orchestrate` コマンド** | マルチエージェントワークフローを調整するビルトインコマンド。`/multi-plan`, `/multi-execute` 等の関連コマンド群を含む（`ccg-workflow` ランタイム必要） | research/05 |
| **PM2 サービス管理 (`/pm2`)** | PM2ベースのサービスライフサイクル管理。複雑なマルチサービスワークフロー向け。6つの関連コマンドを提供 | research/05 |

---

## 2. コスト追跡・モニタリングツール

### 2.1 公式ツール

| ツール | 説明 | URL |
|---|---|---|
| **OpenTelemetry（OTEL）統合** | Claude CodeネイティブのOTELサポート。コスト・トークン使用量・生産性・チーム分析メトリクスを収集。ラッパーやサイドカー不要 | （組込み機能） |
| **claude-code-monitoring-guide** | Docker Composeで完全なテレメトリスタックをデプロイ。Prometheus + OTEL Collector + Grafana。リアルタイムコスト、トークン消費トレンド、採用率、ROI指標。229スター、32フォーク | https://github.com/anthropics/claude-code-monitoring-guide |

### 2.2 コミュニティツール

| ツール | 説明 | URL |
|---|---|---|
| **ccusage** | ローカルJSONLファイルからClaude Code使用量を分析するCLI。日別・月別・セッション別・5時間課金ウィンドウ分析。MCP統合対応 | https://github.com/ryoppippi/ccusage |
| **ccburn** | Claude Codeトークン消費のビジュアルバーンアップチャート。セッション（5時間ローリング）、週間、週間Sonnet制限を可視化 | PyPI / GitHub |
| **ccost** | 正確なClaude API使用量追跡・コスト分析。インテリジェント重複排除、多通貨対応 | https://github.com/carlosarraes/ccost |
| **ccboard** | Rustベースのモニタリング。TUI（9タブ）+ Webインターフェース。予算アラート、30日予測 | https://github.com/FlorianBruniaux/ccboard |
| **claude-code-otel** | 包括的なオブザーバビリティソリューション | https://github.com/ColeMurray/claude-code-otel |
| **claude_telemetry** | OTELラッパー。Logfire, Sentry, Honeycomb, Datadogへエクスポート。`claudia`コマンドで`claude`を置換 | https://github.com/TechNickAI/claude_telemetry |

### 2.3 コスト最適化関連ツール

| ツール/手法 | 説明 | ソース |
|---|---|---|
| **cc-copilot-bridge** | GitHub Copilot Pro（$10/月定額）経由でリクエストをルーティングし、トークン課金を回避するコスト管理手法 | research/09 |

---

## 3. セッション管理ツール・機能

| 機能/コマンド | 説明 | ソース |
|---|---|---|
| **`--session-id <id>`** | セッションを指定して会話を継続 | research/05 |
| **`--resume`** | 直前のセッションを再開 | research/05 |
| **`--continue`** | 直前のセッションのコンテキストを引き継いで新規プロンプトを実行 | research/05 |
| **V2 Session API** | `send()` + `stream()` 分離によるマルチターン会話。`sessionId`でセッション再開可能。`unstable_v2_createSession()` / `unstable_v2_resumeSession()` | research/05 |
| **`/context`** | トークン使用量を確認 | research/05 |
| **`/compact`** | コンテキストの圧縮（最大50%時点で実行推奨） | research/05 |
| **`/clear`** | タスク切替時にコンテキストリセット | research/05 |
| **`/rename`** | 複数インスタンス起動時のラベル付け | research/05 |
| **`/rewind`（Esc Esc）** | チェックポイント機能。gitベースの編集追跡 | research/05 |
| **`/extra-usage`** | オーバーフロー課金設定（拡張トークン予算） | research/05 |
| **`/fork`** | 現在のコンテキストをフォークして新しいエージェントコンテキストを生成 | research/05 |

---

## 4. 設定管理ツール・機能

| 機能/手法 | 説明 | ソース |
|---|---|---|
| **CLAUDE.md** | プロジェクトルールやコンテキストを記述する設定ファイル。学習モード設定やセッション終了フックの自動キャプチャにも利用 | research/09 |
| **`.claudeignore`** | 大きなファイルを除外しコンテキスト効率化 | research/09 |
| **モデル選択設定** | `settings.json` の `model` フィールドや `/model` コマンドでモデル切替。`CLAUDE_CODE_SUBAGENT_MODEL` 環境変数でサブエージェントモデル指定 | research/05 |
| **OTEL環境変数** | `CLAUDE_CODE_ENABLE_TELEMETRY`, `OTEL_METRICS_EXPORTER`, `OTEL_EXPORTER_OTLP_ENDPOINT` 等でテレメトリを設定 | research/09 |
| **トークン予算環境変数** | `MAX_THINKING_TOKENS`, `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` でトークン制御 | research/05 |
| **カスタム設定ファイル（GitHub Actions用）** | モデル、env、permissions、hooksをJSON形式で指定 | research/05 |

---

## 5. 代替UI/クライアント

| ツール/手法 | 説明 | ソース |
|---|---|---|
| **Simple Chat App** | React/Express WebSocketチャット（Agent SDKデモ） | research/05（claude-agent-sdk-demos） |
| **AskUserQuestion Previews** | HTMLカードUIで選択肢表示、WebSocket + Plan Mode（Agent SDKデモ） | research/05（claude-agent-sdk-demos） |
| **ccboard TUI/Web** | Rustベースの9タブTUI + Webインターフェースによるモニタリング | https://github.com/FlorianBruniaux/ccboard |

---

## 6. ステータスライン・進捗管理

| 機能 | 説明 | ソース |
|---|---|---|
| **`track_progress`（GitHub Actions）** | claude-code-actionの進捗トラッキングコメント有効化。リアルタイムでPR/Issueに進捗を表示 | research/05 |
| **`use_sticky_comment`（GitHub Actions）** | 単一コメントに進捗を統合表示 | research/05 |

---

## 7. 主要GitHubリポジトリカタログ

### 7.1 公式リポジトリ（Anthropic）

| リポジトリ | 用途 | スター | URL |
|---|---|---|---|
| **anthropics/claude-code-action** | GitHub Actions統合（PR/Issue自動レビュー・実装支援） | 6.7k | https://github.com/anthropics/claude-code-action |
| **anthropics/claude-agent-sdk-python** | Python Agent SDK | - | https://github.com/anthropics/claude-agent-sdk-python |
| **anthropics/claude-agent-sdk-demos** | Agent SDKデモ8種（Hello World, Research Agent, Email Agent等） | - | https://github.com/anthropics/claude-agent-sdk-demos |
| **anthropics/claude-code-monitoring-guide** | 公式モニタリングガイド（Prometheus + OTEL + Grafana） | 229 | https://github.com/anthropics/claude-code-monitoring-guide |
| **anthropics/claude-cookbooks** | Cookbook集（RAG, ツール統合, マルチモーダル, エージェントパターン等） | 36.5k | https://github.com/anthropics/claude-cookbooks |
| **anthropics/claude-quickstarts** | クイックスタート（Customer Support, Financial Analyst, Computer Use, Coding Agent等） | 15.7k | https://github.com/anthropics/claude-quickstarts |
| **anthropics/courses** | API Fundamentals等の教育用リポジトリ | - | https://github.com/anthropics/courses |
| **anthropics/skills** | 公式Agent Skills（Creative/Design, Development/Technical, Enterprise/Communication, Document Skills） | - | https://github.com/anthropics/skills |

### 7.2 コミュニティリポジトリ

#### 総合ガイド・ベストプラクティス

| リポジトリ | 説明 | スター | URL |
|---|---|---|---|
| **FlorianBruniaux/claude-code-ultimate-guide** | 23,000+行の教育ガイド。225テンプレート、271問クイズ、41ダイアグラム、脅威DB。MCPサーバーとして利用可能 | 2.4k | https://github.com/FlorianBruniaux/claude-code-ultimate-guide |
| **shanraisshan/claude-code-best-practice** | ベストプラクティス集。サブエージェント、コマンド、スキル、メモリシステム、ホット機能 | - | https://github.com/shanraisshan/claude-code-best-practice |

#### ワークフロー・テンプレート（CLAUDE.md系）

| リポジトリ | 特徴 | スター |
|---|---|---|
| **Superpowers** | TDD-first、全体計画レビュー | 118k |
| **Everything Claude Code** | インスティンクトスコアリング、多言語ルール | 111k |
| **Spec Kit** | Spec駆動、22+統合ツール | 83k |
| **gstack** | ロールペルソナ、並列スプリント | 52k |
| **Get Shit Done** | Wave実行、200K新鮮コンテキスト | 43k |

#### モニタリング・コスト管理

| リポジトリ | 説明 | URL |
|---|---|---|
| **ryoppippi/ccusage** | 使用量分析CLI。JSONL解析、MCP統合 | https://github.com/ryoppippi/ccusage |
| **FlorianBruniaux/ccboard** | Rust製TUI/Webモニター。予算アラート、30日予測 | https://github.com/FlorianBruniaux/ccboard |
| **carlosarraes/ccost** | API使用量追跡・コスト分析。重複排除、多通貨対応 | https://github.com/carlosarraes/ccost |
| **ColeMurray/claude-code-otel** | OTELオブザーバビリティソリューション | https://github.com/ColeMurray/claude-code-otel |
| **TechNickAI/claude_telemetry** | OTELラッパー。Datadog/Sentry/Honeycomb対応 | https://github.com/TechNickAI/claude_telemetry |
