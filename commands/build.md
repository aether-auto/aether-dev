---
description: "Pick the next viable ticket and build it using TDD with an agent team (PM, testing, dev, QA, refactoring)"
argument-hint: "[optional ticket ID to build a specific ticket]"
---

# /build — Test-Driven Ticket Implementation

Build the next viable ticket using agent teams and TDD.

**Ticket override:** $ARGUMENTS

## <HARD-GATE>

1. **MUST have `.tasks/INDEX.md`** — run `/gen-tasks` first if missing.
2. **MUST have project docs** (`spec.md`, `CLAUDE.md`) — run `/setup` first if missing.
3. **MUST follow TDD.** Tests before implementation. No code without a failing test.
4. **MUST NOT skip phases.** Planning → Red → Green → QA → Refactor → Commit.
5. **MUST end with a commit.** All tests passing, ticket marked completed.

</HARD-GATE>

## Phase 0: Ticket Selection

1. Read `.tasks/INDEX.md`, parse ticket table.
2. If `$ARGUMENTS` specifies a ticket, select it (error if blocked/completed).
3. Otherwise: first ticket not `completed`/`in-progress` with all deps `completed`.
4. No viable ticket → inform user and exit.
5. Mark ticket `in-progress`, read full `.tasks/{ticket-id}.md`.

## Phase 1: Planning (PM + Testing)

### 1a. PM Agent (`aether-dev:build-pm`)
Analyze requirements, define concrete goals/behaviors, determine scope (frontend/backend/db), create task items for testing.

### 1b. Testing Agent (`aether-dev:build-testing`)
Write failing tests for each PM goal. Confirm all new tests FAIL (red), existing tests pass.

**Transition:** PM goals defined, tests written, new tests red, existing tests green.

## Phase 2: Implementation (Dev Agents — Parallel)

Spawn based on scope:

| Scope | Agent | Skill |
|-------|-------|-------|
| UI, pages, styles, client state | Frontend | `aether-dev:build-frontend` |
| API, business logic, middleware | Backend | `aether-dev:build-backend` |
| Schema, migrations, seeds, queries | DB | `aether-dev:build-db` |

**Rules:** Read failing tests first (tests = contract). Write minimum code to pass. Run tests after every change. Follow `CLAUDE.md` conventions.

**Transition:** All tests green, no hook errors, all agents complete.

## Phase 3: QA (Optional)

Skip for pure config/docs/internal refactoring. Use `aether-dev:build-qa`.
- **UI:** Playwright MCP — navigation, interactions, visual state
- **API:** Direct requests — status codes, response shapes, error cases
- Issues found → route to dev agent → re-validate (max 2 loops)

## Phase 4: Refactoring (`aether-dev:build-refactor`)

Simplify, modularize, remove dead code/debug artifacts. All tests must pass after each change.

## Phase 5: Commit & Close

1. Stage files, run full test suite
2. Commit: `feat({scope}): {title} [#{ticket-id}]`
3. Update `.tasks/INDEX.md` → `completed`
4. Separate commit: `chore(tasks): mark {ticket-id} completed`

## Error Recovery

| Situation | Action |
|-----------|--------|
| Tests won't pass after 3 iterations | Escalate to user with failing tests + attempts |
| Hook errors persist | Show errors, ask user about suppression |
| QA regression | Route to Phase 2 (max 2 loops) |
| No test framework | Inform user to run `/scaffold` first |
