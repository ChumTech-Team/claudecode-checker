# Claude Code CLI 早見表

---

## 1. スラッシュコマンド一覧

### セッション管理

| コマンド | 説明 |
|---------|------|
| `/clear` | 会話履歴をクリアして新しい会話を開始 |
| `/compact [focus]` | コンテキストを圧縮（フォーカス指定でトピック絞り込み） |
| `/resume` | セッション再開/切替 |
| `/rename [name]` | セッション名変更 |
| `/branch [name]` | 会話分岐（`/fork` エイリアス） |
| `/cost` | APIトークン使用量を表示 |
| `/context` | コンテキスト使用状況を確認（グリッド表示） |
| `/diff` | インタラクティブdiffビューア |
| `/usage` | プラン制限を確認 |
| `/extra-usage` | オーバーフロー課金を設定 |

### 設定・モデル

| コマンド | 説明 |
|---------|------|
| `/config` | 設定画面を開く |
| `/model [model]` | モデルとリーズニングを選択 |
| `/effort [level]` | 推論レベル設定（low/medium/high） |
| `/permissions` | パーミッション管理 |
| `/output-style` | 出力スタイルメニュー |
| `/output-style [style]` | 出力スタイルを直接指定（例: `explanatory`） |
| `/output-style:new` | 新しい出力スタイルを作成 |
| `/vim` | vim スタイル編集を有効化 |

### ツール・構成

| コマンド | 説明 |
|---------|------|
| `/init` | CLAUDE.md作成 |
| `/memory` | CLAUDE.mdファイル編集 / auto memoryトグル |
| `/mcp` | MCPサーバー管理 |
| `/hooks` | Hook管理 |
| `/skills` | 利用可能スキル一覧 |
| `/doctor` | インストール診断（キーバインド警告含む） |
| `/terminal-setup` | Shift+Enterバインディングをインストール |
| `/keybindings` | キーバインド設定ファイルを開く |
| `/help` | ヘルプを表示 |

### 特殊コマンド

| コマンド | 説明 |
|---------|------|
| `/plan [desc]` | 読み取り専用プランニングモード |
| `/simplify` | コードレビュー（3並列エージェント） |
| `/batch` | 大規模並列変更（5-30 worktree） |
| `/btw <question>` | サイドクエスチョン（コンテキスト消費なし） |
| `/loop [interval]` | 定期タスクスケジュール |
| `/voice` | 音声入力（20言語対応） |
| `/rc` / `/remote-control` | リモートコントロール |
| `/schedule` | クラウドスケジュールタスク |

---

## 2. CLIフラグ一覧

### コアコマンド

| コマンド | 説明 |
|---------|------|
| `claude` | インタラクティブモード起動 |
| `claude "質問"` | プロンプト付きで起動 |
| `claude -p "質問"` | ヘッドレス（非インタラクティブ）モード |
| `claude -c` | 最後の会話を継続 |
| `claude -r "名前"` | セッション名で再開 |
| `claude update` | アップデート |

### 主要フラグ

| フラグ | 説明 |
|--------|------|
| `--model` | モデル指定 |
| `-w` / `--worktree` | Git worktreeで隔離ブランチ |
| `-n` / `--name` | セッション名指定 |
| `--add-dir` | 追加ワーキングディレクトリ |
| `--agent` | エージェント指定 |
| `--allowedTools` | ツールの事前承認（例: `["Read", "Grep", "Glob"]`） |
| `--output-format` | 出力形式（`json` / `stream`） |
| `--json-schema` | 構造化出力スキーマ |
| `--max-turns` | ターン数制限 |
| `--max-budget-usd` | コスト上限（例: `5`） |
| `--effort` | 推論レベル（`low` / `med` / `high` / `max`） |
| `--bare` | 最小ヘッドレスモード（hooks/LSP/plugins無し） |
| `--console` | Anthropic Console経由認証 |
| `--verbose` | 詳細ログ出力 |
| `--channels` | パーミッションリレー / MCP push messages |
| `--remote` | Webセッション（claude.ai/code） |
| `--chrome` | Chrome連携 |

### システムプロンプトカスタマイズ

| フラグ | 説明 |
|--------|------|
| `--system-prompt` | システムプロンプトを完全置換 |
| `--system-prompt-file` | ファイルからシステムプロンプトを置換 |
| `--append-system-prompt` | 既存に追加（推奨） |
| `--append-system-prompt-file` | ファイルから既存に追加 |
| `--dangerously-skip-permissions` | 全プロンプトをスキップ（CLI専用） |

> `--system-prompt` と `--system-prompt-file` は排他。append系はreplacement系と組み合わせ可能。

---

## 3. キーボードショートカット一覧

| ショートカット | 動作 |
|--------------|------|
| `Ctrl+C` | 入力/生成キャンセル |
| `Ctrl+D` | セッション終了 |
| `Ctrl+L` | 画面クリア |
| `Ctrl+O` | 詳細出力切替 / トランスクリプトビューア |
| `Ctrl+R` | コマンド履歴のインタラクティブ検索 |
| `Ctrl+G` | エディタでプロンプト編集 |
| `Ctrl+B` | タスクをバックグラウンドに |
| `Ctrl+T` | タスクリスト切替 |
| `Ctrl+V` | 画像ペースト |
| `Ctrl+F` (2回) | バックグラウンドエージェント終了 |
| `Esc Esc` | 巻き戻し / 取り消し |
| `Shift+Tab` | パーミッションモード切替 |
| `Shift+Enter` | 改行挿入 |
| `Alt+P` | モデル切替 |
| `Alt+T` | 思考モード切替 |
| `/` | スラッシュコマンドメニュー表示 |

### Shift+Enter対応状況

| ターミナル | 設定 |
|-----------|------|
| iTerm2, WezTerm, Ghostty, Kitty | 設定不要 |
| VS Code, Alacritty, Zed, Warp | `/terminal-setup` が必要 |

### Option/Altキー設定

| ターミナル | 設定 |
|-----------|------|
| Terminal.app | 設定 > プロファイル > キーボード > 「Use Option as Meta Key」をチェック |
| VS Code | 設定 > プロファイル > Keys > Left/Right Option keyを「Esc+」に設定 |
| iTerm2 | 設定不要 |

---

## 4. 主要環境変数一覧

| 変数 | 説明 |
|------|------|
| `ANTHROPIC_API_KEY` | APIキー |
| `ANTHROPIC_MODEL` | デフォルトモデル |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Opusモデルのバージョン指定 |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Sonnetモデルのバージョン指定 |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Haikuモデルのバージョン指定 |
| `CLAUDE_CODE_EFFORT_LEVEL` | 推論レベル（`low` / `med` / `high`） |
| `MAX_THINKING_TOKENS` | 思考トークン数（`0` = 無効） |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | 最大出力トークン（デフォルト32K） |
| `CLAUDECODE` | Claude Codeシェル検出（`=1`） |

> `ANTHROPIC_SMALL_FAST_MODEL` は非推奨。`ANTHROPIC_DEFAULT_HAIKU_MODEL` を使用すること。

---

## 5. パーミッションモード一覧

| モード | 説明 |
|--------|------|
| `default` | 標準のパーミッションプロンプト。allowされていないツールは拒否に変換 |
| `acceptEdits` | ファイル操作を自動承認。他のツールは通常のパーミッションが必要 |
| `plan` | 読み取り専用。コード分析・プラン作成のみ、変更不可 |
| `dontAsk` | 未承認ツールは拒否（プロンプトなし） |
| `bypassPermissions` | 全パーミッションチェックをスキップ（denyルールは有効） |
| `auto` | バックグラウンド安全分類器がプロンプト注入や危険なエスカレーションをブロック |

> 安全な運用: `allowedTools` + `permissionMode: "dontAsk"` の組み合わせが `bypassPermissions` より安全。

### パーミッション評価順序

1. **deny** ルールが最初に評価
2. 次に **ask** ルール
3. 最後に **allow** ルール
4. 最初にマッチしたルールが適用
5. denyルールは `bypassPermissions` モードでも有効

---

## 6. エフォートレベル

| レベル | 説明 |
|-------|------|
| `low` | 高速・低コスト。単純なタスク向け |
| `medium` | デフォルト（Opus 4.6、Sonnet 4.6） |
| `high` | 深い推論。複雑な問題向け |
| `max` | 最も深い推論。トークン使用制限なし |

設定方法: `/effort`、`/model`、`--effort` フラグ、`CLAUDE_CODE_EFFORT_LEVEL` 環境変数
