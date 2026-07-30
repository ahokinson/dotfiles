---
name: iac-security
description: Review Terraform, Kubernetes, and infrastructure-as-code for security misconfigurations
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: security
---

## What I do

- Review IaC templates for security misconfigurations and overly permissive
  access
- Enforce encryption at rest and in transit, secure state backends,
  least-privilege IAM
- Guide policy-as-code with OPA/conftest and drift detection

## When to use me

Use this skill to review, audit, or harden Terraform, OpenTofu, Helm charts,
CloudFormation, or Kubernetes YAML for security issues. Not for writing new IaC
from scratch or debugging apply/plan errors.

## Key Controls

**Terraform:**
- Encrypt state at rest (SSE-KMS). Lock with DynamoDB
- Restrict access to CI and break-glass roles
- Pin provider and module versions exactly
- Mark sensitive variables and outputs with `sensitive = true`
- Run tfsec or checkov in CI on every PR
- Enforce policy-as-code with OPA/conftest

**Kubernetes:**
- Enforce Pod Security Standards (Restricted)
- Default-deny NetworkPolicies
- Namespace-scoped RBAC Roles over ClusterRoles
- `automountServiceAccountToken: false` unless needed

**Operations:**
- Schedule drift detection (daily `terraform plan` in read-only mode)
- Treat drift as a security event
