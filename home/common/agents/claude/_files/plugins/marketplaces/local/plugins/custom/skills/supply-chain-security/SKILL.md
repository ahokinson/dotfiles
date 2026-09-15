---
name: supply-chain-security
description: |
  Audit dependency management, package provenance, and artifact integrity.
  TRIGGER when: user asks to audit dependencies, review lockfiles, check for vulnerable packages, verify artifact provenance, or generate/verify SBOMs.
  DO NOT TRIGGER when: user is installing/updating packages normally, asking how to use a dependency, or debugging import errors.
command: supply-chain-security
---

# Supply Chain Security

Review dependency management and artifact integrity for supply chain risks.

Run SCA (Dependabot, Renovate, Snyk, Grype) against every project. Pin
dependencies to exact versions in lock files. Pin container base images and
Actions to digests. Verify package provenance where supported (npm provenance,
Sigstore).

Restrict package sources to trusted registries; configure scoped registries to
prevent dependency confusion. Audit transitive dependencies. Review new
dependencies before adoption (maintenance status, OpenSSF Scorecard).

Sign container images with cosign. Generate SBOMs with syft. Verify signatures
before deployment.
