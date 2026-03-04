#!/usr/bin/env bash
# validate-claude-md.sh — PostToolUse hook for validating CLAUDE.md files
#
# Reads JSON from stdin (Claude Code hook protocol), extracts the file path
# and content, then runs structural, format, and quality checks.
#
# Output: JSON with additionalContext field containing validation results.
# Always exits 0 — feedback is provided via additionalContext, never by blocking.

set -euo pipefail

INPUT=$(cat)

# Extract the file path from tool_input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('file_path', ''))
" 2>/dev/null || echo "")

# Only validate files named CLAUDE.md
BASENAME=$(basename "$FILE_PATH" 2>/dev/null || echo "")
if [[ "$BASENAME" != "CLAUDE.md" ]]; then
    exit 0
fi

# Skip if this is a subdirectory CLAUDE.md (only validate project root)
DIR=$(dirname "$FILE_PATH" 2>/dev/null || echo "")
DIRBASE=$(basename "$DIR" 2>/dev/null || echo "")
# Allow root CLAUDE.md — skip .agent-docs/ or nested ones
if [[ "$DIRBASE" == ".agent-docs" || "$DIRBASE" == "references" ]]; then
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

# --- Structural Checks ---

# S-01: Required sections present
REQUIRED_SECTIONS=(
    "Tech Stack"
    "Commands"
    "Code Style"
    "Architecture"
    "File Structure"
)

MISSING_SECTIONS=()
for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! echo "$CONTENT" | grep -qiE "^#+ .*${section}"; then
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
sections = re.split(r'^#{1,3} .+$', content, flags=re.MULTILINE)
headings = re.findall(r'^(#{1,3} .+)$', content, flags=re.MULTILINE)
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
    ERRORS+=("[S-02] Sections with insufficient content (<3 lines): $EMPTY_SECTIONS")
fi

# S-03: Line count ≤200
LINE_COUNT=$(echo "$CONTENT" | wc -l | tr -d ' ')
if [[ "$LINE_COUNT" -gt 200 ]]; then
    ERRORS+=("[S-03] CLAUDE.md is $LINE_COUNT lines (maximum 200). Move detail to .agent-docs/ and use @imports.")
fi

# --- Format Checks ---

# Helper: count matching lines
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

# F-01: Contains at least 3 runnable commands (backtick-wrapped)
CMD_COUNT=$(echo "$CONTENT" | python3 -c "
import sys, re
content = sys.stdin.read()
# Match backtick-wrapped commands that look runnable (start with common CLI prefixes)
cmds = re.findall(r'\x60([a-z][\w-]+ [\w/.@-]+[^\x60]*)\x60', content)
# Also match commands in table cells
table_cmds = re.findall(r'\|\s*\x60([a-z][\w-]+ [^\x60]+)\x60', content)
print(len(set(cmds + table_cmds)))
" 2>/dev/null || echo "0")

if [[ "$CMD_COUNT" -lt 3 ]]; then
    ERRORS+=("[F-01] Found $CMD_COUNT runnable commands (minimum 3). Commands section must have copy-pasteable commands.")
fi

# F-02: Tech stack mentions specific technologies
GENERIC_STACK=$(echo "$CONTENT" | python3 -c "
import sys, re
content = sys.stdin.read()
# Find Tech Stack section
match = re.search(r'(?i)#{1,3} .*tech stack.*?\n(.*?)(?=\n#{1,3} |\Z)', content, re.DOTALL)
if match:
    section = match.group(1)
    generic = ['frontend framework', 'backend framework', 'database system', 'TBD', 'TODO']
    found = [g for g in generic if g.lower() in section.lower()]
    if found:
        print(', '.join(found))
" 2>/dev/null || echo "")

if [[ -n "$GENERIC_STACK" ]]; then
    ERRORS+=("[F-02] Tech stack uses generic terms: $GENERIC_STACK. Name specific technologies (e.g., 'Next.js 14', not 'frontend framework').")
fi

# F-03: Has @import references to .agent-docs/ files
IMPORT_COUNT=$(count_matches "@\.agent-docs/" "-E")
if [[ "$IMPORT_COUNT" -lt 1 ]]; then
    ERRORS+=("[F-03] No @.agent-docs/ imports found. CLAUDE.md must reference supporting docs via @imports.")
fi

# --- Quality Checks ---

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
    ERRORS+=("[Q-01] Forbidden vague adjectives: $(IFS=', '; echo "${FOUND_FORBIDDEN[*]}"). Replace with concrete descriptions.")
fi

# Q-02: Unfilled placeholders
PLACEHOLDER_MATCHES=$(echo "$CONTENT" | grep -oE '\{[A-Za-z_][A-Za-z_ ]*\}' || true)
PLACEHOLDER_COUNT=0
if [[ -n "$PLACEHOLDER_MATCHES" ]]; then
    PLACEHOLDER_COUNT=$(echo "$PLACEHOLDER_MATCHES" | wc -l | tr -d ' ')
fi
if [[ "$PLACEHOLDER_COUNT" -gt 0 ]]; then
    SAMPLE=$(echo "$PLACEHOLDER_MATCHES" | head -5 | tr '\n' ', ')
    WARNINGS+=("[Q-02] Found $PLACEHOLDER_COUNT unfilled placeholders, e.g.: $SAMPLE")
fi

# --- Output Results ---

ERROR_COUNT=${#ERRORS[@]}
WARNING_COUNT=${#WARNINGS[@]}

if [[ "$ERROR_COUNT" -eq 0 && "$WARNING_COUNT" -eq 0 ]]; then
    RESULT="CLAUDE.MD VALIDATION PASSED: All structural, format, and quality checks passed."
else
    RESULT="CLAUDE.MD VALIDATION RESULTS:\\n"

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
