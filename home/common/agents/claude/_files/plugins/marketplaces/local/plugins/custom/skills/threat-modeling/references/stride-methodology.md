# STRIDE Methodology Reference

Apply STRIDE per element: walk every DFD element and evaluate which categories
apply.

## Element-to-Category Mapping

| DFD Element     | S | T | R | I | D | E |
|-----------------|---|---|---|---|---|---|
| External entity | X |   | X |   |   |   |
| Process         | X | X | X | X | X | X |
| Data flow       |   | X |   | X | X |   |
| Data store      |   | X | X | X | X |   |

## S: Spoofing (violates Authentication)

**Ask:**
- Can an entity interact without proving identity?
- Are credentials replayable or forgeable?
- Is auth enforced at every entry point, or can internal endpoints be called
  directly?
- Are service-to-service calls authenticated, or does the system rely on network
  isolation alone?

**Patterns:**
- Credential stuffing from breached databases
- Token forgery (JWT `alg:none`, guessed symmetric key)
- API key extraction from client code or mobile apps
- Service identity spoofing in meshes (rogue pod registration)
- SSRF to IMDS for credential theft
- DNS spoofing / BGP hijack

**Mitigate:**
- MFA for human users
- Short-lived scoped tokens (OAuth 2.0 / OIDC) over long-lived API keys
- mTLS for service-to-service
- Session binding to device/network characteristics
- IMDSv2 (session-oriented) on cloud instances
- Rotate and vault all secrets; never embed in source or client bundles

## T: Tampering (violates Integrity)

**Ask:**
- Can data flowing between these elements be modified by an intermediary?
- Are writes to this data store authorized and validated?
- Is integrity of config files, deployment artifacts, and dependencies verified?
- Are audit logs stored in a tamper-evident manner?

**Patterns:**
- MITM modification over unencrypted channels
- Parameter manipulation (prices, quantities, access levels)
- SQL injection modifying database records
- Dependency confusion / supply-chain poisoning
- Log injection to hide activity or trigger automation
- Forged message bus events

**Mitigate:**
- TLS 1.2+ on all data flows; certificate pinning for high-value mobile clients
- Server-side input validation; never trust client-supplied values for authz or
  pricing
- Parameterized queries / ORM abstractions
- Signed deployment artifacts with pre-execution verification
- HMAC / digital signatures on inter-service messages
- Append-only / WORM log storage
- Pinned dependency versions with checksum verification; private registry mirror

## R: Repudiation (violates Non-repudiation)

**Ask:**
- Does this process log caller identity, action performed, and timestamp?
- Can a user modify or delete their own audit records?
- Are logs shipped to an immutable centralized store outside the component's
  trust boundary?
- Is the log pipeline itself authenticated and integrity-protected?

**Patterns:**
- Uninstrumented action paths leaving no trace
- Log tampering by compromised host
- Timestamp manipulation via system clock changes
- Shared account abuse (no individual attribution)
- Missing transaction receipts

**Mitigate:**
- Log all state-changing ops with caller identity, action, target, timestamp,
  outcome
- Centralized append-only log store (SIEM, immutable object storage)
- Alert on log delivery gaps or attempts to disable logging
- Unique credentials per principal; eliminate shared accounts
- Authenticated NTP sources
- Digital signatures for high-value transactions

## I: Information Disclosure (violates Confidentiality)

**Ask:**
- Does this flow carry sensitive data? Is it encrypted in transit?
- Is data at rest encrypted with keys managed outside the store's trust
  boundary?
- Do error messages or debug endpoints reveal internal implementation details?
- Are access controls field/record-level or only table-level?
- Can resources be enumerated via predictable identifiers?

**Patterns:**
- Cleartext transmission (HTTP, unencrypted gRPC, plain SMTP)
- Excessive API response data (full records when subset needed)
- Error-based leakage (stack traces, SQL errors, framework versions)
- Timing side-channels in auth responses
- Storage misconfiguration (public buckets, overly permissive IAM)
- Sensitive data (tokens, PII) written to logs

**Mitigate:**
- Encrypt in transit (TLS 1.2+) and at rest (AES-256)
- Least-privilege API responses: return only fields the caller needs
- Disable debug modes and verbose errors in production
- Constant-time comparison for auth routines
- Audit storage/DB permissions via IaC with policy checks
- Mask/redact sensitive log fields; use structured logging with allow-lists
- Opaque identifiers (UUIDs) to prevent enumeration

## D: Denial of Service (violates Availability)

**Ask:**
- Can an unauthenticated caller consume significant resources (CPU, memory,
  disk, network)?
- Is there a rate limit or concurrency cap on this endpoint?
- Does this process accept unbounded input (file uploads, request bodies, result
  sets)?
- Can one tenant exhaust shared resources and affect others?
- Does the process degrade gracefully when dependencies fail, or cascade?

**Patterns:**
- Volumetric floods overwhelming bandwidth or connection pools
- Algorithmic complexity attacks (ReDoS, billion-laughs XML bomb)
- Resource exhaustion (large uploads, unclosed connections, memory leaks)
- Lock contention blocking other transactions
- Dependency starvation causing cascading failure
- Economic DoS via auto-scaling abuse

**Mitigate:**
- Rate limiting and throttling at edge (API gateway, CDN, WAF)
- Max sizes on request bodies, uploads, query params, headers
- Circuit breakers and bulkheads to isolate failures
- Timeouts on regex evaluation, XML parsing, DB queries
- Per-tenant resource quotas in multi-tenant systems
- Auto-scaling with cost ceilings and anomaly alerts
- Immutable backups for ransomware recovery

## E: Elevation of Privilege (violates Authorization)

**Ask:**
- Are authz checks enforced on every operation, or only at the entry point?
- Can a user modify their own role or permissions via API manipulation?
- Are admin functions reachable without role verification?
- Does the system rely on client-side enforcement of access controls?
- Can an attacker escape a sandbox (container, VM, browser, chroot)?

**Patterns:**
- IDOR (changing resource ID to access another user's data)
- Privilege escalation via parameter tampering (`role`/`is_admin` in request or
  JWT)
- Path traversal (`../` to escape restricted directories)
- Container escape via kernel vuln or misconfigured security context
- SQL injection to modify own user record (`role = 'admin'`)
- OAuth scope escalation
- Over-privileged service accounts / Lambda execution roles

**Mitigate:**
- Resource-level authz on every request, not just at gateway
- Deny by default; allow-list approach for permissions
- Asymmetric JWT algorithms (RS256/ES256); reject `alg:none`
- Least-privilege IAM roles, Kubernetes RBAC, service accounts
- Non-root containers with read-only FS and dropped capabilities
- Path canonicalization; reject traversal sequences before file ops
- Regular access-control reviews and automated authz testing
