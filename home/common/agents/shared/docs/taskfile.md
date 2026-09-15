# Taskfile Conventions

## General

- `Taskfile.yml` at repo root. Always.
- go-task is the task runner. No Make, no npm scripts for automation.
- Use tasks for anything beyond a single command: builds, linting, migrations,
  local setup.

## Naming

- Lowercase, colon-separated namespaces: `db:migrate`, `lint:fix`, `docker:up`.
- `default` task shows available tasks or runs the most common workflow.
- `setup` task for first-time project bootstrap.

## Structure

- Group related tasks with namespace prefixes.
- Use `deps` for task dependencies, not chained shell commands.
- Use `sources` and `generates` for file-based caching where applicable.
- Keep task descriptions short. One line.

## Variables

- Define shared variables at the top level under `vars:`.
- Use `.env` files via `dotenv:` for environment-specific config.
- Never hardcode paths that vary across machines.

## Patterns

- `dev` task to start the local development environment (Compose + watchers).
- `lint` runs all linters. `lint:fix` auto-fixes.
- `build` produces artifacts. `clean` removes them.
- `db:migrate`, `db:seed`, `db:reset` for database lifecycle.
