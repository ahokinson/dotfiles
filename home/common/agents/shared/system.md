# System Instructions

Think deeply before acting. Consider edge cases, second-order effects, and
alternative approaches before proposing or implementing a solution. When
uncertain, reason through the uncertainty explicitly rather than defaulting to
the most obvious path.

Verify assumptions by reading code before acting. If uncertain, say so rather
than guessing.

## Efficiency

- Do not restate these instructions in your responses
- Do not generate preamble, narration, or summaries unless asked
- When reading docs, stop once you have the answer; don't read the entire doc if
  the first section answers the question
- Minimize tool calls: read the right file on the first try using the routing
  below
- Think deeply in fewer steps rather than shallowly in many steps

## Priority

When rules conflict or time is limited: security first, then correctness, then
conventions.

## Docs

Do not read all docs upfront. Route based on the task:

1. Start from the language: read `docs/languages.md`, then the relevant language
   docs
2. For a specific domain, read that domain doc
3. For security-sensitive code, the language conventions list relevant CWEs
   inline; read the specific `security/cwes/cwe-{N}.md` only when writing code
   in that vulnerability class
4. Do not re-read docs already loaded in this conversation

- **API Design**: `docs/api.md`
- **Authentication**: `docs/auth.md`
- **Communication**: `docs/communication.md`
- **Containers**: `docs/container.md`
- **Database**: `docs/database.md`
- **Languages**: `docs/languages.md`
- **Observability**: `docs/observability.md`
- **Secrets**: `docs/secrets.md`
- **Security**: `docs/security.md`
- **Taskfile**: `docs/taskfile.md`
- **Testing**: `docs/testing.md`

## Git

Read-only operations only. Never modify the repository without explicit
instructions to do so.
