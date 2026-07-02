#!/usr/bin/env bash
# pact-check-hook.sh — PostToolUse hook adapter for pact-static-check.sh.
#
# The raw static checker, wired directly as a hook, runs a full-directory
# scan on EVERY Edit/Write — including non-Pact files. This adapter reads
# the hook JSON payload on stdin, extracts the edited file path, and runs
# the gate only when that file is a .pact/.repl — and only on that file.
#
# Exit codes: 0 = pass or not applicable; 2 = violations (fed back to the
# agent as tool feedback by Claude Code).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

payload="$(cat)"

file_path="$(printf '%s' "$payload" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
print((d.get("tool_input") or {}).get("file_path") or "")
' 2>/dev/null)" || file_path=""

case "$file_path" in
  *.pact|*.repl) ;;
  *) exit 0 ;;
esac

[ -f "$file_path" ] || exit 0

if out="$("$SCRIPT_DIR/pact-static-check.sh" "$file_path" 2>&1)"; then
  exit 0
fi
printf '%s\n' "$out" >&2
exit 2
