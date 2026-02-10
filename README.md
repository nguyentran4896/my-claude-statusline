# My Claude Statusline

A beautiful statusline for [Claude Code](https://claude.com/claude-code) showing git branch, directory, model, and token usage.

## Preview

![Statusline Preview](preview.png)

## Install

**Copy this prompt and send it to Claude Code:**

```
Please install the statusline from https://github.com/nguyentran4896/my-claude-statusline - download the statusline.json and configure it for me
```

That's it! Claude will handle everything automatically.

## What You Get

- 📁 **Directory** - Current project name
- 🔱 **Git Branch** - Branch with status indicator
- 🟩 **Token Usage** - Progress bar with percentage
- 🧠 **Model** - Active Claude model

## Customize

After installation, edit `~/.claude/statusline.json` to change colors:

- `git_branch`: `#10b981` (green)
- `git_status`: `#f59e0b` (amber)
- `directory`: `#3b82f6` (blue)
- `model`: `#8b5cf6` (purple)
- `tokens`: `#ec4899` (pink)

## License

MIT
