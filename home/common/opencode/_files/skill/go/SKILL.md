---
name: go
description: Prescriptive Go conventions, architecture, and patterns
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: go
---

## What I do

- Enforce opinionated Go conventions for naming, formatting, errors, and imports
- Prescribe project layout, package design, and approved frameworks
- Guide concurrency, interface, and domain modeling patterns

## When to use me

Use this skill when writing or reviewing Go code. These conventions are
prescriptive; follow them, do not suggest alternatives.

## Conventions

Read `docs/go/conventions.md` for naming, formatting, imports, and error
handling rules. Key points: gofmt is law, MixedCaps for all names, always handle
errors with `%w` wrapping, no naked returns.

Read `docs/go/architecture.md` for project layout (`cmd/`, `internal/domain/`,
`internal/infra/`), package design (accept interfaces, return structs), approved
frameworks (stdlib first, chi for routing), and tooling (golangci-lint,
Taskfile, Docker Compose).

Read `docs/go/patterns.md` for concurrency (errgroup, context cancellation),
interfaces (small, defined at consumer), constructors (functional options), and
domain modeling (custom types, iota enums).
