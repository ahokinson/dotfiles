#!/usr/bin/env zsh
# PreToolUse Bash gate: fail-closed backstop for the command guards.
#
# guard-health.zsh (SessionStart) writes a sentinel when tirith or cupcake
# are degraded. under bypassPermissions those guards are the only boundary and
# they fail open, so a broken guard means no protection. while the sentinel
# exists this denies all Bash, so the agent can't run commands unguarded. it
# can't cherry-pick "safe" commands to allow, because judging that is cupcake's
# job and cupcake is the thing that's broken.
#
# to recover, run the repair with a `!` prefix. that runs in your shell rather
# than the agent's Bash tool, so it skips this hook: `! ./switch.zsh` from the
# dotfiles repo root. this has to be the first Bash PreToolUse hook, ahead of
# tirith and cupcake, so it wins.

sentinel="${XDG_STATE_HOME:-$HOME/.local/state}/guard/degraded"
[[ -f "${sentinel}" ]] || exit 0

reason="$(cat "${sentinel}" 2>/dev/null)"
jq -n --arg r "${reason}" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ("Agent command guards are degraded, so Bash is blocked fail-closed: under bypassPermissions the guards are the only protection and they are not currently enforcing. Cause: " + $r + ". Repair with `! ./switch.zsh` from the dotfiles repo root (the ! prefix bypasses this gate), then restart the session.")
  }
}'
exit 0
