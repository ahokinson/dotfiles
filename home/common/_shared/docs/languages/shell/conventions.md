# Shell Conventions

## Shebang & Strict Mode

- Prefer zsh. Use `#!/usr/bin/env zsh` for new scripts.
- Use `#!/usr/bin/env bash` only when portability to non-zsh systems is
  required.
- Always set `set -euo pipefail` immediately after the shebang.

## Zsh Preferences

- Use zsh features where they simplify code: `${var:?msg}` parameter expansion,
  `=()` process substitution, native associative arrays.
- `autoload -Uz` for function loading from `$fpath`.
- Prefer zsh builtins over external commands when a builtin equivalent exists
  (e.g., `${(s:/:)path}` over `cut`).

## Naming

- `snake_case` for local variables and functions.
- `UPPER_SNAKE_CASE` for exported environment variables and constants.
- Prefix private/internal functions with `_` (e.g., `_parse_args`).
- Lowercase hyphenated filenames: `install-deps`, `setup-env.zsh`.

## Quoting

- Always quote variable expansions: `"${var}"`, not `$var`.
- Use `"$@"` for argument passthrough. Never unquoted `$@` or `$*`.
- Single quotes for string literals with no expansions.

## Error Handling

- Check return codes explicitly: `if ! command; then ... fi`.
- Use `trap cleanup EXIT` for resource cleanup.
- Prefer `if ! command` over `command || true`; be explicit about intent.
- Use `readonly` for constants: `readonly config_dir="/etc/app"`.
- Use `local` for all function-scoped variables.

## General

- `printf` over `echo`; `echo` behavior varies across shells and platforms.
- One function per concern. Keep functions short; if a function exceeds ~30
  lines of logic, extract a helper.
- Use `local` for all variables inside functions.
- `readonly` for values that should never change after assignment.

## Security

- No `eval` with external or user-controlled data.
- No unvalidated variable commands (`"$cmd" "$args"` where `cmd` comes from
  input).
- Sanitize `PATH` in scripts that run with elevated privileges.
- Use `mktemp` for temporary files; never hardcoded paths in `/tmp`.
- Use `[[ ]]` over `[ ]`; it prevents word splitting and glob expansion.
