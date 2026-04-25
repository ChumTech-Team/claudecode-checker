# インシデント対応手順

> 作成日: 2026-03-28
> 対象: Claude Code利用時のセキュリティインシデント

---

## 1. シークレット漏洩時

1. `claude-kill` でセッション停止
2. 漏洩したトークンを即座にローテーション
3. `git log` で漏洩コミットを特定
4. `git filter-branch` またはBFG Repo-Cleanerで履歴から除去
5. リモートリポジトリにforce pushして履歴を上書き
6. 影響範囲の確認（漏洩トークンでアクセス可能だったリソースの監査）

### 対象となるシークレットの例

- APIキー（Anthropic, OpenAI, Notion, etc.）
- GitHub PAT（Personal Access Token）
- SSH秘密鍵
- データベース接続文字列
- 環境変数に含まれるパスワード

### 事後対応

- `.gitignore` / `.claudeignore` の見直し
- allowリストからシークレット入りコマンドを削除
- denyリストの強化

---

## 2. 不正操作検出時

1. `claude-kill` でセッション停止
2. `git diff` / `git log` で変更内容を確認
3. `git stash` または `git checkout` で復旧
4. Hook/denyルールを強化

### 不正操作の兆候

- 意図しないファイルの削除・変更
- 不明なリモートへのpush
- 権限昇格を試みるコマンド実行
- `.claude/settings.json` の改ざん

---

## 3. Prompt Injection検出時

1. セッションを即座に終了（Ctrl+C → `claude-kill`）
2. 直前に読み込んだファイル/URLの内容を確認
3. 実行されたコマンドをログから確認
4. 影響を受けたファイルを `git diff` で確認し復旧

### 予防策

- 信頼できないソースのファイルを読み込む前に内容を目視確認
- denyルールで重要操作（force push, rm -rf等）を保護
- Hookで危険なコマンドをブロック

---

## 4. MCP/サプライチェーン攻撃検出時

1. 疑わしいMCPサーバーを即座に無効化
   ```bash
   claude mcp remove <server-name>
   ```
2. MCPサーバーが実行したコマンド/アクセスしたリソースを確認
3. 影響を受けたファイル/データを特定・復旧
4. npmパッケージのセキュリティアドバイザリを確認

---

## 緊急連絡先

| 状況 | 対応 |
|------|------|
| GitHubトークン漏洩 | GitHub Settings → Developer settings → Tokens → Revoke |
| Notionトークン漏洩 | Notion Settings → Integrations → Revoke |
| Anthropic APIキー漏洩 | Anthropic Console → API Keys → Revoke |
| SSH鍵漏洩 | `ssh-keygen` で新鍵生成、GitHub/サーバーの公開鍵を差替 |

---

## キルスイッチ

```bash
# 全Claude Codeプロセスを停止
pkill -f "claude"
# エイリアス: claude-kill
```
