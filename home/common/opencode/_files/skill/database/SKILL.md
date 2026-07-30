---
name: database
description: Database selection, connectors, and raw SQL conventions
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: database
---

## What I do

- Prescribe database selection (Redis, Turso, Postgres)
- Enforce raw SQL over ORMs and query builders
- Specify approved connectors per language

## When to use me

Use this skill when designing data storage or writing database queries. No ORMs,
no query builders, no NoSQL.

## Conventions

Read `docs/database.md` for the full specification. Key points: Redis for
ephemeral state, Turso for simple relational, Postgres for complex relational.
Raw SQL with parameterized queries. Migrations as numbered SQL files.
