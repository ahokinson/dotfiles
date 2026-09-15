# TypeScript Patterns

## React Components

- Function components only. No class components.
- Hooks for state and effects. No HOCs unless wrapping third-party.
- Explicit prop types via `interface`. Never inline prop types.
- Custom hooks to extract reusable stateful logic (`useAuth`, `useFetch`).

## State Modeling

- Discriminated unions for state machines and variant types.
- `as const` for literal types and exhaustive checks.
- Zod or similar for runtime validation at system boundaries (API inputs, form
  data).
- Keep state minimal. Derive computed values, don't store them.

## Async

- `async`/`await` over raw `Promise.then()` chains.
- Avoid callback patterns. Convert callbacks to promises when interfacing with
  legacy APIs.
- `AbortController` for cancellable async operations.

## Type Patterns

- Generics for reusable utilities. Constrain with `extends`.
- Utility types (`Pick`, `Omit`, `Partial`, `Required`) over manual
  redefinition.
- `satisfies` operator to validate types without widening.

## General

- Composition over inheritance. Prefer interfaces + functions over class
  hierarchies.
- Immutable by default. Spread/copy instead of mutating.
- Early returns to reduce nesting.
