# Common Weakness Enumeration (CWE) Index

Known vulnerability classes with documented defenses. Read the relevant CWE doc
before writing code in that problem space. These are solved problems; apply the
known fix.

## Authentication

Missing or flawed identity verification.

- `cwes/cwe-287.md`, **Improper Authentication**: Missing or bypassable
  authentication checks

## Concurrency

Shared state accessed without synchronization.

- `cwes/cwe-362.md`, **Race Conditions**: TOCTOU and unsynchronized
  check-and-act sequences

## Credentials

Secrets and authentication material mishandled.

- `cwes/cwe-798.md`, **Hardcoded Credentials**: Passwords, keys, or tokens
  embedded in source code

## Cross-Site Request Forgery

Unintended actions performed via authenticated sessions.

- `cwes/cwe-352.md`, **CSRF**: Attacker tricks authenticated user's browser into
  making requests

## Cross-Site Scripting

Untrusted data rendered in browser contexts.

- `cwes/cwe-79.md`, **Cross-Site Scripting (XSS)**: User input reflected or
  stored in HTML output
- `cwes/cwe-1321.md`, **Prototype Pollution**: User-controlled keys modify
  `Object.prototype`

## Code Injection

Untrusted data evaluated as code within the application runtime.

- `cwes/cwe-95.md`, **Code Injection**: User input passed to `eval()`, `exec()`,
  `new Function()`
- `cwes/cwe-134.md`, **Format String Injection**: User input used as format
  string template
- `cwes/cwe-1336.md`, **Template Injection (SSTI)**: User input rendered as
  server-side template source

## Command & Query Injection

Untrusted data interpreted as commands or queries.

- `cwes/cwe-78.md`, **OS Command Injection**: User input passed to shell
  commands
- `cwes/cwe-89.md`, **SQL Injection**: User input concatenated into SQL queries
- `cwes/cwe-611.md`, **XML External Entity (XXE)**: External entity resolution
  in XML parsers

## Insecure Deserialization

Untrusted data deserialized into objects.

- `cwes/cwe-502.md`, **Deserialization of Untrusted Data**: Arbitrary object
  instantiation from external input

## Denial of Service

Resource exhaustion through algorithmic complexity attacks.

- `cwes/cwe-1333.md`, **ReDoS**: Catastrophic regex backtracking on crafted
  input

## Memory Safety

Writes or reads outside allocated memory bounds.

- `cwes/cwe-787.md`, **Out-of-Bounds Write**: Writing past buffer boundaries via
  `unsafe` or cgo

## Numeric

Arithmetic errors from fixed-width types.

- `cwes/cwe-190.md`, **Integer Overflow**: Arithmetic exceeding type range
  causes wrapping or truncation

## Path Traversal

Untrusted data used to construct file paths.

- `cwes/cwe-22.md`, **Path Traversal**: User input used in file path operations

## Server-Side Request Forgery

User-controlled URLs used in server-side requests.

- `cwes/cwe-918.md`, **SSRF**: Server fetches attacker-controlled URLs reaching
  internal services
