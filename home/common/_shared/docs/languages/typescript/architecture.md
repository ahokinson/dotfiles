# TypeScript Architecture

## Project Structure

- Feature-folder structure for React apps. Group by feature, not by type.
- Co-locate components with their styles, types, and tests.
- Barrel files (`index.ts`) for public module API. One per feature folder.
- Path aliases over deep relative imports (`@/features/auth` not
  `../../../features/auth`).

## Module Design

- Explicit exports. No re-exporting everything.
- One concept per file. Split when a file exceeds ~200 lines.
- Framework-aware: React and Next.js patterns are expected and fine.

## Approved Frameworks

- `React` for UI.
- `Next.js` for full-stack React apps.
- `pino` for structured logging.
- Ask the user before adding frameworks not listed here.

## Dependencies

- bun as runtime, package manager, bundler, and test runner.
- Commit `bun.lock`.

## Tooling

- bun for everything: runtime, install, test, build.
