---
name: scaffolding
description: "Use this skill when setting up project infrastructure, initializing repositories, creating boilerplate, or scaffolding project structure. Reads spec.md to determine stack and generates appropriate project skeleton with testing, database, and CI/CD infrastructure."
---

# Scaffolding Skill

Set up complete project infrastructure from a spec.md. Every decision derives from the spec — never assume a stack.

**Project structure patterns:** `${SKILL_DIR}/references/project-structure-guide.md`
**Infrastructure patterns:** `${SKILL_DIR}/references/infra-setup-guide.md`

## Reading spec.md

Extract these sections before generating anything:

| Section | Extracts | Drives |
|---------|----------|--------|
| 1. Overview | App name, one-liner | CLAUDE.md header, package name |
| 6. Data Models | Entities, fields, types, relationships | DB schema, seed file |
| 8. Auth | Method, roles, permissions | Auth config, middleware scaffold |
| 10. Tech Stack | Frontend, backend, DB, ORM, infra | Every scaffold decision |

**STOP** if section 10 is missing or empty. Cannot scaffold without stack info.

## Phase Order

Execute strictly in order. Each phase depends on the previous.

1. **Git** — `git init`, `.gitignore`, initial commit structure
2. **Project** — Directory layout, package.json, configs, CLAUDE.md files
3. **Testing** — Test runner, directory structure, example tests
4. **Database** — ORM setup, initial schema from spec, seed scaffold
5. **CI/CD** — GitHub Actions workflows, Husky + lint-staged + commitlint

## Stack Decision Tree

| Spec Says | Scaffold |
|-----------|----------|
| Next.js | App Router layout, `next.config.ts`, server dir inside `src/` |
| React + separate backend | `client/` + `server/` split, Vite for client |
| Express / Fastify | `server/src/` with routes, controllers, services, middleware |
| Prisma | `npx prisma init`, translate section 6 to `.prisma` schema |
| Drizzle | Install packages, translate section 6 to TS schema in `src/server/db/` |
| PostgreSQL | `.env.example` with `DATABASE_URL=postgresql://...` |
| MongoDB | `.env.example` with `MONGODB_URI=mongodb://...` |
| Monorepo mentioned | Turborepo structure: `apps/` + `packages/` |

## Config Requirements

Every scaffolded project MUST have:

| File | Non-Negotiable |
|------|---------------|
| `.gitignore` | Stack-appropriate, includes `node_modules/`, `.env`, build dirs |
| `package.json` | All scripts: `dev`, `build`, `test`, `lint`, `format`, `db:*` |
| `tsconfig.json` | `strict: true`, path aliases matching project structure |
| `eslint.config.js` | Flat config format, framework plugin |
| `.prettierrc` | Team-consistent formatting |
| `.env.example` | Every env var with placeholder value |
| `.editorconfig` | Indent, charset, EOL settings |
| `CLAUDE.md` | Root + every new subdirectory |

## CLAUDE.md Rules

**Root CLAUDE.md** includes: project name, tech stack, all commands, project structure map, conventions, environment setup instructions.

**Subdirectory CLAUDE.md** includes: folder purpose, what files belong here, folder-specific patterns.

Create a subdirectory CLAUDE.md for every directory that contains source code or configuration.

## BAD/GOOD

| BAD | GOOD | Why |
|-----|------|-----|
| Scaffold React when spec says Next.js | Read section 10 first, scaffold exactly what it says | Spec is source of truth |
| `npm install` 20 packages upfront | Install only what this phase needs | Avoid unused dependencies |
| Skip `.env.example` | Always create with all required vars | Team onboarding depends on it |
| Hardcode `localhost:5432` in db config | Use `process.env.DATABASE_URL` | Environment-specific values in env vars |
| Create empty directories | Every directory has at least one file or `.gitkeep` | Git doesn't track empty dirs |
| Giant root CLAUDE.md with everything | Root = overview + commands; subdirs = specific guidance | Keep context local and focused |
| No initial commit after git init | Commit after each phase completes | Clean git history from the start |
