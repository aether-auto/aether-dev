---
name: ideation
description: "Use this skill when the user asks to 'ideate', 'brainstorm an app', 'I have an app idea', 'help me plan a web app', 'gather requirements', or 'interview me about my project'. Conducts an adaptive structured interview to produce a comprehensive spec.md."
---

# Ideation Skill

Conduct a structured requirements interview for a web app. Extract enough to produce a complete, unambiguous spec.

**Full question bank:** `${SKILL_DIR}/references/interview-guide.md`

## Interview Stages

1. **Vision & Goals** (Rounds 1-2) — Problem, audience, success metrics. Extract user types, core actions, domain keywords.
2. **Context & Users** (Rounds 2-3) — All user types, personas, usage patterns. 3+ types → Persona Deep-Dive branch.
3. **Core Features** (Rounds 3-5) — Primary workflows, data entities, interactions, edge cases, priorities. Most branches trigger here (real-time, payments, complex data).
4. **Technical Constraints** (Rounds 5-6) — Tech stack, auth, integrations, scale. Present options, don't impose.
5. **Validation** (Final Round) — Summarize everything, get explicit confirmation.

**Rounds:** min 3, max 8, typical 4-6.

## Adaptive Branching

| Signal | Branch | Action |
|--------|--------|--------|
| 3+ user types | Persona Deep-Dive | Permissions per role, role workflows |
| Real-time/live/sync/chat | Architecture Probe | Conflict resolution, offline, update frequency |
| Payment/billing/PII/HIPAA | Security & Compliance | Payment flows, encryption, compliance |
| 2+ integrations | Integration Deep-Dive | Data direction, sync, failure handling |
| 5+ entities/complex relationships | Data Model Deep-Dive | Relationships, cascades, lifecycle |

## Question Rules

**DO:** Reference prior answers (≥60%). Offer concrete options. Front-load critical questions. Use AskUserQuestion for every round. Ask 1-2 questions max per round.

**DON'T:** Lead ("wouldn't X be great?"). Anchor ("most apps use..."). Speculate on unmentioned features. Solution before Stage 4. Combine unrelated questions.

## Handling Vagueness

**Critical gaps** (block and ask): unclear problem statement, no user types, undefined primary workflow, no success criteria. Follow up with concrete options.

**Non-critical gaps** (flag and continue): performance targets, design preferences, integration details, roadmap. Add to Open Questions.

## Research Phase

After interview, before spec generation: 2-4 targeted WebSearch calls.
- Domain-specific data models, API patterns, security considerations, UX patterns
- Max 4 searches, domain-relevant only, no generic queries
- Synthesize into spec sections (don't dump raw results)
- Never override explicit user preferences

## Transition Criteria

ALL must be true before spec generation:
1. ≥3 AskUserQuestion rounds completed
2. All 5 stages touched
3. Core problem statement clear (1-2 sentences)
4. ≥2 distinct personas with roles, goals, pain points
5. Primary workflow defined step-by-step
6. Core data entities identified (2-3 with key fields)
7. User confirmed summary
