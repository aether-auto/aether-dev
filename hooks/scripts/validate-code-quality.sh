#!/usr/bin/env bash
# validate-code-quality.sh — PostToolUse hook for Write tool
# Checks source files for debug artifacts, TODOs, large files, hardcoded secrets
# Follows hook protocol: JSON stdin, JSON stdout, exit 0 always

set -euo pipefail

INPUT=$(cat)

# Extract file path from hook input
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null || echo "")

# Only validate source code files
if [[ ! "$FILE_PATH" =~ \.(ts|tsx|js|jsx|py|rb|go|rs|java|kt)$ ]]; then
  echo '{"additionalContext":""}'
  exit 0
fi

# Skip test files — they have their own validator
if [[ "$FILE_PATH" =~ \.(test|spec)\. ]] || [[ "$FILE_PATH" =~ __tests__/ ]]; then
  echo '{"additionalContext":""}'
  exit 0
fi

# Skip if file doesn't exist
if [[ ! -f "$FILE_PATH" ]]; then
  echo '{"additionalContext":""}'
  exit 0
fi

ERRORS=""
WARNINGS=""
CONTENT=$(cat "$FILE_PATH")

# C-01: No console.log / print() debug statements
if echo "$CONTENT" | grep -qE '^\s*(console\.(log|debug|info)|print\(|println!)'; then
  WARNINGS="${WARNINGS}\n[C-01] WARNING: Debug statements found (console.log/print) — remove before committing"
fi

# C-02: No TODO/FIXME without ticket reference
if echo "$CONTENT" | grep -qE '(TODO|FIXME|HACK|XXX)' && ! echo "$CONTENT" | grep -qE '(TODO|FIXME|HACK|XXX).*TASK-[0-9]+'; then
  WARNINGS="${WARNINGS}\n[C-02] WARNING: TODO/FIXME without ticket reference — add TASK-NNN or remove"
fi

# C-03: File length check
LINE_COUNT=$(wc -l < "$FILE_PATH" | tr -d ' ')
if [[ "$LINE_COUNT" -gt 300 ]]; then
  WARNINGS="${WARNINGS}\n[C-03] WARNING: File has ${LINE_COUNT} lines (>300) — consider splitting"
fi

# C-04: No hardcoded secrets
if echo "$CONTENT" | grep -qiE '(api[_-]?key|secret[_-]?key|password|token)\s*[:=]\s*["\x27][a-zA-Z0-9]{8,}'; then
  ERRORS="${ERRORS}\n[C-04] ERROR: Possible hardcoded secret — use environment variables"
fi

# C-05: No large commented-out code blocks
COMMENTED_BLOCKS=$(echo "$CONTENT" | grep -c '^\s*//' || true)
if [[ "$COMMENTED_BLOCKS" -gt 10 ]]; then
  WARNINGS="${WARNINGS}\n[C-05] WARNING: ${COMMENTED_BLOCKS} commented lines found — remove dead code"
fi

# Build output
if [[ -n "$ERRORS" || -n "$WARNINGS" ]]; then
  FEEDBACK="Code quality check for $(basename "$FILE_PATH"):${ERRORS}${WARNINGS}"
  FEEDBACK_JSON=$(echo -e "$FEEDBACK" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || echo "\"Code quality check found issues\"")
  echo "{\"additionalContext\":${FEEDBACK_JSON}}"
else
  echo '{"additionalContext":""}'
fi

exit 0
