# My Claude Statusline

A beautiful statusline for [Claude Code](https://claude.com/claude-code) showing git branch, directory, model, and token usage.

## Preview

![Statusline Preview](preview.png)

## Install

**Option 1: JSON Config (Recommended)**

Copy and paste this into Claude Code:

```
Install statusline: download https://raw.githubusercontent.com/nguyentran4896/my-claude-statusline/main/statusline.json to ~/.claude/statusline.json and configure ~/.claude/settings.json if needed
```

**Option 2: Shell Script (Advanced)**

For more control, use the shell script template:

```
Install statusline: download https://raw.githubusercontent.com/nguyentran4896/my-claude-statusline/main/statusline-template.sh to ~/.claude/statusline-cool.sh, make it executable, and configure ~/.claude/settings.json to use it
```

The shell script gives you full control over the output format and logic.

## What You Get

- 📁 **Directory** - Current project name
- 🔱 **Git Branch** - Branch with status indicator
- 🟩 **Token Usage** - Progress bar with percentage
- 🧠 **Model** - Active Claude model

## Customize

### JSON Config

Edit `~/.claude/statusline.json` to change colors:

- `git_branch`: `#10b981` (green)
- `git_status`: `#f59e0b` (amber)
- `directory`: `#3b82f6` (blue)
- `model`: `#8b5cf6` (purple)
- `tokens`: `#ec4899` (pink)

### Shell Script

Edit `~/.claude/statusline-cool.sh` to:
- Customize colors (hex values at the top)
- Change icons (Nerd Font characters)
- Modify the output format and logic
- Add custom segments

The shell script is run by Claude Code and outputs the statusline text with ANSI color codes.

## Files

- `statusline.json` - JSON configuration (declarative, simpler)
- `statusline-template.sh` - Shell script template (programmatic, more control)
- `preview.png` - Visual preview

## License

MIT
