#!/usr/bin/env zsh
# SessionStart health check for the two-layer agent command guard.
#
# with permissions.defaultMode = bypassPermissions, these guards are all that
# stands between the agent and a dangerous command, and every layer fails open
# (a missing binary, broken stub, or eval error all fall through to allow). so a
# silently broken guard leaves nothing enforcing and nothing to say so. this
# catches that at session start. it only warns, via stderr plus injected agent
# context; it never blocks the session and always exits 0.
#
# deployed to ~/.claude/hooks/; wired as a SessionStart hook in settings.json.

problems=()

command -v tirith  >/dev/null 2>&1 || problems+=("tirith (command scanner) not on PATH")
command -v opa     >/dev/null 2>&1 || problems+=("opa (cupcake's Rego engine) not on PATH")

if ! command -v cupcake >/dev/null 2>&1; then
    problems+=("cupcake (policy engine) not on PATH")
else
    stub="${XDG_DATA_HOME:-$HOME/.local/share}/cupcake-stub"
    if [[ ! -d "${stub}/.cupcake/policies/claude" ]]; then
        problems+=("cupcake stub project missing (${stub}/.cupcake), run dot.zsh sync")
    else
        # end-to-end check: feed a known halt command (rm -rf /, FILESYSTEM-001)
        # through the real cupcake-guard.zsh and assert it denies. this exercises
        # the whole path: stub, cupcake eval, opa/WASM, global store, and the
        # wrapper's fail-open handling. cupcake eval needs a full hook event, so
        # session_id/transcript_path/cwd are all mandatory; leaving them out makes
        # eval exit 1, which the wrapper's `|| exit 0` swallows and would false-alarm here.
        guard="${0:a:h}/guard-cupcake.zsh"
        ev='{"session_id":"guard-healthcheck","transcript_path":"/dev/null","cwd":"'"${HOME}"'","permission_mode":"bypassPermissions","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"rm -rf /"}}'
        out="$(print -r -- "${ev}" | zsh "${guard}" 2>/dev/null)"
        [[ "${out}" == *'"permissionDecision":"deny"'* ]] \
            || problems+=("cupcake did not block a known-dangerous command (rm -rf /), guard not enforcing")
    fi
fi

# shared machine-wide sentinel: the PreToolUse gate (guard-gate.zsh) and the
# opencode gate read this to fail closed, denying all Bash while the guards are
# degraded. written on failure, removed on health. SessionStart runs before any
# tool call, so a session that starts healthy clears a stale sentinel left by a
# prior broken one.
sentinel="${XDG_STATE_HOME:-$HOME/.local/state}/guard/degraded"

if (( ${#problems} == 0 )); then
    rm -f "${sentinel}" 2>/dev/null
    exit 0
fi

joined="${(j: · :)problems}"
mkdir -p "${sentinel:h}" 2>/dev/null && print -r -- "${joined}" >"${sentinel}" 2>/dev/null
print -r -- "agent guard healthcheck failed: ${joined}" >&2
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"Security guard degraded: %s. bypassPermissions is active and Bash is now gated fail-closed (guard-gate.zsh denies all Bash until healthy). Repair with `! config/common/cupcake/dot.zsh sync` (the ! prefix runs in your shell, bypassing the gate), then restart."}}\n' "${joined}"
exit 0
