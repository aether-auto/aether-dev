---
description: "Initialize project infrastructure: git, project files, testing, database, and CI/CD"
argument-hint: "[path to spec.md - defaults to ./spec.md]"
---

# /scaffold — Project Infrastructure Setup

Set up complete project infrastructure from spec.md through 5 sequential phases.

**Spec path:** $ARGUMENTS (default: `./spec.md`)

## <HARD-GATE>

1. **MUST have spec.md.** Read it. If missing or unreadable, stop and tell the user to run `/ideate` first.
2. **MUST have section 10 (Tech Stack).** If empty or missing, stop — cannot scaffold without stack decisions.
3. **MUST NOT scaffold over existing project.** If `package.json` (or equivalent) already exists in the target directory, stop and warn. Offer to continue only if user confirms.
4. **MUST create `.scaffold-in-progress` marker** at start and remove it at end (enables validation hook).
5. **MUST NOT install packages beyond what each phase requires.** No speculative dependencies.

</HARD-GATE>

## Phase 1: Git Initialization

1. Run `git init`
2. Create `.gitignore` — use `aether-dev:scaffolding` skill for stack-appropriate patterns
3. Create initial commit: `chore: initialize repository`

**Verify:** `.git/` exists, `.gitignore` is non-empty.

## Phase 2: Project Structure

Use the `aether-dev:scaffolding` skill. Follow its stack decision tree.

1. Read spec.md section 10 for all stack choices
2. Create directory layout matching the identified stack pattern
3. Create `package.json` with all standard scripts (dev, build, test, lint, format, db:*)
4. Install and configure: TypeScript, ESLint (flat config), Prettier
5. Create `.env.example` with all required environment variables
6. Create `.editorconfig`
7. Create root `CLAUDE.md` — project name, stack, commands, structure, conventions
8. Create subdirectory `CLAUDE.md` files for every source directory

**Verify:** `package.json` exists, `tsconfig.json` compiles, `CLAUDE.md` at root.

## Phase 3: Testing Infrastructure

Read `${CLAUDE_PLUGIN_ROOT}/skills/scaffolding/references/infra-setup-guide.md` section 1.

1. Install test runner (Vitest preferred, Jest if spec requires)
2. Create `vitest.config.ts` (or `jest.config.ts`)
3. Create test directories: `tests/unit/`, `tests/integration/`, `tests/e2e/`
4. Create `tests/unit/example.test.ts` — one passing test proving setup works
5. Add Playwright config for E2E (install deferred to build phase)
6. Add coverage configuration
7. Verify: `npm test` passes

**Verify:** `npm test` exits 0, test directories exist.

## Phase 4: Database Setup

Read `${CLAUDE_PLUGIN_ROOT}/skills/scaffolding/references/infra-setup-guide.md` section 2.

1. Identify ORM from spec.md section 10
2. Install ORM and initialize (Prisma: `npx prisma init`, Drizzle: create config)
3. Translate spec.md section 6 data models into ORM schema
4. Create seed file scaffold with example data (2-3 records per model)
5. Add `db:*` scripts to `package.json` if not already present
6. Update `.env.example` with `DATABASE_URL`

**Skip if:** spec.md section 10 has no database or ORM specified.

**Verify:** Schema file exists, seed file exists, `.env.example` has `DATABASE_URL`.

## Phase 5: CI/CD Pipeline

Read `${CLAUDE_PLUGIN_ROOT}/skills/scaffolding/references/infra-setup-guide.md` sections 3-4.

1. Create `.github/workflows/ci.yml` — lint, test, build jobs
2. Create `.github/workflows/deploy.yml` — placeholder with TODO
3. Install Husky, lint-staged, commitlint
4. Run `npx husky init`
5. Create pre-commit hook (lint-staged) and commit-msg hook (commitlint)
6. Create `.lintstagedrc.json` and `commitlint.config.js`

**Verify:** `.github/workflows/ci.yml` exists, Husky hooks exist.

## Phase 6: Finalize

1. Remove `.scaffold-in-progress` marker file
2. Run full lint check: `npm run lint`
3. Run tests: `npm test`
4. Create commit: `chore: scaffold project infrastructure`

**Present summary:**
```
## Scaffold Complete: {App Name}
**Stack:** {frontend} + {backend} + {database}
- Directories: {count} created
- Config files: {count}
- Test runner: {name} (1 passing test)
- Database: {ORM} with {N} models from spec
- CI/CD: GitHub Actions (lint → test → build)
- Git hooks: Husky + lint-staged + commitlint

**Next steps:**
1. Copy `.env.example` to `.env` and fill in values
2. Run `npm run db:migrate` to set up database
3. Run `/gen-tasks` to generate task list (if not done)
4. Run `/build` to start building features
```

## Error Recovery

- **Missing spec.md:** Direct user to `/ideate`
- **Partial scaffold (crashed mid-phase):** Detect existing artifacts, resume from last incomplete phase
- **Package install fails:** Check Node version, suggest `nvm use 20`, retry
- **ORM init fails:** Verify DATABASE_URL format, check if DB server is running
