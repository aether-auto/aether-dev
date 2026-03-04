#!/usr/bin/env bash
# validate-tests.sh — PostToolUse hook for Write tool
# Validates test file structure: assertions, naming, no .only/.skip
# Follows hook protocol: JSON stdin, JSON stdout, exit 0 always

set -euo pipefail

INPUT=$(cat)

# Extract tool and file path from hook input
TOOL=$(echo "$INPUT" | grep -o '"tool_name":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null || echo "")
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null || echo "")

# Only validate Write tool calls
if [[ "$TOOL" != "Write" && "$TOOL" != "" ]]; then
  echo '{"additionalContext":""}'
  exit 0
fi

# Only validate test/spec files
if [[ ! "$FILE_PATH" =~ \.(test|spec)\.(ts|tsx|js|jsx)$ ]] && [[ ! "$FILE_PATH" =~ __tests__/ ]] && [[ ! "$FILE_PATH" =~ /tests?/ ]]; then
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

# T-01: Must contain at least 1 test block
if ! echo "$CONTENT" | grep -qE '(describe|test|it)\s*\('; then
  ERRORS="${ERRORS}\n[T-01] ERROR: Test file has no describe/test/it blocks"
fi

# T-02: Must have at least 1 assertion
if ! echo "$CONTENT" | grep -qE '(expect|assert|should)\s*[\.(]'; then
  ERRORS="${ERRORS}\n[T-02] ERROR: Test file has no assertions (expect/assert/should)"
fi

# T-03: Test names should be descriptive
SHORT_NAMES=$(echo "$CONTENT" | grep -oE "(test|it)\s*\(\s*['\"][^'\"]{0,10}['\"]" | head -5 || true)
if [[ -n "$SHORT_NAMES" ]]; then
  WARNINGS="${WARNINGS}\n[T-03] WARNING: Short test names found — use descriptive names (should...when...)"
fi

# T-04: No .only or .skip markers
if echo "$CONTENT" | grep -qE '\.(only|skip)\s*\('; then
  WARNINGS="${WARNINGS}\n[T-04] WARNING: Found .only or .skip — remove before committing"
fi

# T-05: No hardcoded ports, URLs, or credentials
if echo "$CONTENT" | grep -qE '(localhost:[0-9]{4}|127\.0\.0\.1:[0-9]|password.*=.*["\x27][^"\x27]+|api_key|secret)' ; then
  WARNINGS="${WARNINGS}\n[T-05] WARNING: Possible hardcoded ports/URLs/credentials in test file"
fi

# Build output
if [[ -n "$ERRORS" || -n "$WARNINGS" ]]; then
  FEEDBACK="Test validation for $(basename "$FILE_PATH"):${ERRORS}${WARNINGS}"
  # Escape for JSON
  FEEDBACK_JSON=$(echo -e "$FEEDBACK" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || echo "\"Test validation found issues\"")
  echo "{\"additionalContext\":${FEEDBACK_JSON}}"
else
  echo '{"additionalContext":""}'
fi

exit 0
