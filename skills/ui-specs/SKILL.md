---
name: ui-specs
description: "Use this skill when generating UI specification pages, creating design token systems, building spec galleries, or when the user says 'ui specs', 'design specs', 'mockup pages', 'visual specs', or 'preview UI'. Produces single-file HTML/CSS specs with shared design tokens."
---

# UI Specs Skill

Generate single-file HTML/CSS specs for every screen in the project, unified by a shared design token system.

**Token reference:** `${SKILL_DIR}/references/design-tokens.md`
**Gallery reference:** `${SKILL_DIR}/references/gallery-template.md`

## Output Structure

```
.ui-specs/
  tokens.css          # CSS custom properties (shared)
  index.html          # Gallery page with token editor
  pages/
    {page-name}.html  # One self-contained file per screen
```

## Page Generation Rules

Each page HTML file MUST:

1. Be fully self-contained — inline all CSS and JS
2. Reference design tokens via `var(--token-name)` — **never hardcode** colors, fonts, or spacing
3. Include `<meta name="viewport" content="width=device-width, initial-scale=1">`
4. Include the token listener script (below) as the last `<script>` before `</body>`
5. Declare all token defaults in a `:root` block at the top of `<style>`

**Token listener script** (include in every page):
```html
<script>
window.addEventListener('message', e => {
  if (e.data?.type === 'token-update') {
    Object.entries(e.data.tokens).forEach(([k, v]) =>
      document.documentElement.style.setProperty(k, v)
    );
  }
});
</script>
```

## Page Context Template

When invoking `frontend-design` skill for each page, provide:

```
Page: {name}
Purpose: {purpose from screen inventory}
Key Elements: {elements from screen inventory}
Navigation: accessed from {source}, links to {targets}
Design Tokens: {paste tokens.css content}
UI Vision: {from spec.md section 11}
Constraint: Use var(--token-name) for ALL colors, fonts, spacing. No hardcoded values.
```

## BAD vs GOOD

| BAD | GOOD | Why |
|-----|------|-----|
| `color: #3498db` | `color: var(--color-primary)` | Hardcoded = can't update from gallery |
| `font-family: Inter` | `font-family: var(--font-body)` | Must use token reference |
| `padding: 16px` | `padding: var(--space-md)` | Spacing from token scale |
| 5 separate CSS files | Single `<style>` block | Must be self-contained |
| No viewport meta | `<meta name="viewport" ...>` | Responsive required |
| Missing token listener | Script before `</body>` | Gallery can't update tokens |

## Token Setup Process

1. Read spec.md section 11 for design direction keywords
2. Map keywords to token values (see `design-tokens.md` reference)
3. Ask user to confirm/adjust: primary color, font choice, overall feel
4. Write `.ui-specs/tokens.css`

## Gallery Page Rules

The gallery (`index.html`) is a standalone HTML page with:

1. **Sidebar** — token editor with live controls (color pickers, font dropdowns, sliders)
2. **Main area** — responsive grid of iframe cards showing each page
3. **Token propagation** — "Apply" sends `postMessage({ type: 'token-update', tokens: {...} })` to all iframes
4. **Export** — "Export Tokens" downloads current values as `tokens.css`

See `gallery-template.md` for full HTML structure.

## Quality Checklist

Before marking a page complete:

- [ ] All colors use `var(--color-*)` tokens
- [ ] All fonts use `var(--font-*)` tokens
- [ ] All spacing uses `var(--space-*)` tokens
- [ ] Viewport meta tag present
- [ ] Token listener script present
- [ ] Page renders correctly at 375px and 1440px widths
- [ ] No external dependencies (CDN links OK for Google Fonts only)
