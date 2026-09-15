# Security

Apply to all code, especially code handling user input, authentication, external
data, shared state, or arithmetic on external values.

## Principles

- **Validate at boundaries.** All user input, API parameters, and external data
  must be validated before use.
- **No secrets in code.** Use environment variables or secret managers. See
  `secrets.md`.
- **Least privilege.** Grant the minimum access required: file permissions,
  database roles, API scopes, container capabilities.
- **Defense in depth.** Don't rely on a single layer. Validate input,
  parameterize queries, encode output, set security headers.

## Common Weakness Enumeration (CWE)

Read `security/cwe.md` for the index of known weaknesses and their defenses.
Individual CWE docs contain language-specific remediation patterns.

- `security/cwe.md`: master index, grouped by category
- `security/cwes/cwe-{number}.md`: individual weakness details and fixes

When making decisions about input handling, query construction, authentication,
serialization, or command execution, check the relevant CWE doc first. These are
known, solved problems; don't reinvent the defense.
