---
name: review
description: "Use this skill when the user asks to 'review code', 'review the last commit', 'code review', 'check my changes', or 'review before push'. Performs a structured fresh-context code review using parallel specialist agents."
---

# Review Skill

Perform a structured code review of the last commit using fresh context and parallel specialist agents.

**Review checklist:** `${SKILL_DIR}/references/review-checklist.md`
**Agent roles:** `${SKILL_DIR}/references/review-agent-roles.md`

## Fresh-Context Rules

The review MUST use fresh context to prevent familiarity bias:

1. **Diff-only input** — Agents receive `git diff HEAD~1 HEAD`, not full source files.
2. **No build context** — Agents do NOT see the build conversation, task description, or spec.
3. **Project context only** — CLAUDE.md provides coding standards and architecture — nothing about intent.
4. **Independent agents** — Each specialist reviews alone, no cross-agent discussion during review.

## Agent Team Structure

Spawn 3 agents **in parallel** (fan-out), then synthesize (fan-in):

| Agent | Dimensions | Key Questions |
|-------|-----------|---------------|
| **Correctness** | Logic, edge cases, design, contracts | Does it work? Could it break? Does it fit? |
| **Quality** | Complexity, naming, DRY, readability | Is it too complex? Could it be simpler? |
| **Safety** | Security, tests, error handling, validation | Is it safe? Is it tested? Does it handle failure? |

Each agent uses the review checklist and outputs findings in this format:

```
[BLOCKER|SUGGESTION|NIT] path/to/file.ext:42 — Short description of the issue.
Context: relevant code snippet or explanation.
Fix: suggested resolution.
```

## Severity Definitions

| Severity | Meaning | Action |
|----------|---------|--------|
| **BLOCKER** | Bug, security hole, missing test for new logic, broken contract | Must fix before push |
| **SUGGESTION** | Naming improvement, complexity reduction, better pattern | Should fix, discuss if disagreed |
| **NIT** | Style preference, minor formatting, cosmetic | Optional, author's discretion |

## Synthesis Rules

After all agents complete:
1. Collect all findings into a single list
2. Deduplicate — same file+line from multiple agents = merge, keep highest severity
3. Group by severity: BLOCKER > SUGGESTION > NIT
4. Present to user with file:line references
5. If blockers exist: fix, amend commit, re-run tests, re-check blockers only
6. If no blockers: proceed to push

## Review Scope

**DO review:** Changed lines and their immediate context (5 lines above/below). New files entirely. Deleted code for accidental removals.

**DON'T review:** Unchanged files. Pre-existing issues not touched by the diff. Style choices already established in the codebase.
