---
description: "Decompose spec.md into feature-based development tasks with dependencies"
argument-hint: "[optional: path to spec.md if not in root]"
---

# /gen-tasks — Task Generation

Turn a validated `spec.md` into a structured set of development tasks in `.tasks/`.

**Spec path:** $ARGUMENTS (default: `spec.md`)

## <HARD-GATE>

1. **MUST have a valid `spec.md`** (or user-specified path). Cannot generate tasks without it.
2. **MUST read all project context** (CLAUDE.md, `.agent-docs/`) before decomposing.
3. **MUST produce feature-based vertical-slice tasks**, not layer-based (no "build all models" then "build all APIs").
4. **MUST write tasks to `.tasks/TASK-NNN.md`** to trigger validation hook.
5. **MUST generate `.tasks/INDEX.md`** with unblocked tasks section after all task files are written.

</HARD-GATE>

## Phase 1: Context Gathering

1. Read `spec.md` — extract personas, user stories, data models, API endpoints, scope, tech stack.
2. Read `CLAUDE.md` and any files in `.agent-docs/` if they exist — absorb project conventions.
3. If `spec.md` does not exist or is empty, stop and inform the user to run `/ideate` first.

## Phase 2: Task Decomposition

Use the `aether-dev:gen-tasks` skill. Follow its decomposition rules exactly.

**Rules:**
- Each task = a deliverable feature slice (DB + API + UI when applicable)
- Tasks should be independently testable
- Map spec scope priorities to task priorities (`In Scope` essentials → `must-have`, secondary → `should-have`, `Future` → `could-have`)
- Identify dependencies: auth before protected features, shared models before features that use them, base UI layout before pages
- Target 8-20 tasks for a typical MVP; adjust to project complexity

**Task format:** See `${CLAUDE_PLUGIN_ROOT}/skills/gen-tasks/references/task-format.md`

**Decomposition guidance:** See `${CLAUDE_PLUGIN_ROOT}/skills/gen-tasks/references/decomposition-guide.md`

## Phase 3: Write Task Files

1. Create `.tasks/` directory if it does not exist.
2. Write each task as `.tasks/TASK-NNN.md` — hook fires automatically on each write.
3. **Errors in hook feedback:** fix frontmatter/structure and re-write (hook runs again).
4. If errors persist after 3 attempts on a single task, skip and note in summary.

## Phase 4: Generate INDEX

1. After all task files pass validation, write `.tasks/INDEX.md`.
2. INDEX must include:
   - **Unblocked Tasks** section: tasks with no dependencies or all dependencies `done`
   - **All Tasks** table: every task with ID, title, status, priority, dependencies
   - **Dependency Graph**: ASCII representation of the task DAG
3. The INDEX must be regenerated whenever a task status changes (documented for /build).

## Phase 5: Summary

Present results:
```
## Tasks Generated
**Directory:** .tasks/
- Total tasks: {count}
- Must-have: {count} | Should-have: {count} | Could-have: {count}
- Unblocked (ready to build): {count}
- Dependency chains: {max depth}
- Files: {list of TASK-NNN.md files}
```

## Error Recovery

- **No spec.md**: Tell user to run `/ideate` first.
- **Spec incomplete/invalid**: Warn about missing sections, generate tasks from available content, note gaps.
- **User says "regenerate"**: Delete existing `.tasks/` contents and start fresh.
- **User says "add task"**: Append next `TASK-NNN.md` with next available number, regenerate INDEX.
