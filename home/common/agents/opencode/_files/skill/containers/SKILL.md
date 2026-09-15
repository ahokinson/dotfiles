---
name: containers
description: Docker, Compose, and container image conventions
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: containers
---

## What I do

- Enforce Dockerfile best practices (multi-stage, non-root, digest pinning)
- Prescribe Compose conventions (compose.yaml, healthchecks, named volumes)
- Specify registry and image tagging standards

## When to use me

Use this skill when writing Dockerfiles, Compose configs, or working with
container images. Rancher Desktop, not Docker Desktop.

## Conventions

Read `docs/container.md` for the full specification. Key points: multi-stage
builds always, pin images by SHA digest, non-root runtime user, `compose.yaml`
(not docker-compose.yml), healthchecks on every service, GHCR as primary
registry.
