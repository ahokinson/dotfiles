---
name: container-security
description: Audit and harden Dockerfiles, container images, and Kubernetes security contexts
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: security
---

## What I do

- Audit Dockerfiles for insecure patterns (mutable tags, root user, secrets in
  layers)
- Review container runtime security contexts (capabilities, seccomp, read-only
  filesystem)
- Enforce multi-stage builds, minimal base images, and digest pinning

## When to use me

Use this skill to review, audit, or harden Dockerfiles, docker-compose configs,
container images, or Kubernetes pod/deployment security contexts. Not for
writing new Dockerfiles from scratch or debugging runtime errors.

## Hardening Checklist

**Dockerfile:**
- Multi-stage builds: build stage has compilers/tools, runtime stage has only
  the artifact and CA certs
- Base on minimal images: distroless, Alpine, or scratch
- Run as non-root with a dedicated UID/GID
- Use `COPY` not `ADD`
- Pin base images to digest
- No secrets in layers or build args

**Runtime:**
- Read-only root filesystem
- Drop ALL capabilities, add back only what is needed
- `seccompProfile: RuntimeDefault`
- `allowPrivilegeEscalation: false`

**CI:**
- Scan images with Trivy; block critical/high findings
