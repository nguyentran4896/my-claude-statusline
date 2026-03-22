#!/bin/bash

# Statusline for Claude Code — clean, information-dense, dynamically colored
# Format: Plan | Project | Git | Tokens | Rate Limits | Model | Style
#
# Rate limits segment (Max/Pro only) — half-block stacked dual bar:
#   5h 10% ▀▀▀▀▀░░░░░ 2% 7d  (top half=5h, bottom half=7d, independent colors)

# ── Paths ──
config_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

# ── ANSI colors ──
c_reset="\033[0m"
c_bold="\033[1m"
c_dim="\033[2m"
c_green="\033[38;5;40m"
c_yellow="\033[38;5;226m"
c_orange="\033[38;5;208m"
c_red="\033[38;5;196m"
c_cyan="\033[38;5;51m"
c_magenta="\033[38;5;201m"
c_pink="\033[38;5;213m"
c_gray="\033[38;5;240m"
c_white_dim="\033[38;5;250m"

# ── Separator ──
sep="${c_dim}${c_gray} | ${c_reset}"

# ── Read JSON input ──
input=$(cat)

# ── Extract all fields (pipe-delimited to preserve empties) ──
IFS='|' read -r model_id context_size used_pct project_dir output_style \
  five_hour_pct five_hour_reset seven_day_pct seven_day_reset \
  <<< "$(echo "$input" | jq -r '[
    (.model.id // "unknown"),
    (.context_window.context_window_size // 0),
    (.context_window.used_percentage // 0),
    (.workspace.project_dir // ""),
    (.output_style.name // "default"),
    (if .rate_limits.five_hour.used_percentage != null then (.rate_limits.five_hour.used_percentage | ceil) else "" end),
    (.rate_limits.five_hour.resets_at // ""),
    (if .rate_limits.seven_day.used_percentage != null then (.rate_limits.seven_day.used_percentage | ceil) else "" end),
    (.rate_limits.seven_day.resets_at // "")
  ] | join("|")')"

# ── Defaults ──
model_id="${model_id:-unknown}"
context_size="${context_size:-0}"
used_pct="${used_pct:-0}"
output_style="${output_style:-default}"

# ── Plan icon ──
case "$config_dir" in
  *claude-personal*) seg_plan="🚀" ;;
  *)                 seg_plan="🎯" ;;
esac

# ═══════════════════════════════════════════════════
# Helpers
# ═══════════════════════════════════════════════════

format_tokens() {
  local n=${1:-0}
  if [ "$n" -ge 1000000 ] 2>/dev/null; then
    printf "%.1fm" "$(echo "$n / 1000000" | bc -l)"
  elif [ "$n" -ge 1000 ] 2>/dev/null; then
    echo "$((n / 1000))k"
  else
    echo "$n"
  fi
}

format_context() {
  local n=${1:-0}
  if [ "$n" -ge 1000000 ] 2>/dev/null; then
    printf "%.0fM" "$(echo "$n / 1000000" | bc -l)"
  elif [ "$n" -ge 1000 ] 2>/dev/null; then
    echo "$((n / 1000))K"
  else
    echo "$n"
  fi
}

create_bar() {
  local pct=${1:-0} width=5
  local filled=$((pct * width / 100))
  [ "$filled" -gt "$width" ] && filled=$width
  local empty=$((width - filled)) bar=""
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty; i++)); do bar+="░"; done
  echo "$bar"
}

# Return 256-color index by percentage: green → yellow → orange → red
color_index_by_pct() {
  local pct=${1:-0}
  if   [ "$pct" -le 50 ] 2>/dev/null; then echo "40"    # green
  elif [ "$pct" -le 75 ] 2>/dev/null; then echo "226"   # yellow
  elif [ "$pct" -le 90 ] 2>/dev/null; then echo "208"   # orange
  else echo "196"                                         # red
  fi
}

# Create a half-block dual progress bar: top half = 5h, bottom half = 7d
# Uses ▀ with fg=top color, bg=bottom color per cell
create_dual_bar() {
  local top_pct=${1:-0} bot_pct=${2:-0} width=${3:-10}
  local top_ci=${4:-40} bot_ci=${5:-40}
  local dim_fg=238 dim_bg=236

  local top_filled=$(( top_pct * width / 100 ))
  local bot_filled=$(( bot_pct * width / 100 ))
  [ "$top_filled" -gt "$width" ] && top_filled=$width
  [ "$bot_filled" -gt "$width" ] && bot_filled=$width

  local bar=""
  for (( i=0; i<width; i++ )); do
    local t=0 b=0
    [ "$i" -lt "$top_filled" ] && t=1
    [ "$i" -lt "$bot_filled" ] && b=1

    if [ $t -eq 1 ] && [ $b -eq 1 ]; then
      # Both filled: ▀ with fg=top color, bg=bot color
      bar+="\033[38;5;${top_ci}m\033[48;5;${bot_ci}m▀\033[0m"
    elif [ $t -eq 1 ]; then
      # Top only: ▀ with fg=top color, bg=dim
      bar+="\033[38;5;${top_ci}m\033[48;5;${dim_bg}m▀\033[0m"
    elif [ $b -eq 1 ]; then
      # Bottom only: ▀ with fg=dim, bg=bot color
      bar+="\033[38;5;${dim_bg}m\033[48;5;${bot_ci}m▀\033[0m"
    else
      # Neither: dim block
      bar+="\033[38;5;${dim_fg}m\033[48;5;${dim_bg}m░\033[0m"
    fi
  done
  printf "%b" "$bar"
}

# Pie chart using 8 steps (each step = 12.5%)
# ○ ◔ ◑ ◕ ● covers 0/25/50/75/100, but we use 8-step for precision:
# ○ ⅛ ¼ ⅜ ½ ⅝ ¾ ⅞ ●  → mapped via Unicode pie quarters + eights
pie_chart() {
  local pct=${1:-0}
  # Clamp to 0-100
  [ "$pct" -lt 0 ] 2>/dev/null && pct=0
  [ "$pct" -gt 100 ] 2>/dev/null && pct=100
  # Map percentage to 8 segments (0=empty, 8=full)
  local step=$(( (pct * 8 + 50) / 100 ))
  case "$step" in
    0) echo "○" ;;
    1) echo "◔" ;;   # ~12.5%
    2) echo "◔" ;;   # ~25%
    3) echo "◑" ;;   # ~37.5%
    4) echo "◑" ;;   # ~50%
    5) echo "◕" ;;   # ~62.5%
    6) echo "◕" ;;   # ~75%
    7) echo "●" ;;   # ~87.5%
    *) echo "●" ;;   # 100%
  esac
}

format_reset() {
  local reset_epoch=${1:-0}
  [ -z "$reset_epoch" ] || [ "$reset_epoch" = "0" ] && return
  local now diff minutes hours rem_min
  now=$(date +%s)
  diff=$(( reset_epoch - now ))
  [ "$diff" -le 0 ] && { echo "now"; return; }
  minutes=$(( diff / 60 ))
  hours=$(( minutes / 60 ))
  rem_min=$(( minutes % 60 ))
  if [ "$hours" -eq 0 ]; then
    echo "${minutes}m"
  elif [ "$hours" -lt 24 ]; then
    echo "${hours}h${rem_min}m"
  else
    if [[ "$OSTYPE" == darwin* ]]; then
      date -r "$reset_epoch" "+%a %-I%p"
    else
      date -d "@$reset_epoch" "+%a %-I%p"
    fi
  fi
}

# Color by percentage: green → yellow → orange → red
color_by_pct() {
  local pct=${1:-0} t1=${2:-30} t2=${3:-60} t3=${4:-80}
  if   [ "$pct" -le "$t1" ] 2>/dev/null; then echo "$c_green"
  elif [ "$pct" -le "$t2" ] 2>/dev/null; then echo "$c_yellow"
  elif [ "$pct" -le "$t3" ] 2>/dev/null; then echo "$c_orange"
  else echo "$c_red"
  fi
}

# ═══════════════════════════════════════════════════
# Segments
# ═══════════════════════════════════════════════════

# ── Model ──
model_name="Claude"; model_version=""
case "$model_id" in
  *opus*)   model_name="Opus" ;;
  *sonnet*) model_name="Sonnet" ;;
  *haiku*)  model_name="Haiku" ;;
esac
if [[ "$model_id" =~ ([0-9]+)-([0-9]+) ]]; then
  model_version=" ${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
fi
seg_model="${c_cyan}${model_name}${model_version}${c_reset}"

# ── Project ──
project_name=""
if [ -n "$project_dir" ] && [ "$project_dir" != "null" ]; then
  project_name=$(basename "$project_dir")
fi
seg_project="${c_yellow}${project_name}${c_reset}"

# ── Git ──
seg_git=""
if [ -n "$project_dir" ] && [ "$project_dir" != "null" ]; then
  git_dir="$project_dir"
  found_git=false
  while [ -n "$git_dir" ] && [ "$git_dir" != "/" ]; do
    [ -d "$git_dir/.git" ] && { found_git=true; break; }
    git_dir=$(dirname "$git_dir")
  done
  if [ "$found_git" = true ]; then
    branch=$(git -C "$git_dir" -c core.useBuiltinFSMonitor=false rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
      dirty=$(git -C "$git_dir" -c core.useBuiltinFSMonitor=false status --porcelain 2>/dev/null)
      ahead=$(git -C "$git_dir" -c core.useBuiltinFSMonitor=false rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
      behind=$(git -C "$git_dir" -c core.useBuiltinFSMonitor=false rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
      if [ -n "$dirty" ]; then
        seg_git="${c_reset}${branch} ${c_orange}✗${c_reset}"
      else
        seg_git="${c_reset}${branch} ${c_green}✓${c_reset}"
      fi
      [ "${ahead:-0}" -gt 0 ] 2>/dev/null && seg_git+=" ${c_cyan}↑${ahead}${c_reset}"
      [ "${behind:-0}" -gt 0 ] 2>/dev/null && seg_git+=" ${c_magenta}↓${behind}${c_reset}"
    fi
  fi
fi

# ── Tokens ──
total_tokens=0
[ "$context_size" -gt 0 ] 2>/dev/null && [ "$used_pct" -gt 0 ] 2>/dev/null && \
  total_tokens=$(( (context_size * used_pct) / 100 ))
tokens_fmt=$(format_tokens "$total_tokens")
size_fmt=$(format_context "$context_size")
token_color=$(color_by_pct "$used_pct" 30 60 80)
token_pie=$(pie_chart "$used_pct")
seg_tokens="${token_color}${token_pie} ${tokens_fmt}/${size_fmt} (${used_pct}%)${c_reset}"

# ── Rate limits (Max/Pro only, half-block stacked dual bar) ──
seg_rate=""
if [ -n "$five_hour_pct" ] || [ -n "$seven_day_pct" ]; then
  fh_pct="${five_hour_pct:-0}"
  sd_pct="${seven_day_pct:-0}"

  # Get independent color indices for each bar
  fh_ci=$(color_index_by_pct "$fh_pct")
  sd_ci=$(color_index_by_pct "$sd_pct")

  # Get ANSI color escapes for labels/text
  fh_color="\033[38;5;${fh_ci}m"
  sd_color="\033[38;5;${sd_ci}m"

  # Build stacked dual bar (top=5h, bottom=7d)
  dual_bar=$(create_dual_bar "$fh_pct" "$sd_pct" 10 "$fh_ci" "$sd_ci")

  # Format reset times
  fh_reset=$(format_reset "$five_hour_reset")
  sd_reset=$(format_reset "$seven_day_reset")
  reset_str=""
  if [ -n "$fh_reset" ] && [ -n "$sd_reset" ]; then
    reset_str=" ${c_dim}⏳${fh_reset}·${sd_reset}${c_reset}"
  elif [ -n "$fh_reset" ]; then
    reset_str=" ${c_dim}⏳${fh_reset}${c_reset}"
  elif [ -n "$sd_reset" ]; then
    reset_str=" ${c_dim}⏳${sd_reset}${c_reset}"
  fi

  # Option C layout: 5h 55% ██████▀░░░ 22% 7d
  seg_rate="${c_white_dim}5h${c_reset} ${fh_color}${fh_pct}%${c_reset} ${dual_bar} ${sd_color}${sd_pct}%${c_reset} ${c_white_dim}7d${c_reset}${reset_str}"
fi

# ── Output style ──
seg_style=""
if [ "$output_style" != "default" ] && [ -n "$output_style" ] && [ "$output_style" != "null" ]; then
  seg_style="${c_pink}${output_style}${c_reset}"
fi

# ═══════════════════════════════════════════════════
# Assembly
# ═══════════════════════════════════════════════════
output="${seg_plan}"
[ -n "$project_name" ] && output+="${sep}${seg_project}"
[ -n "$seg_git" ]      && output+="${sep}${seg_git}"
output+="${sep}${seg_tokens}"
[ -n "$seg_rate" ]     && output+="${sep}${seg_rate}"
output+="${sep}${seg_model}"
[ -n "$seg_style" ]    && output+="${sep}${seg_style}"

printf "%b" "$output"
