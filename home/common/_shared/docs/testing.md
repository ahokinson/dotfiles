# Testing

Do not generate tests unless explicitly asked. When asked, follow these
principles.

## Philosophy

Unit tests are the foundation. Prefer many focused unit tests over fewer
integration tests. Each test should verify one behavior. If a test name needs
"and" in it, split it.

Mock external dependencies at the boundary; define interfaces (repository
pattern, API clients) and substitute test doubles. Do not mock drivers or
low-level I/O directly. Tests should be fast, deterministic, and runnable
offline. The goal is confidence in logic, not in infrastructure.

Coverage matters. Aim for meaningful coverage of branches and edge cases, not
just line count. Untested error paths are bugs waiting to happen.

## Patterns

Use standard, idiomatic test patterns for each language:

- **Go**: `testing` package, table-driven tests, `testify` only if already in
  deps
- **Python**: `pytest`, fixtures, `unittest.mock.patch` (the mock module is
  fine; do not use `unittest.TestCase`)
- **TypeScript**: `bun test`, `describe`/`it` blocks

Follow the Arrange-Act-Assert structure. Keep test setup close to the assertion.
Shared fixtures are fine when they reduce noise, but avoid deep test
hierarchies.

## What to Test

- Public API surface and exported functions
- Error paths and edge cases (nil, empty, boundary values)
- State transitions and side effects
- Validation logic

## What Not to Test

- Private implementation details that change frequently
- Framework behavior (trust the framework)
- Trivial getters/setters with no logic
