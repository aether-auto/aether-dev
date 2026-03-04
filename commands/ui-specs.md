---
description: "Generate single-file HTML/CSS UI specs for every screen, serve a gallery with editable design tokens for iterative review"
argument-hint: "[optional: specific pages to regenerate or 'all']"
---

# /ui-specs — UI Specification & Design Token Gallery

Generate visual UI specs from `spec.md`, serve them locally for iterative review.

**Scope:** $ARGUMENTS

## <HARD-GATE>

1. **MUST have `spec.md`** with populated sections 5 (User Flows & Screens) and 11 (UI/UX Vision).
2. **MUST extract screen inventory** from spec.md before generating any HTML.
3. **MUST use design tokens** (CSS custom properties) — no hardcoded colors/fonts in page specs.
4. **MUST generate gallery page** with token editor before serving.
5. **MUST serve locally** and use AskUserQuestion for feedback before completing.

</HARD-GATE>

## Phase 1: Extract UI Context

Read these files and extract UI-relevant information:

1. `spec.md` — Section 5 (screen inventory, user flows) and Section 11 (UI/UX vision, design direction, principles)
2. `CLAUDE.md` and `.agent-docs/ui-vision.md` (if they exist) — additional design context
3. Build a **page list** from the screen inventory table in spec.md section 5

Output: internal list of `{ pageName, purpose, keyElements, accessedFrom }` for each screen.

## Phase 2: Design Token Setup

Use the `aether-dev:ui-specs` skill. Follow its token setup process.

1. Extract design direction from spec.md section 11 (color feel, typography, patterns)
2. Ask user via AskUserQuestion: confirm or adjust color palette, font choices, spacing preferences
3. Generate `.ui-specs/tokens.css` with CSS custom properties

**Rules:**
- Token categories: colors (10), typography (6), spacing (6), layout (4) — see skill references
- Font choices: use Google Fonts for display/body, system monospace for code
- Colors: derive from design direction; primary + secondary + accent + neutrals + semantic (error/success)

## Phase 3: Page Generation

For each screen in the page list:

1. Invoke the `frontend-design` skill with context:
   - Page name, purpose, key elements (from Phase 1)
   - Design tokens (from Phase 2) — instruct to use CSS var() references only
   - UI vision and principles from spec.md section 11
   - Navigation context (accessed from, links to)
2. Write output to `.ui-specs/pages/{page-name}.html`
   - Hook validates structure automatically
3. On hook errors: fix and re-write (max 3 attempts per page)

**Rules:**
- One HTML file per screen — fully self-contained (inline CSS/JS)
- Every color/font/spacing MUST reference `tokens.css` variables
- Include responsive viewport meta tag
- Include token listener script for gallery integration (see skill reference)

## Phase 4: Gallery Generation

Generate `.ui-specs/index.html` — the gallery/overview page.

Read template guidance: use `aether-dev:ui-specs` skill gallery rules.

The gallery page contains:
- **Token editor sidebar**: color pickers, font dropdowns, spacing sliders for all design tokens
- **Page grid**: iframe preview cards for every generated page
- **Token propagation**: postMessage to update all iframes when tokens change
- **Export button**: download current tokens as `tokens.css`

## Phase 5: Serve & Review Loop

1. Run: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/serve-ui-specs.sh`
2. Present URL to user (default: `http://localhost:8420`)
3. AskUserQuestion — ask user to review in browser:
   - "Approve all" → stop server, mark complete
   - "Change tokens" → user edits in gallery, exports, agent reads updated tokens
   - "Redesign {page}" → regenerate specific page(s) with feedback, re-serve
   - "Add page" → generate new page spec, add to gallery, re-serve
4. Loop until user approves

**Present summary on completion:**
```
## UI Specs Complete: {App Name}
**Directory:** .ui-specs/
- Pages: {count} ({names})
- Design Tokens: {token count} across {category count} categories
- Gallery: .ui-specs/index.html
- Server: stopped
```

## Error Recovery

- **No spec.md**: Tell user to run `/ideate` first.
- **Empty section 5/11**: Ask user to describe screens and design vision directly.
- **Server port in use**: Try ports 8421-8429 sequentially.
- **"Start over"**: Delete `.ui-specs/`, begin Phase 1.
