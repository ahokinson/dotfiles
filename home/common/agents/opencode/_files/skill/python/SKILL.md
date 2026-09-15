---
name: python
description: Prescriptive Python conventions, architecture, and patterns
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: python
---

## What I do

- Enforce opinionated Python conventions for naming, typing, imports, and errors
- Prescribe project structure, tooling (uv, ruff, ty), and approved frameworks
- Guide class design, structural typing, and async patterns

## When to use me

Use this skill when writing or reviewing Python code. These conventions are
prescriptive; follow them, do not suggest alternatives.

## Conventions

Read `docs/python/conventions.md` for naming (snake_case/PascalCase), type hints
(required on all signatures, union syntax), imports (absolute only), and error
handling (specific exceptions, custom classes).

Read `docs/python/architecture.md` for project metadata (pyproject.toml, uv),
module design (`__init__.py` for public API), approved frameworks (FastAPI,
Pydantic), and tooling (ruff, ty, Taskfile, Docker Compose).

Read `docs/python/patterns.md` for class design (dataclasses for value objects,
Pydantic at boundaries), structural typing (Protocol over ABCs), resource
management (context managers), and concurrency (async/await, TaskGroup).
