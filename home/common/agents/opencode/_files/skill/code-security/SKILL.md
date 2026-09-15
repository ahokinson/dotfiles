---
name: code-security
description: Systematic security-focused code review identifying vulnerabilities, misconfigurations, and insecure patterns
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: security
---

## What I do

- Perform systematic security code reviews following OWASP methodology
- Trace untrusted data from sources to sinks (taint analysis)
- Identify injection, auth, crypto, and business logic vulnerabilities
- Produce structured findings with severity, CWE, and remediation

## When to use me

Use this skill for security reviews, vulnerability assessments, or
penetration-test-style analysis of code. Not for general code review,
refactoring, or style fixes.

## Review Phases

### 1. Reconnaissance
Identify stack, map entry points and trust boundaries, locate security config,
review dependency manifests, map auth/authz architecture.

### 2. Taint Analysis
Trace untrusted data from sources (HTTP params, DB results, file contents,
message queues, third-party APIs) to sinks (SQL, OS commands, file paths, HTML
rendering, deserialization, redirect targets, crypto operations, logging).
Verify sanitizers on every path. Watch for wrong-context sanitizers,
second-order flows, indirect flows, and framework magic.

### 3. Vulnerability Pattern Matching (OWASP Top 10)
1. Injection (SQLi, XSS, command, SSTI)
2. Broken auth (weak credentials, session fixation, token flaws)
3. Broken access control (missing authz, IDOR, path traversal, CORS)
4. Cryptographic failures (weak algos, hardcoded keys, bad RNG)
5. Insecure deserialization
6. SSRF

### 4. Language-Specific Analysis
Apply language-specific vulnerability patterns for the identified stack.

### 5. Auth Deep Dive
- **Authentication**: bcrypt/scrypt/Argon2id only. MFA bypass impossible.
  Session tokens >= 128-bit CSPRNG. JWT enforces algorithm, checks exp/iss/aud.
  Reset flows don't leak account existence.
- **Authorization**: Every state-changing endpoint has explicit authz.
  Centralized in middleware. Object-level authz prevents IDOR. API and UI
  enforce identical rules.

### 6. Cryptography Review
AES-256-GCM or ChaCha20-Poly1305 (never ECB). RSA >= 2048-bit OAEP or
curve25519/P-256. Platform CSPRNG only. No hardcoded key material. TLS 1.2+.
Nonces never reused.

### 7. Data Exposure Review
Sensitive fields excluded from API responses. Errors don't leak internals. Logs
free of passwords, tokens, keys, PII. Sensitive data at rest encrypted.

### 8. Business Logic and Race Conditions
TOCTOU, double-spend, parallel rate-limit bypass, integer overflow in business
calculations, state machine violations.

## Reporting Format

```markdown
### [SEVERITY] Finding Title

**CWE:** CWE-XXX -- Name
**OWASP:** A0X:2021 -- Category
**Location:** `path/to/file.ext:line`

**Description:** What and why.
**Vulnerable Code:** The specific code.
**Proof of Concept:** Exploitation steps.
**Remediation:** Specific fix.
**References:** CWE links or framework docs.
```

| Severity | Criteria |
|----------|----------|
| CRITICAL | RCE, auth bypass, unauth full data breach |
| HIGH | SQLi, stored XSS, IDOR on sensitive resources, privesc |
| MEDIUM | Reflected XSS, CSRF, internal path/stack trace disclosure |
| LOW | Missing security headers, verbose errors, minor info leak |
| INFO | Best-practice deviations without direct exploitability |
