# Go Patterns

## Concurrency

- Use `errgroup.Group` for structured concurrent work with error propagation.
- Channels for communication between goroutines. Mutexes for shared state.
- Always ensure goroutines can be cancelled via context.
- Never launch goroutines without a shutdown path.

## Context

- Always the first parameter: `func Foo(ctx context.Context, ...)`.
- Never store context in a struct.
- Derive child contexts for timeouts and cancellation scopes.

## Interfaces

- Keep interfaces small. One or two methods is ideal.
- Define interfaces where they are consumed, not where they are implemented.
- Use `io.Reader`, `io.Writer`, and other stdlib interfaces when they fit.

## Constructors

- Functional options pattern for constructors with many optional parameters.
- Simple constructors: `func New(required1, required2 Type) *Thing`.
- Validate required inputs in constructors. Return error if invalid.

## Domain Modeling

- Use custom types for domain concepts: `type UserID string`, `type Money
  int64`.
- Enums via `const` + `iota` with a `String()` method.
- Table-driven logic for repetitive branching, not just tests.

## Resource Management

- `defer` for cleanup immediately after acquiring a resource.
- Implement `io.Closer` for types that hold resources.
