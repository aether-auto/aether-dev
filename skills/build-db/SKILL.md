---
name: build-db
description: "Use this skill when acting as the Database agent during /build. Handles schema changes, migrations, seed data, and query optimization for ticket implementation."
---

# Build DB Skill

Implement database changes needed for ticket features. Migrations must be reversible, seeds must be idempotent.

## Responsibilities

- Create or modify database schema (tables, columns, indexes, constraints)
- Write migrations using the project's ORM (Prisma, Drizzle, etc.)
- Create or update seed data for development/testing
- Optimize queries if performance is part of the ticket
- Run migrations and verify schema state
- Report completion to team lead

## Input

- Failing test file paths showing expected data operations
- Data model specs from `.agent-docs/data-models.md`
- Project `CLAUDE.md` for ORM patterns and DB conventions
- Existing schema files for consistency

## Output

- Migration files in the project's migration directory
- Updated schema/model definitions
- Seed data if needed
- Completion report via SendMessage to team lead

## Migration Rules

| BAD | GOOD | Why |
|-----|------|-----|
| Modify existing migration file | Create new migration | Preserves history |
| `DROP TABLE` without backup | Rename → create new → migrate data | Data safety |
| No down migration | Include reversible `down()` | Rollback capability |
| Hardcoded IDs in seeds | Use generated or sequential IDs | Idempotency |
| Missing index on FK | Add index for all foreign keys | Query performance |

## Rules

**DO:**
- Create one migration per logical schema change
- Name migrations descriptively: `add_avatar_to_users`, `create_projects_table`
- Add indexes for columns used in WHERE, JOIN, ORDER BY
- Include NOT NULL constraints with sensible defaults
- Write idempotent seed data (safe to run multiple times)
- Validate migration runs both up and down

**DON'T:**
- Modify production-like data in migrations — use seeds
- Create circular foreign key dependencies
- Add columns without specifying nullable/default behavior
- Skip unique constraints where business logic requires uniqueness
- Forget to update TypeScript types after schema changes

## Coordination

- Receive requirements from testing agent or backend agent
- Coordinate with backend agent on model types and query patterns
- Report schema changes to team lead
- Flag if migration requires data backfill
