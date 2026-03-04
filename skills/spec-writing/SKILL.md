---
name: spec-writing
description: "Use this skill when generating product specifications, requirements documents, or feature specs. Ensures concrete, measurable, unambiguous writing meeting IEEE 29148 quality characteristics."
---

# Spec Writing Skill

Every statement must be **testable**. If you can't write a verification for it, it's not a requirement.

**Per-section guidance:** `${SKILL_DIR}/references/section-guide.md`

## BAD → GOOD

| BAD | GOOD | Why |
|-----|------|-----|
| "Should be fast" | "API responses < 500ms p95 under 100 concurrent users" | Metric + threshold + conditions |
| "Easily find things" | "Search returns results in < 2s; filter by category, date, status" | Observable behavior + capabilities |
| "Handle errors gracefully" | "On API failure: error toast with message + Retry button, auto-dismiss 5s" | Exact behavior, elements, timing |
| "Should be secure" | "All endpoints require JWT. Tokens expire 24h. Passwords: bcrypt cost 12" | Specific tech, values, constraints |
| "Intuitive UI" | "Onboarding (3 steps) completes in < 2min. Primary action uses filled button" | Measurable outcome + pattern |

## Style Rules

- **Active voice, present tense, third person.** "The system sends" not "should be sent."
- **Quantify everything.** No "several", "quickly", "many" — use numbers.
- **Name things.** Specific field names, screen names, button labels.
- **One requirement per statement.** Don't combine behaviors.
- **Tables** for structured data. **Numbered lists** for sequences.

## Forbidden Language

Never use without a measurable qualifier:

| Term | Replace With |
|------|-------------|
| user-friendly | Specific UI behavior or usability metric |
| scalable | Specific capacity numbers |
| robust | Specific error handling behaviors |
| simple / easy | Step count or time-to-completion |
| efficient | Performance metric (time, memory) |
| intuitive | Discoverability metric or named UI pattern |
| seamless | Specific transition behavior |
| flexible / powerful | Specific capabilities |

## Section Patterns

**User Stories:** `As a {persona from §3}, I want to {observable action} so that {measurable benefit}.`
- BAD: "As a user, I want to manage data so that things work better."
- GOOD: "As a Project Manager, I want to archive completed projects so that my active list shows only in-progress work."

**Acceptance Criteria:** `Given {precondition}, when {action}, then {observable outcome}.`
- BAD: "Given logged in, when they do stuff, then it works."
- GOOD: "Given a Team Member on the board, when they drag a card to 'In Progress', then status updates and card moves within 500ms."

**APIs:** method, path, description, auth, request body (typed), response (with status codes). Plural nouns (`/api/projects`). Include error responses.

**Data Models:** field name, type, constraints, description. Every model: id, created_at, updated_at. Explicit FKs. Enum values listed.

**NFRs:** specific + measurable + conditions. Not "fast and reliable" → "< 500ms p95, 99.9% uptime monthly, RTO < 1h."

## Self-Review

1. Can I write a test for every statement?
2. Are all numbers explicit?
3. Are behaviors described, not just features?
4. Do all cross-references resolve?
5. Any forbidden language remaining?
