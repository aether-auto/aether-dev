# Agent Docs Standards

Standards for all files in `.agent-docs/`. Each file must be self-contained, readable without CLAUDE.md, and use tables over prose.

## General Rules

| Rule | Details |
|------|---------|
| Format | Markdown with tables, no HTML |
| Length | 60-180 lines per file |
| Headers | `##` for top-level sections |
| Content source | Extract from spec.md only — never fabricate |
| Self-contained | Each file readable independently |
| No vague terms | Same forbidden list as spec validation |
| No placeholders | All `{placeholder}` patterns must be filled |

## File Standards

### data-models.md

**Source:** spec.md §6, §7

**Required:** Field table per model, relationship diagram (ASCII), constraints summary, index recommendations.

**Field table:** `| Field | Type | Constraints | Default | Description |`

**Relationships:** `User 1──N Project (owner_id FK, ON DELETE CASCADE)` — always include FK column and cascade behavior.

| BAD | GOOD |
|-----|------|
| "Users have many projects" | "User 1──N Project (owner_id FK, ON DELETE CASCADE)" |

### api-specs.md

**Source:** spec.md §7, §8

**Required:** Endpoint summary table, request/response schema per endpoint, auth requirements, error codes.

**Endpoint table:** `| Method | Path | Auth | Description |`

**Detail format per endpoint:**
- Auth requirement, request field table (`| Field | Type | Required | Validation |`), response field table, error codes.

### product-goals.md

**Source:** spec.md §1, §2, §3, §12

**Required:** Product summary (name, problem, value prop), goals table with metrics, persona summary table (`| Persona | Role | Primary Goal | Key Pain Point |`), scope boundaries, anti-goals.

| BAD | GOOD |
|-----|------|
| "The app helps users manage tasks" | "TaskFlow reduces project status meetings by 50% via real-time task visibility for 2-15 person teams" |

### user-flows.md

**Source:** spec.md §5, §4

**Required:** ASCII flow diagrams per journey, step-by-step narratives, screen inventory table (`| Screen | Route | Purpose | Key Elements |`), user story → screen mapping.

**Flow header:** `**Persona:** {who} | **Trigger:** {what} | **Goal:** {outcome}`

### ui-vision.md

**Source:** spec.md §11, §5

**Required:** Design direction statement, principles list, component pattern table (`| Pattern | Usage | Example |`), layout patterns, responsive strategy.

| BAD | GOOD |
|-----|------|
| "The UI should be clean and modern" | "Minimal chrome, high content density. Reference: Linear. Neutral palette, single accent for CTAs. 8px grid." |

### code-style.md

**Source:** spec.md §10, §9

**Required:** Naming conventions table (`| Context | Convention | Example |`), file organization, import ordering, component patterns, error handling, testing conventions.

| BAD | GOOD |
|-----|------|
| "Follow standard naming conventions" | "Components: PascalCase files+exports. One per file. Co-locate: `Button.tsx` + `Button.module.css`" |
