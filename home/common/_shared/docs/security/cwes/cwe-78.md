# CWE-78: OS Command Injection

**Category**: Injection
**Severity**: Critical

User-controlled input passed to shell commands allows arbitrary command
execution.

## The Problem

Any time user input is interpolated into a string that gets executed as a shell command, an attacker can inject additional commands using shell metacharacters (`;`, `|`, `&&`, `` ` ``, `$()`).

## Defense

**Never construct shell commands from user input.** Use language APIs that
bypass the shell entirely.

### Go

```go
// WRONG: shell execution with user input
exec.Command("sh", "-c", "convert " + filename)

// RIGHT: direct execution, no shell
exec.Command("convert", filename)
```

### Python

```python
# WRONG: shell=True with user input
subprocess.run(f"convert {filename}", shell=True)

# RIGHT: argument list, no shell
subprocess.run(["convert", filename])
```

### TypeScript

```typescript
// WRONG: shell execution
exec(`convert ${filename}`)

// RIGHT: argument list, no shell
execFile("convert", [filename])
```

## Key Rules

- Never use `shell=True` (Python), `sh -c` (Go), or `exec()` (Node) with user
  input
- Pass arguments as arrays, not interpolated strings
- If shell features are truly needed, use an allowlist of permitted values;
  never pass raw input
- Validate input against an expected pattern before use
