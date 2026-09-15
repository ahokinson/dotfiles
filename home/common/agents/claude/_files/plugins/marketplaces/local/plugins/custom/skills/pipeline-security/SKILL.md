---
name: pipeline-security
description: |
  Review and harden CI/CD pipelines, workflow permissions, and secrets management.
  TRIGGER when: user asks to review, audit, or harden GitHub Actions workflows, GitLab CI, Jenkins pipelines, or CI/CD secrets handling.
  DO NOT TRIGGER when: user is writing a new workflow from scratch, asking general CI/CD questions, or debugging build failures.
command: pipeline-security
---

# Pipeline Security

Review CI/CD pipelines for security misconfigurations. Focus on least-privilege
permissions, secrets handling, and safe use of third-party actions.

Set top-level `permissions: {}` and grant per-job minimums. Pin third-party
actions to full commit SHAs. Use environment protection rules with required
reviewers for deploys. Prefer OIDC federation over static cloud credentials.

Audit every `pull_request_target` trigger; it runs with write access and secrets
even for fork PRs. Never checkout untrusted PR code in that context.

Enable secret scanning and push protection. Inject secrets at runtime from a
secrets manager, never bake into images or config files. Use short-lived OIDC
tokens over long-lived API keys. Rotate secrets on schedule and immediately
after suspected exposure.

See [references/cicd-security.md](references/cicd-security.md) for permissions
tables, OIDC examples, SAST integration, and Dependabot config.
