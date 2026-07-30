# JavaScript Conventions

## When to Use JavaScript

- Only when the codebase is already JavaScript and the user is not refactoring
  to TypeScript.
- For new projects or new files, always use TypeScript instead.
- If adding a new file to a JS codebase, ask whether to use TypeScript before
  defaulting to JS.

## Style

- Follow the same conventions as `typescript/conventions.md` where applicable.

## Type Safety Without TypeScript

- JSDoc type annotations on all exported functions.
- `// @ts-check` at the top of every file to enable editor type checking.
- `jsconfig.json` with `"checkJs": true` at project root.

## Architecture & Patterns

- No separate architecture or patterns docs for JavaScript.
- Mirror the existing codebase's architecture and patterns. Match what's already
  there.
- For anything not established by the codebase, fall back to the TypeScript
  docs.
- When existing patterns contradict TypeScript conventions, prefer TypeScript
  conventions unless refactoring would be disruptive to the immediate task.

## General

- Do not introduce JS-only patterns that diverge from TypeScript conventions.
- If the codebase is mixed JS/TS, write new code in TypeScript.
