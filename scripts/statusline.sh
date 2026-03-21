#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
DIM='\033[2m'
RESET='\033[0m'

# Line 1: model, dir, git branch with staged/modified counts
BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH_NAME=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH_NAME" ]; then
        STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        GIT_PARTS=""
        [ "$STAGED" -gt 0 ] && GIT_PARTS="${GREEN}+${STAGED}${RESET}"
        [ "$MODIFIED" -gt 0 ] && GIT_PARTS="${GIT_PARTS}${YELLOW}~${MODIFIED}${RESET}"
        BRANCH=" | 🌿 ${BRANCH_NAME}${GIT_PARTS:+ $GIT_PARTS}"
    fi
fi
printf "${CYAN}[%s]${RESET} 📁 %s%b\n" "$MODEL" "${DIR##*/}" "$BRANCH"

# Line 2: color-coded progress bar, context %, cost, rate limits with resets_at
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /█}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

COST_FMT=$(printf '$%.2f' "$COST")

# Format reset countdown for 5h window: "Xd Ym" or "Ym" if < 1d
fmt_reset_5h() {
    local resets_at=$1 now secs_left
    now=$(date +%s)
    secs_left=$((resets_at - now))
    if [ "$secs_left" -le 0 ]; then
        echo "now"
    elif [ "$secs_left" -lt 3600 ]; then
        echo "$((secs_left / 60))m"
    else
        local h=$((secs_left / 3600))
        local m=$(( (secs_left % 3600) / 60 ))
        [ "$m" -gt 0 ] && echo "${h}h ${m}m" || echo "${h}h"
    fi
}

# Format reset countdown for 7d window: "Xd Yh" or "Yh" if < 1d
fmt_reset_7d() {
    local resets_at=$1 now secs_left
    now=$(date +%s)
    secs_left=$((resets_at - now))
    if [ "$secs_left" -le 0 ]; then
        echo "now"
    elif [ "$secs_left" -lt 86400 ]; then
        echo "$((secs_left / 3600))h"
    else
        local d=$((secs_left / 86400))
        local h=$(( (secs_left % 86400) / 3600 ))
        [ "$h" -gt 0 ] && echo "${d}d ${h}h" || echo "${d}d"
    fi
}

# Color a percentage: green < 60, yellow < 85, red >= 85
color_pct() {
    local pct=$1 text=$2
    if [ "$pct" -ge 85 ]; then printf "${RED}%s${RESET}" "$text"
    elif [ "$pct" -ge 60 ]; then printf "${YELLOW}%s${RESET}" "$text"
    else printf "%s" "$text"; fi
}

# Rate limits (Claude.ai Pro/Max only)
FIVE_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
SEVEN_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
SEVEN_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

RATE_INFO=""
if [ -n "$FIVE_PCT" ] || [ -n "$SEVEN_PCT" ]; then
    RATE_PARTS=""
    if [ -n "$FIVE_PCT" ]; then
        F=$(printf "%.0f" "$FIVE_PCT")
        RESET_STR=""
        [ -n "$FIVE_RESET" ] && RESET_STR="${DIM}↺ $(fmt_reset_5h "$FIVE_RESET")${RESET}"
        RATE_PARTS="5h: $(color_pct "$F" "${F}%")${RESET_STR:+ $RESET_STR}"
    fi
    if [ -n "$SEVEN_PCT" ]; then
        S=$(printf "%.0f" "$SEVEN_PCT")
        RESET_STR=""
        [ -n "$SEVEN_RESET" ] && RESET_STR="${DIM}↺ $(fmt_reset_7d "$SEVEN_RESET")${RESET}"
        RATE_PARTS="${RATE_PARTS}${RATE_PARTS:+ | }7d: $(color_pct "$S" "${S}%")${RESET_STR:+ $RESET_STR}"
    fi
    RATE_INFO=" | $RATE_PARTS"
fi

printf "${BAR_COLOR}%s${RESET} %s%% | ${YELLOW}%s${RESET}\n" \
    "$BAR" "$PCT" "$COST_FMT"

# Line 3: rate limits (only shown when present)
if [ -n "$RATE_PARTS" ]; then
    printf "%b\n" "$RATE_PARTS"
fi
