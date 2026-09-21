---
name: supply-chain-security
description: |
  Audit dependency management, package provenance, and artifact integrity.
  TRIGGER when: user asks to audit dependencies, review lockfiles, check for vulnerable packages, verify artifact provenance, or generate/verify SBOMs.
  DO NOT TRIGGER when: user is installing/updating packages normally, asking how to use a dependency, or debugging import errors.
command: supply-chain-security
---
