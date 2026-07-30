---
name: taskfile
description: go-task conventions for task automation
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: tooling
---

## What I do

- Prescribe Taskfile.yml conventions for task naming, structure, and variables
- Enforce go-task as the standard task runner (no Make, no npm scripts)
- Guide standard task patterns (dev, lint, build, db lifecycle)

## When to use me

Use this skill when creating or reviewing Taskfile.yml configurations.

## Conventions

Read `docs/taskfile.md` for the full specification. Key points: Taskfile.yml at
repo root, colon-separated namespaces (`db:migrate`, `lint:fix`), `default` and
`setup` tasks required, `deps` for dependencies not chained shell commands.
