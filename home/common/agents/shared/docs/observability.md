# Observability

Logs exist to trace issues for debugging. Every log entry should help someone
figure out what happened and why.

## Structured Logging

Always use structured logging. No `fmt.Println` or `console.log` in committed
code. Use the structured logger at Debug level for development diagnostics. Use
the structured logger for the language:

- **Go**: `log/slog`
- **Python**: `structlog`
- **TypeScript**: `pino`

Every log entry should include enough context to trace it back to the operation
that produced it. Include request IDs, user identifiers, and operation names
where available.

## Log Levels

Use four levels consistently:

- **Debug**: Internal state useful during development. Disabled in production.
  Variable values, function entry/exit, cache hits/misses.
- **Info**: Normal operations worth recording. Service startup, request
  completion, job finished, configuration loaded.
- **Warning**: Something unexpected that the system handled. Retried request,
  fallback used, deprecated feature accessed, approaching a limit.
- **Error**: Something failed and needs attention. Unhandled exception, external
  service unavailable, data integrity violation. Errors should be actionable; if
  nobody needs to do anything, it's a warning.

Don't over-log. If every request logs ten Info lines, that's Debug. If warnings
fire constantly, they're noise. Calibrate levels so that each one means
something.

## Format

Prefer JSON format for machine parsing. Include timestamps in ISO 8601. Use
consistent field names across services (`msg`, `level`, `ts`, `err`,
`request_id`).
