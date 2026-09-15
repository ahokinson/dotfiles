# Languages

Route by language, then by need:

| Language | Conventions | Architecture | Patterns |
|----------|------------|-------------|----------|
| Go | `languages/go/conventions.md` | `languages/go/architecture.md` | `languages/go/patterns.md` |
| Python | `languages/python/conventions.md` | `languages/python/architecture.md` | `languages/python/patterns.md` |
| TypeScript | `languages/typescript/conventions.md` | `languages/typescript/architecture.md` | `languages/typescript/patterns.md` |
| JavaScript | `languages/javascript/conventions.md` | n/a | n/a |
| Shell | `languages/shell/conventions.md` | n/a | n/a |

1. Always read **conventions** for the language you are writing
2. Read **architecture** when the task involves project structure, dependencies,
   or tooling
3. Read **patterns** when the task involves concurrency, domain modeling, or
   framework-specific design
## Cross-Language Rules

- Prefer stdlib for application logic; use mandated tools for linting,
  validation, and infrastructure
- Prefer types with methods for stateful operations. Standalone functions are
  fine for stateless logic. Composition over inheritance.
- Taskfile.yml for task automation, Docker Compose (Rancher Desktop) for
  services
