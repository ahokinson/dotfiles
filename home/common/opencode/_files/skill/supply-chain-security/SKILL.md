---
name: supply-chain-security
description: Audit dependency management, package provenance, and artifact integrity
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: security
---

## What I do

- Audit dependencies for known vulnerabilities and typosquatting
- Enforce lockfiles, version pinning, and digest pinning
- Guide SBOM generation, image signing, and package provenance verification

## When to use me

Use this skill to audit dependencies, review lockfiles, check for vulnerable
packages, verify artifact provenance, or generate/verify SBOMs. Not for
installing/updating packages normally or debugging import errors.

## Key Controls

**Dependency Management:**
- Run SCA (Dependabot, Renovate, Snyk, Grype) against every project
- Pin dependencies to exact versions in lockfiles
- Pin container base images and Actions to digests
- Verify package provenance where supported (npm provenance, Sigstore)

**Registry Security:**
- Restrict package sources to trusted registries
- Configure scoped registries to prevent dependency confusion
- Audit transitive dependencies
- Review new dependencies before adoption (maintenance status, OpenSSF
  Scorecard)

**Artifact Integrity:**
- Sign container images with cosign
- Generate SBOMs with syft
- Verify signatures before deployment
