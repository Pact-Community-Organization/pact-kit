#!/usr/bin/env bash
# install.sh — install the Pact Community package into ~/.claude/
#
# Usage (one command from anywhere):
#   bash <(curl -fsSL https://raw.githubusercontent.com/Pact-Community-Organization/pact-kit/main/scripts/install.sh)
#
# Or after cloning:
#   bash scripts/install.sh
#
# The script MERGES into ~/.claude/ — it never deletes existing files.
# Run it twice safely; existing files are overwritten only if they came from this package.

set -euo pipefail

REPO_URL="https://github.com/Pact-Community-Organization/pact-kit.git"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
TMP_DIR=""

cleanup() { [ -n "$TMP_DIR" ] && rm -rf "$TMP_DIR"; }
trap cleanup EXIT

# Detect whether we are running from inside a clone or via curl.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/../skills/pact-capabilities.md" ]; then
  SRC="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  echo "Cloning Pact Community package..."
  TMP_DIR="$(mktemp -d)"
  git clone --depth 1 --quiet "$REPO_URL" "$TMP_DIR"
  SRC="$TMP_DIR"
fi

echo "Installing Pact Community package into $CLAUDE_DIR/"
echo ""

mkdir -p \
  "$CLAUDE_DIR/skills" \
  "$CLAUDE_DIR/instructions" \
  "$CLAUDE_DIR/commands" \
  "$CLAUDE_DIR/agents" \
  "$CLAUDE_DIR/scripts"

cp "$SRC/skills/"*.md        "$CLAUDE_DIR/skills/"
cp "$SRC/instructions/"*.md  "$CLAUDE_DIR/instructions/"
cp "$SRC/commands/"*.md      "$CLAUDE_DIR/commands/"
cp "$SRC/agents/pact-auditor.md" "$CLAUDE_DIR/agents/"
cp "$SRC/scripts/pact-static-check.sh" "$CLAUDE_DIR/scripts/"
cp "$SRC/scripts/session-end-secrets-scan.sh" "$CLAUDE_DIR/scripts/"
chmod +x "$CLAUDE_DIR/scripts/"*.sh
cp "$SRC/CLAUDE.md.template" "$CLAUDE_DIR/CLAUDE.md.template"

echo "Installed:"
printf "  %-20s %d files\n" "skills/"       "$(ls "$CLAUDE_DIR/skills/"*.md | wc -l | tr -d ' ')"
printf "  %-20s %d files\n" "instructions/" "$(ls "$CLAUDE_DIR/instructions/"*.md | wc -l | tr -d ' ')"
printf "  %-20s %d files\n" "commands/"     "$(ls "$CLAUDE_DIR/commands/"*.md | wc -l | tr -d ' ')"
printf "  %-20s %s\n"       "agents/"       "pact-auditor.md"
printf "  %-20s %d scripts\n" "scripts/"    "$(ls "$CLAUDE_DIR/scripts/"*.sh | wc -l | tr -d ' ')"
echo ""
echo "Next steps:"
echo ""
echo "  1. Copy the starter configuration and fill in the identity placeholder:"
echo "       cp '$CLAUDE_DIR/CLAUDE.md.template' '$CLAUDE_DIR/CLAUDE.md'"
echo ""
echo "  2. Add the hooks snippet from CLAUDE.md.template to ~/.claude/settings.json"
echo "     to enable automatic static analysis on every .pact and .repl edit."
echo ""
echo "  3. For each Pact project, copy the per-project template:"
echo "       cp '$SRC/project-templates/CLAUDE.md.project' /path/to/project/CLAUDE.md"
echo ""
echo "  4. Before shipping any module, say 'security review' in Claude Code."
