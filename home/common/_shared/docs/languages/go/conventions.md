# Go Conventions

## Formatting & Naming

- gofmt is law. No exceptions, no alternatives.
- MixedCaps for all names. No underscores in Go identifiers.
- Acronyms are all-caps: `HTTPServer`, `XMLParser`, `ID`; follow stdlib
  convention.
- Package names: short, lowercase, single word. No `util`, `common`, `base`.
- Exported symbols must have godoc comments starting with the symbol name.

## Imports

- Group in order: stdlib, blank line, external packages.
- Use goimports or editor-on-save to manage automatically.
- Never use dot imports. Alias only to resolve conflicts.

## Error Handling

- Always handle errors. Never use `_` to discard them.
- Wrap errors with `fmt.Errorf("context: %w", err)` to build chains.
- Define sentinel errors with `errors.New` for known conditions.
- Check errors with `errors.Is` and `errors.As`, never string matching.
- No naked returns. Ever.

## General

- No `init()` unless absolutely required (e.g., registering drivers).
- No `panic` in library code. Reserve for truly unrecoverable states.
- Prefer `var` declaration for zero values, `:=` for initialized values.
- Use `context.Context` as the first parameter, not embedded in structs.
- const over var for values known at compile time.

## Security

- No `exec.Command("sh", "-c", ...)` with user input; pass args directly
  (CWE-78).
- Parameterized queries only: no string concatenation in SQL (CWE-89).
- Validate ranges before narrowing conversions (`int64` to `int32`) (CWE-190).
- `sync.Mutex` across check-and-act sequences; run `go test -race` on every test
  run (CWE-362).
- Go `encoding/xml` is safe from XXE by default, but verify third-party XML
  libraries (CWE-611).
- Avoid `unsafe` package; it bypasses memory safety (CWE-787).
