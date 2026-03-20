# My Claude Statusline

Beautiful, information-dense statusline for [Claude Code](https://claude.com/claude-code) with rate limits, git info, token usage, and more.

## Preview

![Statusline Preview](preview.png)

## Features

- **Plan indicator** — 🚀 Max / 🎯 Enterprise (emoji icons for compactness)
- **Project name** — current working directory
- **Git info** — branch, dirty/clean status, ahead/behind counts
- **Token usage** — colored progress bar with percentage and size
- **Rate limits** — 5-hour session + 7-day weekly usage with countdown timers
- **Model** — current Claude model and version
- **Output style** — shown when non-default

## Install

**Copy and paste this into Claude Code:**

```
Install statusline: download https://raw.githubusercontent.com/nguyentran4896/my-claude-statusline/main/statusline-template.sh to ~/.claude/statusline-cool.sh, make it executable, and configure ~/.claude/settings.json to use it
```

That's it! Claude handles everything.

## Customize

Edit `~/.claude/statusline-cool.sh` to:

- Change colors (ANSI 256 values at the top)
- Swap plan icons (🚀/🎯 → anything you like)
- Adjust color thresholds for token/rate limit bars
- Add or remove segments in the assembly section at the bottom
