# Authentication & Authorization

JWT for stateless API auth. Server-side sessions for web apps with browser
clients.

## API Key Handling

- Treat API keys as secrets. Never log, expose in URLs, or return in responses.
- Hash stored API keys (SHA-256 is fine here since they are high-entropy, unlike
  passwords; this does not apply to passwords, see Password Hashing below).
- Use a recognizable prefix for identification: `sk_live_`, `pk_test_`; enables
  grep and rotation tooling.
- Support key rotation: allow multiple active keys per client during transition
  periods.
- Scope keys to minimum required permissions. Full-access keys are a liability.

## Authorization

- Enforce authorization server-side. Client-side checks are UX, not security.
- Centralize authorization logic: one module, one pattern, not scattered `if`
  checks.
- Implement object-level access checks: verify the user can access *this
  specific* resource, not just *this type* of resource.
- Deny by default. Explicitly grant access, never explicitly deny.
- Log authorization failures; they indicate bugs or attacks.

## JWT Validation

- Always verify the signature. Never decode without validation
  (`jwt.decode(verify=False)`).
- Validate all claims: `exp`, `iss`, `aud`, `nbf`. Reject tokens missing
  required claims.
- Use asymmetric keys (RS256/ES256) for multi-service architectures. Symmetric
  (HS256) only when a single service issues and validates.
- Never store secrets, PII, or authorization data in the JWT payload; it is
  base64, not encrypted.
- Implement token revocation for logout and compromise scenarios (blocklist or
  short expiry + refresh tokens).

## Password Hashing

- Use bcrypt (cost >= 12) or argon2id. No other algorithms.
- Never use SHA-256, SHA-512, MD5, or any general-purpose hash for passwords.
- Never truncate or limit password length below 64 characters.
- Compare hashes with constant-time functions to prevent timing attacks.

## Session Management

- Server-side sessions for web applications. Store session data on the server,
  not in cookies.
- Regenerate session IDs on authentication state changes (login, privilege
  escalation).
- Set cookie flags: `HttpOnly`, `Secure`, `SameSite=Lax` (or `Strict` where
  possible).
- Enforce idle and absolute timeouts. 15-30 min idle, 8-24 hr absolute depending
  on sensitivity.
- Invalidate sessions server-side on logout; do not rely solely on cookie
  deletion.
