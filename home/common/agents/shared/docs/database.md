# Database Conventions

## Database Selection

Pick the first that fits:

1. Ephemeral state, caching, queues? **Redis**.
2. Simple relational data? **Turso** (libSQL).
3. Complex relational data at scale? **Postgres**.

- Never MongoDB, DynamoDB, Firestore, or any document/NoSQL database. Relational
  schemas enforce data integrity at the storage layer; document stores defer it
  to application code, which always drifts.
- No MySQL. No raw SQLite; use Turso (libSQL) instead.

## Connectors

- Use the official SDK/connector for each language. No ORMs, no query builders.
- **Go**: `github.com/tursodatabase/libsql-client-go`,
  `github.com/redis/go-redis/v9`, `github.com/jackc/pgx/v5`
- **Python**: `libsql-client`, `redis-py`, `psycopg`
- **TypeScript**: `@libsql/client`, `ioredis`, `postgres` (postgresjs)

## Principles

- Raw SQL for queries. No ORMs, no query builders, no abstraction layers. ORMs
  hide the query; when performance matters, you need to see and control the SQL.
- Migrations as numbered SQL files. No migration frameworks. Numbered SQL files
  are portable, auditable, and require no runtime dependency.
- Connection pooling at the application level.
- Always parameterize queries. Never interpolate values into SQL strings.
