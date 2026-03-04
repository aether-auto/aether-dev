# Section Writing Guide

Per-section guidance: what to include, one good example, key pitfalls, and minimum checklist.

---

## §1. Overview & Problem Statement

**Include:** app name, one-liner (audience + value), problem statement (who/pain/workaround/outcome), 2-3 paragraphs background.

**Example problem statement:**
> Freelance team leads spend 4+ hours/week switching between Trello, Toggl, and FreshBooks. Data is siloed — completing a task doesn't log time or trigger invoicing. TaskFlow unifies this into a single workflow.

**Pitfalls:** Too abstract ("helps productivity"), feature-first instead of problem-first, no gap specificity.
**Checklist:** App named; one-liner names audience+value; problem has WHO/PAIN/WORKAROUND/OUTCOME; background provided.

---

## §2. Goals & Success Metrics

**Include:** 3-5 goals with metric/target/timeframe table, ≥2 anti-goals.

**Example:**
| # | Goal | Metric | Target | Timeframe |
|---|------|--------|--------|-----------|
| G-001 | Reduce admin time | Weekly hours on admin | < 1h (from 4+) | 3mo post-launch |

**Pitfalls:** Vanity metrics (signups without retention), no timeframe, unmeasurable goals, missing anti-goals.
**Checklist:** ≥3 goals with numeric targets + timeframes; ≥2 anti-goals.

---

## §3. Users & Personas

**Include:** ≥2 personas, each with: role, demographics, goals, pain points, usage frequency.

**Pitfalls:** Generic "User"/"Admin", missing pain points, overlapping personas, >4-5 personas.
**Checklist:** ≥2 distinct personas; each has all 5 attributes; every persona referenced in stories exists here.

---

## §4. User Stories

**Include:** ≥5 stories (As a/I want/So that), unique IDs, MoSCoW priority, ≥5 acceptance criteria (Given/When/Then).

**Example:**
> US-003: As a Team Lead, I want to mark a task complete and auto-calculate billable time so that I don't manually transfer time data.
> AC-003: Given a task with time entries, when they click "Complete Task", then status→Completed, billable time calculated, line item added to draft invoice. Given no time entries, when clicking "Complete Task", then warning modal: "No time tracked. Complete anyway?"

**Pitfalls:** "As a user" (use persona name), vague benefits, missing error/edge ACs, compound stories.
**Checklist:** ≥5 stories with IDs + priority; ≥5 ACs in Given/When/Then; error paths covered.

---

## §5. User Flows & Screens

**Include:** ≥2 flows with ASCII diagrams + steps, screen inventory table.

**Example:**
```
[Login] → creds → [Dashboard] → click project → [Board] → "New Task" → [Modal] → save → [Board]
```

| Screen | Purpose | Key Elements | Accessed From |
|--------|---------|--------------|---------------|
| Board | Kanban task view | Columns, draggable cards, "New Task" btn | Dashboard → project |

**Pitfalls:** Missing error states, orphan screens, no navigation description.
**Checklist:** ≥2 flows with diagrams; screen inventory covers all referenced screens.

---

## §6. Data Models

**Include:** ≥2 models with field/type/constraints/description tables, relationship diagram.

**Example:**
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK | Identifier |
| name | string | required, max 100 | Display name |
| status | enum | values: active, archived | State |
| owner_id | UUID | FK → User.id | Owner |

```
User 1──N Project; Project 1──N Task; Task 1──N TimeEntry
```

**Pitfalls:** Missing id/timestamps, untyped fields, no constraints, implicit relationships.
**Checklist:** ≥2 models; each has id/created_at/updated_at; all fields typed+constrained; explicit FKs; enum values listed; relationship diagram.

---

## §7. API Specifications

**Include:** ≥3 endpoints with method/path/description/auth/request/response, error format.

**Example:**
| Method | Path | Auth | Request | Response |
|--------|------|------|---------|----------|
| POST | /api/projects | Team Lead | `{name: string, rate: number}` | `201: {id, name, rate, status}` |
| GET | /api/projects | Required | `?status=active&page=1` | `200: {data: [], total, page}` |

**Pitfalls:** Missing auth column, no error responses, inconsistent naming (singular/plural), no pagination.
**Checklist:** ≥3 endpoints; each has method+path+auth+types; CRUD for core entities; error format defined.

---

## §8. Authentication & Authorization

**Include:** auth method, flow steps, permission matrix, security considerations.

**Example matrix:**
| Permission | Lead | Member | Viewer |
|------------|------|--------|--------|
| Create project | Yes | No | No |
| View project | Own | Assigned | Invited |

**Pitfalls:** Auth without authz, missing token lifecycle, role name mismatch with §3.
**Checklist:** Method specified; flow described; permission matrix covers all §3 roles; token expiry+refresh defined.

---

## §9. Non-Functional Requirements

**Include:** performance (with conditions), reliability, accessibility (WCAG level), browser/device support.

**Example:** Page load < 2s on 4G; API < 500ms p95 under 100 users; 99.9% uptime monthly.

**Pitfalls:** No conditions ("fast"), no measurement method, missing accessibility, unrealistic targets.
**Checklist:** Performance with numbers+conditions; uptime target; WCAG level; browser versions listed.

---

## §10. Tech Stack & Architecture

**Include:** frontend/backend/database/infrastructure specifics, architecture pattern (2-3 sentences).

**Pitfalls:** Incompatible choices, no rationale, no architecture pattern, overengineering for MVP.
**Checklist:** Framework+language+styling; backend+DB+ORM; hosting; architecture described; choices compatible.

---

## §11. UI/UX Vision

**Include:** design direction (with reference apps), ≥3 principles, patterns (nav/layout/forms/feedback), responsive strategy.

**Example:** "Clean, professional, Linear-like. Monochrome base, accent colors for status. Information-dense, type-heavy."

**Pitfalls:** "Modern and clean" (vs what?), no reference apps, no responsive strategy, no feedback patterns.
**Checklist:** Direction with references; ≥3 principles; nav+layout+forms+feedback patterns; responsive strategy.

---

## §12. Scope

**Include:** ≥5 MVP features, ≥3 out-of-scope with reasons, ≥2 future considerations.

**Pitfalls:** Vague in-scope ("management features"), out-of-scope without reasons, scope doesn't match stories.
**Checklist:** ≥5 specific MVP features; ≥3 out-of-scope with reasons; ≥2 future items; Must Have stories match in-scope.

---

## §13. Open Questions & Assumptions

**Include:** ≥1 question with impact, ≥1 assumption with risk-if-wrong.

**Example:**
| Q-001 | Will team plans have free trials? | Affects billing flow — trial needs limited access without payment | Open |
| A-001 | Reliable internet (no offline) | Would need service worker + conflict resolution (+2-3 weeks) |

**Pitfalls:** Lazy questions (should've asked in interview), assumptions without risks, >5-7 questions.
**Checklist:** ≥1 question with impact; ≥1 assumption with risk; all genuinely unresolvable at spec time.
