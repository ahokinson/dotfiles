# Secrets Management

## Environment Variables

- Load secrets from environment variables at startup. Never hardcode them.
- Fail loudly if a required secret is missing; do not fall back to empty strings
  or defaults.
- Never log secret values. Log that a secret was loaded, not what it contains.
- Use `.env` files for local development only. Never commit them.

## Secret Managers

- Use a secret manager for production: 1Password CLI (`op`), HashiCorp Vault, or
  cloud-native (AWS Secrets Manager, GCP Secret Manager).
- Applications read secrets from environment variables; the secret manager
  populates the environment, not the app.
- Establish a rotation schedule. 90 days for API keys, immediately on
  compromise.
- Audit access to secrets. Know who and what can read them.

## What Never to Commit

- `.env` and `.env.*` files
- Private keys (`*.key`, `*.pem`, `id_ed25519`, `id_rsa`)
- Service account credentials (`*-credentials.json`, `*-key.json`)
- TLS certificates with embedded private keys
- Tokens, API keys, passwords, connection strings

## .gitignore Patterns

Always include these patterns in `.gitignore`:

```gitignore
*.key
*.pem
*-credentials.json
*-key.json
.env
.env.*
```

## Pre-commit Detection

- Use `gitleaks` or `detect-secrets` as a pre-commit hook to catch secrets
  before they reach history.
- If a secret is committed: rotate it immediately. The secret is compromised the
  moment it enters git history.
- Use `git filter-repo` to remove secrets from history; `git filter-branch` is
  slow and error-prone.
- Never assume a force-push removes the secret. Anyone who fetched before the
  rewrite has a copy.
