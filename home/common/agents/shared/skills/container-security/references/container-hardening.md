# Container Hardening Reference

## Dockerfile Best Practices

### Multi-Stage Build (Go Example)

```dockerfile
# Build stage
FROM golang:1.22-bookworm AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app ./cmd/server

# Runtime stage
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /app /app
USER nonroot:nonroot
ENTRYPOINT ["/app"]
```

Build stage holds compilers, test frameworks, linters. Runtime stage holds only
the artifact and CA certs. Final image drops from hundreds of MB to single
digits. Build cache layers are not shipped to production.

For Node.js, Python, Java, or other runtimes, the same pattern applies: install
dependencies and build in the first stage, copy only production artifacts to a
minimal runtime stage.

### Non-Root User Setup

For distroless images, use the built-in `nonroot` user (UID 65534):

```dockerfile
FROM gcr.io/distroless/static-debian12:nonroot
USER nonroot:nonroot
```

For other base images, create a dedicated user:

```dockerfile
FROM node:22-slim
RUN groupadd --gid 10001 app && \
    useradd --uid 10001 --gid app --shell /bin/false app
WORKDIR /home/app
COPY --chown=app:app . .
USER app:app
CMD ["node", "server.js"]
```

### Base Image Selection

| Base Image | Size | Shell | Package Mgr | Use Case |
|---|---|---|---|---|
| `scratch` | 0 MB | No | No | Statically linked Go/Rust binaries |
| `gcr.io/distroless/static` | ~2 MB | No | No | Static binaries needing CA certs, tzdata |
| `gcr.io/distroless/base` | ~20 MB | No | No | Dynamically linked binaries (glibc) |
| `alpine` | ~7 MB | Yes | apk | Apps needing a shell or C libraries (musl) |
| `debian-slim` | ~80 MB | Yes | apt | Apps requiring glibc and broad packages |

Avoid full-distribution images (`ubuntu`, `centos`) in production.

### Key Rules

- Use `COPY` not `ADD` (prevents unintended archive extraction and remote URL
  fetch).
- Pin base images to digest: `FROM node:22-slim@sha256:a1b2c3d4...`; update via
  Dependabot/Renovate.
- Do not install `curl`, `wget`, `netcat`, `ssh`, or debug tools in production
  images. Use `kubectl debug` for ephemeral debugging.
- Scan images with Trivy in CI; block critical/high findings. Scan continuously
  in the registry for newly disclosed CVEs.
- Sign images with cosign. Generate SBOMs with syft. Verify signatures before
  deployment.
- Never store secrets in images (`ENV`, `COPY .env`). Inject at runtime from a
  secrets manager.

## Kubernetes Security Context

### Complete Pod Spec

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 10001
    runAsGroup: 10001
    fsGroup: 10001
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: app
      image: registry.example.com/app@sha256:abc123...
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
      resources:
        requests:
          memory: "128Mi"
          cpu: "100m"
        limits:
          memory: "256Mi"
          cpu: "500m"
      volumeMounts:
        - name: tmp
          mountPath: /tmp
  volumes:
    - name: tmp
      emptyDir:
        sizeLimit: 64Mi
```

Use `emptyDir` volumes with `sizeLimit` for any writable paths the app needs
(tmp, caches, PID files).

### Pod Security Standards

| Profile | Purpose | Key Restrictions |
|---|---|---|
| **Privileged** | Unrestricted. System-critical infra only. | None |
| **Baseline** | Prevents known privilege escalations. | No `hostNetwork`, `hostPID`, no privileged containers |
| **Restricted** | Hardened best practices. | Non-root, drop all caps, read-only FS, seccomp required |

Enforce at namespace level:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

Apply `restricted` to all production namespaces. Use `baseline` for system
namespaces. Never apply `privileged` to application namespaces.

### Capability Reference

| Capability | Purpose | Typical Requirement |
|---|---|---|
| `NET_BIND_SERVICE` | Bind to ports below 1024 | Web servers on port 80/443 |
| `NET_RAW` | Raw sockets | Network diagnostic tools only |
| `SYS_PTRACE` | Process tracing | Debugging sidecars only |
| `CHOWN`, `DAC_OVERRIDE`, `FOWNER` | File ownership changes | Almost never in production |

Drop ALL capabilities by default. Add back only what is required. If an
application claims to need `SYS_ADMIN`, investigate whether a more specific
capability suffices.

For high-security workloads, generate custom seccomp profiles using
`inspektor-gadget` or `oci-seccomp-bpf-hook` by recording syscalls during normal
operation, then enforcing only those.

### Runtime Checklist

- `runAsNonRoot: true` at pod level
- `readOnlyRootFilesystem: true` on every container
- `allowPrivilegeEscalation: false` on every container
- `capabilities.drop: [ALL]` on every container
- `seccompProfile.type: RuntimeDefault` at pod level
- Resource requests and limits set on every container
- `automountServiceAccountToken: false` unless pod calls the Kubernetes API
