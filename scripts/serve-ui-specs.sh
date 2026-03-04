#!/usr/bin/env bash
# serve-ui-specs.sh — Start/stop a local preview server for UI specs
#
# Usage:
#   bash serve-ui-specs.sh [PORT]     Start server (default port 8420)
#   bash serve-ui-specs.sh --stop     Stop running server
#
# Serves .ui-specs/ directory via python3 http.server. No dependencies required.

set -euo pipefail

SPEC_DIR=".ui-specs"
PID_FILE="$SPEC_DIR/.server.pid"
DEFAULT_PORT=8420

# --- Stop mode ---
if [[ "${1:-}" == "--stop" ]]; then
    if [[ -f "$PID_FILE" ]]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            kill "$PID"
            echo "Server stopped (PID $PID)"
        else
            echo "Server not running (stale PID file)"
        fi
        rm -f "$PID_FILE"
    else
        echo "No server PID file found"
    fi
    exit 0
fi

# --- Start mode ---
if [[ ! -d "$SPEC_DIR" ]]; then
    echo "Error: $SPEC_DIR directory not found. Run /ui-specs first." >&2
    exit 1
fi

if [[ ! -f "$SPEC_DIR/index.html" ]]; then
    echo "Error: $SPEC_DIR/index.html not found. Gallery page required." >&2
    exit 1
fi

# Kill existing server if running
if [[ -f "$PID_FILE" ]]; then
    OLD_PID=$(cat "$PID_FILE")
    kill "$OLD_PID" 2>/dev/null || true
    rm -f "$PID_FILE"
fi

PORT="${1:-$DEFAULT_PORT}"

# Try ports sequentially if in use
for ATTEMPT in $(seq 0 9); do
    TRY_PORT=$((PORT + ATTEMPT))
    if ! lsof -i :"$TRY_PORT" >/dev/null 2>&1; then
        PORT="$TRY_PORT"
        break
    fi
    if [[ "$ATTEMPT" -eq 9 ]]; then
        echo "Error: ports $PORT-$TRY_PORT all in use" >&2
        exit 1
    fi
done

python3 -m http.server "$PORT" -d "$SPEC_DIR" >/dev/null 2>&1 &
SERVER_PID=$!
echo "$SERVER_PID" > "$PID_FILE"

echo "UI Spec gallery serving at: http://localhost:$PORT"
echo "PID: $SERVER_PID"
echo "Stop with: bash $0 --stop"
