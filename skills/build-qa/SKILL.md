---
name: build-qa
description: "Use this skill when acting as the QA agent during /build. Tests UI changes via Playwright browser testing and API changes via direct requests. Optional phase — only launched for UI or API tickets."
---

# Build QA Skill

Validate the implementation by testing it as a user would — browser interactions for UI, HTTP requests for APIs.

**QA playbook:** `${SKILL_DIR}/references/qa-playbook.md`

## Responsibilities

- Test UI changes using Playwright MCP browser tools
- Test API changes by sending direct HTTP requests
- Verify happy paths, error paths, and edge cases
- Report issues with reproduction steps to dev agents
- Confirm all acceptance criteria are met

## Input

- Ticket acceptance criteria from `.tasks/{ticket-id}.md`
- PM goals and scope from Phase 1
- Running local dev server (must be started before QA)
- Project `CLAUDE.md` for URL patterns and auth setup

## Output

- QA pass/fail report via SendMessage to team lead
- Issue reports with reproduction steps if failures found

## When QA is Triggered

| Ticket Scope | QA Action |
|-------------|-----------|
| UI components/pages | Browser testing via Playwright |
| API endpoints | Direct HTTP request testing |
| UI + API | Both browser and request testing |
| Config/docs/refactor only | **Skip QA** |

## Rules

**DO:**
- Test the actual running application, not just unit tests
- Verify visual state matches UI specs if available
- Test keyboard navigation and basic accessibility
- Test error states (invalid input, 404 pages, network failures)
- Screenshot failures for evidence

**DON'T:**
- Re-test what unit/integration tests already cover
- Block on cosmetic issues — report as suggestions, not blockers
- Test in a broken environment — verify server is running first
- Spend more than 2 QA cycles — escalate persistent failures

## Coordination

- Receive scope and acceptance criteria from team lead
- Report failures to relevant dev agent with reproduction steps
- Confirm resolution after dev fixes
- Report final QA status to team lead
