---
name: typescript
description: Prescriptive TypeScript conventions, architecture, and patterns
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: typescript
---

## What I do

- Enforce opinionated TypeScript conventions for type safety, naming, and error
  handling
- Prescribe project structure, tooling (bun), and approved frameworks (React,
  Next.js)
- Guide React component patterns, state modeling, and async patterns

## When to use me

Use this skill when writing or reviewing TypeScript code. These conventions are
prescriptive; follow them, do not suggest alternatives.

## Conventions

Read `docs/typescript/conventions.md` for type safety (strict mode, no `any`),
naming (camelCase/PascalCase), imports (named only, no default exports), and
error handling (typed error classes).

Read `docs/typescript/architecture.md` for project structure (feature-folders,
barrel files, path aliases), approved frameworks (React, Next.js), dependencies
(bun for everything), and testing (bun test, co-located).

Read `docs/typescript/patterns.md` for React components (function only, hooks,
explicit prop types), state modeling (discriminated unions, Zod at boundaries),
async (async/await, AbortController), and type patterns (generics, utility
types, satisfies).
