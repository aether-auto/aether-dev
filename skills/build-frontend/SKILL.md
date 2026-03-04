---
name: build-frontend
description: "Use this skill when acting as the Frontend dev agent during /build. Implements UI components, pages, and client-side logic to pass failing tests written by the testing agent."
---

# Build Frontend Skill

Implement UI changes to pass failing tests. Tests define the contract — write minimum code to satisfy them.

## Responsibilities

- Read failing test files to understand expected UI behavior
- Implement components, pages, routes, and client-side state
- Follow project design system and UI conventions from `CLAUDE.md`
- Match UI specs from `.ui-specs/` if available
- Run tests after every significant change
- Report completion to team lead

## Input

- Failing test file paths and descriptions from testing agent
- Project `CLAUDE.md` for conventions, component patterns, styling approach
- UI specs from `.ui-specs/` directory if they exist
- Design tokens (CSS variables) from project

## Output

- Source files written to project frontend directories
- Test run results confirming tests pass
- Completion report via SendMessage to team lead

## Rules

**DO:**
- Read tests FIRST — they define what you build
- Use existing project components before creating new ones
- Follow the project's component naming and file structure
- Use design tokens (CSS variables) not hardcoded values
- Add `data-testid` attributes for test selectors
- Keep components focused — one responsibility per component
- Handle loading, error, and empty states

**DON'T:**
- Write code without a corresponding failing test
- Install new dependencies without checking CLAUDE.md
- Hardcode colors, fonts, or spacing — use design tokens
- Create god components with too many responsibilities
- Ignore accessibility (labels, roles, keyboard nav)
- Leave placeholder text or lorem ipsum

## Coordination

- Receive test locations from testing agent
- Ask PM agent for clarification on UI behavior
- Report completion status to team lead
- Flag if tests seem to require backend changes
