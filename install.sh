#!/usr/bin/env bash
# install.sh — One-command installer for the aether-dev Claude Code plugin
# Usage: curl -fsSL https://raw.githubusercontent.com/arnavmarda/aether-dev/main/install.sh | bash

set -euo pipefail

REPO="aether-auto/aether-dev"
PLUGIN="aether-dev"
MARKETPLACE="aether-dev"

BOLD="\033[1m"
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

echo -e "${BOLD}aether-dev installer${RESET}"
echo "───────────────────────────────────"

# Preflight: check Claude Code is installed
if ! command -v claude &>/dev/null; then
  echo -e "${RED}Error: Claude Code CLI not found.${RESET}"
  echo "Install it first: https://docs.anthropic.com/en/docs/claude-code"
  exit 1
fi

# Step 1: Add the marketplace
echo "Adding marketplace..."
claude plugin marketplace add "$REPO"

# Step 2: Install the plugin
echo "Installing plugin..."
claude plugin install "${PLUGIN}@${MARKETPLACE}"

echo ""
echo -e "${GREEN}${BOLD}aether-dev installed successfully!${RESET}"
echo ""
echo "Available commands:"
echo "  /ideate      — Interactive product ideation"
echo "  /setup       — Generate CLAUDE.md and agent docs from spec"
echo "  /gen-tasks   — Decompose spec into buildable task files"
echo "  /ui-specs    — Generate UI specifications and design tokens"
echo "  /scaffold    — Scaffold project structure and configs"
echo "  /build       — TDD ticket implementation with agent teams"
echo "  /review      — Code review with parallel specialist agents"
echo "───────────────────────────────────"
