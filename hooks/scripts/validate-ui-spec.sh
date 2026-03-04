#!/usr/bin/env bash
# validate-ui-spec.sh — PostToolUse hook for validating UI spec HTML files
#
# Reads JSON from stdin (Claude Code hook protocol), extracts the file path
# and content, then runs structural checks on generated UI spec pages.
#
# Output: JSON with additionalContext field containing validation results.
# Always exits 0 — feedback is provided via additionalContext, never by blocking.

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('file_path', ''))
" 2>/dev/null || echo "")

# Only validate HTML files inside .ui-specs/
if [[ "$FILE_PATH" != *.ui-specs/*.html ]]; then
    exit 0
fi

CONTENT=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('content', ''))
" 2>/dev/null || echo "")

if [[ -z "$CONTENT" ]]; then
    exit 0
fi

ERRORS=()
WARNINGS=()

# Skip gallery index.html — it has different rules
BASENAME=$(basename "$FILE_PATH")
if [[ "$BASENAME" == "index.html" ]]; then
    # Gallery page: just check basic HTML structure
    if ! echo "$CONTENT" | grep -qi "<!DOCTYPE html>"; then
        ERRORS+=("[G-01] Missing <!DOCTYPE html> declaration")
    fi
    if ! echo "$CONTENT" | grep -qi '<meta.*viewport'; then
        WARNINGS+=("[G-02] Missing viewport meta tag")
    fi
else
    # --- Page spec checks ---

    # P-01: DOCTYPE present
    if ! echo "$CONTENT" | grep -qi "<!DOCTYPE html>"; then
        ERRORS+=("[P-01] Missing <!DOCTYPE html> declaration")
    fi

    # P-02: Viewport meta tag
    if ! echo "$CONTENT" | grep -qi '<meta.*viewport'; then
        ERRORS+=("[P-02] Missing <meta name=\"viewport\"> tag — required for responsive design")
    fi

    # P-03: Token listener script present
    if ! echo "$CONTENT" | grep -q "token-update"; then
        ERRORS+=("[P-03] Missing token listener script — page cannot receive gallery token updates. Include: window.addEventListener('message', ...) with 'token-update' handler")
    fi

    # P-04: Uses CSS custom properties (at least some)
    VAR_COUNT=$(echo "$CONTENT" | grep -oE 'var\(--[a-z]' | wc -l | tr -d ' ')
    if [[ "$VAR_COUNT" -lt 3 ]]; then
        ERRORS+=("[P-04] Found only $VAR_COUNT CSS var() references — page must use design tokens via var(--token-name) for colors, fonts, and spacing")
    fi

    # P-05: No excessive hardcoded hex colors (allow a few for shadows/gradients)
    HEX_COUNT=$(echo "$CONTENT" | grep -oE '#[0-9a-fA-F]{3,8}' | wc -l | tr -d ' ')
    if [[ "$HEX_COUNT" -gt 15 ]]; then
        WARNINGS+=("[P-05] Found $HEX_COUNT hardcoded hex colors — prefer var(--color-*) tokens. Some hardcoded values are OK for shadows and gradients.")
    fi

    # P-06: Has a root or style block
    if ! echo "$CONTENT" | grep -q '<style'; then
        WARNINGS+=("[P-06] No <style> block found — page should have inline CSS")
    fi
fi

# --- Output Results ---

ERROR_COUNT=${#ERRORS[@]}
WARNING_COUNT=${#WARNINGS[@]}

if [[ "$ERROR_COUNT" -eq 0 && "$WARNING_COUNT" -eq 0 ]]; then
    RESULT="UI SPEC VALIDATION PASSED: All structural checks passed for $(basename "$FILE_PATH")."
else
    RESULT="UI SPEC VALIDATION RESULTS for $(basename "$FILE_PATH"):\\n"

    if [[ "$ERROR_COUNT" -gt 0 ]]; then
        RESULT+="\\nERRORS ($ERROR_COUNT) — must fix:\\n"
        for err in "${ERRORS[@]}"; do
            RESULT+="  - $err\\n"
        done
    fi

    if [[ "$WARNING_COUNT" -gt 0 ]]; then
        RESULT+="\\nWARNINGS ($WARNING_COUNT) — review and fix if appropriate:\\n"
        for warn in "${WARNINGS[@]}"; do
            RESULT+="  - $warn\\n"
        done
    fi
fi

python3 -c "
import json, sys
result = sys.argv[1]
print(json.dumps({'additionalContext': result}))
" "$RESULT"

exit 0
