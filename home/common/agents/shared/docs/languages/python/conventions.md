# Python Conventions

## Formatting & Naming

- ruff for linting and formatting. No black, no isort, no flake8.
- ty for type checking. No mypy, no pyright.
- snake_case for functions, variables, modules. PascalCase for classes.
- UPPER_SNAKE_CASE for constants.

## Type Hints

- Type hints on all function signatures and class attributes. No exceptions.
- Use `str | None` union syntax, not `Optional[str]`.
- Use `collections.abc` types (`Sequence`, `Mapping`) over `list`, `dict` in
  signatures.
- `dataclasses` for value objects. `Pydantic` for validation/serialization
  boundaries.

## Imports

- Group in order: stdlib, blank line, third-party, blank line, local.
- Absolute imports only. No relative imports.
- Never use wildcard imports (`from x import *`).

## Error Handling

- Specific exception types. Never bare `except:` or `except Exception:` without
  re-raise.
- Use custom exception classes for domain errors.

## General

- No `*args`/`**kwargs` unless wrapping or decorating.
- f-strings over `.format()` or `%`.
- `pathlib.Path` over `os.path`.

## Security

- No `shell=True` with user input in `subprocess` calls (CWE-78).
- Parameterized queries only: no f-strings or `%` formatting in SQL (CWE-89).
- No `eval()` or `exec()` with user-controlled input (CWE-95).
- No user-controlled format strings (`str.format(**user_dict)`) or template
  sources (CWE-134, CWE-1336).
- No `pickle.loads` or `yaml.load` on untrusted data; use `yaml.safe_load`
  (CWE-502).
- Use `defusedxml` for all XML parsing of untrusted data (CWE-611).
