# CWE-95: Code Injection

**Category**: Injection
**Severity**: Critical

User-controlled input passed to code evaluation functions allows arbitrary code
execution within the application's runtime.

## The Problem

Functions like `eval()`, `exec()`, `new Function()`, and dynamic `import()`
execute strings as code. When any part of the string is user-controlled, an
attacker can execute arbitrary code with the application's full privileges:
reading files, exfiltrating data, or pivoting to other systems.

Unlike command injection (CWE-78), code injection runs within the application's
runtime, giving access to in-memory secrets, database connections, and internal
APIs.

## Defense

**Never pass user input to code evaluation functions.** There is almost always a
safer alternative.

### Python

```python
# WRONG: eval on user input
result = eval(user_expression)

# WRONG: exec on user input
exec(user_code)

# WRONG: compile + exec is still code execution
code = compile(user_input, "<string>", "exec")
exec(code)

# RIGHT: for math expressions, use ast.literal_eval (only allows literals)
import ast
result = ast.literal_eval(user_input)  # raises ValueError on non-literals

# RIGHT: for configurable logic, use a data-driven approach
operations = {"add": operator.add, "sub": operator.sub}
if user_op not in operations:
    raise ValueError(f"unknown operation: {user_op}")
result = operations[user_op](a, b)
```

### TypeScript

```typescript
// WRONG: eval
const result = eval(userInput)

// WRONG: Function constructor is eval in disguise
const fn = new Function("x", userInput)

// WRONG: setTimeout/setInterval with string argument
setTimeout(userInput, 1000)

// RIGHT: use a parser or allowlisted operations
const ALLOWED_OPS = { add: (a, b) => a + b, sub: (a, b) => a - b } as const
const op = ALLOWED_OPS[userInput]
if (!op) throw new Error("unknown operation")
const result = op(a, b)
```

## Key Rules

- Never use `eval()`, `exec()`, `new Function()`, or `compile()` with user input
- `setTimeout` and `setInterval` accept string arguments that are eval'd; always
  pass functions instead
- For math expressions, use `ast.literal_eval` (Python) or a dedicated parser
  library
- For dynamic behavior, use allowlisted maps of operations, not code generation
- `ast.literal_eval` is safe for literals only; it rejects function calls,
  attribute access, and operators
