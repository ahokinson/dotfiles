# CWE-79: Cross-Site Scripting (XSS)

**Category**: Cross-Site Scripting
**Severity**: High

User-controlled input rendered in HTML without encoding allows script execution
in other users' browsers.

## The Problem

When user input is inserted into HTML pages without proper encoding, attackers
can inject JavaScript that runs in the context of other users' sessions,
stealing cookies, credentials, or performing actions on their behalf.

Three variants: Reflected (input from request), Stored (input from database),
DOM-based (client-side manipulation).

## Defense

**Encode output for the context it appears in.** HTML context needs HTML
encoding. JavaScript context needs JS encoding. URL context needs URL encoding.

### Go

```go
// WRONG: raw string in template
fmt.Fprintf(w, "<p>%s</p>", userInput)

// RIGHT: use html/template (auto-escapes)
tmpl.Execute(w, data)
```

### Python

```python
# WRONG: raw string in response
return f"<p>{user_input}</p>"

# RIGHT: use a templating engine that auto-escapes (Jinja2 default)
return render_template("page.html", data=user_input)
```

### TypeScript (React)

```tsx
// WRONG: dangerouslySetInnerHTML with user input
<div dangerouslySetInnerHTML={{__html: userInput}} />

// RIGHT: JSX auto-escapes by default
<div>{userInput}</div>
```

## Key Rules

- Use templating engines with auto-escaping enabled (this is the default in most
  modern frameworks)
- Never use `dangerouslySetInnerHTML`, `v-html`, or `{!! !!}` with user input
- Set `Content-Security-Policy` headers to limit script sources
- For rich text, use a sanitization library (DOMPurify) with an allowlist of
  tags
- `HttpOnly` and `Secure` flags on session cookies limit the impact of XSS
