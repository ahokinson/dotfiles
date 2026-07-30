---
name: pipeline-security
description: Review and harden CI/CD pipelines, workflow permissions, and secrets management
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: security
---

## What I do

- Audit CI/CD pipelines for permission escalation and secrets exposure
- Enforce least-privilege workflow permissions and action pinning
- Guide OIDC federation, secret rotation, and environment protection rules

## When to use me

Use this skill to review, audit, or harden GitHub Actions workflows, GitLab CI,
Jenkins pipelines, or CI/CD secrets handling. Not for writing new workflows from
scratch or debugging build failures.

## Key Controls

**Permissions:**
- Set top-level `permissions: {}` and grant per-job minimums
- Pin third-party actions to full commit SHAs
- Use environment protection rules with required reviewers for deploys

**Secrets:**
- Enable secret scanning and push protection
- Inject secrets at runtime from a secrets manager, never bake into images or
  config files
- Use short-lived OIDC tokens over long-lived API keys
- Rotate secrets on schedule and immediately after suspected exposure

**Dangerous Patterns:**
- Audit every `pull_request_target` trigger; it runs with write access and
  secrets even for fork PRs
- Never checkout untrusted PR code in that context
- Prefer OIDC federation over static cloud credentials
