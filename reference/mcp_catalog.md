# MCP サーバーカタログ

> 情報源: `research/04_拡張機能.md` / `04_拡張機能.md`
> 作成日: 2026-03-28

---

## 1. カテゴリ別 MCP サーバー一覧

| カテゴリ | サーバー名 | 説明 | パッケージ |
|---|---|---|---|
| **ファイル** | Filesystem | セキュアなファイル操作、アクセス制御設定可能 | `@modelcontextprotocol/server-filesystem` |
| **VCS** | GitHub | リポジトリ読み取り・検索・操作 | `@modelcontextprotocol/server-github` |
| **検索** | Brave Search | Web検索・ローカル検索 | `@modelcontextprotocol/server-brave-search` |
| **DB** | PostgreSQL | DB接続・クエリ実行 | `@modelcontextprotocol/server-postgres` |
| **ブラウザ** | Playwright | ブラウザ自動化・テスト | `@playwright/mcp` |
| **通信** | Slack | チャンネル・メッセージ操作 | `@modelcontextprotocol/server-slack` |
| **クラウド** | Google Drive | ファイル管理 | `@modelcontextprotocol/server-gdrive` |
| **監視** | Sentry | エラー監視・トラッキング | `@modelcontextprotocol/server-sentry` |
| **ユーティリティ** | Memory | 永続的なメモリストア | `@modelcontextprotocol/server-memory` |
| **推論** | Sequential Thinking | 構造化された段階的推論プロセス | `@modelcontextprotocol/server-sequential-thinking` |
| **ドキュメント** | Context7 | リアルタイムライブラリドキュメント取得（バージョン固有） | `@upstash/context7-mcp` |

---

## 2. `.mcp.json` 設定例

### 2.1 基本テンプレート

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/project"],
      "env": {}
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxx"
      }
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "BSA_xxxx"
      }
    }
  }
}
```

### 2.2 個別サーバー設定スニペット

**PostgreSQL:**
```json
{
  "postgresql": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://user:pass@localhost:5432/mydb"],
    "env": {}
  }
}
```

**Playwright:**
```json
{
  "playwright": {
    "command": "npx",
    "args": ["-y", "@playwright/mcp"],
    "env": {}
  }
}
```

**Slack:**
```json
{
  "slack": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-slack"],
    "env": {
      "SLACK_BOT_TOKEN": "xoxb-xxxx"
    }
  }
}
```

**Sentry:**
```json
{
  "sentry": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-sentry"],
    "env": {
      "SENTRY_AUTH_TOKEN": "sntrys_xxxx"
    }
  }
}
```

**Memory:**
```json
{
  "memory": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-memory"],
    "env": {}
  }
}
```

**Sequential Thinking:**
```json
{
  "sequential-thinking": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
    "env": {}
  }
}
```

---

## 3. 設定スコープ

| スコープ | 保存先 | 用途 | CLI追加例 |
|---|---|---|---|
| **Local**（デフォルト） | `~/.claude.json` のプロジェクトパス配下 | 個人用、現プロジェクトのみ | `claude mcp add my-server -- npx -y ...` |
| **Project** | プロジェクトルートの `.mcp.json` | チーム共有、VCS管理可能 | `claude mcp add --scope project my-server -- npx -y ...` |
| **User** | `~/.claude.json` | 全プロジェクト共通の個人設定 | `claude mcp add --scope user my-server -- node server.js` |

---

## 4. 用途別推奨構成

### 4.1 日常開発（ミニマル）

個人開発の最小構成。コスト最小。

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxx" }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {}
    }
  }
}
```

| サーバー | 理由 |
|---|---|
| GitHub | PR/Issue操作、リポジトリ検索 |
| Memory | セッション間の情報持続 |

### 4.2 フルスタック開発

Web開発の標準構成。DB + ブラウザテスト + VCS。

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxx" }
    },
    "postgresql": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://user:pass@localhost:5432/mydb"],
      "env": {}
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp"],
      "env": {}
    },
    "sentry": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sentry"],
      "env": { "SENTRY_AUTH_TOKEN": "sntrys_xxxx" }
    }
  }
}
```

| サーバー | 理由 |
|---|---|
| GitHub | PR/Issue管理 |
| PostgreSQL | DBクエリ・スキーマ確認 |
| Playwright | E2Eテスト・ブラウザ自動化 |
| Sentry | エラー監視・デバッグ |

### 4.3 データサイエンス / リサーチ

情報収集 + DB + ドキュメント参照。

```json
{
  "mcpServers": {
    "postgresql": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://user:pass@localhost:5432/mydb"],
      "env": {}
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": { "BRAVE_API_KEY": "BSA_xxxx" }
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "env": {}
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "env": {}
    }
  }
}
```

| サーバー | 理由 |
|---|---|
| PostgreSQL | データ分析・クエリ |
| Brave Search | 論文・技術情報の検索 |
| Context7 | ライブラリドキュメントのバージョン固有取得 |
| Sequential Thinking | 分析の段階的推論 |

### 4.4 DevOps / チーム運用

監視 + 通知 + VCS + エラー追跡。

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxx" }
    },
    "sentry": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sentry"],
      "env": { "SENTRY_AUTH_TOKEN": "sntrys_xxxx" }
    },
    "slack": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"],
      "env": { "SLACK_BOT_TOKEN": "xoxb-xxxx" }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {}
    }
  }
}
```

| サーバー | 理由 |
|---|---|
| GitHub | CI/CD管理、PR自動化 |
| Sentry | エラー監視・アラート確認 |
| Slack | チーム通知・コミュニケーション |
| Memory | 運用ナレッジの永続化 |

---

## 5. Top 5 推奨サーバー

| 順位 | サーバー | 推奨理由 |
|---|---|---|
| 1 | **GitHub** | ほぼ全ての開発者が利用。PR/Issue操作、リポジトリ検索をClaude Codeから直接実行。VCS連携の基本 |
| 2 | **Brave Search** | Web検索でリアルタイム情報を取得。技術調査・エラー解決に不可欠 |
| 3 | **PostgreSQL** | DB操作が必要なプロジェクトで必須。スキーマ確認・クエリ実行を自然言語で指示可能 |
| 4 | **Playwright** | E2Eテスト・ブラウザ自動化。フロントエンド開発で動作確認を自動化 |
| 5 | **Context7** | ライブラリのバージョン固有ドキュメントをリアルタイム取得。古い情報に基づくコード生成を防止 |

---

## 6. コンテキストコストに関する注意

MCPサーバーはコンテキストコストが **最も高い** 拡張レイヤーである。

| 項目 | 詳細 |
|---|---|
| デフォルト動作 | Tool Search有効: ツール名のみ先行読み込み、スキーマは必要時に遅延読み込み |
| `ENABLE_TOOL_SEARCH=auto` | コンテキストウィンドウの10%以内に収まるならスキーマを事前読み込み |
| 出力制限 | MCPツール出力が10,000トークン超で警告。`MAX_MCP_OUTPUT_TOKENS`で調整（デフォルト25,000） |
| 対応モデル | Sonnet 4以降、Opus 4以降（Haikuは非対応） |

**最適化の指針:** 必要なサーバーだけを有効にし、不要なサーバーは追加しない。

---

## 7. 管理コマンド

```bash
# サーバー一覧の確認
claude mcp list

# 特定サーバーの詳細
claude mcp get <server-name>

# サーバーの追加
claude mcp add <server-name> -- <command> [args...]
claude mcp add --scope project my-server -- npx -y @modelcontextprotocol/server-filesystem /path

# サーバーの削除
claude mcp remove <server-name>
```

---

## 8. MCPツール命名規則

```
mcp__<server名>__<tool名>

例:
  mcp__github__search_repositories
  mcp__filesystem__read_file
  mcp__slack__send_message
```

Hooksの `matcher` でMCPツールをフィルタリングする際にもこの命名規則を使用する:

```json
{
  "matcher": "mcp__github__.*",
  "hooks": [{
    "type": "command",
    "command": "echo \"GitHub tool called: $(jq -r '.tool_name')\" >&2"
  }]
}
```
