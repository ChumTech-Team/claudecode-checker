# Claude Code Hooks パターン集

> 作成日: 2026-03-28
> ソース: research/04_拡張機能.md

---

## 1. Hookイベント一覧

Hooksはライフサイクルの特定ポイントで実行されるユーザー定義のシェルコマンド/ハンドラ。LLMの判断に依存せず**決定論的に**実行される。

### 1.1 ハンドラタイプ

| タイプ | 説明 |
|---|---|
| **command** | シェルコマンドを実行 |
| **http** | HTTPリクエストを送信 |
| **prompt** | Claudeにプロンプトを注入 |
| **agent** | エージェントを起動 |

### 1.2 全イベント一覧（ブロック可否付き）

「ブロック可」列は、exit 2 や JSON の permissionDecision でツール実行を拒否できるかを示す。PreToolUse が主要なブロック対応イベント。

| イベント | タイミング | 対応ハンドラ | ブロック可 | 主な用途 |
|---|---|---|---|---|
| **SessionStart** | セッション開始時 | command | - | 環境セットアップ、ログ開始 |
| **SessionEnd** | セッション終了時 | command, http | - | クリーンアップ、統計ログ |
| **UserPromptSubmit** | ユーザープロンプト送信時 | 全タイプ | - | 入力検証、スキル推薦 |
| **PreToolUse** | ツール実行前 | 全タイプ | **Yes** | 操作ブロック、入力修正 |
| **PostToolUse** | ツール成功後 | 全タイプ | - | 自動フォーマット、ログ |
| **PostToolUseFailure** | ツール失敗後 | command, http | - | エラーハンドリング |
| **Stop** | Claude応答完了時 | 全タイプ | - | 結果検証、通知 |
| **SubagentStart** | サブエージェント開始時 | command, http | - | ログ、初期化 |
| **SubagentStop** | サブエージェント完了時 | 全タイプ | - | 結果検証 |
| **Notification** | 通知送信時 | command, http | - | カスタム通知 |
| **PreCompact** | コンパクション前 | command, http | - | 状態保存 |
| **PostCompact** | コンパクション後 | command, http | - | 状態復元 |
| **PermissionRequest** | 権限要求時 | command, http | - | カスタム権限ポリシー |
| **ConfigChange** | 設定変更時 | command, http | - | 設定監視 |
| **CwdChanged** | 作業ディレクトリ変更時 | command, http | - | パス追跡 |
| **Elicitation** | 質問表示時 | command, http | - | 質問のカスタマイズ |
| **ElicitationResult** | 質問回答時 | command, http | - | 回答処理 |
| **FileChanged** | ファイル変更時 | command, http | - | ファイル監視 |
| **InstructionsLoaded** | 指示読み込み時 | command, http | - | 指示の動的修正 |
| **StopFailure** | 停止失敗時 | command, http | - | エラー処理 |
| **TaskCompleted** | タスク完了時 | 全タイプ | - | 進捗追跡 |
| **TaskCreated** | タスク作成時 | 全タイプ | - | タスク監視 |
| **TeammateIdle** | チームメイトアイドル時 | command, http | - | チーム管理 |
| **WorktreeCreate** | Worktree作成時 | command, http | - | 環境セットアップ |
| **WorktreeRemove** | Worktree削除時 | command, http | - | クリーンアップ |
| **Setup** | 初期セットアップ時 | command | - | 依存関係インストール |

---

## 2. Exit Code 制御

Hookは2つのアプローチで制御を行う（同時使用不可）。

### 方式1: Exit Code のみ

```
Exit 0 → 続行（ツール実行を許可）
Exit 2 → ブロック（ツール実行を拒否）
```

### 方式2: JSON出力（exit 0 + stdout JSON）

JSON の内容に基づく制御。Exit 2 の場合 JSON は無視される。

**PreToolUse の JSON制御（hookSpecificOutput）:**
```json
{
  "hookSpecificOutput": {
    "permissionDecision": "allow",
    "permissionDecisionReason": "安全な操作です"
  }
}
```

`permissionDecision` の値:
- `"allow"` -- ツール実行を許可
- `"deny"` -- ツール実行を拒否
- `"ask"` -- ユーザーにエスカレーション

**PostToolUse 等の JSON制御（トップレベル）:**
```json
{
  "decision": "block",
  "reason": "この操作は許可されていません"
}
```

### 制御フロー図

```
Hook実行
  |-- Exit 2 --> 即座にブロック（JSON無視）
  +-- Exit 0
       |-- stdout にJSON なし --> 続行
       +-- stdout にJSON あり
            |-- PreToolUse --> hookSpecificOutput.permissionDecision で判定
            +-- その他    --> トップレベル decision で判定
```

---

## 3. 実用パターン集

全パターンは `settings.json` の `hooks` セクションに記載する。以下では各パターンの matcher + hooks 部分を示す。

### settings.json の全体構造

```json
{
  "hooks": {
    "PreToolUse": [ /* matcher + hooks の配列 */ ],
    "PostToolUse": [ /* matcher + hooks の配列 */ ],
    "SessionStart": [ /* matcher + hooks の配列 */ ],
    "Stop": [ /* matcher + hooks の配列 */ ],
    "UserPromptSubmit": [ /* matcher + hooks の配列 */ ],
    "PreCompact": [ /* matcher + hooks の配列 */ ]
  }
}
```

---

### 3.1 自動フォーマット（Prettier）

**イベント:** PostToolUse | **対象ツール:** Edit

ファイル編集後に自動的に Prettier でフォーマットする。

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $(jq -r '.tool_input.file_path')"
          }
        ]
      }
    ]
  }
}
```

---

### 3.2 型チェック（TypeScript）

**イベント:** PostToolUse | **対象ツール:** Edit

ファイル編集後に TypeScript の型チェックを実行する。

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npx tsc --noEmit 2>&1 | head -20"
          }
        ]
      }
    ]
  }
}
```

---

### 3.3 rm -rf 検知・ブロック

**イベント:** PreToolUse | **対象ツール:** Bash | **ブロック:** exit 2

危険な `rm -rf /` コマンドをブロックする。

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.command' | grep -qE 'rm\\s+-rf\\s+/' && exit 2 || exit 0",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

---

### 3.4 .env ファイル編集ブロック

**イベント:** PreToolUse | **対象ツール:** Edit | **ブロック:** exit 2

`.env` ファイルへの編集を禁止する。

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | grep -qE '\\.env' && exit 2 || exit 0"
          }
        ]
      }
    ]
  }
}
```

---

### 3.5 ブランチ保護（mainブランチ編集禁止）

**イベント:** PreToolUse | **対象ツール:** Edit | **ブロック:** exit 2

main ブランチ上でのファイル編集を禁止する。

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "[ \"$(git branch --show-current)\" = 'main' ] && exit 2 || exit 0"
          }
        ]
      }
    ]
  }
}
```

---

### 3.6 自動テスト実行

**イベント:** PostToolUse | **対象ツール:** Edit

編集されたファイルに関連するテストを自動実行する。

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npx jest --findRelatedTests $(jq -r '.tool_input.file_path') --passWithNoTests 2>&1 | tail -5"
          }
        ]
      }
    ]
  }
}
```

---

### 3.7 通知音 / デスクトップ通知（macOS）

**イベント:** Stop

Claude の応答完了時にデスクトップ通知を表示する。

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude Code task completed\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

**音声通知（UV single-file script）:**

以下のスクリプトを `.claude/hooks/notify.py` として保存し、Stop フックから呼び出す。

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyttsx3"]
# ///
import pyttsx3
engine = pyttsx3.init()
engine.say("Task completed")
engine.runAndWait()
```

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "uv run $CLAUDE_PROJECT_DIR/.claude/hooks/notify.py"
          }
        ]
      }
    ]
  }
}
```

---

### 3.8 セッション開始コンテキスト注入

**イベント:** SessionStart

セッション開始時に依存関係のチェック等の環境セットアップを行う。

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "uv sync --quiet 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

---

### 3.9 PreCompact バックアップ

**イベント:** PreCompact

コンパクション前に状態を保存する。

```json
{
  "hooks": {
    "PreCompact": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"$(date): PreCompact triggered\" >> ~/.claude/compact-log.txt"
          }
        ]
      }
    ]
  }
}
```

---

### 3.10 Anti-rationalization gate

**イベント:** Stop | **ハンドラタイプ:** agent

Stop イベントで agent タイプのフックを使い、Claude の出力を別のエージェントが検証する。タスク完了の主張が実際の変更と一致しているかチェックし、合理化（やった振り）を防止する。

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "agent",
            "command": "Verify that the claimed changes actually match the git diff. If the assistant claims something was done but it wasn't, report the discrepancy."
          }
        ]
      }
    ]
  }
}
```

---

### 3.11 スキル推薦エンジン

**イベント:** UserPromptSubmit

ユーザープロンプト送信時にプロンプトを解析し、関連スキルを推薦する。キーワード（2点）、正規表現パターン（4点）、ディレクトリマッチ（5点）でスコアリングする構成。`skill-eval.sh` -> `skill-eval.js` -> `skill-rules.json` の3ファイルで動作。

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash $CLAUDE_PROJECT_DIR/.claude/hooks/skill-eval.sh"
          }
        ]
      }
    ]
  }
}
```

---

### 3.12 Bash監査ログ（コマンドログ記録）

**イベント:** PostToolUse | **対象ツール:** Bash

全 Bash コマンドをログファイルに記録する。

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.command' >> ~/.claude/command-log.txt"
          }
        ]
      }
    ]
  }
}
```

---

### 3.13 Auto-allow（pip/python -> uv 強制）

**イベント:** PreToolUse | **対象ツール:** Bash | **制御:** JSON permissionDecision

`pip`、`python`、`pytest` コマンドを拒否し、`uv run` の使用を強制する。

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.command' | grep -qE '^(pip |python |pytest )' && echo '{\"hookSpecificOutput\":{\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"Use uv run instead\"}}' || exit 0"
          }
        ]
      }
    ]
  }
}
```

---

## 4. 追加パターン

### 4.1 自動Lintチェック

**イベント:** PostToolUse | **対象ツール:** Edit

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npx eslint $(jq -r '.tool_input.file_path') 2>&1"
          }
        ]
      }
    ]
  }
}
```

### 4.2 sudo コマンドブロック

**イベント:** PreToolUse | **対象ツール:** Bash | **ブロック:** exit 2

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.command' | grep -q 'sudo' && exit 2 || exit 0"
          }
        ]
      }
    ]
  }
}
```

### 4.3 force push 防止

**イベント:** PreToolUse | **対象ツール:** Bash | **ブロック:** exit 2

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.command' | grep -qE 'git\\s+push.*--force' && exit 2 || exit 0"
          }
        ]
      }
    ]
  }
}
```

### 4.4 ファイル変更追跡

**イベント:** PostToolUse | **対象ツール:** Edit

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"$(date): $(jq -r '.tool_input.file_path')\" >> ~/.claude/edit-log.txt"
          }
        ]
      }
    ]
  }
}
```

### 4.5 MCP GitHub ツール呼び出しログ

**イベント:** PostToolUse | **対象ツール:** mcp__github__.*

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "mcp__github__.*",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"GitHub tool called: $(jq -r '.tool_name')\" >&2"
          }
        ]
      }
    ]
  }
}
```

---

## 5. UV Single-File Script パターン

UV single-file スクリプトを使うと、仮想環境や requirements.txt の管理なしに Python フックを実行できる。

### テンプレート

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["requests", "pyyaml"]
# ///

import sys
import json

# stdinからフックのJSON入力を読み取り
data = json.load(sys.stdin)
tool_name = data.get("tool_name", "")

# 処理ロジック
if "dangerous" in tool_name:
    print(json.dumps({
        "hookSpecificOutput": {
            "permissionDecision": "deny",
            "permissionDecisionReason": "Dangerous tool detected"
        }
    }))
else:
    sys.exit(0)
```

### settings.json での呼び出し

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "uv run $CLAUDE_PROJECT_DIR/.claude/hooks/pre_tool_use.py"
          }
        ]
      }
    ]
  }
}
```

**利点:**
- 仮想環境管理が不要
- requirements.txt が不要
- 依存関係がスクリプトファイル内に自己完結
- `$CLAUDE_PROJECT_DIR` でプロジェクトルートからの相対パス解決
