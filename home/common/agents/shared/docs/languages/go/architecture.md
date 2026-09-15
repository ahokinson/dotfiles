# Go Architecture

## Project Layout

- `cmd/` for entrypoints. One `main.go` per binary.
- `internal/` for private packages. Use domain-driven subpackages.
- `internal/domain/` for business logic and types. No external dependencies.
- `internal/infra/` for adapters: databases, HTTP clients, external services.
- `go.mod` at repo root. No nested modules.

## Package Design

- Accept interfaces, return structs.
- Repository pattern for data access. Interface in domain, implementation in
  infra.
- Dependency injection via constructor functions (`func New(...) *Thing`).
- No DI frameworks. No reflection-based wiring.
- Keep packages small and focused. One concept per package.

## Approved Frameworks

- The standard library is very thorough. Use `net/http`, `encoding/json`,
  `html/template`, etc. before reaching for anything else.
- `chi` for HTTP routing when stdlib `net/http` mux is insufficient.
- `gopkg.in/yaml.v3` for YAML parsing.
- `gocui` for terminal UIs.
- `log/slog` for structured logging.
- Ask the user before adding frameworks not listed here.

## Dependencies

- `go.sum` must be committed.

## Tooling

- `go build`, `go test`, `go vet` as baseline.
- golangci-lint for comprehensive linting.
