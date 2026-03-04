# Task Decomposition Guide

How to break a spec.md into feature-based development tasks.

---

## Step 1: Identify Foundation Tasks

Foundation tasks set up infrastructure that other features depend on.

| Foundation Type | When Needed | Example Task |
|----------------|-------------|--------------|
| Auth system | Spec has Section 8 with auth | "Implement user registration and login" |
| App shell / layout | Spec has Section 5 with screens | "Set up app shell, navigation, and base layout" |
| Shared data models | Models used by 3+ features | "Create core data models and migrations" |
| File/media handling | Spec mentions uploads | "Implement file upload service" |

**Rules:**
- Keep foundation tasks minimal — only what's truly shared
- Auth is almost always TASK-001 or TASK-002
- App shell is usually the first UI task

## Step 2: Extract Features from Spec

Read these spec sections in order:

| Section | What to Extract |
|---------|----------------|
| 4. User Stories | Each Must-Have story = candidate feature |
| 5. User Flows | Each flow = candidate feature (may overlap with stories) |
| 12. Scope | In Scope items confirm MVPs; Out of Scope items are excluded |
| 7. API Specifications | Group endpoints by resource = feature boundary |
| 6. Data Models | Models cluster with the features that own them |

## Step 3: Group into Vertical Slices

Merge related items into single tasks. One task should deliver one testable feature.

| BAD (horizontal) | GOOD (vertical) |
|-------------------|-----------------|
| "Create all database models" | "Implement project CRUD with API and list page" |
| "Build all API endpoints" | "Build team management (invite, roles, remove)" |
| "Style all pages" | "Create dashboard with project summary cards" |
| "Add form validation" | "Implement search and filter for project list" |

### Grouping Heuristic

Features that share the SAME primary data model often belong in the SAME task:
- User stories US-003, US-004 both about "projects" → one task
- But if CRUD is simple and search/filter is complex → split them

Features that touch DIFFERENT models are DIFFERENT tasks:
- "Create project" and "Invite team member" → two tasks (Project vs TeamMember)

## Step 4: Build Dependency DAG

For each task, ask: "Can an agent start this without any other task being done?"

| If yes | `depends_on: []` |
|--------|-------------------|
| If no | List the specific blocking task IDs |

### Common Dependency Patterns

```
Auth ──→ Any protected feature
App Shell ──→ Any page/screen
Core Model ──→ Features using that model
Basic CRUD ──→ Advanced features (search, export, analytics)
```

### Dependency Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Chain everything | TASK-01→02→03→04→05 serial | Only declare true blockers |
| Depend on "setup" for everything | Over-coupling | Split setup; only depend on relevant part |
| Circular dependency | A→B→A impossible | Merge into one task or restructure |
| UI depends on API | Often false — can mock | Only if integration is the whole task |

## Step 5: Assign Priorities

| Spec Source | Priority | Typical % |
|-------------|----------|-----------|
| In Scope — core workflow features | `must-have` | 50-60% |
| In Scope — supporting features | `should-have` | 25-35% |
| Future Considerations (low effort only) | `could-have` | 5-15% |

## Step 6: Validate the Task Set

Before writing files, verify:

- [ ] Every In Scope spec feature is covered by at least one task
- [ ] No task is purely horizontal (only models, only APIs, only UI)
- [ ] Dependency graph has no cycles
- [ ] At least 2 tasks are unblocked (can start immediately)
- [ ] No task has more than 3 direct dependencies
- [ ] Task count is 8-20 for typical MVP (adjust for complexity)
- [ ] Must-have tasks form a buildable path from first to last

## Quick Reference: Task Count Guidelines

| Project Complexity | Task Count | Dependency Depth |
|-------------------|------------|-----------------|
| Simple (3-5 pages, 2-3 models) | 8-12 | 2-3 levels |
| Medium (6-10 pages, 4-6 models) | 12-16 | 3-4 levels |
| Complex (10+ pages, 7+ models) | 16-20 | 4-5 levels |
