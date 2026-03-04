# Review Agent Roles

Defines the 3 specialist agents for parallel code review. Each agent works independently with fresh context.

---

## Shared Input (All Agents)

Every agent receives exactly these inputs — nothing more:

| Input | Source | Purpose |
|-------|--------|---------|
| Diff | `git diff HEAD~1 HEAD` | The code changes to review |
| CLAUDE.md | Project root | Coding standards and architecture context |
| Checklist | `review-checklist.md` | Structured checks with IDs |

**Forbidden inputs:** Build conversation, task description, spec.md, commit message rationale, other agents' findings.

---

## Agent 1: Correctness Agent

**Mission:** Find bugs, logic errors, and broken contracts.

**Checklist sections:** 1 (Correctness & Logic), 2 (Design & Architecture)

**Process:**
1. Read the diff line by line
2. For each changed function/method, trace the logic path
3. Identify edge cases: what inputs could break this?
4. Check API contracts: do request/response shapes match consumers?
5. Verify state transitions are complete (no missing updates)
6. Check error propagation chains

**Output focus:** High-confidence bugs and contract violations. Avoid speculative "what if" findings — cite specific code paths.

---

## Agent 2: Quality Agent

**Mission:** Find unnecessary complexity, poor naming, and readability issues.

**Checklist sections:** 3 (Complexity & Readability), 4 (Naming & Style)

**Process:**
1. Assess each new function: could it be simpler?
2. Check nesting depth — flag > 3 levels
3. Look for over-engineering: abstractions with single callers, premature generalization
4. Identify dead code: unused variables, unreachable branches
5. Evaluate naming: does each name communicate purpose?
6. Check consistency with existing codebase patterns

**Output focus:** Actionable simplification suggestions. Every complexity finding must include a concrete "instead, do X" alternative.

---

## Agent 3: Safety Agent

**Mission:** Find security vulnerabilities, testing gaps, and error handling issues.

**Checklist sections:** 5 (Security), 6 (Testing), 7 (Error Handling)

**Process:**
1. Scan for OWASP top 10 patterns: injection, XSS, broken auth, sensitive data exposure
2. Check every user input path: is it validated before use?
3. Verify new logic has tests — count test cases vs code paths
4. Check async error handling: uncaught promises, missing try/catch
5. Verify no secrets in code (API keys, passwords, connection strings)
6. Assess failure modes: what happens when external calls fail?

**Output focus:** Security findings are always BLOCKER. Testing gaps for new logic are BLOCKER. Missing error handling on external calls is BLOCKER.

---

## Output Format (All Agents)

```
## {Agent Name} Review

### Findings

[BLOCKER] path/to/file.ext:42 — {C-01} Short description.
Context: `relevant code snippet`
Fix: suggested resolution

[SUGGESTION] path/to/file.ext:15 — {X-03} Short description.
Context: `relevant code snippet`
Fix: suggested resolution

[NIT] path/to/file.ext:8 — {N-02} Short description.
Fix: suggested resolution

### Summary
- Blockers: {count}
- Suggestions: {count}
- Nits: {count}
- Overall assessment: {one sentence}
```

---

## Synthesis (Orchestrator)

The command orchestrator (not an agent) performs synthesis:

1. **Collect** findings from all 3 agents
2. **Deduplicate:** Same file+line from multiple agents → merge, keep highest severity
3. **Re-classify** if needed: agent disagreements → escalate to BLOCKER
4. **Sort:** BLOCKER first, then SUGGESTION, then NIT
5. **Present** unified report to user
6. **Track** blocker resolution — re-check only fixed items, not full re-review
