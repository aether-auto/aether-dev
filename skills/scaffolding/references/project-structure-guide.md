# Project Structure Guide

Standard directory layouts, config files, and naming conventions by stack.

## 1. Directory Layouts

### Next.js (Full-Stack)
```
project-root/
  src/
    app/              # App Router pages + layouts
    components/       # Shared UI components
    lib/              # Utilities, helpers, constants
    server/           # Server-side: API, services, db
      db/             # Schema, migrations, seed
      services/       # Business logic
    types/            # Shared TypeScript types
  public/             # Static assets
  tests/              # unit/, integration/, e2e/
  .github/workflows/
```

### React + Express (Separate Frontend/Backend)
```
project-root/
  client/src/         # React (Vite): components/, pages/, hooks/, lib/, types/
  server/src/         # Express: routes/, controllers/, services/, db/, middleware/, types/
  tests/              # unit/, integration/, e2e/
  .github/workflows/
```

### Monorepo (Turborepo)
```
project-root/
  apps/               # web/ (frontend), api/ (backend)
  packages/           # shared/, ui/, config/
  .github/workflows/
  turbo.json
```

## 2. Config Files

| Config | When | Key Settings |
|--------|------|-------------|
| `tsconfig.json` | Always (TS) | `strict: true`, `paths` aliases, `target: ES2022` |
| `eslint.config.js` | Always | Flat config, framework plugin, import sorting |
| `.prettierrc` | Always | `semi`, `singleQuote`, `trailingComma`, `printWidth: 100` |
| `.env.example` | Always | All env vars with placeholders, never real secrets |
| `.editorconfig` | Always | `indent_style`, `indent_size`, `end_of_line` |
| `vite.config.ts` | Vite | Aliases matching tsconfig paths |
| `next.config.ts` | Next.js | Minimal — add as needed |
| `tailwind.config.ts` | Tailwind | Content paths, theme extensions from spec |

## 3. .gitignore Essentials

| Category | Patterns |
|----------|----------|
| Dependencies | `node_modules/`, `.pnp.*` |
| Build | `dist/`, `.next/`, `build/`, `out/` |
| Environment | `.env`, `.env.local`, `.env.*.local` (keep `.env.example`) |
| IDE / OS | `.vscode/settings.json`, `.idea/`, `.DS_Store`, `Thumbs.db` |
| Testing | `coverage/`, `playwright-report/`, `test-results/` |
| Database | `*.db`, `*.sqlite`, `prisma/*.db` |
| Misc | `*.log`, `*.tsbuildinfo` |

**`.env.example` must NOT be in `.gitignore` — it is committed.**

## 4. Package.json Scripts

| Script | Purpose | Example |
|--------|---------|---------|
| `dev` | Dev server | `next dev` / `vite` / `nodemon` |
| `build` | Production build | `next build` / `tsc && vite build` |
| `start` | Run production | `next start` / `node dist/index.js` |
| `test` | Unit tests | `vitest run` / `jest` |
| `test:watch` | Watch mode | `vitest` / `jest --watch` |
| `test:e2e` | E2E tests | `playwright test` |
| `lint` / `lint:fix` | Lint | `eslint .` / `eslint . --fix` |
| `format` | Format | `prettier --write .` |
| `db:generate` | ORM client | `prisma generate` / `drizzle-kit generate` |
| `db:migrate` | Migrations | `prisma migrate dev` / `drizzle-kit migrate` |
| `db:seed` | Seed data | `tsx src/server/db/seed.ts` |

## 5. Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Component files | PascalCase | `UserProfile.tsx` |
| Utility files | camelCase | `formatDate.ts` |
| Route/page files | kebab-case | `user-profile/page.tsx` |
| Directories | kebab-case | `user-profile/` |
| Env vars | SCREAMING_SNAKE | `DATABASE_URL` |
| DB tables | snake_case plural | `user_profiles` |
| DB columns | snake_case | `created_at` |

## 6. BAD/GOOD Examples

| BAD | GOOD | Why |
|-----|------|-----|
| 5+ levels of nesting | Max 3 levels deep | Deep nesting hinders navigation |
| `utils/helpers/misc.ts` | `lib/format-date.ts` | Name files by purpose |
| No `.env.example` | `.env.example` with all vars | Team needs to know required vars |
| Hardcoded `DB_URL` in code | `DATABASE_URL` from `process.env` | Never hardcode connections |
| Barrel files everywhere | Barrel files only for public API dirs | Avoids circular deps and slow builds |
