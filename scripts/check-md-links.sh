#!/usr/bin/env bash
# check-md-links.sh — verify that relative markdown links resolve to real files.
# Catches the class of breakage introduced by bulk path rewrites (e.g. the
# ~/.claude/ <-> relative-path extraction sed). External links are not fetched.

set -euo pipefail

ROOT="${1:-.}"
fail=0

while IFS= read -r f; do
  dir="$(dirname "$f")"
  while IFS= read -r link; do
    [ -n "$link" ] || continue
    case "$link" in
      http://*|https://*|mailto:*|'#'*) continue ;;
    esac
    target="${link%%#*}"
    [ -n "$target" ] || continue
    if [ ! -e "$dir/$target" ]; then
      printf 'BROKEN: %s -> %s\n' "$f" "$link"
      fail=1
    fi
  done < <(grep -oE '\]\([^)]+\)' "$f" 2>/dev/null | sed -E 's/^\]\(//; s/\)$//' || true)
done < <(find "$ROOT" -name '*.md' -not -path '*/.git/*' -not -path '*/node_modules/*' -type f)

if [ "$fail" -eq 0 ]; then
  echo "All relative markdown links resolve."
fi
exit "$fail"
