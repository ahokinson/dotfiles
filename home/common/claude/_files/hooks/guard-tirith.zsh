#!/usr/bin/env zsh
# tirith scans each Bash command before it runs. only a hard block verdict
# (exit 1) denies; safe and advisory commands pass silently. no tirith on PATH
# means no-op, so a missing binary never blocks work.
#
# on a deny, increments a per-session counter written to a sourceable zsh state
# file the statusline reads (cc-violations-<session_id>.state). the write is
# fail-safe: any error is swallowed so it never affects the deny decision.

command -v tirith >/dev/null 2>&1 || exit 0

input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
[[ -z "$cmd" ]] && exit 0

tirith check --non-interactive -- "$cmd" >/dev/null 2>&1
(( $? == 1 )) || exit 0

# fail-safe per-session counter for the statusline
{
  sid="$(printf '%s' "$input" | jq -r '.session_id // empty')"
  [[ -n "$sid" ]] && {
    vf="${XDG_STATE_HOME:-$HOME/.local/state}/guard/violations-${sid}.state"
    integer tirith=0 cupcake=0 context=0
    [[ -r "$vf" ]] && source "$vf" 2>/dev/null
    (( tirith++ ))
    mkdir -p "${vf:h}" 2>/dev/null
    { print -r -- "tirith=$tirith"; print -r -- "cupcake=$cupcake"; print -r -- "context=$context" } >"$vf" 2>/dev/null
  }
} 2>/dev/null

jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "Blocked by tirith: dangerous command pattern (e.g. pipe-to-shell, homograph URL, terminal injection, data exfiltration). Run `tirith check -- '\''<command>'\''` to see the findings."
  }
}'
exit 0
