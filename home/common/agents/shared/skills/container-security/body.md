# Container Hardening

Review Dockerfiles and container runtime configurations for security issues.

Use multi-stage builds: build stage has compilers/tools, runtime stage has only
the artifact and CA certs. Base on minimal images: distroless, Alpine, or
scratch. Run as non-root with a dedicated UID/GID. Use `COPY` not `ADD`. Pin
base images to digest.

Scan images with Trivy in CI; block critical/high findings. At runtime:
read-only root filesystem, drop ALL capabilities, add back only what is needed,
`seccompProfile: RuntimeDefault`, `allowPrivilegeEscalation: false`.

See [references/container-hardening.md](references/container-hardening.md) for
Dockerfile examples, pod security contexts, base image selection, and capability
reference.
