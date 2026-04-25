#!/bin/bash
# =============================================================================
# Claude Code コスト管理ダッシュボード
# =============================================================================
# ccusage の出力をフォーマットし、日次/週次のコストサマリーを表示する
#
# 前提: npm install -g ccusage が完了していること
# 使い方:
#   ./cost_dashboard.sh          # 全サマリーを表示
#   ./cost_dashboard.sh daily    # 日次のみ
#   ./cost_dashboard.sh weekly   # 週次のみ
#   ./cost_dashboard.sh monthly  # 月次のみ
# =============================================================================

set -euo pipefail

# --- 設定 ---
BUDGET_DAILY=20       # 日次予算上限 ($)
BUDGET_MONTHLY=400    # 月次予算上限 ($)
LOG_DIR="${HOME}/.claude/cost_logs"
LOG_FILE="${LOG_DIR}/cost_$(date +%Y%m%d).log"

# --- カラー定義 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- ユーティリティ関数 ---
print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_section() {
    echo ""
    echo -e "${BOLD}${CYAN}── $1 ──${NC}"
}

check_ccusage() {
    if ! command -v ccusage &> /dev/null; then
        echo -e "${RED}エラー: ccusage がインストールされていません${NC}"
        echo "  インストール: npm install -g ccusage"
        exit 1
    fi
}

ensure_log_dir() {
    mkdir -p "${LOG_DIR}"
}

# --- 日次サマリー ---
show_daily() {
    print_section "日次コストサマリー ($(date +%Y-%m-%d))"

    echo -e "${BOLD}本日の使用状況:${NC}"
    if ccusage --period day --format table 2>/dev/null; then
        echo ""
    else
        echo -e "  ${YELLOW}(データなし、または ccusage が利用不可)${NC}"
    fi

    echo -e "${BOLD}予算状況:${NC}"
    echo -e "  日次予算上限: \$${BUDGET_DAILY}"
    echo -e "  ${YELLOW}※ 超過時は Sonnet に切替、またはセッション分割を検討${NC}"
}

# --- 週次サマリー ---
show_weekly() {
    print_section "週次コストサマリー"

    echo -e "${BOLD}今週の使用状況:${NC}"
    if ccusage --period week --format table 2>/dev/null; then
        echo ""
    else
        echo -e "  ${YELLOW}(データなし、または ccusage が利用不可)${NC}"
    fi

    echo ""
    echo -e "${BOLD}週次コスト最適化チェック:${NC}"
    echo -e "  [ ] サブエージェントは Sonnet を使用しているか"
    echo -e "  [ ] CI/CD は Sonnet で実行しているか"
    echo -e "  [ ] 不要な大規模コンテキストのセッションはないか"
    echo -e "  [ ] CLAUDE.md の変更頻度はキャッシュに影響していないか"
}

# --- 月次サマリー ---
show_monthly() {
    print_section "月次コストサマリー ($(date +%Y-%m))"

    echo -e "${BOLD}今月の使用状況:${NC}"
    if ccusage --period month --format table 2>/dev/null; then
        echo ""
    else
        echo -e "  ${YELLOW}(データなし、または ccusage が利用不可)${NC}"
    fi

    echo ""
    echo -e "${BOLD}月次予算:${NC}"
    echo -e "  月次予算上限: \$${BUDGET_MONTHLY}"

    echo ""
    echo -e "${BOLD}モデル別コスト参考 (2026年3月時点):${NC}"
    printf "  %-15s %-12s %-12s %-20s\n" "モデル" "入力" "出力" "用途"
    printf "  %-15s %-12s %-12s %-20s\n" "───────────" "────────" "────────" "────────────"
    printf "  %-15s %-12s %-12s %-20s\n" "Opus 4.6"   "\$15/MTok"  "\$75/MTok"  "複雑なタスク"
    printf "  %-15s %-12s %-12s %-20s\n" "Sonnet 4.5" "\$3/MTok"   "\$15/MTok"  "日常タスク"
    printf "  %-15s %-12s %-12s %-20s\n" "Haiku 3.5"  "\$0.8/MTok" "\$4/MTok"   "単純タスク"
}

# --- コストログ記録 ---
save_log() {
    ensure_log_dir
    {
        echo "=== コストログ $(date '+%Y-%m-%d %H:%M:%S') ==="
        echo "--- Daily ---"
        ccusage --period day --format table 2>/dev/null || echo "(データなし)"
        echo "--- Weekly ---"
        ccusage --period week --format table 2>/dev/null || echo "(データなし)"
        echo "--- Monthly ---"
        ccusage --period month --format table 2>/dev/null || echo "(データなし)"
        echo ""
    } >> "${LOG_FILE}"
    echo -e "${GREEN}ログを保存しました: ${LOG_FILE}${NC}"
}

# --- メイン ---
main() {
    check_ccusage

    local mode="${1:-all}"

    print_header "Claude Code コスト管理ダッシュボード"
    echo -e "  実行日時: $(date '+%Y-%m-%d %H:%M:%S')"

    case "${mode}" in
        daily|day|d)
            show_daily
            ;;
        weekly|week|w)
            show_weekly
            ;;
        monthly|month|m)
            show_monthly
            ;;
        all|*)
            show_daily
            show_weekly
            show_monthly
            ;;
    esac

    # ログ保存
    save_log

    echo ""
    echo -e "${BOLD}${GREEN}ダッシュボード表示完了${NC}"
    echo -e "  エイリアス設定済みの場合: cc-daily / cc-weekly / cc-monthly"
}

main "$@"
