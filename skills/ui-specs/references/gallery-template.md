# Gallery Page Template

The gallery page (`.ui-specs/index.html`) lets users view all UI specs and edit design tokens live.

## HTML Structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{App Name} — UI Spec Gallery</title>
  <!-- Google Fonts link matching tokens -->
</head>
<body>
  <header>Project name, page count, "Export Tokens" button</header>
  <div class="layout">
    <aside class="token-editor">Token controls (see below)</aside>
    <main class="page-grid">Iframe cards (see below)</main>
  </div>
</body>
</html>
```

## Token Editor Sidebar

Collapsible sidebar with grouped controls. Each control reads/writes a CSS custom property.

| Section | Controls | Input Type |
|---------|----------|------------|
| Colors | primary, secondary, accent, bg, surface, text, text-muted, border, error, success | `<input type="color">` |
| Typography | display font, body font | `<select>` with Google Fonts options |
| Typography | base size | `<input type="range" min="12" max="24" step="1">` |
| Spacing | base unit | `<input type="range" min="4" max="16" step="2">` |
| Layout | border radius | `<input type="range" min="0" max="24" step="2">` |

**Buttons:**
- "Apply" — broadcasts tokens to all iframes
- "Reset" — restores original token values
- "Export Tokens" — downloads current state as `tokens.css`

## Token Propagation Protocol

Gallery sends updates to page iframes via `postMessage`:

```javascript
// On "Apply" click:
const tokens = {};
document.querySelectorAll('[data-token]').forEach(input => {
  const name = input.dataset.token;
  const value = input.value;
  tokens[name] = value;
  document.documentElement.style.setProperty(name, value);
});

document.querySelectorAll('iframe').forEach(frame => {
  frame.contentWindow.postMessage({ type: 'token-update', tokens }, '*');
});
```

Each page includes a matching listener (see SKILL.md).

## Page Grid Cards

Each page renders as a card in a responsive CSS grid:

```
+---------------------------+
| Page Name           [status badge] |
| Purpose description (1 line)       |
+---------------------------+
| iframe preview (16:10 aspect)      |
|                                    |
+---------------------------+
```

- Grid: `repeat(auto-fill, minmax(400px, 1fr))` with `gap: var(--space-lg)`
- Iframe: `width: 100%`, scaled with `transform: scale(0.5)` in container with `overflow: hidden`
- Click card: expands iframe to full-width modal overlay
- Status badge: "Draft" (yellow), "Approved" (green), "Needs Changes" (red)

## Export Function

```javascript
function exportTokens() {
  let css = '/* tokens.css — Exported from UI Spec Gallery */\n:root {\n';
  document.querySelectorAll('[data-token]').forEach(input => {
    css += `  ${input.dataset.token}: ${input.value};\n`;
  });
  css += '}\n';
  const blob = new Blob([css], { type: 'text/css' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'tokens.css';
  a.click();
}
```

## Styling Rules

- Gallery itself uses the same design tokens for its own styling
- Sidebar: fixed width `280px`, scrollable, `--color-surface` background
- Header: sticky, `--color-primary` accent bar
- Dark/light: respect `--color-bg` and `--color-text` tokens
- Responsive: sidebar collapses to top drawer below `768px`

## Font Dropdown Options

Populate font `<select>` with commonly paired Google Fonts:

| Category | Fonts |
|----------|-------|
| Sans-serif | Inter, Plus Jakarta Sans, DM Sans, Outfit, Space Grotesk, Geist |
| Serif | Playfair Display, Lora, Merriweather, Source Serif 4 |
| Display | Syne, Clash Display, Cabinet Grotesk, Satoshi |
| Mono | JetBrains Mono, Fira Code, IBM Plex Mono |

On font change: dynamically inject `<link>` for the selected Google Font into gallery and all iframes.
