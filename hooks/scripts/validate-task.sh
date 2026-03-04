#!/usr/bin/env bash
# validate-task.sh — PostToolUse hook for validating .tasks/TASK-*.md files
#
# Reads JSON from stdin (Claude Code hook protocol), extracts the file path
# and content, then runs structural and format checks.
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

# Only validate files matching .tasks/TASK-*.md
if [[ ! "$FILE_PATH" =~ \.tasks/TASK-[0-9]+\.md$ ]]; then
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

# --- T-01: YAML frontmatter present ---
if ! echo "$CONTENT" | head -1 | grep -q '^---$'; then
    ERRORS+=("[T-01] Missing YAML frontmatter: file must start with '---'")
fi

FRONTMATTER=$(echo "$CONTENT" | python3 -c "
import sys, re
content = sys.stdin.read()
m = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
if m:
    print(m.group(1))
else:
    print('')
" 2>/dev/null || echo "")

# --- T-02: Required frontmatter fields ---
REQUIRED_FIELDS=("id" "title" "status" "priority" "depends_on")
MISSING_FIELDS=()
for field in "${REQUIRED_FIELDS[@]}"; do
    if ! echo "$FRONTMATTER" | grep -qE "^${field}:"; then
        MISSING_FIELDS+=("$field")
    fi
done

if [[ ${#MISSING_FIELDS[@]} -gt 0 ]]; then
    ERRORS+=("[T-02] Missing required frontmatter fields: $(IFS=', '; echo "${MISSING_FIELDS[*]}")")
fi

# --- T-03: Valid status value ---
STATUS_VAL=$(echo "$FRONTMATTER" | grep -E '^status:' | sed 's/^status:\s*//' | tr -d ' ' || echo "")
if [[ -n "$STATUS_VAL" ]] && [[ "$STATUS_VAL" != "pending" && "$STATUS_VAL" != "in-progress" && "$STATUS_VAL" != "done" ]]; then
    ERRORS+=("[T-03] Invalid status '$STATUS_VAL': must be 'pending', 'in-progress', or 'done'")
fi

# --- T-04: Valid priority value ---
PRIORITY_VAL=$(echo "$FRONTMATTER" | grep -E '^priority:' | sed 's/^priority:\s*//' | tr -d ' ' || echo "")
if [[ -n "$PRIORITY_VAL" ]] && [[ "$PRIORITY_VAL" != "must-have" && "$PRIORITY_VAL" != "should-have" && "$PRIORITY_VAL" != "could-have" ]]; then
    ERRORS+=("[T-04] Invalid priority '$PRIORITY_VAL': must be 'must-have', 'should-have', or 'could-have'")
fi

# --- T-05: Required sections present ---
REQUIRED_SECTIONS=("## Summary" "## Description" "## Acceptance Criteria" "## Dependencies")
MISSING_SECTIONS=()
for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! echo "$CONTENT" | grep -qF "$section"; then
        MISSING_SECTIONS+=("$section")
    fi
done

if [[ ${#MISSING_SECTIONS[@]} -gt 0 ]]; then
    ERRORS+=("[T-05] Missing required sections: $(IFS=', '; echo "${MISSING_SECTIONS[*]}")")
fi

# --- T-06: Non-empty sections ---
EMPTY_SECTIONS=$(echo "$CONTENT" | python3 -c "
import sys, re
content = sys.stdin.read()
required = ['Summary', 'Description', 'Acceptance Criteria', 'Dependencies']
empty = []
for sec_name in required:
    pattern = r'## ' + re.escape(sec_name) + r'\n(.*?)(?=\n## |\Z)'
    m = re.search(pattern, content, re.DOTALL)
    if m:
        lines = [l.strip() for l in m.group(1).strip().split('\n') if l.strip()]
        if len(lines) < 1:
            empty.append(sec_name)
    else:
        pass  # already caught by T-05
if empty:
    print(', '.join(empty))
" 2>/dev/null || echo "")

if [[ -n "$EMPTY_SECTIONS" ]]; then
    ERRORS+=("[T-06] Empty sections (need content): $EMPTY_SECTIONS")
fi

# --- T-07: Acceptance criteria format ---
AC_COUNT=$(echo "$CONTENT" | grep -cE '^\s*- \[ \]' 2>/dev/null || true)
AC_COUNT=${AC_COUNT:-0}
AC_COUNT=$(echo "$AC_COUNT" | tr -d '[:space:]')
if [[ "$AC_COUNT" -lt 1 ]]; then
    ERRORS+=("[T-07] Acceptance Criteria must have at least 1 checklist item ('- [ ] ...')")
fi

# --- T-08: ID consistency ---
FM_ID=$(echo "$FRONTMATTER" | grep -E '^id:' | sed 's/^id:\s*//' | tr -d ' ' || echo "")
FILENAME=$(basename "$FILE_PATH" .md)
if [[ -n "$FM_ID" ]] && [[ "$FM_ID" != "$FILENAME" ]]; then
    WARNINGS+=("[T-08] Frontmatter id '$FM_ID' does not match filename '$FILENAME'")
fi

# --- T-09: Dependency format ---
DEPS=$(echo "$FRONTMATTER" | python3 -c "
import sys, re
fm = sys.stdin.read()
m = re.search(r'depends_on:\s*\[(.*?)\]', fm)
if m and m.group(1).strip():
    deps = [d.strip().strip('\"').strip(\"'\") for d in m.group(1).split(',')]
    for d in deps:
        if d and not re.match(r'^TASK-\d{3}$', d):
            print(d)
" 2>/dev/null || echo "")

if [[ -n "$DEPS" ]]; then
    WARNINGS+=("[T-09] Invalid dependency format (expected TASK-NNN): $DEPS")
fi

# --- Output Results ---

ERROR_COUNT=${#ERRORS[@]}
WARNING_COUNT=${#WARNINGS[@]}

if [[ "$ERROR_COUNT" -eq 0 && "$WARNING_COUNT" -eq 0 ]]; then
    RESULT="TASK VALIDATION PASSED: All structural and format checks passed."
else
    RESULT="TASK VALIDATION RESULTS:\\n"

    if [[ "$ERROR_COUNT" -gt 0 ]]; then
        RESULT+="\\nERRORS ($ERROR_COUNT) — must fix:\\n"
        for err in "${ERRORS[@]}"; do
            RESULT+="  - $err\\n"
        done
    fi

    if [[ "$WARNING_COUNT" -gt 0 ]]; then
        RESULT+="\\nWARNINGS ($WARNING_COUNT) — review:\\n"
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
