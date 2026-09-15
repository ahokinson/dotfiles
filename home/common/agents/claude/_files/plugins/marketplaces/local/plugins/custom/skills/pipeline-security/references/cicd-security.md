# CI/CD Security Reference

## GitHub Actions Permissions

Set `permissions: {}` at workflow level. Grant per-job minimums.

| Permission | Read | Write | Use Case |
|---|---|---|---|
| `contents` | Checkout code | Push commits, create releases |
| `packages` | Pull packages | Push container images to GHCR |
| `security-events` | - | Upload SARIF results to Code Scanning |
| `pull-requests` | Read PR metadata | Post comments, approve PRs |
| `id-token` | - | Request OIDC JWT for cloud auth |
| `actions` | List workflow runs | Cancel/re-run workflows |
| `issues` | Read issues | Create/update issues |

Never grant `write-all` or leave permissions unspecified in public repositories.

## Environment Protection Rules

Configure environments for deployment jobs (Settings > Environments):

- **Required reviewers**: At least one approval before the job runs.
- **Wait timer**: Delay (e.g., 15 min) to allow cancellation.
- **Branch restrictions**: Only allow deploys from `main` or release branches.
- Reference in workflow: `environment: { name: production, url:
  https://app.example.com }`

## OIDC Federation (AWS)

Replace long-lived credentials with short-lived OIDC tokens:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502  # v4.0.2
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-deploy
          aws-region: us-east-1
```

Same pattern applies to GCP (`google-github-actions/auth`) and Azure
(`azure/login`). No static credentials to rotate. Tokens scoped to
repo/branch/environment. Lifetime is minutes, not months.

## pull_request_target Danger

`pull_request_target` runs with base branch context, write permissions, and
secrets access, even for fork PRs.

- **Never** checkout PR code (`github.event.pull_request.head.sha`) in this
  trigger.
- Use it only for metadata operations (labeling, commenting).
- For untrusted code: use `pull_request` trigger (no secrets/write), then a
  `workflow_run` trigger for post-processing.
- If checkout is unavoidable, ensure no user-controlled code executes (no `npm
  install`, no `make`, no script execution).

## Secrets Management

### Rotation Schedule

| Secret Type | Rotation Frequency | Method |
|---|---|---|
| API keys | 90 days or on suspected compromise | Automated via secrets manager |
| Database passwords | 90 days | Dual-credential automated rotation |
| TLS certificates | Before expiry | ACME / cert-manager |
| SSH keys | Annually or on personnel change | Automated provisioning |
| OIDC tokens | Per-use (minutes) | No rotation needed |
| Signing keys | Annually | Key ceremony with backup |

### Key Practices

- Inject secrets at runtime, never at build time or in image layers.
- Use short-lived OIDC tokens over static API keys.
- Enable GitHub secret scanning and push protection.
- Supplement with `gitleaks` or `detect-secrets` pre-commit hooks.
- Rotate immediately after any suspected exposure.
- Use External Secrets Operator or Vault for Kubernetes secret injection from
  external stores.

## SAST Integration (Semgrep)

```yaml
jobs:
  sast:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@v4

      - name: Run Semgrep
        uses: semgrep/semgrep-action@v1
        with:
          config: >-
            p/default
            p/owasp-top-ten
            p/javascript
          generateSarif: true

      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: semgrep.sarif
```

Other SAST options: CodeQL (deep dataflow, GitHub-native), SonarQube (broad
language support), Bandit (Python), gosec (Go). Run DAST (ZAP) against preview
environments, never production.

## Dependency Updates (Dependabot)

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    groups:
      dev-dependencies:
        dependency-type: "development"
        update-types: ["minor", "patch"]

  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

Pin all actions to full SHA hashes. Use Dependabot or Renovate to automate SHA
pin updates. For Renovate, use `helpers:pinGitHubActionDigests` preset.

## Pipeline Architecture

Separate build, test, scan, and deploy into distinct jobs with independent
permissions. No single job should have both the ability to modify source code
and deploy to production.

```yaml
jobs:
  build:
    permissions: { contents: read }

  test:
    needs: build
    permissions: { contents: read }

  scan:
    needs: build
    permissions: { contents: read, security-events: write }

  deploy:
    needs: [test, scan]
    permissions: { id-token: write }
    environment: production
```

Verify checksums when passing artifacts between jobs. Use
`actions/upload-artifact` with `retention-days: 1` and include SHA256 checksums
alongside artifacts.
