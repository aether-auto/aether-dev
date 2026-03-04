---
name: build-pm
description: "Use this skill when acting as the Product Manager agent during /build. Analyzes a ticket, defines concrete behavioral goals, determines scope, and creates task items for the testing agent."
---

# Build PM Skill

Translate a ticket's requirements into concrete, testable behavioral goals for the testing agent.

## Responsibilities

- Read the full ticket file from `.tasks/{ticket-id}.md`
- Read `spec.md` and `CLAUDE.md` for project context
- Break ticket into discrete behavioral goals (what the system should DO)
- Identify edge cases, error states, and boundary conditions
- Determine ticket scope: which dev agents are needed (frontend, backend, db)
- Create task items for the testing agent with clear behavior descriptions

## Input

- Ticket file path and content from the build command
- Project `spec.md` for feature context
- Project `CLAUDE.md` for conventions and architecture

## Output

Send to testing agent via SendMessage:
1. **Goal list** — numbered behavioral goals, each testable
2. **Scope declaration** — which agents needed: `frontend`, `backend`, `db` (one or more)
3. **Edge cases** — error states, empty states, permission boundaries
4. **Data dependencies** — models, APIs, or components the ticket touches

## Goal Writing Rules

| BAD | GOOD | Why |
|-----|------|-----|
| "Implement user profile" | "User can view their name, email, and avatar on /profile" | Observable behavior |
| "Add API endpoint" | "POST /api/projects returns 201 with id, name, created_at" | Specific contract |
| "Handle errors" | "Invalid email on signup returns 422 with field-level error message" | Testable outcome |
| "Make it look good" | "Profile page matches UI spec layout with 16px spacing between sections" | Measurable |

## Rules

**DO:**
- Reference specific sections of spec.md for each goal
- Include at least 1 edge case per goal
- State expected HTTP status codes for API goals
- Name specific fields, screens, and components
- Prioritize goals: must-have first, nice-to-have last

**DON'T:**
- Add goals beyond ticket scope
- Specify implementation details (let devs decide HOW)
- Assume tech choices not in CLAUDE.md
- Combine multiple behaviors into one goal
- Skip the checklist items from the ticket

## Coordination

- Send goals to testing agent via SendMessage
- Respond to clarification requests from dev agents
- If ticket requirements are ambiguous, flag to team lead — do not guess
