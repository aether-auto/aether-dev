# Code Review Checklist

Structured checklist for each review dimension. Every finding must cite a specific check ID.

---

## 1. Correctness & Logic

| ID | Check | Severity |
|----|-------|----------|
| C-01 | Logic errors: wrong conditions, off-by-one, inverted boolean | BLOCKER |
| C-02 | Edge cases: null/undefined, empty arrays, zero values, boundary inputs | BLOCKER |
| C-03 | Race conditions or concurrency issues | BLOCKER |
| C-04 | API contract violations: request/response shape mismatches | BLOCKER |
| C-05 | State management: stale state, missing updates, inconsistent state | BLOCKER |
| C-06 | Data flow: values used before defined, unused return values | SUGGESTION |
| C-07 | Error propagation: errors silently swallowed, missing error paths | BLOCKER |

### Examples

| BAD | GOOD | Check |
|-----|------|-------|
| `if (items.length > 0)` when `items` can be null | `if (items?.length > 0)` | C-02 |
| `for (let i = 0; i <= arr.length; i++)` | `for (let i = 0; i < arr.length; i++)` | C-01 |
| `setState(count + 1)` in async callback | `setState(prev => prev + 1)` | C-05 |
| `try { await api() } catch {}` | `try { await api() } catch (e) { logger.error(e) }` | C-07 |

---

## 2. Design & Architecture

| ID | Check | Severity |
|----|-------|----------|
| D-01 | Change fits the existing architecture patterns in CLAUDE.md | SUGGESTION |
| D-02 | No unnecessary coupling between modules | SUGGESTION |
| D-03 | Follows established project conventions (file structure, exports) | SUGGESTION |
| D-04 | Database schema changes are backwards-compatible or have migration | BLOCKER |
| D-05 | API changes are backwards-compatible or versioned | BLOCKER |

---

## 3. Complexity & Readability

| ID | Check | Severity |
|----|-------|----------|
| X-01 | Over-engineering: abstractions for single use cases | SUGGESTION |
| X-02 | Functions longer than ~40 lines without clear reason | SUGGESTION |
| X-03 | Nesting depth > 3 levels | SUGGESTION |
| X-04 | Clever code that requires mental gymnastics to understand | SUGGESTION |
| X-05 | Magic numbers or strings without named constants | NIT |
| X-06 | Dead code: unreachable branches, unused variables/imports | SUGGESTION |

### Examples

| BAD | GOOD | Check |
|-----|------|-------|
| `createAbstractFactoryProvider(config)` for one button | Direct implementation | X-01 |
| `if (a) { if (b) { if (c) { ... } } }` | Early returns or guard clauses | X-03 |
| `arr.reduce((a,b) => ({...a,[b.k]:b.v}),{})` | `Object.fromEntries(arr.map(b => [b.k, b.v]))` | X-04 |
| `setTimeout(fn, 86400000)` | `setTimeout(fn, ONE_DAY_MS)` | X-05 |

---

## 4. Naming & Style

| ID | Check | Severity |
|----|-------|----------|
| N-01 | Variable/function names describe purpose, not implementation | NIT |
| N-02 | Boolean names read as questions: `isReady`, `hasPermission`, `canEdit` | NIT |
| N-03 | Consistent naming with existing codebase conventions | NIT |
| N-04 | Abbreviations avoided unless domain-standard (`id`, `url`, `api` OK) | NIT |

### Examples

| BAD | GOOD | Check |
|-----|------|-------|
| `const data = fetchUsers()` | `const users = fetchUsers()` | N-01 |
| `const ready = true` | `const isReady = true` | N-02 |
| `getUserData` alongside `fetchUserInfo` | Pick one convention and use it | N-03 |

---

## 5. Security

| ID | Check | Severity |
|----|-------|----------|
| S-01 | User input validated and sanitized before use | BLOCKER |
| S-02 | No SQL injection vectors (raw string interpolation in queries) | BLOCKER |
| S-03 | No XSS vectors (unsanitized user content in HTML/JSX) | BLOCKER |
| S-04 | Authentication checked on protected routes/endpoints | BLOCKER |
| S-05 | Authorization: users can only access their own resources | BLOCKER |
| S-06 | Secrets not hardcoded (API keys, passwords, tokens) | BLOCKER |
| S-07 | Sensitive data not logged or exposed in error messages | SUGGESTION |
| S-08 | CORS, CSP, and security headers configured appropriately | SUGGESTION |

---

## 6. Testing

| ID | Check | Severity |
|----|-------|----------|
| T-01 | New logic has corresponding tests | BLOCKER |
| T-02 | Edge cases from C-02 are tested | SUGGESTION |
| T-03 | Tests are deterministic (no time-dependent, random, or order-dependent) | BLOCKER |
| T-04 | Tests test behavior, not implementation details | SUGGESTION |
| T-05 | Mocks are minimal — only external dependencies | SUGGESTION |
| T-06 | Test names describe the scenario and expected outcome | NIT |

### Examples

| BAD | GOOD | Check |
|-----|------|-------|
| New API endpoint with no tests | Tests for happy path + error cases | T-01 |
| `expect(component.state.count).toBe(1)` | `expect(screen.getByText('1')).toBeVisible()` | T-04 |
| `test('test 1', ...)` | `test('returns 404 when user not found', ...)` | T-06 |

---

## 7. Error Handling

| ID | Check | Severity |
|----|-------|----------|
| E-01 | Async operations have error handling (try/catch, .catch) | BLOCKER |
| E-02 | Error messages are actionable for the user | SUGGESTION |
| E-03 | Failures don't leave system in inconsistent state | BLOCKER |
| E-04 | Network failures handled gracefully (retry, fallback, user feedback) | SUGGESTION |
