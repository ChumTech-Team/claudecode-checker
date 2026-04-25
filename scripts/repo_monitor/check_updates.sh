#!/bin/bash
# =============================================================================
# check_updates.sh - 監視対象GitHubリポジトリの更新チェック
#
# 使い方:
#   ./check_updates.sh              # 更新チェック（差分があれば report.md を生成）
#   ./check_updates.sh --init       # state.json を現在の最新コミットで初期化
#   ./check_updates.sh --status     # 各リポジトリの最終チェック状態を表示
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"
STATE_FILE="$SCRIPT_DIR/state.json"
REPORT_FILE="$SCRIPT_DIR/report.md"

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# gh CLI チェック
if ! command -v gh &> /dev/null; then
    echo -e "${RED}ERROR: gh CLI が見つかりません。brew install gh でインストールしてください。${NC}"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${RED}ERROR: jq が見つかりません。brew install jq でインストールしてください。${NC}"
    exit 1
fi

# config.json からリポジトリ一覧を取得
get_repos() {
    jq -r '.repos[].repo' "$CONFIG_FILE"
}

# 特定リポジトリの影響先ファイル一覧を取得
get_affects() {
    local repo="$1"
    jq -r --arg r "$repo" '.repos[] | select(.repo == $r) | .affects[]' "$CONFIG_FILE"
}

# 特定リポジトリの優先度を取得
get_priority() {
    local repo="$1"
    jq -r --arg r "$repo" '.repos[] | select(.repo == $r) | .priority' "$CONFIG_FILE"
}

# GitHub APIから最新コミット情報を取得
fetch_latest_commit() {
    local repo="$1"
    gh api "repos/$repo/commits?per_page=1" \
        --jq '.[0] | "\(.sha)\t\(.commit.committer.date)\t\(.commit.message | split("\n")[0])"' \
        2>/dev/null || echo "ERROR\tERROR\tfetch failed"
}

# 2つのコミット間の差分サマリを取得
fetch_diff_summary() {
    local repo="$1"
    local old_sha="$2"
    local new_sha="$3"

    # コミット一覧を取得（最大20件）
    gh api "repos/$repo/compare/${old_sha}...${new_sha}" \
        --jq '{
            total_commits: .total_commits,
            commits: [.commits[] | {
                sha: .sha[0:7],
                date: .commit.committer.date,
                message: (.commit.message | split("\n")[0])
            }] | .[0:20],
            files_changed: [.files[] | {
                filename: .filename,
                status: .status,
                additions: .additions,
                deletions: .deletions
            }] | .[0:50]
        }' 2>/dev/null || echo '{"error": "compare failed"}'
}

# --init: state.json を初期化
init_state() {
    echo -e "${YELLOW}state.json を初期化中...${NC}"
    echo "{" > "$STATE_FILE.tmp"
    local first=true

    while IFS= read -r repo; do
        echo -n "  $repo ... "
        local result
        result=$(fetch_latest_commit "$repo")
        local sha date msg
        sha=$(echo "$result" | cut -f1)
        date=$(echo "$result" | cut -f2)
        msg=$(echo "$result" | cut -f3- | head -c 120)

        if [ "$sha" = "ERROR" ]; then
            echo -e "${RED}FAILED${NC}"
            sha="unknown"
            date="unknown"
            msg="fetch failed"
        else
            echo -e "${GREEN}OK${NC} ($date)"
        fi

        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> "$STATE_FILE.tmp"
        fi

        # jq で安全にJSON生成
        jq -n \
            --arg sha "$sha" \
            --arg date "$date" \
            --arg msg "$msg" \
            --arg repo "$repo" \
            --arg checked "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
            '{($repo): {last_sha: $sha, last_date: $date, last_message: $msg, checked_at: $checked}}' \
            | sed '1d;$d' >> "$STATE_FILE.tmp"

    done < <(get_repos)

    echo "" >> "$STATE_FILE.tmp"
    echo "}" >> "$STATE_FILE.tmp"

    # jq で整形して保存
    jq '.' "$STATE_FILE.tmp" > "$STATE_FILE"
    rm -f "$STATE_FILE.tmp"

    echo -e "\n${GREEN}state.json を初期化しました。${NC}"
}

# --status: 現在の状態を表示
show_status() {
    if [ ! -f "$STATE_FILE" ]; then
        echo -e "${RED}state.json が見つかりません。--init で初期化してください。${NC}"
        exit 1
    fi

    echo "=== リポジトリ監視状態 ==="
    echo ""
    printf "%-45s %-12s %-25s %s\n" "リポジトリ" "優先度" "最終コミット日" "メッセージ"
    printf "%-45s %-12s %-25s %s\n" "-----" "----" "----------" "-------"

    while IFS= read -r repo; do
        local priority date msg
        priority=$(get_priority "$repo")
        date=$(jq -r --arg r "$repo" '.[$r].last_date // "unknown"' "$STATE_FILE")
        msg=$(jq -r --arg r "$repo" '.[$r].last_message // "unknown"' "$STATE_FILE" | head -c 50)
        printf "%-45s %-12s %-25s %s\n" "$repo" "$priority" "$date" "$msg"
    done < <(get_repos)
}

# メイン: 更新チェック
check_updates() {
    if [ ! -f "$STATE_FILE" ]; then
        echo -e "${RED}state.json が見つかりません。--init で初期化してください。${NC}"
        exit 1
    fi

    echo -e "${YELLOW}更新チェック中...${NC}"
    local updates_found=0
    local report_entries=()
    local updated_state
    updated_state=$(cat "$STATE_FILE")

    while IFS= read -r repo; do
        echo -n "  $repo ... "

        local old_sha
        old_sha=$(jq -r --arg r "$repo" '.[$r].last_sha // "unknown"' "$STATE_FILE")

        local result
        result=$(fetch_latest_commit "$repo")
        local new_sha new_date new_msg
        new_sha=$(echo "$result" | cut -f1)
        new_date=$(echo "$result" | cut -f2)
        new_msg=$(echo "$result" | cut -f3- | head -c 120)

        if [ "$new_sha" = "ERROR" ]; then
            echo -e "${RED}FETCH FAILED${NC}"
            continue
        fi

        if [ "$old_sha" = "$new_sha" ]; then
            echo -e "${GREEN}変更なし${NC}"
        else
            echo -e "${YELLOW}更新あり!${NC} ($new_date)"
            updates_found=$((updates_found + 1))

            # 差分サマリを取得
            local diff_summary=""
            if [ "$old_sha" != "unknown" ]; then
                diff_summary=$(fetch_diff_summary "$repo" "$old_sha" "$new_sha")
            fi

            # 影響先ファイル一覧
            local affects
            affects=$(get_affects "$repo")
            local priority
            priority=$(get_priority "$repo")

            # レポートエントリ追加
            report_entries+=("$(jq -n \
                --arg repo "$repo" \
                --arg priority "$priority" \
                --arg old_sha "$old_sha" \
                --arg new_sha "$new_sha" \
                --arg new_date "$new_date" \
                --arg new_msg "$new_msg" \
                --arg affects "$affects" \
                --argjson diff "${diff_summary:-null}" \
                '{repo: $repo, priority: $priority, old_sha: $old_sha, new_sha: $new_sha, new_date: $new_date, new_msg: $new_msg, affects: ($affects | split("\n")), diff: $diff}'
            )")

            # state更新
            updated_state=$(echo "$updated_state" | jq \
                --arg r "$repo" \
                --arg sha "$new_sha" \
                --arg date "$new_date" \
                --arg msg "$new_msg" \
                --arg checked "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
                '.[$r] = {last_sha: $sha, last_date: $date, last_message: $msg, checked_at: $checked}')
        fi
    done < <(get_repos)

    # state.json を更新
    echo "$updated_state" | jq '.' > "$STATE_FILE"

    if [ "$updates_found" -eq 0 ]; then
        echo -e "\n${GREEN}全リポジトリ変更なし。${NC}"
        # 空のレポートは作らない
        rm -f "$REPORT_FILE"
        exit 0
    fi

    # report.md を生成
    echo -e "\n${YELLOW}${updates_found}件の更新を検出。report.md を生成中...${NC}"

    {
        echo "# リポジトリ更新レポート"
        echo ""
        echo "**チェック日時:** $(date '+%Y-%m-%d %H:%M:%S')"
        echo "**更新リポジトリ数:** ${updates_found}"
        echo ""
        echo "---"
        echo ""

        for entry in "${report_entries[@]}"; do
            local repo priority old_sha new_sha new_date new_msg
            repo=$(echo "$entry" | jq -r '.repo')
            priority=$(echo "$entry" | jq -r '.priority')
            old_sha=$(echo "$entry" | jq -r '.old_sha')
            new_sha=$(echo "$entry" | jq -r '.new_sha')
            new_date=$(echo "$entry" | jq -r '.new_date')
            new_msg=$(echo "$entry" | jq -r '.new_msg')

            echo "## [$repo](https://github.com/$repo) [${priority}]"
            echo ""
            echo "- **最新コミット:** \`${new_sha:0:7}\` ($new_date)"
            echo "- **前回チェック:** \`${old_sha:0:7}\`"
            echo "- **コミットメッセージ:** $new_msg"
            echo ""

            # コミット一覧
            local total_commits
            total_commits=$(echo "$entry" | jq -r '.diff.total_commits // 0')
            if [ "$total_commits" -gt 0 ] 2>/dev/null; then
                echo "### コミット一覧 (${total_commits}件)"
                echo ""
                echo "| SHA | 日付 | メッセージ |"
                echo "|-----|------|----------|"
                echo "$entry" | jq -r '.diff.commits[]? | "| `\(.sha)` | \(.date) | \(.message) |"'
                echo ""

                # 変更ファイル
                echo "### 変更ファイル"
                echo ""
                echo "| ファイル | 状態 | +/- |"
                echo "|---------|------|-----|"
                echo "$entry" | jq -r '.diff.files_changed[]? | "| `\(.filename)` | \(.status) | +\(.additions)/-\(.deletions) |"'
                echo ""
            fi

            # 影響先
            echo "### 影響する教材ファイル"
            echo ""
            echo "$entry" | jq -r '.affects[]? | "- `\(.)`"'
            echo ""
            echo "---"
            echo ""
        done

        echo "## 次のアクション"
        echo ""
        echo "Claude Code エージェントに以下を依頼してください:"
        echo ""
        echo '```'
        echo "このレポートの内容を分析して、影響する教材ファイルの具体的な更新案を提示してください。"
        echo "対象: scripts/repo_monitor/report.md"
        echo '```'

    } > "$REPORT_FILE"

    echo -e "${GREEN}report.md を生成しました: $REPORT_FILE${NC}"
}

# メイン処理
case "${1:-}" in
    --init)
        init_state
        ;;
    --status)
        show_status
        ;;
    *)
        check_updates
        ;;
esac
