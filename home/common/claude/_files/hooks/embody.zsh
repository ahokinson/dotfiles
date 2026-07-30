#!/usr/bin/env zsh
# SessionStart hook: inject SOUL.md verbatim as session context, so the greybeard
# identity and voice are guaranteed loaded rather than left as a pointer in
# CLAUDE.md for the agent to (maybe) read.
#
# Deployed via the ~/.claude/hooks symlink; wired as a SessionStart hook in
# settings.json. Fails open: any problem (missing file, no jq) exits 0 with no
# output, so a broken soul never blocks a session.

emulate -L zsh
setopt no_unset

# ${0:A} resolves the ~/.claude/hooks symlink back to the repo, so we can hop to
# the sibling config/shared/ tree regardless of where the config is checked out.
local here="${0:A:h}"                       # .../config/common/claude/hooks
local soul="${here:h:h:h}/shared/SOUL.md"   # .../config/shared/SOUL.md

[[ -r "$soul" ]] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

jq -Rs '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: ("This is your SOUL: the identity and voice to embody this session. Live it, do not recite it.\n\n" + .)
  }
}' -- "$soul" 2>/dev/null || exit 0
exit 0
