#!/usr/bin/env zsh
# Context-aware guard: the last PreToolUse Bash hook. Where tirith and cupcake
# judge the command string alone, this inspects live repo state to block things
# that are only wrong in context. Fails open (missing jq/git, not a repo, or any
# error -> allow). On a deny it bumps a per-session counter the statusline reads.
#
# CONTEXT-001: block switching to a branch (git checkout/switch <branch>) while
#   tracked files have staged/unstaged changes - it drags or risks the work.
# CONTEXT-002: block discarding file changes (git checkout -- <paths> / checkout .
#   / git restore <paths>) when those paths actually have unstaged edits to lose.
# Creating a branch (-b/-c), untracked-only trees, and restore --staged are allowed.

emulate -L zsh

command -v jq  >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0

local input cmd cwd
input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
[[ -z "$cmd" ]] && exit 0
# cheap gate: nothing to do unless the command touches the working tree
[[ "$cmd" == (*checkout*|*switch*|*restore*) ]] || exit 0
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
[[ -z "$cwd" ]] && cwd="$PWD"

git_here() { git -C "$cwd" "$@" 2>/dev/null }

# Tracked staged/unstaged changes present (untracked ignored - they carry over).
tree_is_dirty() { [[ -n "$(git_here status --porcelain --untracked-files=no)" ]] }

# True if the given pathspecs have unstaged changes that a restore would discard.
would_discard() {
	local -a pathspecs=("$@")
	(( ${#pathspecs} == 0 )) && pathspecs=(.)
	[[ -n "$(git_here diff --name-only -- "${pathspecs[@]}")" ]]
}

record_and_deny() { # $1 = reason
	{
		local sid vf
		sid="$(printf '%s' "$input" | jq -r '.session_id // empty')"
		if [[ -n "$sid" ]]; then
			vf="${XDG_STATE_HOME:-$HOME/.local/state}/guard/violations-${sid}.state"
			integer tirith=0 cupcake=0 context=0
			[[ -r "$vf" ]] && source "$vf" 2>/dev/null
			(( context++ ))
			mkdir -p "${vf:h}" 2>/dev/null
			{ print -r -- "tirith=$tirith"; print -r -- "cupcake=$cupcake"; print -r -- "context=$context" } >"$vf" 2>/dev/null
		fi
	} 2>/dev/null
	jq -n --arg reason "$1" '{
		hookSpecificOutput: {
			hookEventName: "PreToolUse",
			permissionDecision: "deny",
			permissionDecisionReason: $reason
		}
	}'
	exit 0
}

# Inspect one checkout/switch/restore invocation; may deny (and exit).
analyze() {
	local sub="$1"; shift
	local -a args=("$@")
	local creating=0 staged=0 worktree=0 dashdash=0 target=""
	local -a pathspecs=()
	integer i after_dashdash=0
	for (( i = 1; i <= ${#args}; i++ )); do
		local word="${args[i]}"
		if (( after_dashdash )); then pathspecs+=("$word"); continue; fi
		case "$word" in
			--) dashdash=1; after_dashdash=1 ;;
			-b|-B|-c|-C|--create|--orphan) creating=1 ;;
			--staged|-S) staged=1 ;;
			--worktree|-W) worktree=1 ;;
			--source|-s) (( i++ )) ;;                  # takes a value; skip it
			-*) ;;                                      # any other flag
			*) [[ -z "$target" ]] && target="$word"; pathspecs+=("$word") ;;
		esac
	done

	case "$sub" in
		switch)
			(( creating )) && return
			[[ -n "$target" ]] || return
			tree_is_dirty && record_and_deny "Blocked (CONTEXT-001): switching branches with uncommitted changes to tracked files. Commit or \`git stash\` first, then switch."
			;;
		checkout)
			(( creating )) && return
			if (( ! dashdash )) && [[ -n "$target" ]] && { [[ "$target" == "-" ]] || git_here show-ref --verify --quiet "refs/heads/$target"; }; then
				tree_is_dirty && record_and_deny "Blocked (CONTEXT-001): switching branches with uncommitted changes to tracked files. Commit or \`git stash\` first, then switch."
			else
				would_discard "${pathspecs[@]}" && record_and_deny "Blocked (CONTEXT-002): \`git checkout\` would discard unstaged changes to those files. Commit or \`git stash\` first if you want to keep them."
			fi
			;;
		restore)
			(( staged && ! worktree )) && return       # --staged only just unstages; safe
			would_discard "${pathspecs[@]}" && record_and_deny "Blocked (CONTEXT-002): \`git restore\` would discard unstaged changes to those files. Commit or \`git stash\` first if you want to keep them."
			;;
	esac
}

git_here rev-parse --is-inside-work-tree >/dev/null || exit 0

# Tokenize respecting quotes; walk each git invocation to its checkout/switch/
# restore subcommand and hand its args (up to the next operator) to analyze.
local -a tokens operators
tokens=(${(z)cmd})
operators=(';' '|' '||' '&&' '&' '|&')

integer index count=${#tokens}
for (( index = 1; index <= count; index++ )); do
	[[ "${tokens[index]}" == "git" ]] || continue

	integer sub_index=$(( index + 1 ))
	while (( sub_index <= count )); do
		case "${tokens[sub_index]}" in
			-C|-c|--git-dir|--work-tree|--namespace|--exec-path) (( sub_index += 2 )) ;;
			-*) (( sub_index++ )) ;;
			*) break ;;
		esac
	done
	local subcommand="${tokens[sub_index]}"
	[[ "$subcommand" == (checkout|switch|restore) ]] || continue

	local -a sub_args=()
	integer arg
	for (( arg = sub_index + 1; arg <= count; arg++ )); do
		(( ${operators[(Ie)${tokens[arg]}]} )) && break
		sub_args+=("${tokens[arg]}")
	done

	analyze "$subcommand" "${sub_args[@]}"
done
exit 0
