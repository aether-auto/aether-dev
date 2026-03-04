---
name: build-backend
description: "Use this skill when acting as the Backend dev agent during /build. Implements API routes, business logic, services, and middleware to pass failing tests written by the testing agent."
---

# Build Backend Skill

Implement server-side logic to pass failing tests. Tests define the API contract — match it exactly.

## Responsibilities

- Read failing test files to understand expected API behavior
- Implement routes, controllers, services, and middleware
- Follow project architecture patterns from `CLAUDE.md`
- Handle validation, error responses, and edge cases
- Run tests after every significant change
- Report completion to team lead

## Input

- Failing test file paths and descriptions from testing agent
- Project `CLAUDE.md` for architecture, error handling patterns, auth approach
- Data models from `.agent-docs/data-models.md` or `spec.md`
- API specs from `.agent-docs/api-specs.md` if available

## Output

- Source files written to project backend directories
- Test run results confirming tests pass
- Completion report via SendMessage to team lead

## API Implementation Rules

| BAD | GOOD | Why |
|-----|------|-----|
| Return 200 for everything | Use correct HTTP status codes (201, 400, 404, 422) | REST semantics |
| Return raw error strings | Return structured error objects `{ error: { code, message, fields } }` | Consistent error format |
| No input validation | Validate at route entry, reject early | Security + UX |
| Catch-all error handler only | Specific error types with appropriate codes | Debuggability |
| Hardcoded config values | Use env vars via `.env` | Portability |

## Rules

**DO:**
- Read tests FIRST — they define the API contract
- Validate all inputs at the boundary (request params, body, headers)
- Return consistent response shapes across endpoints
- Use middleware for cross-cutting concerns (auth, logging, error handling)
- Follow the project's existing patterns for similar endpoints
- Handle both success and error paths for every endpoint

**DON'T:**
- Write endpoints without corresponding failing tests
- Expose internal errors or stack traces in responses
- Skip authentication/authorization checks if auth is in scope
- Introduce new dependencies without checking CLAUDE.md
- Mix business logic into route handlers — use service layer
- Hardcode database queries — use the project's ORM/query builder

## Coordination

- Receive test locations from testing agent
- Ask PM agent for clarification on business rules
- Coordinate with DB agent if schema changes are needed
- Report completion status to team lead
