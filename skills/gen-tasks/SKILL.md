---
name: gen-tasks
description: "Use this skill when the user asks to 'generate tasks', 'create tickets', 'break down the spec', 'plan development tasks', 'create a task list', or 'decompose into work items'. Reads spec.md and produces feature-based development tasks in .tasks/ with dependencies and an INDEX."
---

# Gen-Tasks Skill

Decompose a validated spec into feature-based, vertical-slice development tasks with dependency tracking.

**Task format reference:** `${SKILL_DIR}/references/task-format.md`
**Decomposition guide:** `${SKILL_DIR}/references/decomposition-guide.md`

## Decomposition Rules

1. **Vertical slices, not horizontal layers.** Each task delivers a working feature end-to-end (model + API + UI). Never create tasks like "build all models" or "build all endpoints."
2. **One task = one deliverable.** A task is done when its acceptance criteria pass and the feature is testable in isolation.
3. **8/80 guideline.** Each task should represent roughly 1-4 hours of focused agent work. Split if larger; merge if trivial.
4. **Foundation tasks first.** Auth, base layout, shared data models — these are legitimate standalone tasks that others depend on.

## Priority Mapping

| Spec Source | Task Priority | Meaning |
|-------------|---------------|---------|
| In Scope (MVP) — core features | `must-have` | Required for launch |
| In Scope (MVP) — secondary features | `should-have` | Important but not blocking |
| Future Considerations | `could-have` | Include only if low effort |

## Dependency Rules

Declare `depends_on` when a task literally cannot start without another being `done`.

| Pattern | Example |
|---------|---------|
| Auth before protected resources | TASK-001 (auth) blocks TASK-003 (dashboard) |
| Shared model before features using it | TASK-002 (user model) blocks TASK-004 (profile page) |
| Base layout before pages | TASK-003 (app shell) blocks TASK-005 (settings page) |
| CRUD before advanced features | TASK-004 (create posts) blocks TASK-008 (search posts) |

**DO NOT** over-declare dependencies. If two features share no data or UI, they are independent.

## Task Quality (INVEST)

| Criterion | Rule |
|-----------|------|
| **I**ndependent | Minimally coupled; can be built/tested without other pending tasks |
| **N**egotiable | Description explains intent, not exact implementation |
| **V**aluable | Delivers visible user or system value |
| **E**stimable | Scope is clear enough to estimate effort |
| **S**ized | Fits the 8/80 guideline (1-4 hours agent work) |
| **T**estable | Acceptance criteria are specific and verifiable |

## Writing Acceptance Criteria

Each criterion must be a checkbox item that is specific and testable.

| BAD | GOOD |
|-----|------|
| `- [ ] Users can log in` | `- [ ] User submits email+password, receives JWT, is redirected to /dashboard` |
| `- [ ] API works` | `- [ ] POST /api/projects returns 201 with { id, name, created_at }` |
| `- [ ] Page looks good` | `- [ ] Projects list page renders project cards with name, status, and created date` |
| `- [ ] Handle errors` | `- [ ] Invalid login returns 401 and displays "Invalid credentials" message` |

## Decomposition Process

1. **Extract features** from spec sections 4 (User Stories), 5 (User Flows), 12 (Scope).
2. **Group by feature**, not by layer — combine related stories into one task.
3. **Identify foundations** — auth, base models, app shell — create tasks for these first.
4. **Build dependency DAG** — connect tasks, verify no cycles, minimize dependency depth.
5. **Assign priorities** from spec scope section.
6. **Write tasks** using the format in `${SKILL_DIR}/references/task-format.md`.
7. **Generate INDEX** with unblocked tasks at top.
