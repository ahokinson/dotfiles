# OWASP Top 10 (2021): Code-Level Detection

## A01: Broken Access Control
CWE: 200, 201, 352, 639, 862, 863, 425

**Detect:** Missing auth middleware on routes, IDOR (queries without ownership
filter), path traversal via user-controlled filenames, CORS reflecting Origin
with credentials, missing CSRF tokens on state-changing forms.

**Search:**
- Routes without auth decorators/middleware (`@app.route` without
  `@login_required`, Express handlers without auth in chain)
- DB queries using only `req.params.id` without filtering by authenticated user
- `filepath.Join`, `os.path.join`, `path.resolve` with user input
- `cors({ origin: true, credentials: true })`

**Fix:** Centralize authz in middleware. Filter queries by authenticated user.
Canonicalize paths and verify prefix. Allowlist CORS origins. Anti-CSRF tokens
for state-changing ops.

---

## A02: Cryptographic Failures
CWE: 259, 327, 328, 330, 331, 798

**Detect:** Password hashing with MD5/SHA-family, hardcoded secrets/keys,
`math/rand`/`random`/`Math.random()` for security values, ECB mode, missing
IV/nonce.

**Search:**
- `hashlib.sha256`, `hashlib.md5`, `MessageDigest.getInstance("SHA-256")` near
  passwords
- String literals matching API key patterns (`sk-`, `AKIA`, connection strings)
- `math/rand`, `import random`, `Math.random()`
- `AES.MODE_ECB`, `"ECB"`

**Fix:** bcrypt/scrypt/Argon2id for passwords. Secrets from env/secret manager.
Platform CSPRNG only. AES-256-GCM or ChaCha20-Poly1305.

---

## A03: Injection
CWE: 20, 74, 77, 78, 79, 89, 90, 917, 1336

**Detect:** SQL via string concat/formatting, OS command via shell=True or
exec(), SSTI via user-controlled template source, XSS via raw HTML rendering,
NoSQL via unvalidated objects in queries.

**Search:**
- `f"SELECT`, `"SELECT * FROM " +`, `db.Query("..."+`, `fmt.Sprintf` in SQL
- `shell=True`, `os.system(`, `exec(` with user input
- `Template(request.`, `Template(user_`
- `dangerouslySetInnerHTML`, `v-html`, `.innerHTML =`
- MongoDB `find({` with unsanitized `req.body`

```python
# VULNERABLE: string formatting in SQL
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
```

**Fix:** Parameterized queries. `subprocess.run([...], shell=False)`. Template
context vars, not template source. Framework auto-escaping. Explicit type
validation for NoSQL.

---

## A04: Insecure Design
CWE: 209, 256, 501, 522

**Detect:** Missing rate limiting on auth endpoints, account enumeration via
differing responses, client-trusted business logic (prices, quantities),
skippable workflow steps.

**Fix:** Rate limit auth. Identical responses for valid/invalid accounts.
Server-side revalidation of all business logic. Server-side workflow state
tracking.

---

## A05: Security Misconfiguration
CWE: 2, 11, 13, 15, 16, 388

**Detect:** Debug mode in production, stack traces in error responses, missing
security headers, default credentials in config.

**Search:**
- `debug=True`, `DEBUG = True`, `NODE_ENV` not set to production
- `err.stack` in response body
- Missing `Strict-Transport-Security`, `Content-Security-Policy`,
  `X-Content-Type-Options`
- `password: admin`, `password: password` in config files

**Fix:** Debug off in prod. Generic client errors, detailed server logs.
Security headers via middleware. No default credentials.

---

## A06: Vulnerable and Outdated Components
CWE: 1035, 1104

**Detect:** Pinned versions with known CVEs in lockfiles, unmaintained
dependencies, vendored libraries not receiving updates.

**Fix:** Automated dependency scanning (Dependabot/Snyk/Renovate). Pin and
regularly update. Remove unused deps.

---

## A07: Identification and Authentication Failures
CWE: 255, 259, 287, 288, 384, 798

**Detect:** Predictable session tokens, JWT without algorithm enforcement,
missing brute-force protection on login.

**Search:**
- `random.randint`, `Math.random()`, `rand.Int` for session/token generation
- `jwt.verify(token, secret)` without `algorithms` option
- Login endpoints without rate limiting or lockout

```javascript
// VULNERABLE: no algorithm enforcement
const payload = jwt.verify(token, secret);
// FIX: jwt.verify(token, secret, { algorithms: ["RS256"] })
```

**Fix:** CSPRNG with >= 128-bit tokens. Explicit JWT algorithm. Account
lockout/progressive delays.

---

## A08: Software and Data Integrity Failures
CWE: 345, 353, 502, 565, 829

**Detect:** Native deserialization of untrusted data, unsigned
updates/downloads, unprotected CI/CD pipelines.

**Search:**
- `pickle.loads`, `ObjectInputStream`, `readObject()`, `node-serialize`,
  `unserialize`
- `XMLDecoder`, `XStream`, `yaml.load(` without SafeLoader
- Remote code/config downloads without signature verification

**Fix:** JSON/protobuf for untrusted data. `ObjectInputFilter` if Java native
deser unavoidable. Signed artifacts. Branch protection on CI/CD.

---

## A09: Security Logging and Monitoring Failures
CWE: 117, 223, 532, 778

**Detect:** Passwords/tokens/PII in logs, log injection via unsanitized user
input, missing audit trail for auth events.

**Search:**
- `log.*password`, `logger.info(.*token`, `log.info(".*card`
- `logger.info(f".*{request.` without sanitization

**Fix:** Never log secrets/PII. Sanitize log input (strip newlines/control
chars). Log auth events with timestamp, user, IP, action. Structured logging
(JSON).

---

## A10: Server-Side Request Forgery (SSRF)
CWE: 918

**Detect:** User-supplied URLs in server-side HTTP requests, DNS rebinding
bypass potential.

**Search:**
- `requests.get(request.`, `fetch(req.query.`, `http.Get(r.URL.Query`
- Any user input used as URL/hostname in server-side clients

```python
# VULNERABLE: user-controlled URL
response = requests.get(request.args.get("url"))
```

**Fix:** Allowlist domains/prefixes. Block private IP ranges after DNS
resolution. Resolve DNS then pass IP to client (prevents rebinding). Disable or
revalidate redirects.
