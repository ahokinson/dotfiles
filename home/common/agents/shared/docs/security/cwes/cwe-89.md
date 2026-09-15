# CWE-89: SQL Injection

**Category**: Injection
**Severity**: Critical

User-controlled input concatenated into SQL queries allows arbitrary database
operations.

## The Problem

String concatenation or interpolation in SQL queries lets attackers modify query
logic, extract data, modify records, or escalate privileges.

## Defense

**Always use parameterized queries.** Every language and database driver
supports them. There is no valid reason to concatenate user input into SQL.

### Go

```go
// WRONG: string concatenation
db.Query("SELECT * FROM users WHERE id = " + id)

// RIGHT: parameterized query
db.Query("SELECT * FROM users WHERE id = ?", id)
```

### Python

```python
# WRONG: f-string interpolation
cursor.execute(f"SELECT * FROM users WHERE id = {id}")

# RIGHT: parameterized query
cursor.execute("SELECT * FROM users WHERE id = ?", (id,))
```

### TypeScript

```typescript
// WRONG: template literal
db.query(`SELECT * FROM users WHERE id = ${id}`)

// RIGHT: parameterized query
db.query("SELECT * FROM users WHERE id = ?", [id])
```

## Key Rules

- Use parameterized queries for every query that includes external data
- Never concatenate, interpolate, or format user input into SQL strings
- ORMs are generally safe but watch for raw query escape hatches
- For dynamic column or table names (which can't be parameterized), use an
  allowlist
- Apply least-privilege database roles; the application user should not have DDL
  permissions
