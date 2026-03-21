#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# ANSI color codes
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Color a percentage value: yellow >= 60%, red >= 85%
color_pct() {
    local pct=$1
    local text=$2
    if [ "$pct" -ge 85 ]; then
        printf "${RED}%s${RESET}" "$text"
    elif [ "$pct" -ge 60 ]; then
        printf "${YELLOW}%s${RESET}" "$text"
    else
        printf "%s" "$text"
    fi
}

# Extract relevant fields
model_name=$(echo "$input" | jq -r '.model.display_name // .model.id')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')

# Get current directory basename
dir_name=$(basename "$current_dir")

# Calculate context usage percentage
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
    # Calculate current context tokens (input + cache creation + cache read)
    current=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    size=$(echo "$input" | jq '.context_window.context_window_size')
    pct=$((current * 100 / size))
    context_info=" [$(color_pct "$pct" "${pct}%")]"
else
    context_info=""
fi

# Rate limit info (Claude.ai subscribers only; fields are optional)
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
rate_info=""
if [ -n "$five_pct" ] || [ -n "$seven_pct" ]; then
    rate_parts=""
    if [ -n "$five_pct" ]; then
        five_int=$(printf "%.0f" "$five_pct")
        rate_parts="5h:$(color_pct "$five_int" "${five_int}%")"
    fi
    if [ -n "$seven_pct" ]; then
        seven_int=$(printf "%.0f" "$seven_pct")
        rate_parts="${rate_parts}${rate_parts:+ }7d:$(color_pct "$seven_int" "${seven_int}%")"
    fi
    rate_info=" | $rate_parts"
fi

printf "%s %s in %s (%s)%s%s" "$model_name" "$output_style" "$dir_name" "$(whoami)" "$context_info" "$rate_info"
