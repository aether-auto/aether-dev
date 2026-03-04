---
name: setup
description: "Use this skill when generating project-level CLAUDE.md and .agent-docs/ from a spec.md. Triggers: 'setup project context', 'generate CLAUDE.md', 'create project docs', 'set up agent docs', 'project setup'."
---

# Setup Skill

Generate a project `CLAUDE.md` and `.agent-docs/` reference files by extracting and expanding content from a completed `spec.md`.

**CLAUDE.md structure guide:** `${SKILL_DIR}/references/claude-md-guide.md`
**Doc standards:** `${SKILL_DIR}/references/doc-standards.md`

## CLAUDE.md Requirements

The generated CLAUDE.md must contain these sections:

| Section | Purpose | Max Lines |
|---------|---------|-----------|
| Project Overview | Name, one-liner, what it does | 10 |
| Tech Stack | Specific frameworks, languages, versions | 15 |
| Common Commands | Dev, test, build, lint — copy-pasteable | 20 |
| Code Style | Naming, imports, patterns, formatting | 25 |
| Architecture | Pattern description, key directories | 20 |
| File Structure | Directory tree with purpose annotations | 25 |
| Agent Doc Imports | `@.agent-docs/*.md` references | 10 |

**Total: ≤200 lines.** Overflow goes into `.agent-docs/` files via @import.

## Quality Rules

**DO:**
- Extract all content from spec.md — never fabricate
- Write concrete, verifiable instructions ("Use camelCase for variables", not "use good naming")
- Make commands copy-pasteable with actual values
- Use tables for structured data (stack, commands, file structure)
- Include only what an agent would get wrong without the file

**DON'T:**
- Include secrets, API keys, or connection strings
- Repeat obvious framework knowledge (e.g., "React uses components")
- Use vague adjectives: user-friendly, scalable, robust, simple, easy, efficient, intuitive
- Leave unfilled placeholders in the final output
- Exceed 200 lines in CLAUDE.md

## .agent-docs/ Files

Generate all 6 files. Each must be self-contained and follow `${SKILL_DIR}/references/doc-standards.md`.

| File | Source Sections | Focus |
|------|----------------|-------|
| `data-models.md` | §6 Models, §7 API | Complete field tables, types, constraints, relationships |
| `api-specs.md` | §7 API, §8 Auth | Every endpoint with method, path, auth, request/response, errors |
| `product-goals.md` | §1-§3, §12 | Goals with metrics, persona summaries, scope boundaries |
| `user-flows.md` | §5 Flows, §4 Stories | Step-by-step flows, screen inventory, user story mapping |
| `ui-vision.md` | §11 UI/UX, §5 Flows | Design direction, component patterns, responsive strategy |
| `code-style.md` | §10 Stack, §9 NFRs | Naming conventions, file org, import rules, linting config |

## Generation Process

1. Read spec.md completely — extract working notes per section
2. Generate all 6 `.agent-docs/` files first (CLAUDE.md @imports them)
3. Generate CLAUDE.md with @imports pointing to the docs
4. Self-review: verify no vague terms, no placeholders, ≤200 lines, all commands runnable
5. Write CLAUDE.md — validation hook will fire

## Output Checklist

Before writing CLAUDE.md, verify:
- [ ] All 7 CLAUDE.md sections present
- [ ] Line count ≤200
- [ ] ≥3 runnable commands in Commands section
- [ ] Tech stack names specific technologies
- [ ] All 6 `.agent-docs/` files written
- [ ] No forbidden vague adjectives
- [ ] No unfilled `{placeholder}` patterns
- [ ] Every instruction traceable to spec.md content
