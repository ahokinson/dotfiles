# CWE-22: Path Traversal

**Category**: Path Traversal
**Severity**: High

User-controlled input used in file path operations allows reading or writing
arbitrary files.

## The Problem

When user input is used to construct file paths without validation, attackers
can use `../` sequences or absolute paths to escape the intended directory and
access sensitive files (`/etc/passwd`, `.env`, application source).

## Defense

**Resolve the path and verify it's within the allowed directory.**

### Go

```go
// WRONG: direct concatenation
path := filepath.Join(baseDir, userInput)

// RIGHT: resolve and verify
path := filepath.Join(baseDir, userInput)
resolved, err := filepath.EvalSymlinks(path)
if err != nil || !strings.HasPrefix(resolved, baseDir) {
    return fmt.Errorf("path outside allowed directory")
}
```

### Python

```python
# WRONG: direct concatenation
path = base_dir / user_input

# RIGHT: resolve and verify
path = (base_dir / user_input).resolve()
if not str(path).startswith(str(base_dir.resolve())):
    raise ValueError("path outside allowed directory")
```

### TypeScript

```typescript
// WRONG: direct concatenation
const filePath = path.join(baseDir, userInput)

// RIGHT: resolve and verify
const filePath = path.resolve(baseDir, userInput)
if (!filePath.startsWith(path.resolve(baseDir))) {
  throw new Error("path outside allowed directory")
}
```

## Key Rules

- Always resolve paths to their canonical form before checking prefixes
- Resolve symlinks; they can bypass prefix checks
- Never rely on stripping `../`; there are many encoding bypasses
- Use chroot or container filesystem isolation as defense in depth
- Allowlist permitted file extensions when applicable
