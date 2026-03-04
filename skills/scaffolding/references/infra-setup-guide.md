# Infrastructure Setup Guide

Testing, database, CI/CD, and git hook patterns for project scaffolding.

---

## 1. Testing Infrastructure

### Test Pyramid

| Layer | Ratio | Runner | Location | Speed |
|-------|-------|--------|----------|-------|
| Unit | ~70% | Vitest / Jest | `tests/unit/` | ms |
| Integration | ~20% | Vitest / Jest | `tests/integration/` | seconds |
| E2E | ~10% | Playwright | `tests/e2e/` | seconds-minutes |

### Runner Config Essentials

| Runner | Config File | Key Settings |
|--------|------------|-------------|
| Vitest | `vitest.config.ts` | `globals: true`, `environment: 'node'/'jsdom'`, include `tests/unit/**` + `tests/integration/**`, coverage `v8` |
| Playwright | `playwright.config.ts` | `testDir: 'tests/e2e'`, `baseURL`, `webServer` with dev command |

### Initial Test Files

| File | Purpose |
|------|---------|
| `tests/unit/example.test.ts` | Minimal passing unit test proving setup works |
| `tests/integration/.gitkeep` | Placeholder — integration tests come during build |
| `tests/e2e/smoke.spec.ts` | Navigate to `/`, verify page loads (after first UI build) |

### Coverage Configuration

| Setting | Value |
|---------|-------|
| Provider | `v8` (Vitest) or `--coverage` (Jest) |
| Reporters | `text` (terminal), `html` (local), `lcov` (CI) |
| Thresholds (initial) | None — add after first build phase |
| CI integration | Upload `lcov` to coverage service in CI |

---

## 2. Database Setup

### ORM Selection (from spec.md section 10)

| ORM | Init Command | Schema Location | Migration Command |
|-----|-------------|-----------------|-------------------|
| Prisma | `npx prisma init` | `prisma/schema.prisma` | `npx prisma migrate dev --name init` |
| Drizzle | `npm i drizzle-orm drizzle-kit` | `src/server/db/schema.ts` | `npx drizzle-kit generate && npx drizzle-kit migrate` |

### Initial Schema

Translate spec.md section 6 (Data Models) into ORM schema:

| Spec Field Type | Prisma Type | Drizzle Type |
|----------------|-------------|--------------|
| UUID | `String @id @default(uuid())` | `uuid('id').primaryKey().defaultRandom()` |
| string | `String` | `text('name')` or `varchar('name', { length: N })` |
| number/integer | `Int` | `integer('count')` |
| boolean | `Boolean` | `boolean('active')` |
| DateTime | `DateTime` | `timestamp('created_at')` |
| enum | `enum` block | `pgEnum(...)` |

### Seed File

```
src/server/db/seed.ts   (or prisma/seed.ts for Prisma)
```

Create a seed file scaffold with:
- Import schema/models
- Example seed data matching spec.md entities (2-3 records per model)
- Idempotent: clear then insert (use transactions)

### Connection Configuration

| File | Content |
|------|---------|
| `.env.example` | `DATABASE_URL=postgresql://user:password@localhost:5432/dbname` |
| `src/server/db/index.ts` | ORM client initialization, connection pool |

**IMPORTANT:** `.env` is gitignored. `.env.example` is committed with placeholder values.

---

## 3. CI/CD Setup

### `ci.yml` Structure

| Job | Runs | Needs | Steps |
|-----|------|-------|-------|
| `lint` | `ubuntu-latest` | — | checkout, setup-node (v20, cache npm), `npm ci`, `npm run lint` |
| `test` | `ubuntu-latest` | `lint` | checkout, setup-node, `npm ci`, `npm test` |
| `build` | `ubuntu-latest` | `test` | checkout, setup-node, `npm ci`, `npm run build` |

**Triggers:** `push` to `main` + `pull_request` to `main`.

### Job Design Rules

| Rule | Rationale |
|------|-----------|
| Lint before test | Fail fast on style issues |
| Test before build | Don't waste build time on failing tests |
| Cache `npm` | `actions/setup-node` cache cuts install time 60-80% |
| Pin action versions | `@v4` not `@latest` — reproducible builds |
| `npm ci` not `npm install` | Clean install from lockfile — deterministic |

### Deploy Workflow (Placeholder)

Create `.github/workflows/deploy.yml` as a placeholder:
- Triggered on push to `main` only
- Single job with a TODO comment for deployment steps
- Do NOT configure actual deployment during scaffold

---

## 4. Git Hooks Setup

### Husky + lint-staged + commitlint

| Package | Purpose |
|---------|---------|
| `husky` | Git hooks manager |
| `lint-staged` | Run linters on staged files only |
| `@commitlint/cli` + `@commitlint/config-conventional` | Enforce conventional commits |

### Setup

Install: `npm install -D husky lint-staged @commitlint/cli @commitlint/config-conventional` then `npx husky init`.

### Hook Files

| Hook | File | Command |
|------|------|---------|
| pre-commit | `.husky/pre-commit` | `npx lint-staged` |
| commit-msg | `.husky/commit-msg` | `npx --no -- commitlint --edit $1` |

### Config Files

| File | Content |
|------|---------|
| `.lintstagedrc.json` | `{ "*.{ts,tsx,js,jsx}": ["eslint --fix"], "*.{ts,tsx,js,jsx,json,md}": ["prettier --write"] }` |
| `commitlint.config.js` | `export default { extends: ['@commitlint/config-conventional'] };` |

**Conventional commit format:** `type(scope): description` — types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `perf`, `build`.

---

## 5. BAD/GOOD Examples

| BAD | GOOD | Why |
|-----|------|-----|
| No test runner configured | Vitest config + example test in scaffold | Tests must run from day 1 |
| `DATABASE_URL=postgres://...` in code | `process.env.DATABASE_URL` + `.env.example` | Secrets never in source |
| CI runs `npm install` | CI runs `npm ci` | Deterministic installs from lockfile |
| All tests in one flat directory | `tests/unit/`, `tests/integration/`, `tests/e2e/` | Separation enables selective runs |
| CI triggers on every branch | CI triggers on `main` + PRs to `main` | Avoids wasted runs on feature branches |
| `npx prisma db push` in CI | `npx prisma migrate deploy` in CI | Push skips migration history |
| No seed file | Seed file with example data | Developers need data to work with locally |
| Git hooks installed manually | Husky auto-installs on `npm install` | Consistent across all contributors |
| `actions/checkout@latest` | `actions/checkout@v4` | Pinned versions = reproducible CI |
