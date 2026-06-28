#!/usr/bin/env bash
# install.sh — copy Pact Community marketplace assets into a target repository.
#
# Usage (one command from anywhere):
#   bash <(curl -fsSL https://raw.githubusercontent.com/Pact-Community-Organization/github-marketplace/main/scripts/install.sh) [TARGET_DIR]
#
# Or after cloning:
#   bash scripts/install.sh [TARGET_DIR]
#
# TARGET_DIR defaults to the current directory.
# Assets are installed into TARGET_DIR/.github/.

set -euo pipefail

REPO="https://github.com/Pact-Community-Organization/github-marketplace.git"
TARGET="${1:-$(pwd)}"
GITHUB_DIR="$TARGET/.github"
TMP_DIR=""

cleanup() { [ -n "$TMP_DIR" ] && rm -rf "$TMP_DIR"; }
trap cleanup EXIT

# If running via curl (not inside a local clone), clone to a temp directory.
if [ ! -f "$(dirname "$0")/../agents/developer.agent.md" ] 2>/dev/null; then
  echo "Cloning Pact Community marketplace..."
  TMP_DIR="$(mktemp -d)"
  git clone --depth 1 --quiet "$REPO" "$TMP_DIR"
  SRC="$TMP_DIR"
else
  SRC="$(cd "$(dirname "$0")/.." && pwd)"
fi

echo "Installing into $GITHUB_DIR/"

mkdir -p \
  "$GITHUB_DIR/agents" \
  "$GITHUB_DIR/skills" \
  "$GITHUB_DIR/instructions" \
  "$GITHUB_DIR/prompts" \
  "$GITHUB_DIR/hooks" \
  "$GITHUB_DIR/scripts"

cp -R "$SRC/agents/." "$GITHUB_DIR/agents/"
cp -R "$SRC/skills/." "$GITHUB_DIR/skills/"
cp -R "$SRC/instructions/." "$GITHUB_DIR/instructions/"
cp -R "$SRC/prompts/." "$GITHUB_DIR/prompts/"
cp -R "$SRC/hooks/." "$GITHUB_DIR/hooks/"
cp "$SRC/.github/scripts/"*.sh "$GITHUB_DIR/scripts/"
chmod +x "$GITHUB_DIR/scripts/"*.sh
cp "$SRC/copilot-instructions.md" "$GITHUB_DIR/copilot-instructions.md"

echo ""
echo "Done. Installed:"
echo "  $GITHUB_DIR/agents/     ($(ls "$GITHUB_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ') agents)"
echo "  $GITHUB_DIR/skills/     ($(ls -d "$GITHUB_DIR/skills/"*/ 2>/dev/null | wc -l | tr -d ' ') skills)"
echo "  $GITHUB_DIR/instructions/  ($(ls "$GITHUB_DIR/instructions/"*.md 2>/dev/null | wc -l | tr -d ' ') instruction files)"
echo "  $GITHUB_DIR/prompts/    ($(ls "$GITHUB_DIR/prompts/"*.md 2>/dev/null | wc -l | tr -d ' ') prompts)"
echo "  $GITHUB_DIR/hooks/      ($(ls "$GITHUB_DIR/hooks/"*.json 2>/dev/null | wc -l | tr -d ' ') hooks)"
echo "  $GITHUB_DIR/scripts/    ($(ls "$GITHUB_DIR/scripts/"*.sh 2>/dev/null | wc -l | tr -d ' ') scripts)"
echo ""
echo "Next steps:"
echo "  1. Review $GITHUB_DIR/copilot-instructions.md and adjust for your project."
echo "  2. Stage the new files: git add $GITHUB_DIR/"
echo "  3. See docs/agent-portability.md for per-tool setup (Claude Code, Codex, Gemini CLI)."
