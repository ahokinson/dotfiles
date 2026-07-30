# API Design Conventions

## Style

- REST. No GraphQL, no gRPC unless interfacing with a service that requires it.
- JSON request and response bodies. No XML.
- Plural nouns for resource paths: `/users`, `/orders`.
- Nest sub-resources: `/users/{id}/orders`.

## HTTP Methods

- `GET` for reads. Never mutate state.
- `POST` for creation. Return `201` with the created resource.
- `PUT` for full replacement. `PATCH` for partial updates.
- `DELETE` returns `204` with no body.

## Response Shape

- Consistent envelope for errors:
  ```json
  {"error": {"code": "NOT_FOUND", "message": "User not found"}}
  ```
- Success responses return the resource directly, not wrapped.
- Paginate lists. Use cursor-based pagination, not offset.

## Status Codes

- `200` success. `201` created. `204` no content.
- `400` bad request. `401` unauthenticated. `403` unauthorized. `404` not found.
- `422` validation failure. `429` rate limited.
- `500` only for unexpected errors. Never expose internals.

## Versioning

- URL path prefix: `/v1/`, `/v2/`.
- No header-based versioning.

## Auth

- Bearer tokens in `Authorization` header.
- API keys for service-to-service. Never in query strings.

## General

- Validate all input at the boundary. Trust nothing from the client.
- Idempotency keys for non-idempotent operations.
- Rate limiting on all public endpoints.
