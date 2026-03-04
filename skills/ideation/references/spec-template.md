# {App Name} — Product Requirements Specification

> **Version:** 1.0 | **Date:** {YYYY-MM-DD} | **Status:** Draft

## 1. Overview & Problem Statement

**Product Name:** {App Name}
**One-Liner:** {A single sentence — what it does and for whom.}
**Problem Statement:** {Who} experiences {pain point} when trying to {activity}. Currently, they {workaround}, which results in {negative outcome}. {App Name} solves this by {value proposition}.
**Background:** {2-3 paragraphs of market context.}

## 2. Goals & Success Metrics

| # | Goal | Metric | Target | Timeframe |
|---|------|--------|--------|-----------|
| G-001 | {Goal} | {Metric} | {Target} | {Timeframe} |

**Anti-Goals:** This product will NOT {anti-goal 1}. Will NOT {anti-goal 2}.

## 3. Users & Personas

For each persona, provide a table:

| Attribute | Details |
|-----------|---------|
| **Role** | {Role} |
| **Demographics** | {Age range, tech comfort} |
| **Goals** | {What they want to achieve} |
| **Pain Points** | {Current frustrations} |
| **Usage Frequency** | {Daily / Weekly / Monthly} |

## 4. User Stories

| ID | Story | Priority | AC |
|----|-------|----------|----|
| US-001 | As a {persona}, I want to {action} so that {benefit}. | Must Have | AC-001 |

**Acceptance Criteria:** `AC-NNN:` Given {precondition}, when {action}, then {result}.

## 5. User Flows & Screens

### Flow format:
```
[Screen A] → {action} → [Screen B] → {action} → [Screen C]
                                        ↓ {error}
                                    [Error State]
```
Step-by-step narrative for each flow.

**Screen Inventory:**

| Screen | Purpose | Key Elements | Accessed From |
|--------|---------|--------------|---------------|
| {Screen} | {Purpose} | {Elements} | {Path} |

## 6. Data Models

Per model, include field table:

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, auto-generated | Unique identifier |
| {field} | {type} | {constraints} | {Description} |
| created_at | DateTime | auto-generated | Creation timestamp |
| updated_at | DateTime | auto-updated | Last modified |

**Relationships:** `{Model 1} 1──N {Model 2}` / `{Model 2} N──M {Model 3} (via join table)`

## 7. API Specifications

| Method | Path | Description | Auth | Request Body | Response |
|--------|------|-------------|------|-------------|----------|
| POST | /api/{resource} | Create | Required | `{ field1, field2 }` | `201: { id, ...fields }` |
| GET | /api/{resource} | List | Required | — | `200: [{ id, ...fields }]` |
| GET | /api/{resource}/:id | Get by ID | Required | — | `200: { id, ...fields }` |
| PUT | /api/{resource}/:id | Update | Required | `{ field1? }` | `200: { id, ...fields }` |
| DELETE | /api/{resource}/:id | Delete | Required | — | `204` |

**Error Format:** `{ "error": { "code": "CODE", "message": "msg", "details": {} } }`

| Code | Status | Description |
|------|--------|-------------|
| UNAUTHORIZED | 401 | Missing/invalid auth |
| FORBIDDEN | 403 | Insufficient permissions |
| NOT_FOUND | 404 | Resource doesn't exist |
| VALIDATION_ERROR | 422 | Validation failed |

## 8. Authentication & Authorization

**Method:** {e.g., JWT with email/password}
**Flow:** User submits credentials → server validates → returns token → client stores → included in subsequent requests.

**Permissions:**

| Permission | {Role 1} | {Role 2} | {Role 3} |
|------------|----------|----------|----------|
| {Action} | Yes/No | Yes/No | Yes/No |

**Security:** {token expiry}, {refresh strategy}, {rate limiting}

## 9. Non-Functional Requirements

**Performance:** Page load < {target}; API p95 < {target}; concurrent users: {N}
**Reliability:** Uptime {target}; backup {freq}; RTO < {time}
**Accessibility:** WCAG {level}; screen reader: {Y/N}; keyboard nav: {Y/N}
**Browsers:** {list}  |  **Devices:** {list}; min viewport: {px}

## 10. Tech Stack & Architecture

**Frontend:** {framework}, {language}, {styling}, {state management}
**Backend:** {runtime}, {framework}, {language}
**Database:** {DB}, {ORM}, {caching}
**Infrastructure:** {hosting}, {auth provider}, {file storage}, {email}
**Architecture:** {pattern description — 2-3 sentences}

## 11. UI/UX Vision

**Design Direction:** {2-3 sentences — visual feel, reference apps}
**Principles:** 1. {P1}  2. {P2}  3. {P3}
**Patterns:** Nav: {pattern}; Layout: {pattern}; Forms: {pattern}; Feedback: {pattern}
**Responsive:** {strategy}

## 12. Scope

**In Scope (MVP):** {bulleted feature list}
**Out of Scope (Post-MVP):** {feature — reason} per item
**Future Considerations:** {feature list}

## 13. Open Questions & Assumptions

| # | Question | Impact | Owner | Status |
|---|----------|--------|-------|--------|
| Q-001 | {Question} | {Impact} | {Owner} | Open |

| # | Assumption | Risk if Wrong |
|---|-----------|---------------|
| A-001 | {Assumption} | {Risk} |
