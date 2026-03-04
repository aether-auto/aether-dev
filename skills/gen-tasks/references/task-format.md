# Task File Format Reference

## File Location & Naming

| Item | Value |
|------|-------|
| Directory | `.tasks/` |
| File pattern | `TASK-NNN.md` (zero-padded 3-digit) |
| INDEX file | `.tasks/INDEX.md` |

## Task File Structure

Every task file: YAML frontmatter + Markdown body.

### Frontmatter

```yaml
---
id: TASK-001
title: "Short descriptive title"
status: pending
priority: must-have
depends_on: []
---
```

| Field | Type | Values | Notes |
|-------|------|--------|-------|
| `id` | string | `TASK-NNN` | Must match filename |
| `title` | string | 5-80 chars | Imperative verb phrase |
| `status` | enum | `pending`, `in-progress`, `done` | Initial: `pending` |
| `priority` | enum | `must-have`, `should-have`, `could-have` | From spec scope |
| `depends_on` | list | `[]` or `[TASK-NNN, ...]` | Task IDs this blocks on |

### Body Sections

| Section | Min Content | Format |
|---------|-------------|--------|
| Summary | 1 sentence | What this delivers and why |
| Description | 3 lines | Cover: **Data** (models, migrations), **API** (endpoints, auth), **UI** (pages, interactions). Reference spec sections. |
| Acceptance Criteria | 1 checkbox | `- [ ] Specific, testable criterion` |
| Dependencies | 1 line | `- None` or `- TASK-NNN: reason` |

## Examples

### GOOD Task
```markdown
---
id: TASK-002
title: "Implement user registration and login"
status: pending
priority: must-have
depends_on: []
---
# TASK-002: Implement user registration and login

## Summary
Build email/password registration and JWT login. Foundation for all protected routes.

## Description
- **Data:** User model: id (UUID), email (unique), password_hash, name, role (enum), timestamps. See spec §6.
- **API:** POST /api/auth/register → 201+JWT. POST /api/auth/login → 200+JWT. Auth middleware. See spec §7-8.
- **UI:** Registration form, login form, redirect to /dashboard on success. See spec §5 Flow 1.

## Acceptance Criteria
- [ ] POST /api/auth/register creates user and returns JWT
- [ ] POST /api/auth/login returns JWT for valid credentials, 401 for invalid
- [ ] Passwords hashed with bcrypt before storage
- [ ] Registration form validates matching passwords client-side
- [ ] Authenticated user redirected to /dashboard

## Dependencies
- None
```

### BAD Task — Problems: vague title, horizontal layer scope, untestable criteria
```markdown
---
id: TASK-099
title: "Backend stuff"
status: pending
priority: must-have
depends_on: []
---
## Summary
Do the backend.
## Description
Build all the API endpoints and database models.
## Acceptance Criteria
- [ ] API works
- [ ] Database is set up
```

## INDEX File Format

`.tasks/INDEX.md` has three sections: **Unblocked Tasks** (ready to build), **All Tasks** (full table), **Dependency Graph** (ASCII).

```markdown
# Task Index
## Unblocked Tasks
| ID | Title | Priority |
|----|-------|----------|

## All Tasks
| ID | Title | Status | Priority | Dependencies |
|----|-------|--------|----------|--------------|

## Dependency Graph
TASK-001 ──→ TASK-003
TASK-002 ──→ TASK-003
```

A task is **unblocked** when `depends_on` is empty or all dependencies have `status: done`.
