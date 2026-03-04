#!/usr/bin/env bash
# validate-spec.sh — PostToolUse hook for validating spec.md files
#
# Reads JSON from stdin (Claude Code hook protocol), extracts the file path
# and content, then runs structural, format, and quality checks.
#
# Output: JSON with additionalContext field containing validation results.
# Always exits 0 — feedback is provided via additionalContext, never by blocking.

set -euo pipefail

# Read the hook input JSON from stdin
INPUT=$(cat)

# Extract the file path from tool_input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('file_path', ''))
" 2>/dev/null || echo "")

# Only validate files ending in spec.md
if [[ "$FILE_PATH" != *spec.md ]]; then
    exit 0
fi

# Extract file content from tool_input
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

# --- Structural Checks ---

# S-01: All 13 required sections present
REQUIRED_SECTIONS=(
    "## 1. Overview & Problem Statement"
    "## 2. Goals & Success Metrics"
    "## 3. Users & Personas"
    "## 4. User Stories"
    "## 5. User Flows & Screens"
    "## 6. Data Models"
    "## 7. API Specifications"
    "## 8. Authentication & Authorization"
    "## 9. Non-Functional Requirements"
    "## 10. Tech Stack & Architecture"
    "## 11. UI/UX Vision"
    "## 12. Scope"
    "## 13. Open Questions & Assumptions"
)

MISSING_SECTIONS=()
for section in "${REQUIRED_SECTIONS[@]}"; do
    # Match flexibly: the heading must start with the section number
    section_num=$(echo "$section" | grep -oE '## [0-9]+' | head -1)
    if ! echo "$CONTENT" | grep -qE "^${section_num}\\." ; then
        MISSING_SECTIONS+=("$section")
    fi
done

if [[ ${#MISSING_SECTIONS[@]} -gt 0 ]]; then
    ERRORS+=("[S-01] Missing sections: $(IFS=', '; echo "${MISSING_SECTIONS[*]}")")
fi

# S-02: No empty sections (each section must have ≥3 lines of content)
EMPTY_SECTIONS=$(echo "$CONTENT" | python3 -c "
import sys, re
content = sys.stdin.read()
sections = re.split(r'^## \d+\.', content, flags=re.MULTILINE)
headings = re.findall(r'^(## \d+\..+)$', content, flags=re.MULTILINE)
empty = []
for i, sec in enumerate(sections[1:]):  # skip content before first section
    lines = [l.strip() for l in sec.strip().split('\n') if l.strip() and not l.strip().startswith('#') and not l.strip().startswith('---')]
    if len(lines) < 3:
        if i < len(headings):
            empty.append(headings[i])
if empty:
    print(', '.join(empty))
" 2>/dev/null || echo "")

if [[ -n "$EMPTY_SECTIONS" ]]; then
    ERRORS+=("[S-02] Sections with insufficient content (<3 lines): $EMPTY_SECTIONS")
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
    ERRORS+=("[S-03] Placeholder-only sections: $PLACEHOLDER_SECTIONS")
fi

# --- Format Checks ---

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

# F-01: ≥5 user stories in "As a ... I want ... so that" format
USER_STORY_COUNT=$(count_matches "as a .+,? i want .+ so that" "-iE")
if [[ "$USER_STORY_COUNT" -lt 5 ]]; then
    ERRORS+=("[F-01] Found $USER_STORY_COUNT user stories (minimum 5 required in 'As a / I want / so that' format)")
fi

# F-02: ≥5 acceptance criteria in "Given ... when ... then" format
AC_COUNT=$(count_matches "given .+,? when .+,? then" "-iE")
if [[ "$AC_COUNT" -lt 5 ]]; then
    ERRORS+=("[F-02] Found $AC_COUNT acceptance criteria (minimum 5 required in 'Given / when / then' format)")
fi

# F-03: ≥3 API endpoints with HTTP methods
API_COUNT=$(count_matches "(GET|POST|PUT|PATCH|DELETE)\s+/" "-E")
if [[ "$API_COUNT" -lt 3 ]]; then
    ERRORS+=("[F-03] Found $API_COUNT API endpoints (minimum 3 required with HTTP method and path)")
fi

# F-04: ≥2 data models with typed fields
MODEL_COUNT=$(count_matches "\|\s*(string|number|boolean|date|DateTime|UUID|enum|integer|decimal|text|float|bigint|varchar|int)\s*\|" "-E")
if [[ "$MODEL_COUNT" -lt 2 ]]; then
    ERRORS+=("[F-04] Found $MODEL_COUNT typed data model fields (minimum 2 data models with typed fields required)")
fi

# F-05: In Scope and Out of Scope present
if ! echo "$CONTENT" | grep -qiE "in.scope"; then
    ERRORS+=("[F-05] Missing 'In Scope' subsection under Scope")
fi
if ! echo "$CONTENT" | grep -qiE "out.of.scope"; then
    ERRORS+=("[F-05] Missing 'Out of Scope' subsection under Scope")
fi

# --- Quality Checks ---

# Q-01: Forbidden vague adjectives (error level)
FORBIDDEN_TERMS=("user-friendly" "scalable" "robust" "simple" "easy" "efficient" "intuitive")
FOUND_FORBIDDEN=()
for term in "${FORBIDDEN_TERMS[@]}"; do
    COUNT=$(count_matches "\b${term}\b" "-iE")
    if [[ "$COUNT" -gt 0 ]]; then
        FOUND_FORBIDDEN+=("'$term' (${COUNT}x)")
    fi
done

if [[ ${#FOUND_FORBIDDEN[@]} -gt 0 ]]; then
    ERRORS+=("[Q-01] Forbidden vague adjectives found: $(IFS=', '; echo "${FOUND_FORBIDDEN[*]}"). Replace with measurable alternatives.")
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
    WARNINGS+=("[Q-02] Potentially vague terms found: $(IFS=', '; echo "${FOUND_WARNINGS[*]}"). Acceptable only if accompanied by measurable qualifiers.")
fi

# Q-03: Unfilled placeholders
PLACEHOLDER_MATCHES=$(echo "$CONTENT" | grep -oE '\{[A-Za-z_][A-Za-z_ ]*\}' || true)
PLACEHOLDER_COUNT=0
if [[ -n "$PLACEHOLDER_MATCHES" ]]; then
    PLACEHOLDER_COUNT=$(echo "$PLACEHOLDER_MATCHES" | wc -l | tr -d ' ')
fi
if [[ "$PLACEHOLDER_COUNT" -gt 0 ]]; then
    SAMPLE=$(echo "$PLACEHOLDER_MATCHES" | head -5 | tr '\n' ', ')
    WARNINGS+=("[Q-03] Found $PLACEHOLDER_COUNT unfilled placeholders, e.g.: $SAMPLE")
fi

# --- Output Results ---

ERROR_COUNT=${#ERRORS[@]}
WARNING_COUNT=${#WARNINGS[@]}

if [[ "$ERROR_COUNT" -eq 0 && "$WARNING_COUNT" -eq 0 ]]; then
    # All checks passed
    RESULT="SPEC VALIDATION PASSED: All structural, format, and quality checks passed."
else
    RESULT="SPEC VALIDATION RESULTS:\\n"

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

# Output as JSON for Claude Code hook protocol
python3 -c "
import json, sys
result = sys.argv[1]
print(json.dumps({'additionalContext': result}))
" "$RESULT"

exit 0
