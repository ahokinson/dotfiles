# Python Architecture

## Project Metadata

- `pyproject.toml` as single source of project metadata. No `setup.py` or
  `setup.cfg`.
- uv for dependency management, virtual envs, and running scripts.
- Pin dependency versions. Commit `uv.lock`.

## Module Design

- `__init__.py` for explicit public API surface. Re-export what consumers need.
- CLI entrypoints via `__main__.py` or dedicated `cli.py` module.
- Keep modules focused. One concept per module.

## Approved Frameworks

- `FastAPI` for HTTP APIs.
- `Pydantic` for validation and serialization (also a FastAPI dependency).
- `structlog` for structured logging.
- Ask the user before adding frameworks not listed here.

## Dependencies

- uv for all package operations. No pip, no poetry, no pipenv.

## Tooling

- ruff: linting and formatting (replaces black, isort, flake8, pylint).
- ty: type checking (replaces mypy, pyright).
