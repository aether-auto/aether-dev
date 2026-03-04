# Refactoring Patterns

Reference catalog for the refactoring agent. Apply only when tests pass and the pattern clearly improves readability.

## Pattern Catalog

### 1. Extract Function

**When:** Block of code does one identifiable thing inside a larger function.

| Before | After |
|--------|-------|
| Inline 15-line validation block | `validateUserInput(data)` extracted |
| Repeated formatting logic | `formatCurrency(amount)` helper |

**Rule:** Name the function after WHAT it does, not HOW.

### 2. Early Return / Guard Clause

**When:** Deeply nested conditionals checking for error/edge cases.

| Before | After |
|--------|-------|
| `if (user) { if (user.active) { if (user.verified) { ...logic... } } }` | `if (!user) return; if (!user.active) return; if (!user.verified) return; ...logic...` |

**Rule:** Check for failure conditions first, return early, keep happy path unindented.

### 3. Replace Magic Values

**When:** Literal numbers or strings used in conditions/logic.

| Before | After |
|--------|-------|
| `if (retries > 3)` | `if (retries > MAX_RETRIES)` |
| `role === 'admin'` | `role === ROLES.ADMIN` |

**Rule:** Extract to named constant at module scope.

### 4. Simplify Conditionals

**When:** Complex boolean expressions or long if-else chains.

| Before | After |
|--------|-------|
| `if (a && b && !c && (d \|\| e))` | `const isEligible = ...; if (isEligible)` |
| Long if/else if/else chain | Object lookup or map |

### 5. Remove Dead Code

**When:** Unreachable code, unused variables, commented-out blocks.

| Remove | Keep |
|--------|------|
| `// const oldHandler = ...` (commented code) | `// NOTE: rate limit is per-user, not per-IP` (explanation) |
| Unused imports | Imports used in types-only |
| `console.log('debug:', ...)` | Structured logger calls |
| Functions with zero callers | Functions in public API |

### 6. Consolidate Duplicates

**When:** Same logic appears in 2+ places with minor variations.

**Rule:** Extract shared logic, parameterize the differences. But only if the abstraction makes code MORE readable, not less.

| Worth extracting | Not worth extracting |
|-----------------|---------------------|
| 10+ lines repeated in 3 places | 3 similar lines in 2 places |
| Repeated error handling pattern | Slightly similar but different logic |
| Same API call shape with different params | Code that might diverge later |

### 7. Split Large Files

**When:** File exceeds ~300 lines or has multiple unrelated concerns.

**Approach:**
1. Identify natural groupings (by feature, by type, by responsibility)
2. Extract each group to its own file
3. Update imports in all consumers
4. Run tests after each split

## Anti-Patterns — Don't Do These

| Anti-Pattern | Why It's Bad |
|-------------|-------------|
| Refactor code outside ticket scope | Creates unexpected diffs, risk of regressions |
| Create abstraction for single use | Over-engineering, harder to read |
| Rename everything to "better" names | Churn without value, breaks git blame |
| Move files around "for organization" | Breaks imports, confuses team |
| Add TypeScript types to untyped code | Out of scope for a refactor pass |

## Checklist

- [ ] All tests pass before starting
- [ ] Each change is atomic (one pattern at a time)
- [ ] Tests re-run after every change
- [ ] No behavioral changes introduced
- [ ] No new features added
- [ ] All debug artifacts removed
- [ ] File sizes within project conventions
- [ ] All tests pass at the end
