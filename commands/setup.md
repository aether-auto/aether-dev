---
description: "Generate project-level CLAUDE.md and supporting docs from a completed spec.md"
argument-hint: "[path to spec.md — defaults to ./spec.md]"
---

# /setup — Project Context Generation

Generate a project `CLAUDE.md` and `.agent-docs/` reference files from the completed `spec.md`.

**Spec path:** $ARGUMENTS (default: `./spec.md`)

## <HARD-GATE>

1. **MUST read spec.md first.** Cannot generate any docs without ingesting the spec.
2. **MUST NOT fabricate info** absent from spec.md. Unknown details → omit or mark TBD.
3. **MUST write CLAUDE.md** to the project root to trigger the validation hook.
4. **MUST generate all `.agent-docs/` files** before writing CLAUDE.md (it @imports them).
5. **MUST keep CLAUDE.md ≤200 lines.** Use `@.agent-docs/<file>.md` imports for detail.

</HARD-GATE>

## Phase 1: Spec Ingestion

Read `spec.md` (or user-specified path). Verify it exists and contains the 13 required sections.

**Extract into working notes (internal — don't show user):**

| Extract | Source Section |
|---------|---------------|
| App name, one-liner, problem | §1 Overview |
| Goals, metrics, anti-goals | §2 Goals |
| Personas (names, roles) | §3 Personas |
| User stories (priorities) | §4 Stories |
| Screens, flows | §5 Flows |
| Data models, relationships | §6 Models |
| API endpoints, error format | §7 API |
| Auth method, permissions | §8 Auth |
| NFRs (performance, a11y) | §9 NFRs |
| Tech stack, architecture | §10 Stack |
| UI vision, design direction | §11 UI/UX |
| Scope (in/out) | §12 Scope |
| Open questions | §13 Open |

If spec.md is missing or incomplete, stop and tell the user to run `/ideate` first.

## Phase 2: Supporting Docs Generation

Use the `aether-dev:setup` skill. Follow its process exactly.

Read doc standards: `${CLAUDE_PLUGIN_ROOT}/skills/setup/references/doc-standards.md`

Generate these files in `.agent-docs/`:

| File | Content Source | Key Rules |
|------|---------------|-----------|
| `data-models.md` | §6, §7 | Full field tables, relationships diagram, constraints |
| `api-specs.md` | §7, §8 | All endpoints, request/response schemas, auth requirements |
| `product-goals.md` | §1, §2, §3, §12 | Goals table, persona summaries, scope boundaries |
| `user-flows.md` | §5, §4 | Step-by-step flows, screen inventory, story mapping |
| `ui-vision.md` | §11, §5 | Design direction, component patterns, responsive strategy |
| `code-style.md` | §10, §9 | Naming conventions, file organization, import patterns, linting |

Each file must be self-contained and follow the standards in `doc-standards.md`.

## Phase 3: CLAUDE.md Generation

Read the structure guide: `${CLAUDE_PLUGIN_ROOT}/skills/setup/references/claude-md-guide.md`

Generate `CLAUDE.md` at project root with:
- Project overview (name, one-liner, stack)
- Tech stack with specific versions/choices
- Common commands (dev, test, build, lint — copy-pasteable)
- Code style rules (naming, imports, patterns)
- Architecture summary (2-3 sentences + key directories)
- File structure overview
- `@.agent-docs/<file>.md` imports for each generated doc

**Quality rules:**
- Every instruction must be concrete and verifiable
- Commands must be copy-pasteable (no placeholders)
- No vague adjectives (same rules as spec validation)
- Tables over prose where possible

## Phase 4: Validation & Delivery

1. Write `CLAUDE.md` — validation hook fires automatically.
2. **Errors in hook feedback:** fix and re-write (hook runs again). **Warnings:** fix if appropriate.
3. If errors persist after 3 attempts, present CLAUDE.md with note about remaining issues.

**Present summary:**
```
## Setup Complete: {App Name}

**CLAUDE.md:** {line count} lines
**Agent docs generated:**
- .agent-docs/data-models.md — {model count} models
- .agent-docs/api-specs.md — {endpoint count} endpoints
- .agent-docs/product-goals.md — {goal count} goals, {persona count} personas
- .agent-docs/user-flows.md — {flow count} flows, {screen count} screens
- .agent-docs/ui-vision.md — design direction + component patterns
- .agent-docs/code-style.md — naming + file organization rules

Next step: Run `/gen-tasks` to generate the task backlog.
```

## Error Recovery

- **No spec.md found:** Tell user to run `/ideate` first or provide the path.
- **Incomplete spec.md:** List missing sections, suggest re-running `/ideate`.
- **User wants changes:** Edit the specific file(s) requested. Re-run CLAUDE.md validation if CLAUDE.md was changed.
