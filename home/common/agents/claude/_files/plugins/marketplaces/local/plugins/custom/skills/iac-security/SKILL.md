---
name: iac-security
description: |
  Review Terraform, Kubernetes, and infrastructure-as-code for security misconfigurations.
  TRIGGER when: user asks to review, audit, or harden Terraform, OpenTofu, Helm charts, CloudFormation, or Kubernetes YAML for security issues.
  DO NOT TRIGGER when: user is writing new IaC from scratch, asking how to use Terraform/K8s, or debugging apply/plan errors.
command: iac-security
---

# Infrastructure-as-Code Security

Review IaC templates for security misconfigurations, overly permissive access,
and missing encryption.

Encrypt Terraform state at rest (SSE-KMS). Lock with DynamoDB. Restrict access
to CI and break-glass roles. Pin provider and module versions exactly. Use
Dependabot/Renovate for updates. Mark sensitive variables and outputs with
`sensitive = true`. Run tfsec or checkov in CI on every PR. Enforce
policy-as-code with OPA/conftest.

For Kubernetes: enforce Pod Security Standards (Restricted), default-deny
NetworkPolicies, namespace-scoped RBAC Roles over ClusterRoles,
`automountServiceAccountToken: false` unless needed. Schedule drift detection
(daily `terraform plan` in read-only mode). Treat drift as a security event.

See [references/iac-security.md](references/iac-security.md) for Terraform state
protection, OPA policies, RBAC examples, network policies, and common
misconfigurations.
