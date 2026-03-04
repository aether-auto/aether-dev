---
name: build-testing
description: "Use this skill when acting as the Testing agent during /build. Writes failing tests (unit + integration) from PM-defined goals before any implementation begins. Enforces the RED phase of TDD."
---

# Build Testing Skill

Write failing tests that define the expected behavior for a ticket. Tests are the contract — implementation follows.

**TDD reference:** `${SKILL_DIR}/references/tdd-guide.md`

## Responsibilities

- Receive behavioral goals from the PM agent
- Write unit tests for individual functions/components
- Write integration tests for API endpoints and component interactions
- Run all tests — new tests MUST fail (RED phase)
- Verify existing tests still pass
- Report test locations and failure summary to dev agents

## Input

- Behavioral goals from PM agent (via SendMessage)
- Project test configuration from `CLAUDE.md`
- Existing test files for pattern consistency

## Output

- Test files written to project test directories
- Failure report sent to dev agents via SendMessage:
  - Test file paths
  - Test names and what they verify
  - Expected failure reasons

## Test Writing Rules

| BAD | GOOD | Why |
|-----|------|-----|
| `test('works')` | `test('should return 201 with project id when valid data posted')` | Descriptive name |
| No assertions | `expect(res.status).toBe(201)` | Every test needs assertions |
| Tests depend on order | Each test sets up own data | Isolation |
| Testing implementation | Testing behavior/output | Tests survive refactors |
| `test.only(...)` left in | All tests runnable | No skipped tests in commit |

## Structure

```
describe('{Feature or Component}', () => {
  // Arrange: setup shared fixtures

  test('should {expected behavior} when {condition}', () => {
    // Arrange: specific setup
    // Act: perform action
    // Assert: verify outcome
  });
});
```

## Rules

**DO:**
- One assertion concept per test (multiple `expect` for same concept is OK)
- Test naming: `should_{behavior}_when_{condition}`
- Include happy path, error path, and edge case tests
- Use project test utilities and factories if they exist
- Match existing test file naming conventions

**DON'T:**
- Write tests that pass immediately — they must fail first (RED)
- Mock everything — only mock external services and side effects
- Test private/internal implementation details
- Write flaky tests (no timing dependencies, random data)
- Skip writing tests for error cases

## Coordination

- Receive goals from PM agent
- Send test locations and descriptions to dev agents
- Respond to dev agents asking about test expectations
- Re-run tests when devs report completion — confirm GREEN
