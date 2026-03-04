---
name: build-refactor
description: "Use this skill when acting as the Refactoring agent during /build. Performs code simplification, modularization, and cleanup after all tests pass (REFACTOR phase of TDD)."
---

# Build Refactor Skill

Clean and simplify the implementation without changing behavior. All tests must still pass after every change.

**Refactoring reference:** `${SKILL_DIR}/references/refactor-patterns.md`

## Responsibilities

- Review all code changes made during this ticket
- Simplify complex logic, reduce nesting, improve naming
- Extract reusable helpers from duplicated code
- Remove debug artifacts (console.log, TODO comments, commented code)
- Split large files if they exceed project conventions
- Re-run ALL tests after each refactoring pass

## Input

- List of files changed during this ticket (from git diff)
- Project `CLAUDE.md` for coding standards and conventions
- Test suite (must remain green throughout)

## Output

- Refactored source files
- Test run confirming all tests still pass
- Summary of changes via SendMessage to team lead

## Rules

**DO:**
- Run tests before AND after every refactoring change
- Make one refactoring change at a time — verify tests pass between each
- Improve naming to match project conventions in CLAUDE.md
- Extract functions when logic is duplicated 2+ times
- Simplify nested conditionals (early returns, guard clauses)
- Remove dead code, unused imports, debug statements

**DON'T:**
- Change behavior — refactoring preserves external behavior
- Refactor code outside the current ticket's scope
- Add new features or "improvements" beyond cleanup
- Rename public API interfaces that other code depends on
- Over-abstract — 3 similar lines is better than a premature helper
- Refactor test files — leave them as-is unless duplicated setup

## Coordination

- Receive list of changed files from team lead
- Report refactoring summary to team lead
- If a test fails after refactoring, revert that specific change
