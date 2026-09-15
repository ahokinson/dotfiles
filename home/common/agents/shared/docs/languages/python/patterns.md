# Python Patterns

## Classes & Data Modeling

- Classes over standalone functions for stateful operations.
- `dataclasses.dataclass` for value objects and internal data structures.
- `Pydantic.BaseModel` at system boundaries: API inputs, config files, external
  data.
- `Enum` for fixed sets of values. Always inherit from `str, Enum` or `int,
  Enum`.

## Structural Typing

- `Protocol` for structural typing: duck typing with type safety.
- Define protocols where they are consumed, not where they are implemented.
- Prefer protocols over ABCs unless you need shared implementation.

## Resource Management

- Context managers (`with` statement) for anything that acquires/releases
  resources.
- Implement `__enter__`/`__exit__` or use `contextlib.contextmanager`.

## Concurrency

- `async`/`await` for IO-bound concurrency. No threading unless CPU-bound.
- `asyncio.TaskGroup` for structured concurrent work.
- Never mix sync and async without explicit bridge (`asyncio.run`,
  `loop.run_in_executor`).

## General

- Avoid metaclasses and descriptors unless building a framework.
- Decorators for cross-cutting concerns only (logging, auth, retry).
- Composition over inheritance. Inherit only from dataclasses or framework
  bases.
