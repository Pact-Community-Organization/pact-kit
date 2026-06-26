#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
agents_dir="$repo_root/agents"

if [[ ! -d "$agents_dir" ]]; then
  echo "[hooks][pre-tool-use] agents directory not found: $agents_dir"
  exit 0
fi

# Warn if any case-insensitive duplicate agent filenames exist.
duplicates="$({ find "$agents_dir" -maxdepth 1 -type f -name '*.agent.md' -printf '%f\n' 2>/dev/null || true; } | awk '{print tolower($0)}' | sort | uniq -d)"
if [[ -n "$duplicates" ]]; then
  echo "[hooks][pre-tool-use] warning: duplicate agent filenames detected (case-insensitive):"
  echo "$duplicates"
fi

if [[ ! -f "$agents_dir/admin.agent.md" ]]; then
  echo "[hooks][pre-tool-use] warning: missing canonical coordinator agent: agents/admin.agent.md"
fi

exit 0
