---
description: "Review the previous commit with fresh context — parallel agent review, test validation, and push"
argument-hint: "[optional: specific review focus area]"
---

# /review — Fresh-Context Code Review

Review the last commit using independent agents with no build-phase context, then push.

**Focus area:** $ARGUMENTS

## <HARD-GATE>

1. **MUST be in a worktree** with at least one commit to review (HEAD~1 must exist).
2. **MUST run tests before review.** If tests fail, fix first — do not review broken code.
3. **MUST use fresh context.** Review agents receive ONLY the diff, CLAUDE.md, and checklist — never the build conversation, task description, or spec rationale.
4. **MUST resolve all blockers** before pushing. Suggestions and nits are optional.
5. **MUST NOT push** until the review gate hook passes (tests green, no blockers).

</HARD-GATE>

## Phase 1: Pre-Flight Checks

1. Verify worktree: `git rev-parse --verify HEAD~1` must succeed.
2. Check for uncommitted changes — warn if dirty.
3. Run the project test suite. **If tests fail, stop.** Report failures and ask the user to fix.
4. Extract the diff: `git diff HEAD~1 HEAD`
5. Read project CLAUDE.md for context.

**Transition:** Tests pass AND diff extracted.

## Phase 2: Parallel Agent Review

Use the `aether-dev:review` skill. Follow its process exactly.

Spawn **3 specialist agents in parallel** — each receives ONLY:
- The git diff from Phase 1
- Project CLAUDE.md
- Review checklist (`${CLAUDE_PLUGIN_ROOT}/skills/review/references/review-checklist.md`)

| Agent | Skill | Focus |
|-------|-------|-------|
| Correctness | `aether-dev:review` | Logic, edge cases, design, API contracts |
| Quality | `aether-dev:review` | Complexity, naming, DRY, over-engineering |
| Safety | `aether-dev:review` | Security (OWASP), test coverage, error handling |

Agent roles: `${CLAUDE_PLUGIN_ROOT}/skills/review/references/review-agent-roles.md`

**Rules:**
- Agents work independently — no cross-agent communication during review
- Each outputs structured findings: `[BLOCKER|SUGGESTION|NIT] file:line — description`
- If focus area provided in $ARGUMENTS, agents weight that dimension higher

**Transition:** All 3 agents complete.

## Phase 3: Synthesis & Resolution

1. **Collect** all findings from the 3 agents.
2. **Deduplicate** — merge findings pointing to the same code location.
3. **Classify** final severity:
   - **BLOCKER** — Must fix before push (bugs, security holes, missing tests for new logic)
   - **SUGGESTION** — Should fix, improves quality (naming, complexity, style)
   - **NIT** — Optional, minor preference

4. **Present review to user:**
```
## Review Complete: {commit_subject}
**Commit:** {short_sha}
**Files changed:** {count}

### Blockers ({count}) — must fix
- [B-01] file:line — description

### Suggestions ({count}) — recommended
- [S-01] file:line — description

### Nits ({count}) — optional
- [N-01] file:line — description
```

5. **If blockers exist:**
   - Fix each blocker (or discuss with user if ambiguous)
   - Amend the commit: `git add -A && git commit --amend --no-edit`
   - Re-run tests
   - Re-check only the blocker items (no full re-review)

6. **If no blockers:** Proceed to Phase 4.

## Phase 4: Push

1. Confirm tests pass (hook will enforce this on `git push`).
2. Push to remote: `git push` (hook fires automatically).
3. If push fails due to hook, fix issues and retry.

**Present summary:**
```
## Review & Push Complete
**Commit:** {sha} — {subject}
**Branch:** {branch}
**Review:** {blocker_count} blockers fixed, {suggestion_count} suggestions, {nit_count} nits
**Tests:** Passing
**Pushed:** Yes
```

## Error Recovery

- **Tests fail in pre-flight:** Stop. Show failures. User must fix before review.
- **No commit to review:** Error — "No previous commit found. Run /build first."
- **Push rejected (upstream):** Pull/rebase, re-run tests, push again.
- **Blocker fix introduces new issues:** Re-run full review on the amended commit.
