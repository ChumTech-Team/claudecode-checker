#!/bin/bash
# =============================================================================
# Headlessモード活用例
# =============================================================================
# 作成日: 2026-03-28
# 概要: Claude CodeのHeadless（-p）モードを活用したバッチ処理パターン集
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# 1. 基本的なHeadless実行
# -----------------------------------------------------------------------------

# TODOコメントの列挙（JSON出力）
basic_todo_scan() {
  local repo_path="${1:-.}"
  claude -p "このリポジトリのTODOコメントを全て列挙して" \
    --output-format json \
    > "${repo_path}/todos.json"
  echo "TODOスキャン完了: ${repo_path}/todos.json"
}

# テキスト出力でのコードレビュー
basic_code_review() {
  local file_path="$1"
  echo "以下のファイルをレビューして: ${file_path}" \
    | claude -p --output-format text
}

# -----------------------------------------------------------------------------
# 2. パイプライン活用
# -----------------------------------------------------------------------------

# git diffの内容をレビュー
review_git_diff() {
  git diff --staged \
    | claude -p "このdiffをレビューして。セキュリティ・パフォーマンス・可読性の観点でコメントして" \
      --output-format text
}

# 依存パッケージの脆弱性チェック
audit_dependencies() {
  local repo_path="${1:-.}"
  cd "$repo_path"
  claude -p "このリポジトリの依存パッケージの脆弱性をチェックして。npm audit の結果を分析し、対応が必要なものをリストアップして" \
    --output-format text \
    > /tmp/dependency-audit.txt
  echo "監査完了: /tmp/dependency-audit.txt"
}

# -----------------------------------------------------------------------------
# 3. セッション管理付きHeadless
# -----------------------------------------------------------------------------

# セッションIDを指定して継続実行
continue_session() {
  local session_id="$1"
  local prompt="$2"
  claude -p "$prompt" \
    --session-id "$session_id" \
    --output-format text
}

# -----------------------------------------------------------------------------
# 4. 出力形式の使い分け
# -----------------------------------------------------------------------------

# JSON出力（構造化データとして後続処理に渡す場合）
json_output_example() {
  claude -p "このリポジトリの構成を分析し、主要ファイルと役割をJSON形式で返して" \
    --output-format json
}

# テキスト出力（人間が読む場合）
text_output_example() {
  claude -p "このリポジトリのREADMEを要約して" \
    --output-format text
}

# ストリームJSON出力（リアルタイム処理の場合）
stream_output_example() {
  claude -p "大規模なコード分析を実行して" \
    --output-format stream-json
}

# -----------------------------------------------------------------------------
# 5. 定期実行パターン（cron連携）
# -----------------------------------------------------------------------------

# 週次コードベース健全性チェック（crontabに登録して使用）
# crontab例: 0 9 * * 1 /path/to/headless_example.sh weekly_health_check /path/to/repo
weekly_health_check() {
  local repo_path="${1:-.}"
  local report_file="/tmp/weekly-health-$(date +%Y%m%d).txt"
  cd "$repo_path"
  claude -p "このリポジトリの健全性をチェックして: 未使用の依存、TODOコメント、テストカバレッジ、セキュリティ懸念をレポートして" \
    --output-format text \
    > "$report_file"
  echo "週次レポート: $report_file"
}

# -----------------------------------------------------------------------------
# 6. 複数ファイル処理のバッチ
# -----------------------------------------------------------------------------

# 複数ファイルを一括レビュー
batch_review() {
  local files=("$@")
  for file in "${files[@]}"; do
    echo "--- Reviewing: $file ---"
    claude -p "以下のファイルを簡潔にレビューして: $file" \
      --output-format text
    echo ""
  done
}

# -----------------------------------------------------------------------------
# メイン: コマンドラインから関数を呼び出し
# -----------------------------------------------------------------------------

if [[ $# -ge 1 ]]; then
  "$@"
else
  echo "使い方: $0 <関数名> [引数...]"
  echo ""
  echo "利用可能な関数:"
  echo "  basic_todo_scan [repo_path]        - TODOコメントをスキャン"
  echo "  basic_code_review <file_path>      - ファイルをレビュー"
  echo "  review_git_diff                    - ステージ済みdiffをレビュー"
  echo "  audit_dependencies [repo_path]     - 依存パッケージ監査"
  echo "  continue_session <id> <prompt>     - セッション継続"
  echo "  json_output_example                - JSON出力例"
  echo "  text_output_example                - テキスト出力例"
  echo "  stream_output_example              - ストリーム出力例"
  echo "  weekly_health_check [repo_path]    - 週次健全性チェック"
  echo "  batch_review <file1> [file2] ...   - 一括レビュー"
fi
