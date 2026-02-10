#!/bin/bash
# One-line installer for My Claude Statusline

set -e

STATUSLINE_URL="https://raw.githubusercontent.com/nguyentran4896/my-claude-statusline/main/statusline.json"
STATUSLINE_PATH="$HOME/.claude/statusline.json"

# Create .claude directory if it doesn't exist
mkdir -p "$HOME/.claude"

# Download statusline.json
echo "📥 Downloading statusline configuration..."
curl -fsSL "$STATUSLINE_URL" -o "$STATUSLINE_PATH"

# Verify the file was created
if [ -f "$STATUSLINE_PATH" ]; then
    echo "✅ Statusline installed successfully to $STATUSLINE_PATH"
    echo ""
    echo "🎉 All done! Restart Claude Code to see your new statusline."
    echo ""
    echo "💡 Tip: Use 'cat ~/.claude/statusline.json' to view your configuration"
else
    echo "❌ Installation failed. File not found at $STATUSLINE_PATH"
    exit 1
fi
