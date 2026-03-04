# Spec Validation Checklist

## Automated Checks (Hook Script)

Runs on every `*spec.md` write. Errors must be fixed; warnings are non-blocking.

### Structural

| # | Check | Severity | Rule |
|---|-------|----------|------|
| S-01 | All 13 sections present | Error | `## 1.` through `## 13.` headings exist |
| S-02 | No empty sections | Error | Each section ≥3 lines of content |
| S-03 | No placeholder-only sections | Error | Not solely `TBD`, `TODO`, `{...}`, `[...]` |

### Format

| # | Check | Severity | Rule |
|---|-------|----------|------|
| F-01 | User stories | Error | ≥5 "As a {X}, I want to {Y} so that {Z}" |
| F-02 | Acceptance criteria | Error | ≥5 "Given {X}, when {Y}, then {Z}" |
| F-03 | API endpoints | Error | ≥3 lines with HTTP method + path |
| F-04 | Data models | Error | ≥2 tables with typed fields |
| F-05 | Scope subsections | Error | Both "In Scope" and "Out of Scope" present |

### Quality

| # | Check | Severity | Rule |
|---|-------|----------|------|
| Q-01 | Forbidden adjectives | Error | `user-friendly`, `scalable`, `robust`, `simple`, `easy`, `efficient`, `intuitive` |
| Q-02 | Vague terms | Warning | `fast`, `secure`, `responsive`, `flexible`, `powerful`, `seamless` — OK only with measurable qualifier |
| Q-03 | Unfilled placeholders | Warning | Remaining `{placeholder}` patterns |

## Self-Review Checks (Agent — Stage 3)

Semantic checks the agent verifies before finalizing:

### Cross-Reference Consistency

| # | Check |
|---|-------|
| CR-01 | Every persona in User Stories exists in Personas section |
| CR-02 | Every screen in User Flows exists in screen inventory |
| CR-03 | Auth role names consistent across Stories, APIs, and Auth section |
| CR-04 | API request/response fields exist in corresponding data models |
| CR-05 | Every CRUD user story has a corresponding API endpoint |

### Technical Consistency

| # | Check |
|---|-------|
| TC-01 | Tech stack choices are mutually compatible |
| TC-02 | Auth method matches auth provider in Tech Stack |
| TC-03 | Every data model has id, created_at, updated_at |
| TC-04 | Every NFR has a measurable target |

### Completeness

| # | Check |
|---|-------|
| CO-01 | Every user story has ≥1 acceptance criterion |
| CO-02 | Every screen has ≥1 user flow referencing it |
| CO-03 | Open questions are genuine uncertainties, not lazy gaps |
