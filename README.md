# My Claude Statusline

A beautiful statusline for [Claude Code](https://claude.com/claude-code) showing git branch, directory, model, and token usage.

## Preview

![Statusline Preview](preview.png)

## Install

**One-line install:**

```bash
curl -fsSL https://raw.githubusercontent.com/nguyentran4896/my-claude-statusline/main/install.sh | bash
```

Or manually:

```bash
mkdir -p ~/.claude && curl -fsSL https://raw.githubusercontent.com/nguyentran4896/my-claude-statusline/main/statusline.json -o ~/.claude/statusline.json
```

**Then restart Claude Code** to see your new statusline.

## Features

- **Git Branch** - Current branch with status
- **Directory** - Project name
- **Model** - Active Claude model
- **Tokens** - Usage and budget

## Customize

Edit `~/.claude/statusline.json` to change colors or segments.

**Available colors:**
- `git_branch`: `#10b981` (green)
- `git_status`: `#f59e0b` (amber)
- `directory`: `#3b82f6` (blue)
- `model`: `#8b5cf6` (purple)
- `tokens`: `#ec4899` (pink)

**Format template:**
```json
"format": "{git_branch}{git_status} {directory} {model} {tokens}"
```

**Available variables:**
- `{{git.branch}}` - Git branch name
- `{{git.uncommitted_changes}}` - Uncommitted changes count
- `{{git.ahead}}` / `{{git.behind}}` - Commits ahead/behind
- `{{cwd.basename}}` - Current directory name
- `{{model.name}}` - Active model name
- `{{tokens.used}}` / `{{tokens.budget}}` - Token usage

## Troubleshooting

**Icons not showing?** Use a [Nerd Font](https://www.nerdfonts.com/)

**Statusline missing?** Restart Claude Code and check `~/.claude/statusline.json` exists

## License

MIT
