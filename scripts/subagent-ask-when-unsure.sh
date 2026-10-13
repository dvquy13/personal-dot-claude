#!/usr/bin/env bash
# PreToolUse hook (matcher: Agent). Appends an "ask when in doubt" protocol to
# every subagent prompt so subagents return questions instead of guessing.
set -euo pipefail

MARKER="QUESTIONS FOR LEAD"

IFS= read -r -d '' PROTOCOL <<'EOF' || true


---
## When in doubt, pause and ask
If you hit a decision you cannot resolve from this prompt, the code, or a sensible default (ambiguous requirements, conflicting signals, multiple valid approaches that change the outcome, missing info, or a risky/irreversible action), do NOT guess. Stop and return early with:

1. What you completed so far (files touched, findings).
2. A section titled exactly `QUESTIONS FOR LEAD:` listing each question with the options you see and your recommendation.

The lead agent will answer and resume you with context intact. For choices with an obvious default, pick it, note the assumption in your result, and keep going.
EOF

input=$(cat)

# Idempotent: skip if the prompt already carries the protocol.
if jq -e --arg m "$MARKER" '.tool_input.prompt // "" | contains($m)' <<<"$input" >/dev/null; then
  exit 0
fi

jq --arg p "$PROTOCOL" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    updatedInput: (.tool_input + {prompt: ((.tool_input.prompt // "") + $p)})
  }
}' <<<"$input"
