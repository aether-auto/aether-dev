# Startup Prompt — aether-dev Plugin: Next Command Implementation

Copy everything below the line into a new Claude Code session. Replace `{COMMAND}` with the command you're implementing (e.g., `setup`, `gen-tasks`, `ui-specs`, `scaffold`, `build`, `review`).

---

## Context

You are continuing development of the `aether-dev` Claude Code plugin at `/Users/arnavmarda/Desktop/Dev/aether-dev/`. This is a self-contained, reusable software development workflow plugin with phases: ideation → setup → gen-tasks → ui-specs → scaffold → build → review.

You are implementing the **`/{COMMAND}`** command.

### Existing plugin structure

Read the current file tree before starting:
```bash
find /Users/arnavmarda/Desktop/Dev/aether-dev -not -path '*/task-manager-spec/*' -not -path '*/.git/*' -not -path '*/.claude/*' -not -path '*/node_modules/*' -type f | sort
```

**DO NOT modify any existing files** unless the new command requires adding a hook entry to `hooks/hooks.json` (append only).

## Required Reading

Before writing any plans or code, read ALL of these to understand existing patterns:

1. **`workflow.md`** — Master workflow. Find the `{COMMAND}` section and the §Project Memory section. These are your requirements.
2. **`commands/ideate.md`** — Command pattern: frontmatter format, HARD-GATE rules, phased execution, skill invocation via `aether-dev:{skill}`, hook integration.
3. **`skills/ideation/SKILL.md`** — Skill pattern: YAML frontmatter (name + description trigger phrases), concise body (~60-100 lines), delegating detail to `${SKILL_DIR}/references/`.
4. **`hooks/hooks.json` + `hooks/scripts/validate-spec.sh`** — Hook pattern: PostToolUse matcher, bash script reading JSON from stdin, `additionalContext` JSON output, always exit 0.
5. **`skills/ideation/references/`** — Reference file pattern: focused, standalone docs loaded on demand. Tables over prose. ~60-180 lines each.
6. **`.claude-plugin/plugin.json`** — Plugin namespace (`aether-dev`). Do not modify.

## Research Requirements

**You MUST use WebSearch before writing your plan.** Conduct 3-5 targeted searches for academic, professional, and industry sources relevant to the `{COMMAND}` phase. Examples of what to search for:

- Standards or frameworks applicable to this phase (IEEE, ISO, industry methodologies)
- Best practices from professional sources (Atlassian, Thoughtworks, Martin Fowler, etc.)
- Claude Code-specific patterns if relevant (plugin design, CLAUDE.md structuring, hook patterns)
- Real-world approaches to the core problem this command solves

**Rules:**
- Every search must be specific to the command's domain — no generic "how to build plugins" searches
- Synthesize findings into your design decisions and rationale — do not dump raw results
- Cite which research informed which design decision in your plan

## Architecture Constraints

Derived from Phase 1 patterns — follow these exactly:

| Component | Pattern | Reference |
|-----------|---------|-----------|
| Commands | Orchestrators: frontmatter, phases, skill invocation, hook handling | `commands/ideate.md` |
| Skills | Lean SKILL.md (~60-100 lines) + `references/` for detail | `skills/ideation/SKILL.md` |
| Hooks | Bash, JSON stdin/stdout, `additionalContext` feedback, exit 0 always | `hooks/scripts/validate-spec.sh` |
| References | Focused standalone docs, tables over prose, ~60-180 lines | `skills/ideation/references/` |

**File budget per command:** 1 command + 1 skill + 1-2 references + 0-1 hook/script + 0-1 utility script. Roughly 5-7 new files.

**Quality bar:**
- Keep files concise. Ideation phase averages ~100 lines per file.
- Every rule must be actionable — no filler prose.
- BAD/GOOD examples where behavior could be ambiguous.
- Tables over paragraphs for structured information.

## Deliverables

1. **Plan** — File list with per-file purpose, key design decisions table (decision/choice/rationale), verification steps.
2. **Implementation** — All files, after plan approval.
3. **Verification** — Test hooks against sample inputs, verify directory structure, confirm registration.

## Process

1. Enter plan mode
2. Read all 6 required files above
3. Read the `{COMMAND}` section of `workflow.md` carefully
4. Execute 3-5 web searches (research requirements above)
5. Write plan incorporating research findings + existing patterns
6. Present plan for approval
7. Implement after approval
8. Verify hooks and structure

Do NOT skip the research phase. Do NOT write verbose files — match the conciseness of the existing codebase.
