#!/bin/bash

# Read JSON input from stdin
input=$(cat)

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
    context_info=$(printf " [%d%%]" "$pct")
else
    context_info=""
fi

# Rate limit info (Claude.ai subscribers only; fields are optional)
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
rate_info=""
if [ -n "$five_pct" ] || [ -n "$seven_pct" ]; then
    rate_parts=""
    [ -n "$five_pct" ] && rate_parts=$(printf "5h:%.0f%%" "$five_pct")
    [ -n "$seven_pct" ] && rate_parts="$rate_parts${rate_parts:+ }$(printf "7d:%.0f%%" "$seven_pct")"
    rate_info=" | $rate_parts"
fi

printf "%s %s in %s (%s)%s%s" "$model_name" "$output_style" "$dir_name" "$(whoami)" "$context_info" "$rate_info"