#!/usr/bin/env bash
# check-spec-sections.sh — Standalone spec.md validator
#
# Usage: bash scripts/check-spec-sections.sh path/to/spec.md
#
# Runs the same validation checks as the PostToolUse hook but reads from
# a file path instead of stdin JSON. Useful for manual testing.

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <path-to-spec.md>"
    echo "Example: $0 spec.md"
    exit 1
fi

SPEC_FILE="$1"

if [[ ! -f "$SPEC_FILE" ]]; then
    echo "Error: File not found: $SPEC_FILE"
    exit 1
fi

CONTENT=$(cat "$SPEC_FILE")

ERRORS=()
WARNINGS=()
PASS_COUNT=0

echo "================================================"
echo "  Spec Validator — $SPEC_FILE"
echo "================================================"
echo ""

# --- Structural Checks ---

echo "--- Structural Checks ---"

# S-01: All 13 required sections present
REQUIRED_SECTIONS=(
    "1. Overview"
    "2. Goals"
    "3. Users"
    "4. User Stories"
    "5. User Flows"
    "6. Data Models"
    "7. API"
    "8. Authentication"
    "9. Non-Functional"
    "10. Tech Stack"
    "11. UI/UX"
    "12. Scope"
    "13. Open Questions"
)

MISSING_SECTIONS=()
for section in "${REQUIRED_SECTIONS[@]}"; do
    section_num=$(echo "$section" | grep -oE '^[0-9]+')
    if echo "$CONTENT" | grep -qE "^## ${section_num}\\." ; then
        ((PASS_COUNT++))
    else
        MISSING_SECTIONS+=("$section")
    fi
done

if [[ ${#MISSING_SECTIONS[@]} -gt 0 ]]; then
    echo "  FAIL [S-01] Missing sections: $(IFS=', '; echo "${MISSING_SECTIONS[*]}")"
    ERRORS+=("[S-01] Missing sections")
else
    echo "  PASS [S-01] All 13 required sections present"
fi

# S-02: No empty sections
EMPTY_SECTIONS=$(echo "$CONTENT" | python3 -c "
import sys, re
content = sys.stdin.read()
sections = re.split(r'^## \d+\.', content, flags=re.MULTILINE)
headings = re.findall(r'^(## \d+\..+)$', content, flags=re.MULTILINE)
empty = []
for i, sec in enumerate(sections[1:]):
    lines = [l.strip() for l in sec.strip().split('\n') if l.strip() and not l.strip().startswith('#') and not l.strip().startswith('---')]
    if len(lines) < 3:
        if i < len(headings):
            empty.append(headings[i])
if empty:
    print(', '.join(empty))
" 2>/dev/null || echo "")

if [[ -n "$EMPTY_SECTIONS" ]]; then
    echo "  FAIL [S-02] Sections with insufficient content: $EMPTY_SECTIONS"
    ERRORS+=("[S-02] Empty sections")
else
    echo "  PASS [S-02] All sections have sufficient content (≥3 lines)"
    ((PASS_COUNT++))
fi

# S-03: No placeholder-only sections
PLACEHOLDER_SECTIONS=$(echo "$CONTENT" | python3 -c "
import sys, re
content = sys.stdin.read()
sections = re.split(r'^## \d+\.', content, flags=re.MULTILINE)
headings = re.findall(r'^(## \d+\..+)$', content, flags=re.MULTILINE)
placeholder_only = []
for i, sec in enumerate(sections[1:]):
    lines = [l.strip() for l in sec.strip().split('\n') if l.strip() and not l.strip().startswith('#') and not l.strip().startswith('---')]
    if lines:
        non_placeholder = [l for l in lines if not re.match(r'^(\{.*\}|\[.*\]|TBD|TODO|N/A|-)$', l, re.IGNORECASE)]
        if len(non_placeholder) == 0:
            if i < len(headings):
                placeholder_only.append(headings[i])
if placeholder_only:
    print(', '.join(placeholder_only))
" 2>/dev/null || echo "")

if [[ -n "$PLACEHOLDER_SECTIONS" ]]; then
    echo "  FAIL [S-03] Placeholder-only sections: $PLACEHOLDER_SECTIONS"
    ERRORS+=("[S-03] Placeholder-only sections")
else
    echo "  PASS [S-03] No placeholder-only sections"
    ((PASS_COUNT++))
fi

echo ""
echo "--- Format Checks ---"

# Helper: count matching lines safely (grep returns exit 1 on no match, so || true)
count_matches() {
    local pattern="$1"
    local flags="$2"
    local result
    result=$(echo "$CONTENT" | grep $flags "$pattern" 2>/dev/null || true)
    if [[ -z "$result" ]]; then
        echo "0"
    else
        echo "$result" | wc -l | tr -d ' '
    fi
}

# F-01: ≥5 user stories
USER_STORY_COUNT=$(count_matches "as a .+,? i want .+ so that" "-iE")
if [[ "$USER_STORY_COUNT" -lt 5 ]]; then
    echo "  FAIL [F-01] Found $USER_STORY_COUNT user stories (minimum 5)"
    ERRORS+=("[F-01] Insufficient user stories")
else
    echo "  PASS [F-01] Found $USER_STORY_COUNT user stories (≥5)"
    ((PASS_COUNT++))
fi

# F-02: ≥5 acceptance criteria
AC_COUNT=$(count_matches "given .+,? when .+,? then" "-iE")
if [[ "$AC_COUNT" -lt 5 ]]; then
    echo "  FAIL [F-02] Found $AC_COUNT acceptance criteria (minimum 5)"
    ERRORS+=("[F-02] Insufficient acceptance criteria")
else
    echo "  PASS [F-02] Found $AC_COUNT acceptance criteria (≥5)"
    ((PASS_COUNT++))
fi

# F-03: ≥3 API endpoints
API_COUNT=$(count_matches "(GET|POST|PUT|PATCH|DELETE)\s+/" "-E")
if [[ "$API_COUNT" -lt 3 ]]; then
    echo "  FAIL [F-03] Found $API_COUNT API endpoints (minimum 3)"
    ERRORS+=("[F-03] Insufficient API endpoints")
else
    echo "  PASS [F-03] Found $API_COUNT API endpoints (≥3)"
    ((PASS_COUNT++))
fi

# F-04: ≥2 data models with typed fields
MODEL_COUNT=$(count_matches "\|\s*(string|number|boolean|date|DateTime|UUID|enum|integer|decimal|text|float|bigint|varchar|int)\s*\|" "-E")
if [[ "$MODEL_COUNT" -lt 2 ]]; then
    echo "  FAIL [F-04] Found $MODEL_COUNT typed data model fields (minimum 2)"
    ERRORS+=("[F-04] Insufficient typed fields")
else
    echo "  PASS [F-04] Found $MODEL_COUNT typed data model fields (≥2)"
    ((PASS_COUNT++))
fi

# F-05: In Scope and Out of Scope
SCOPE_PASS=true
if ! echo "$CONTENT" | grep -qiE "in.scope"; then
    echo "  FAIL [F-05] Missing 'In Scope' subsection"
    ERRORS+=("[F-05] Missing In Scope")
    SCOPE_PASS=false
fi
if ! echo "$CONTENT" | grep -qiE "out.of.scope"; then
    echo "  FAIL [F-05] Missing 'Out of Scope' subsection"
    ERRORS+=("[F-05] Missing Out of Scope")
    SCOPE_PASS=false
fi
if [[ "$SCOPE_PASS" == true ]]; then
    echo "  PASS [F-05] Both In Scope and Out of Scope present"
    ((PASS_COUNT++))
fi

echo ""
echo "--- Quality Checks ---"

# Q-01: Forbidden vague adjectives
FORBIDDEN_TERMS=("user-friendly" "scalable" "robust" "simple" "easy" "efficient" "intuitive")
FOUND_FORBIDDEN=()
for term in "${FORBIDDEN_TERMS[@]}"; do
    COUNT=$(count_matches "\b${term}\b" "-iE")
    if [[ "$COUNT" -gt 0 ]]; then
        FOUND_FORBIDDEN+=("'$term' (${COUNT}x)")
    fi
done

if [[ ${#FOUND_FORBIDDEN[@]} -gt 0 ]]; then
    echo "  FAIL [Q-01] Forbidden vague adjectives: $(IFS=', '; echo "${FOUND_FORBIDDEN[*]}")"
    ERRORS+=("[Q-01] Forbidden adjectives")
else
    echo "  PASS [Q-01] No forbidden vague adjectives"
    ((PASS_COUNT++))
fi

# Q-02: Warning-level vague terms
WARNING_TERMS=("fast" "secure" "responsive" "flexible" "powerful" "seamless")
FOUND_WARNINGS=()
for term in "${WARNING_TERMS[@]}"; do
    COUNT=$(count_matches "\b${term}\b" "-iE")
    if [[ "$COUNT" -gt 0 ]]; then
        FOUND_WARNINGS+=("'$term' (${COUNT}x)")
    fi
done

if [[ ${#FOUND_WARNINGS[@]} -gt 0 ]]; then
    echo "  WARN [Q-02] Potentially vague terms: $(IFS=', '; echo "${FOUND_WARNINGS[*]}")"
    WARNINGS+=("[Q-02] Vague terms")
else
    echo "  PASS [Q-02] No warning-level vague terms"
    ((PASS_COUNT++))
fi

# Q-03: Unfilled placeholders
PLACEHOLDER_MATCHES=$(echo "$CONTENT" | grep -oE '\{[A-Za-z_][A-Za-z_ ]*\}' || true)
PLACEHOLDER_COUNT=0
if [[ -n "$PLACEHOLDER_MATCHES" ]]; then
    PLACEHOLDER_COUNT=$(echo "$PLACEHOLDER_MATCHES" | wc -l | tr -d ' ')
fi
if [[ "$PLACEHOLDER_COUNT" -gt 0 ]]; then
    SAMPLE=$(echo "$PLACEHOLDER_MATCHES" | head -5 | tr '\n' ', ')
    echo "  WARN [Q-03] Found $PLACEHOLDER_COUNT unfilled placeholders, e.g.: $SAMPLE"
    WARNINGS+=("[Q-03] Unfilled placeholders")
else
    echo "  PASS [Q-03] No unfilled placeholders"
    ((PASS_COUNT++))
fi

# --- Summary ---

echo ""
echo "================================================"
ERROR_COUNT=${#ERRORS[@]}
WARNING_COUNT=${#WARNINGS[@]}
TOTAL=$((PASS_COUNT + ERROR_COUNT + WARNING_COUNT))

if [[ "$ERROR_COUNT" -eq 0 && "$WARNING_COUNT" -eq 0 ]]; then
    echo "  RESULT: ALL CHECKS PASSED ($PASS_COUNT/$PASS_COUNT)"
elif [[ "$ERROR_COUNT" -eq 0 ]]; then
    echo "  RESULT: PASSED with $WARNING_COUNT warning(s) ($PASS_COUNT passed, $WARNING_COUNT warnings)"
else
    echo "  RESULT: FAILED — $ERROR_COUNT error(s), $WARNING_COUNT warning(s)"
fi
echo "================================================"

# Exit with error code if there are errors (not warnings)
if [[ "$ERROR_COUNT" -gt 0 ]]; then
    exit 1
fi

exit 0
