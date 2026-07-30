#!/usr/bin/env zsh
# Sets the @claude_pulse flag that drives the tmux-pulse.zsh status-bar animation,
# from Claude Code hook events. State is passed as $1:
#   think|tool|ask - a turn is active (thinking / running a tool / holding on an
#                    AskUserQuestion, which stays until PostToolUse fires): pulse
#   off            - turn or session ended: stop the pulse
#   notify         - a Notification fired; stop only on idle_prompt. Interrupts
#                    (Esc) fire no hook at all, so the pulse would stay stuck;
#                    idle_prompt is the one signal that lets us clear it afterwards.
# Wired in settings.json; deployed via the ~/.claude/hooks symlink. Fails open.

emulate -L zsh
setopt no_unset

[[ -n "${TMUX:-}" && -n "${TMUX_PANE:-}" ]] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

local state="${1:-}"
[[ -n "$state" ]] || exit 0

if [[ "$state" == "notify" ]]; then
  local notification_type=""
  command -v jq >/dev/null 2>&1 && notification_type=$(jq -r '.notification_type // empty' 2>/dev/null)
  [[ "$notification_type" == "idle_prompt" ]] && state="off" || exit 0
fi

local session_id
session_id=$(tmux display -p -t "$TMUX_PANE" '#{session_id}' 2>/dev/null)

case "$state" in
  think|tool|ask)
    tmux set -t "$session_id" @claude_pulse "$state" 2>/dev/null
    # Spawn the animator if none is running. @claude_ticker holds a unique token so
    # the ticker is single-owner: if a race or reload starts another, the older one
    # sees the token change and exits itself, so duplicates can't rubber-band the
    # animation. run-shell -b puts it under the tmux server, not this process tree.
    local ticker_running
    ticker_running=$(tmux show -v -t "$session_id" @claude_ticker 2>/dev/null)
    if [[ -z "$ticker_running" ]]; then
      local token="$$$RANDOM"
      tmux set -t "$session_id" @claude_ticker "$token" 2>/dev/null
      tmux run-shell -b "zsh '${0:A:h}/tmux-pulse.zsh' '$session_id' '$token'" 2>/dev/null
    fi
    ;;
  off)
    tmux set -u -t "$session_id" @claude_pulse 2>/dev/null
    ;;
  *)
    exit 0
    ;;
esac

tmux refresh-client -S 2>/dev/null
exit 0
