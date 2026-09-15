# Container Conventions

## Runtime

- Rancher Desktop. Not Docker Desktop.
- Docker Compose for local service dependencies and development environments.
- No Kubernetes. No k8s manifests, Helm charts, or orchestration tooling. These
  are single-host applications; orchestration adds complexity without benefit.

## Dockerfiles

- Multi-stage builds always. Separate build and runtime stages.
- Use official language base images when containerizing a language runtime:
  `golang`, `python`, `oven/bun`.
- Runtime stage: `alpine` or `distroless`.
- Pin base image versions with SHA digests, not just tags.
- One process per container.
- Non-root user in runtime stage. Never run as root.
- `.dockerignore` in every project with a Dockerfile.
- Copy dependency manifests and install before copying source (layer caching).
- No `latest` tag. Ever.

## Compose

- `compose.yaml` (not `docker-compose.yml`; the old filename is deprecated).
- Named volumes for persistent data. Never bind-mount data directories in
  production.
- Healthchecks on every service.
- Explicit networks only when services need isolation from each other.
- Environment variables via `env_file`, not inline `environment` blocks.

## Registries

- GitHub Container Registry (`ghcr.io`) as primary.
- Docker Hub (`docker.io`) as fallback for public base images.
- No other registries without explicit approval.

## Images

- Tag images with git SHA and semver. Push both.
- Scan images for vulnerabilities before pushing.
- Keep images small. Remove build tools, caches, and temp files in the build
  stage.
