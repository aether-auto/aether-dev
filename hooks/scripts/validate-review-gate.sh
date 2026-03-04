#!/usr/bin/env bash
# validate-review-gate.sh — PreToolUse hook for gating git push on passing tests
#
# Reads JSON from stdin (Claude Code hook protocol), checks if the command
# is a git push, and if so runs the project test suite first.
#
# Output: JSON with decision and additionalContext fields.
# Always exits 0 — feedback is provided via additionalContext, never by blocking the process.

set -euo pipefail

# Read the hook input JSON from stdin
INPUT=$(cat)

# Extract the command from tool_input
COMMAND=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('command', ''))
" 2>/dev/null || echo "")

# Only gate on git push commands
if ! echo "$COMMAND" | grep -qE '^\s*git\s+push'; then
    exit 0
fi

# Detect the project root (look for package.json, Makefile, etc.)
PROJECT_ROOT=""
SEARCH_DIR=$(pwd)
while [[ "$SEARCH_DIR" != "/" ]]; do
    if [[ -f "$SEARCH_DIR/package.json" ]] || [[ -f "$SEARCH_DIR/Makefile" ]] || [[ -f "$SEARCH_DIR/Cargo.toml" ]]; then
        PROJECT_ROOT="$SEARCH_DIR"
        break
    fi
    SEARCH_DIR=$(dirname "$SEARCH_DIR")
done

if [[ -z "$PROJECT_ROOT" ]]; then
    # No project root found — allow push with warning
    python3 -c "
import json
print(json.dumps({
    'additionalContext': 'REVIEW GATE WARNING: Could not detect project root. Skipping test validation. Ensure tests pass before pushing.'
}))
"
    exit 0
fi

# Detect and run the test command
TEST_CMD=""
TEST_OUTPUT=""
TEST_EXIT=0

cd "$PROJECT_ROOT"

if [[ -f "package.json" ]]; then
    # Check for test script in package.json
    HAS_TEST=$(python3 -c "
import json
with open('package.json') as f:
    pkg = json.load(f)
scripts = pkg.get('scripts', {})
test_cmd = scripts.get('test', '')
if test_cmd and 'no test specified' not in test_cmd:
    print(test_cmd)
" 2>/dev/null || echo "")

    if [[ -n "$HAS_TEST" ]]; then
        TEST_CMD="npm test"
    fi
elif [[ -f "Makefile" ]] && grep -q "^test:" "Makefile"; then
    TEST_CMD="make test"
elif [[ -f "Cargo.toml" ]]; then
    TEST_CMD="cargo test"
elif [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]]; then
    TEST_CMD="python -m pytest"
fi

if [[ -z "$TEST_CMD" ]]; then
    # No test command found — allow push with warning
    python3 -c "
import json
print(json.dumps({
    'additionalContext': 'REVIEW GATE WARNING: No test command detected. Skipping test validation. Add a test script to package.json or Makefile.'
}))
"
    exit 0
fi

# Run tests and capture output
TEST_OUTPUT=$($TEST_CMD 2>&1) || TEST_EXIT=$?

if [[ "$TEST_EXIT" -ne 0 ]]; then
    # Tests failed — block the push
    # Truncate output if too long
    if [[ ${#TEST_OUTPUT} -gt 2000 ]]; then
        TEST_OUTPUT="${TEST_OUTPUT:0:1000}
... (truncated) ...
${TEST_OUTPUT: -1000}"
    fi

    python3 -c "
import json, sys
output = sys.argv[1]
result = f'REVIEW GATE BLOCKED: Tests failed. Fix failing tests before pushing.\n\nTest command: $TEST_CMD\nExit code: $TEST_EXIT\n\nOutput:\n{output}'
print(json.dumps({
    'decision': 'block',
    'additionalContext': result
}))
" "$TEST_OUTPUT"
    exit 0
fi

# Tests passed — allow push
python3 -c "
import json
print(json.dumps({
    'additionalContext': 'REVIEW GATE PASSED: All tests passing. Push allowed.'
}))
"
exit 0
