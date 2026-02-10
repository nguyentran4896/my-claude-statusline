#!/bin/bash
# Claude Code Statusline Template
# Copy this to ~/.claude/statusline-cool.sh and customize as needed

# Colors (customize these hex values)
GIT_BRANCH_COLOR="#10b981"    # green
GIT_STATUS_COLOR="#f59e0b"    # amber
DIRECTORY_COLOR="#3b82f6"     # blue
MODEL_COLOR="#8b5cf6"         # purple
TOKENS_COLOR="#ec4899"        # pink

# Icons (Nerd Font - customize these)
GIT_BRANCH_ICON=""
GIT_STATUS_ICON=""
DIRECTORY_ICON=""
MODEL_ICON=""
TOKENS_ICON=""

# Helper function to colorize text
colorize() {
    local color=$1
    local text=$2
    echo "\033[38;2;$(printf '%d;%d;%d' 0x${color:1:2} 0x${color:3:2} 0x${color:5:2})m${text}\033[0m"
}

output=""

# Git branch
if git rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git --no-optional-locks branch --show-current 2>/dev/null || echo "detached")
    output+="$(colorize "$GIT_BRANCH_COLOR" "$GIT_BRANCH_ICON $branch") "

    # Git status
    uncommitted=$(git --no-optional-locks status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    ahead=$(git --no-optional-locks rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
    behind=$(git --no-optional-locks rev-list --count HEAD..@{u} 2>/dev/null || echo "0")

    if [ "$uncommitted" != "0" ] || [ "$ahead" != "0" ] || [ "$behind" != "0" ]; then
        output+="$(colorize "$GIT_STATUS_COLOR" "$GIT_STATUS_ICON ${uncommitted}↕${ahead}↓${behind}") "
    fi
fi

# Directory
directory=$(basename "$PWD")
output+="$(colorize "$DIRECTORY_COLOR" "$DIRECTORY_ICON $directory") "

# Model (from environment variable if available)
if [ -n "$CLAUDE_MODEL" ]; then
    model_name="$CLAUDE_MODEL"
elif [ -n "$ANTHROPIC_MODEL" ]; then
    model_name="$ANTHROPIC_MODEL"
else
    model_name="Sonnet 4.5"
fi
output+="$(colorize "$MODEL_COLOR" "$MODEL_ICON $model_name") "

# Tokens (Claude Code provides these via environment)
if [ -n "$CLAUDE_TOKENS_USED" ] && [ -n "$CLAUDE_TOKENS_BUDGET" ]; then
    output+="$(colorize "$TOKENS_COLOR" "$TOKENS_ICON ${CLAUDE_TOKENS_USED}/${CLAUDE_TOKENS_BUDGET}")"
fi

echo -e "$output"
