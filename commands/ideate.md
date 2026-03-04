---
description: "Conduct an adaptive interview to turn a web app idea into a comprehensive spec.md"
argument-hint: "[your web app idea - can be vague or detailed]"
---

# /ideate — Ideation & Spec Generation

Turn a web app idea into a complete `spec.md` through structured interview and research.

**User's idea:** $ARGUMENTS

## <HARD-GATE>

1. **MUST interview using AskUserQuestion.** Cannot generate spec from initial idea alone.
2. **MUST complete ≥3 rounds** before any spec content.
3. **MUST NOT speculate** on unprovided info. Critical unknowns → ask. Non-critical → Open Questions.
4. **MUST NOT skip self-review.** Every spec: Extract → Draft → Self-Review.
5. **MUST write to `spec.md`** (or user-specified path ending in `spec.md`) to trigger validation hook.

</HARD-GATE>

## Phase 1: Adaptive Interview

Use the `aether-dev:ideation` skill. Follow its process exactly.

**Rules:**
- 1-2 questions per AskUserQuestion call
- ≥60% questions reference prior answers
- Detect branching signals (3+ user types, real-time, payments, 2+ integrations, complex data)
- Track stage coverage internally (Vision → Users → Features → Technical → Validation)
- Final round: summary confirmation

**Transition — ALL must be true:**
1. ≥3 rounds completed
2. All 5 stages touched
3. Clear problem statement
4. ≥2 personas with roles/goals/pain points
5. Primary workflow defined step-by-step
6. Core entities identified (2-3 with fields)
7. User confirmed summary

## Phase 1.5: Targeted Research

After interview, silently conduct 2-4 WebSearch calls:
- Domain-specific data models, API patterns, security considerations, UX patterns
- Max 4 searches, domain-relevant only, no generic queries
- Synthesize into spec sections (data models → §6, APIs → §7, security → §8/§9, UX → §5/§11)
- Never override user's explicit preferences

## Phase 2: Spec Generation (Three-Stage Chain)

Internal process — don't show intermediate stages.

### Stage 1: Extract
Map every interview answer + research finding to spec sections. Verify every section has ≥1 source. Sections with no source → fill with reasonable defaults, note in §13.

### Stage 2: Draft
Read template: `${CLAUDE_PLUGIN_ROOT}/skills/ideation/references/spec-template.md`

Use `aether-dev:spec-writing` skill for quality. Fill every section:
- Replace all `{placeholders}` with real content
- Exact formats: "As a/I want/So that", "Given/When/Then", tables for models+permissions
- Name everything: fields, screens, buttons, error messages
- Cross-references consistent: persona names, screen names, field names across sections

### Stage 3: Self-Review
Read checklist: `${CLAUDE_PLUGIN_ROOT}/skills/ideation/references/validation-checklist.md`

Verify all automated checks will pass (13 sections, ≥5 stories, ≥5 ACs, ≥3 endpoints, ≥2 models, scope sections, no forbidden adjectives). Verify semantic checks (persona/screen/role consistency, tech compatibility, model completeness). Fix issues before writing.

## Phase 3: Validation & Delivery

1. Write `spec.md` — hook fires automatically
2. **Errors in hook feedback:** fix and re-write (hook runs again). **Warnings:** fix if appropriate.
3. If errors persist after 3 attempts, present spec with note about remaining issues.

**Present summary:**
```
## Spec Generated: {App Name}
**File:** spec.md
- Personas: {count} ({names})
- User Stories: {count} ({Must/Should/Could breakdown})
- API Endpoints: {count}
- Data Models: {count} ({names})
- Tech Stack: {key choices}
- Open Questions: {count}
```

## Error Recovery

- **"Start over"**: Reset completely, begin Round 1.
- **Detailed brief provided**: Still interview (min 3 rounds): confirm brief, ask about gaps, validate priorities.
- **User frustrated with questions**: Consolidate remaining into 1-2 final rounds. Flag gaps as Open Questions.
