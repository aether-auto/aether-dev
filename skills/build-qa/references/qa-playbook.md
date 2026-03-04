# QA Playbook

Reference for the QA agent on testing approaches for UI and API changes.

## Browser Testing (Playwright MCP)

### Setup Checklist

1. Verify dev server is running (`browser_navigate` to localhost URL)
2. Confirm page loads without console errors (`browser_console_messages`)
3. Take baseline screenshot before testing

### UI Test Flow

```
For each acceptance criterion:
  1. Navigate to relevant page (browser_navigate)
  2. Take snapshot (browser_snapshot) to understand page state
  3. Interact with elements (browser_click, browser_type, browser_fill_form)
  4. Verify result (browser_snapshot to check updated state)
  5. Screenshot if failure (browser_take_screenshot)
```

### What to Check

| Category | Checks |
|----------|--------|
| Layout | Elements present, correct positioning, responsive at 1280px and 768px |
| Interactions | Buttons clickable, forms submittable, navigation works |
| States | Loading states shown, error messages display, empty states handle |
| Data | Form data persists after submit, lists show correct items |
| Accessibility | Labels on inputs, buttons have text, keyboard tab order logical |

### Common UI Issues

| Issue | How to Detect |
|-------|--------------|
| Missing element | `browser_snapshot` doesn't show expected element |
| Broken link | `browser_click` on link → snapshot shows 404 |
| Form not submitting | Fill form → submit → snapshot shows no change |
| Console errors | `browser_console_messages` with level=error |
| Layout overflow | `browser_take_screenshot` shows content clipping |

## API Testing (Direct Requests)

### Test Flow

```
For each API endpoint in acceptance criteria:
  1. Send request via Bash (curl or httpie)
  2. Verify status code matches expected
  3. Verify response body shape and key fields
  4. Test error cases (missing fields, invalid data, auth)
```

### What to Check

| Category | Checks |
|----------|--------|
| Status codes | 200/201 for success, 400/422 for validation, 404 for not found, 401/403 for auth |
| Response shape | Required fields present, correct types, no extra sensitive data |
| Validation | Missing required fields → 422, invalid format → 422 with field errors |
| Auth | Unauthenticated → 401, wrong role → 403 |
| Idempotency | GET requests return same data, POST creates only one record |

### Common API Issues

| Issue | How to Detect |
|-------|--------------|
| Wrong status code | Response returns 200 instead of 201 for creation |
| Missing validation | Invalid data accepted without error |
| Leaked data | Response includes password hash, internal IDs, or debug info |
| Missing auth check | Request without token returns 200 instead of 401 |
| Wrong content type | Response headers show text/html instead of application/json |

## Issue Report Format

```markdown
## QA Issue: {short description}

**Severity:** blocker | major | minor
**Endpoint/Page:** {URL or route}
**Steps to reproduce:**
1. {step}
2. {step}
3. {step}

**Expected:** {what should happen}
**Actual:** {what happened}
**Evidence:** {screenshot path or response body}
```

## Severity Definitions

| Severity | Criteria | Action |
|----------|----------|--------|
| Blocker | Acceptance criteria not met, feature broken | Must fix before commit |
| Major | Feature works but significant UX issue | Should fix, dev decides |
| Minor | Cosmetic, non-functional, polish | Log as suggestion, don't block |
