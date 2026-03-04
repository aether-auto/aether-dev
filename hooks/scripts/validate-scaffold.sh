#!/usr/bin/env bash
# validate-scaffold.sh — PostToolUse hook for validating scaffold output
#
# Fires after Bash tool calls. Only activates when .scaffold-in-progress
# marker file exists (created by /scaffold command, removed at end).
#
# Output: JSON with additionalContext field containing validation results.
# Always exits 0 — feedback is provided via additionalContext, never by blocking.

set -euo pipefail

# Read the hook input JSON from stdin
INPUT=$(cat)

# Extract the tool name
TOOL_NAME=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data.get('tool_name', ''))
" 2>/dev/null || echo "")

# Only run for Bash tool calls
if [[ "$TOOL_NAME" != "Bash" ]]; then
    exit 0
fi

# Only activate during scaffold (marker file must exist)
# Search for marker in current dir and common project locations
MARKER_FOUND=false
PROJECT_DIR=""

# Check tool_input for working directory hints
COMMAND=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('command', ''))
" 2>/dev/null || echo "")

# Look for .scaffold-in-progress in cwd and parent dirs
for DIR in "." ".." "../.."; do
    if [[ -f "${DIR}/.scaffold-in-progress" ]]; then
        MARKER_FOUND=true
        PROJECT_DIR=$(cd "$DIR" && pwd)
        break
    fi
done

if [[ "$MARKER_FOUND" != "true" ]]; then
    exit 0
fi

ERRORS=()
WARNINGS=()

# --- Scaffold Validation Checks ---

# SC-01: .git directory exists
if [[ ! -d "${PROJECT_DIR}/.git" ]]; then
    ERRORS+=("[SC-01] .git directory not found — run 'git init' in Phase 1")
fi

# SC-02: .gitignore exists and is non-empty
if [[ ! -f "${PROJECT_DIR}/.gitignore" ]]; then
    ERRORS+=("[SC-02] .gitignore not found — create stack-appropriate .gitignore")
elif [[ ! -s "${PROJECT_DIR}/.gitignore" ]]; then
    ERRORS+=("[SC-02] .gitignore is empty — add patterns for node_modules, .env, build dirs")
fi

# SC-03: Package manager config exists
if [[ ! -f "${PROJECT_DIR}/package.json" ]] && \
   [[ ! -f "${PROJECT_DIR}/pyproject.toml" ]] && \
   [[ ! -f "${PROJECT_DIR}/Cargo.toml" ]]; then
    WARNINGS+=("[SC-03] No package manager config found (package.json / pyproject.toml) — expected after Phase 2")
fi

# SC-04: Test directory exists
if [[ ! -d "${PROJECT_DIR}/tests" ]] && \
   [[ ! -d "${PROJECT_DIR}/__tests__" ]] && \
   [[ ! -d "${PROJECT_DIR}/test" ]]; then
    WARNINGS+=("[SC-04] No test directory found — expected after Phase 3")
fi

# SC-05: CI config exists
if [[ ! -d "${PROJECT_DIR}/.github/workflows" ]]; then
    WARNINGS+=("[SC-05] .github/workflows/ not found — expected after Phase 5")
elif [[ -z "$(ls -A "${PROJECT_DIR}/.github/workflows/" 2>/dev/null)" ]]; then
    WARNINGS+=("[SC-05] .github/workflows/ is empty — add ci.yml in Phase 5")
fi

# SC-06: .env.example exists (check only if package.json mentions db scripts)
if [[ -f "${PROJECT_DIR}/package.json" ]]; then
    HAS_DB=$(python3 -c "
import json, sys
try:
    with open('${PROJECT_DIR}/package.json') as f:
        pkg = json.load(f)
    scripts = pkg.get('scripts', {})
    has_db = any(k.startswith('db:') for k in scripts)
    print('yes' if has_db else 'no')
except:
    print('no')
" 2>/dev/null || echo "no")

    if [[ "$HAS_DB" == "yes" ]] && [[ ! -f "${PROJECT_DIR}/.env.example" ]]; then
        WARNINGS+=("[SC-06] .env.example not found — DB scripts present but no env template")
    fi
fi

# SC-07: Root CLAUDE.md exists
if [[ ! -f "${PROJECT_DIR}/CLAUDE.md" ]]; then
    ERRORS+=("[SC-07] Root CLAUDE.md not found — must be created with project info")
fi

# --- Output Results ---

ERROR_COUNT=${#ERRORS[@]}
WARNING_COUNT=${#WARNINGS[@]}

if [[ "$ERROR_COUNT" -eq 0 && "$WARNING_COUNT" -eq 0 ]]; then
    RESULT="SCAFFOLD VALIDATION PASSED: All checks passed for current phase."
else
    RESULT="SCAFFOLD VALIDATION RESULTS:\\n"

    if [[ "$ERROR_COUNT" -gt 0 ]]; then
        RESULT+="\\nERRORS ($ERROR_COUNT) — must fix:\\n"
        for err in "${ERRORS[@]}"; do
            RESULT+="  - $err\\n"
        done
    fi

    if [[ "$WARNING_COUNT" -gt 0 ]]; then
        RESULT+="\\nWARNINGS ($WARNING_COUNT) — expected in later phases:\\n"
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
