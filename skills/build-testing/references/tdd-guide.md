# TDD Guide — Red-Green-Refactor

Reference for the testing agent and dev agents on test-driven development practices.

## The Cycle

| Phase | Who | Action | Exit Criteria |
|-------|-----|--------|---------------|
| RED | Testing Agent | Write tests from PM goals. Tests define expected behavior. | All new tests FAIL. Existing tests pass. |
| GREEN | Dev Agents | Write minimum code to pass tests. No premature abstraction. | All tests PASS. |
| REFACTOR | Refactor Agent | Clean code, extract helpers, improve naming, remove duplication. | All tests still PASS. |

## Test Pyramid

| Level | What | Ratio | Speed | Example |
|-------|------|-------|-------|---------|
| Unit | Single function/component in isolation | ~70% | <100ms | `calculateTotal(items)` returns correct sum |
| Integration | API endpoint, DB query, component interaction | ~20% | <2s | POST /api/projects creates record and returns 201 |
| E2E | Full user flow through browser | ~10% | <10s | User can sign up, create project, invite member |

## Test Structure

```
describe('{Feature}', () => {
  // Shared setup (beforeEach if needed)

  test('should {behavior} when {condition}', () => {
    // Arrange — set up test data
    // Act — perform the action
    // Assert — verify the outcome
  });
});
```

## Naming Convention

Pattern: `should_{expected_behavior}_when_{condition}`

| BAD | GOOD |
|-----|------|
| `test('works')` | `test('should return 404 when project not found')` |
| `test('handles error')` | `test('should show validation message when email empty')` |
| `test('test1')` | `test('should create user record when signup form submitted')` |

## What to Test

| Always Test | Never Test |
|------------|------------|
| Public API contracts | Private implementation details |
| Error states and validation | Framework internals |
| Edge cases (empty, null, boundary) | Third-party library behavior |
| State transitions | Getter/setter boilerplate |
| Async operations (success + failure) | CSS styling specifics |

## Mocking Rules

| Mock | Don't Mock |
|------|-----------|
| External APIs and services | Your own code |
| Database (in unit tests) | Simple utilities |
| File system operations | Data transformations |
| Time/date for determinism | Business logic |
| Email/notification services | Validation functions |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Test passes immediately (not RED first) | Verify test fails before writing implementation |
| Testing multiple behaviors in one test | Split into focused tests, one concept each |
| Fragile selectors in UI tests | Use data-testid, roles, accessible names |
| Hardcoded test data | Use factories/builders for test data |
| Tests depend on execution order | Each test sets up and tears down own state |
| Snapshot overuse | Only snapshot stable, small outputs |

## RED Phase Checklist

- [ ] Tests written for every PM goal
- [ ] At least 1 happy path + 1 error path per goal
- [ ] Edge cases identified and covered
- [ ] All new tests FAIL when run
- [ ] All pre-existing tests still PASS
- [ ] Test names are descriptive (`should...when...`)
- [ ] No `.only` or `.skip` markers

## GREEN Phase Checklist

- [ ] Minimum code written to pass tests
- [ ] No gold-plating or extra features
- [ ] All tests PASS
- [ ] Hook validations pass
- [ ] No console.log or debug artifacts left
