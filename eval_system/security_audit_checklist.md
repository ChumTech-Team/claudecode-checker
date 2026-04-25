# 定期セキュリティ監査チェックリスト

> 作成日: 2026-03-28
> 実施頻度: 月次（毎月第1月曜日）

---

## 1. Claude Code本体

- [ ] Claude Codeを最新バージョンに更新済み
  ```bash
  claude --version
  npm update -g @anthropic-ai/claude-code
  ```
- [ ] セキュリティアドバイザリを確認: https://github.com/anthropics/claude-code/security
- [ ] 既知のCVEに対するパッチが適用済み

---

## 2. settings.json 監査

- [ ] allowリストにAPI Key/パスワード入りコマンドが含まれていない
  ```bash
  cat ~/.claude/settings.json | jq '.allowedTools[] | select(test("[a-zA-Z0-9]{20,}"))'
  ```
- [ ] allowリストにSSH鍵パス入りコマンドが含まれていない
- [ ] allowリストが50項目以下に維持されている
- [ ] denyリストに `Bash(sed -i:*)` が含まれている
- [ ] `enableAllProjectMcpServers` が `false` である

---

## 3. MCP監査

- [ ] 全MCPサーバーのバージョンを確認
  ```bash
  claude mcp list
  ```
- [ ] 不要なMCPサーバーを無効化
- [ ] MCPサーバーのnpmパッケージにセキュリティアラートがないか確認
- [ ] 各MCPサーバーのアクセス権限を確認（最小権限原則）
- [ ] グローバルスコープには汎用サーバーのみ（GitHub, Context7等）
- [ ] サーバー総数が5つ以下

---

## 4. シークレット管理

- [ ] `.zshrc` に平文トークンが含まれていない（1Password CLI等に移行済み）
- [ ] `.env` ファイルが `.gitignore` に含まれている（全PJ）
- [ ] `.env` ファイルが `.claudeignore` に含まれている（全PJ）
- [ ] Git履歴にシークレットが含まれていない
  ```bash
  git log --all --diff-filter=A -- '*.env' '*.key' '*.pem'
  ```

---

## 5. Skills/Hooks検証

- [ ] 全Hookスクリプトの内容をレビュー
- [ ] 外部コマンド実行を含むSkillの内容をレビュー
- [ ] Hookのexit codeが正しく設定されている（0=許可, 2=ブロック）
- [ ] 第三者作成のSkill/Hookを使用していないか、使用している場合はソースを確認

---

## 6. 依存パッケージ

- [ ] `npm audit --production` を全PJで実行
- [ ] dependabotのアラートを確認・対応（<your-project>, <your-other-project>）
- [ ] 使用していない依存パッケージを削除

---

## 7. アクセス権限

- [ ] GitHub PATの権限が最小限になっている
- [ ] Notion APIトークンの権限が最小限になっている
- [ ] SSH鍵が適切に管理されている（パスフレーズ設定済み）

---

## 8. バックアップ・復旧

- [ ] キルスイッチ（`claude-kill`）が動作することを確認
- [ ] インシデント対応手順（`incident_response.md`）が最新版である
- [ ] 重要リポジトリのバックアップが存在する

---

## 監査結果記録

| 実施日 | 実施者 | 結果 | 指摘事項 | 対応状況 |
|--------|--------|------|---------|---------|
| 2026-04-01 | - | - | - | - |
| 2026-05-01 | - | - | - | - |
| 2026-06-01 | - | - | - | - |
