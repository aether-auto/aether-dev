# CLAUDE.md Structure Guide

## Required Sections

Every generated CLAUDE.md must include these sections in order:

| # | Section | Purpose | Source | Max Lines |
|---|---------|---------|--------|-----------|
| 1 | Project Overview | Name, one-liner, problem, audience | §1 | 10 |
| 2 | Tech Stack | Frameworks, languages, DB, infra | §10 | 15 |
| 3 | Common Commands | Dev, test, build, lint, db | §10 + inference | 20 |
| 4 | Code Style | Naming, imports, formatting | §10 + §9 | 25 |
| 5 | Architecture | Pattern, layers, data flow, key dirs | §10 + §6 | 20 |
| 6 | File Structure | Directory tree with annotations | §10 + inference | 25 |
| 7 | Agent Doc Imports | @import lines to .agent-docs/ | Generated docs | 10 |

**Hard limit: ≤200 lines total.** Overflow goes to `.agent-docs/`.

## Section Templates

### 1. Project Overview
```markdown
# {App Name}
{One-liner from spec §1.}
**Problem:** {Who, pain point, workaround, solution.}
**Users:** {Persona names and roles, comma-separated.}
**Status:** Setup complete — pre-development.
```

### 2. Tech Stack
```markdown
## Tech Stack
| Layer | Technology |
|-------|-----------|
| Frontend | {framework} + {language} + {styling} |
| Backend | {runtime} + {framework} |
| Database | {DB} + {ORM} |
| Auth | {provider/method} |
| Hosting | {platform} |
| Testing | {test framework} |
```

### 3-6. Commands / Code Style / Architecture / File Structure
- **Commands:** Table of `| Command | Purpose |` from package.json scripts
- **Code Style:** Naming conventions, import ordering, component patterns, error handling, formatter config
- **Architecture:** 2-3 sentence pattern + key directories with purposes
- **File Structure:** Annotated directory tree

### 7. Agent Doc Imports
```markdown
## Reference Docs
@.agent-docs/data-models.md
@.agent-docs/api-specs.md
@.agent-docs/product-goals.md
@.agent-docs/user-flows.md
@.agent-docs/ui-vision.md
@.agent-docs/code-style.md
```

## Quality Examples

| Section | BAD | GOOD |
|---------|-----|------|
| Overview | "TaskFlow is a project management app." | "TaskFlow — Real-time collaborative task management for small teams (2-15 people) replacing spreadsheet workflows." |
| Tech Stack | "Frontend: React, Backend: Node" | "Frontend: Next.js 14 + TypeScript 5.3 + Tailwind CSS 3.4" |
| Commands | "Run the dev server using the appropriate command" | "`npm run dev` — Start Next.js dev server on port 3000" |
| Code Style | "Use good naming conventions" | "Variables: camelCase. Components: PascalCase. Files: kebab-case. DB columns: snake_case." |
| Architecture | "Modern architecture that is scalable and robust" | "Three-layer: Next.js App Router (presentation) → tRPC (business logic) → Prisma (data access). Server components by default." |

## Anti-Patterns

| Anti-Pattern | Fix |
|-------------|-----|
| Vague adjectives ("Scalable API") | Name the pattern: "Stateless REST behind Vercel serverless" |
| Obvious knowledge ("React uses JSX") | Only include project-specific info |
| Secrets in CLAUDE.md | Use `.env`, reference var names only |
| 300+ line CLAUDE.md | Move detail to `.agent-docs/` with @imports |
| Placeholder commands | Derive actual commands from spec's tech stack |
| Missing @imports | Always include the 6 standard @import lines |

## @import Syntax

Use bare `@` references on their own line: `@.agent-docs/data-models.md`
- One import per line, path relative to project root
- All 6 `.agent-docs/` files must be imported
