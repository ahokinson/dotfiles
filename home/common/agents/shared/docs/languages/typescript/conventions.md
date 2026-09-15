# TypeScript Conventions

## Type Safety

- `strict: true` in tsconfig. No exceptions.
- Never use `any`. Use `unknown` with type narrowing.
- Explicit return types on all exported functions.
- `interface` for object shapes. `type` for unions and intersections.

## Naming & Imports

- camelCase for variables/functions. PascalCase for types/classes/components.
- Named imports only. No default exports. They break refactoring tools and make
  imports inconsistent across consumers.
- Prefer native APIs (`fetch`, `URL`, `crypto`) over polyfill dependencies.

## Variables & Operators

- `const` over `let`. Never `var`.
- Nullish coalescing (`??`) and optional chaining (`?.`) over manual null
  checks.
- Strict equality (`===`) always. Never `==`.

## Error Handling

- Typed error classes extending `Error` for domain errors.
- Always handle promise rejections. No unhandled `.catch()` chains.

## General

- Template literals over string concatenation.
- `readonly` for properties that should not be reassigned.
- Destructuring for clean extraction, but not when it hurts readability.

## Security

- Allowlist dynamic `import()` / `require()` paths; never use raw user input
  (CWE-22).
- No `dangerouslySetInnerHTML` or `v-html` with user input; use framework
  escaping (CWE-79).
- No `eval()`, `new Function()`, or string arguments to
  `setTimeout`/`setInterval` (CWE-95).
- Use `Number.isSafeInteger()` to validate external input before arithmetic
  (CWE-190).
- Filter `__proto__`, `constructor`, `prototype` keys from user objects; use
  `Map` for user-keyed data (CWE-1321).
- No nested regex quantifiers on user input; use `re2` for user-supplied
  patterns (CWE-1333).
