---
name: code-security
description: |
  Systematic security-focused code review identifying vulnerabilities, misconfigurations, and insecure patterns.
  TRIGGER when: user asks for a security review, vulnerability assessment, security audit, or penetration-test-style analysis of code.
  DO NOT TRIGGER when: user asks for a general code review, feature feedback, refactoring suggestions, or style/lint fixes.
command: code-security
---

# Secure Code Review

## Phase 1: Reconnaissance

1. Identify stack: languages, frameworks, ORMs, template engines, auth
   libraries, serialization formats.
2. Map entry points and trust boundaries.
3. Locate security config: auth middleware, CORS, CSP, TLS, secrets, sessions.
4. Review dependency manifests for known-vulnerable versions.
5. Map auth/authz architecture: middleware chain, identity providers, token
   management.

## Phase 2: Taint Analysis

Trace untrusted data from sources to sinks. Verify sanitizers on every path. A
missing sanitizer on any path is a finding.

**Sources:** HTTP params/headers/cookies/body, DB results (second-order), file
contents, message queue payloads, third-party API responses, environment
variables in multi-tenant contexts.

**Sinks:** SQL execution, OS commands, file path construction, HTML rendering,
deserialization, LDAP/XPath, redirect targets, crypto operations (key material),
logging (data exposure).

**Sanitizers:** Parameterized queries (SQL), context-aware output encoding
(HTML/JS/URL), allow-list validation (paths/redirects), schema validation and
type coercion.

**Pitfalls:**
- Wrong-context sanitizer (HTML-encoding does not prevent SQLi)
- Second-order flows: data stored safely, retrieved later without re-validation
- Indirect flows: user input controls an index/flag/config key, not the sink
  value itself
- Framework magic: ORMs/serializers may introduce or remove taint transparently

## Phase 3: Vulnerability Pattern Matching

Check OWASP Top 10 systematically. See `references/owasp-top-10.md`. Priority:

1. Injection (SQLi, XSS, command, SSTI, expression language)
2. Broken auth (weak credentials, session fixation, token flaws)
3. Broken access control (missing authz, IDOR, path traversal, CORS)
4. Cryptographic failures (weak algos, hardcoded keys, bad RNG)
5. Insecure deserialization
6. SSRF

## Phase 4: Language-Specific Analysis

Apply language-specific rules per identified stack. See
`references/language-vulns.md`.

## Phase 5: Auth Deep Dive

**Authentication:** bcrypt/scrypt/Argon2id only. MFA bypass impossible via alt
endpoints. Session tokens >= 128-bit CSPRNG. JWT enforces algorithm, checks
exp/iss/aud, no `alg:none`. Reset flows don't leak account existence; tokens
single-use and time-limited.

**Authorization:** Every state-changing endpoint has explicit authz. Centralized
in middleware, not duplicated. Object-level authz prevents IDOR. Role
hierarchies prevent horizontal escalation. API and UI enforce identical rules.

## Phase 6: Cryptography Review

- AES-256-GCM or ChaCha20-Poly1305. Never ECB.
- RSA >= 2048-bit OAEP or curve25519/P-256.
- Platform CSPRNG only (`secrets`, `crypto/rand`, `SecureRandom`,
  `crypto.getRandomValues`).
- No hardcoded/logged/committed key material.
- TLS 1.2+, certificate verification enabled.
- Nonces never reused. Key derivation via PBKDF2 (>= 600k
  iterations)/scrypt/Argon2id.

## Phase 7: Data Exposure Review

- Sensitive fields excluded from API responses unless required.
- Errors don't leak internals to clients.
- Logs free of passwords, tokens, keys, PII.
- Sensitive data at rest encrypted. `Cache-Control: no-store` on authenticated
  endpoints.

## Phase 8: Business Logic and Race Conditions

- TOCTOU: condition changes between check and action.
- Race conditions: double-spend, double-redemption, parallel rate-limit bypass.
- Integer overflow in business calculations (quantity, price, balance).
- State machine violations: skipped/replayed steps in multi-step workflows.

## Reporting Format

```markdown
### [SEVERITY] Finding Title

**CWE:** CWE-XXX -- Name
**OWASP:** A0X:2021 -- Category
**Location:** `path/to/file.ext:line`

**Description:** What and why.

**Vulnerable Code:** The specific code.

**Proof of Concept:** Exploitation steps (request, payload, or sequence).

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
