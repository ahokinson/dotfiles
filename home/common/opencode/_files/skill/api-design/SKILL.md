---
name: api-design
description: Opinionated REST API design conventions
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: api
---

## What I do

- Enforce REST-only API design conventions
- Prescribe response shapes, status codes, versioning, and auth patterns
- Guide input validation and pagination

## When to use me

Use this skill when designing or reviewing HTTP APIs. REST only; no GraphQL, no
gRPC unless interfacing with a service that requires it.

## Conventions

Read `docs/api.md` for the full specification. Key points: JSON bodies, plural
nouns for resources, cursor-based pagination, URL path versioning (`/v1/`),
bearer tokens in Authorization header, validate all input at the boundary.
