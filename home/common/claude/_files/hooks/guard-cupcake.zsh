#!/usr/bin/env zsh
# evaluate the Bash command against cupcake's global policies (command-regex
# rules like git-guard, plus the global builtins).
#
# cupcake 0.3.0 needs a project ".cupcake/" in the working directory, so eval
# runs from a stub project; the real rules live in the global store
# (~/Library/Application Support/cupcake) and apply on top. any error or missing
# setup falls through to allow with no output, so a broken layer never blocks work.
# tirith isn't wired in here on purpose: signal-based policies don't get their
# signal in the 0.3.0 global evaluator, so tirith runs as its own hook instead.
#
# on a deny/halt, increments a per-session counter written to a sourceable zsh
# state file the statusline reads (cc-violations-<session_id>.state). the write
# is fail-safe: any error is swallowed so it never affects the deny decision.

command -v cupcake >/dev/null 2>&1 || exit 0

stub="${XDG_DATA_HOME:-$HOME/.local/share}/cupcake-stub"
[[ -d "${stub}/.cupcake/policies/claude" ]] || exit 0

input="$(cat)"
out="$(cd "${stub}" && printf '%s' "${input}" | cupcake eval --harness claude 2>/dev/null)" || exit 0
[[ -n "${out}" ]] || exit 0

# fail-safe per-session counter for the statusline, only on deny/halt tiers
{
  decision="$(printf '%s' "${out}" | jq -r '.hookSpecificOutput.permissionDecision // empty' 2>/dev/null)"
  [[ "$decision" == "deny" ]] && {
    sid="$(printf '%s' "${input}" | jq -r '.session_id // empty')"
    [[ -n "$sid" ]] && {
      vf="${XDG_STATE_HOME:-$HOME/.local/state}/guard/violations-${sid}.state"
      integer tirith=0 cupcake=0 context=0
      [[ -r "$vf" ]] && source "$vf" 2>/dev/null
      (( cupcake++ ))
      mkdir -p "${vf:h}" 2>/dev/null
      { print -r -- "tirith=$tirith"; print -r -- "cupcake=$cupcake"; print -r -- "context=$context" } >"$vf" 2>/dev/null
    }
  }
} 2>/dev/null

print -r -- "${out}"
exit 0
