#!/usr/bin/env bash
# Pact 5 static-analysis gate for generic Copilot/Pact customization bundles.

set -euo pipefail

VIOLATIONS=0
WARNINGS=0

emit_violation() { printf 'VIOLATION: %s\n' "$1"; VIOLATIONS=$((VIOLATIONS + 1)); }
emit_warn() { printf 'WARN:      %s\n' "$1"; WARNINGS=$((WARNINGS + 1)); }
notice() { printf 'NOTICE:    %s\n' "$1"; }

is_missing_msg_data_error() {
  # Errors that mean "this file needs its deploy/test environment (env-data,
  # namespaces, keysets), not that the code is wrong" — bare load can't verify.
  printf '%s' "$1" | grep -qiE \
    'read-(msg|keyset|string|integer|decimal)|no (env-)?data|not (present|found) in (the )?(message|environment|tx)|key .* not found|environment data|namespace not found|cannot find keyset'
}

FILES=()
if [ "$#" -gt 0 ]; then
  for arg in "$@"; do
    if [ -f "$arg" ]; then
      FILES+=("$arg")
    else
      notice "skipping non-file argument: $arg"
    fi
  done
else
  while IFS= read -r f; do
    FILES+=("$f")
  done < <(find . \
    \( -path '*/node_modules/*' -o -path '*/.git/*' -o -path '*/dist/*' \) -prune -o \
    \( -name '*.pact' -o -name '*.repl' \) -type f -print | sort)
fi

if [ "${#FILES[@]}" -eq 0 ]; then
  notice "no .pact / .repl files to check"
  exit 0
fi

printf '== pact-static-check :: %d file(s) ==\n' "${#FILES[@]}"

if command -v pact >/dev/null 2>&1; then
  printf -- '-- Tier 1: pact <file> / --check-shadowing --\n'
  for f in "${FILES[@]}"; do
    if ! out="$(pact "$f" 2>&1)"; then
      if is_missing_msg_data_error "$out"; then
        emit_warn "$f: module requires tx message data (read-msg/read-keyset) — bare load can't verify; run full .repl harness"
        printf '%s\n' "$out" | sed 's/^/           /'
      else
        emit_violation "$f: pact load failed"
        printf '%s\n' "$out" | sed 's/^/           /'
      fi
    fi
    if ! out="$(pact --check-shadowing "$f" 2>&1)"; then
      emit_violation "$f: pact --check-shadowing failed (native shadowing)"
      printf '%s\n' "$out" | sed 's/^/           /'
    fi
  done
else
  notice "pact binary not on PATH — Tier 1 (parse/shadowing/type) SKIPPED."
  notice "Install or point to a Pact 5.3 binary for full coverage."
fi

printf -- '-- Tier 2: semantic greps --\n'

scan_file() {
  _file="$1"; _re="$2"; _kind="$3"; _rule="$4"
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    _ln="${line%%:*}"
    case "$_kind" in
      violation) emit_violation "$_file:$_ln $_rule" ;;
      warn) emit_warn "$_file:$_ln $_rule" ;;
    esac
  done < <(grep -nE "$_re" "$_file" 2>/dev/null || true)
}

for f in "${FILES[@]}"; do
  case "$f" in
    *.pact|*.repl) : ;;
    *) continue ;;
  esac

  scan_file "$f" 'expect-failure[[:space:]]+""([[:space:]]|\))' \
    violation 'empty expect-failure "" — empty substring matches any error (false pass)'

  scan_file "$f" '\(\+[[:space:]]+[^()[:space:]]+[[:space:]]+[^()[:space:]]+[[:space:]]+[^()[:space:]]+' \
    violation '3+ argument (+ ...) on one line — + is binary; nest as (+ a (+ b c))'

  scan_file "$f" '\(try\b.*\b(insert|update|write)\b' \
    violation 'DML (insert/update/write) inside try — try is read-only for DML'

  scan_file "$f" '\(enforce[[:space:]][^)]*\((read|with-read|with-default-read|select|fold-db|keys)[[:space:]]' \
    warn 'table read inside an enforce condition — passes in the REPL but FAILS on the KDA-CE node; let-bind the read before the enforce (same-line matches only; reads via helper fns are not detected)'

  scan_file "$f" '\(defcap[[:space:]]+[A-Z][A-Z0-9_-]*[[:space:]]*\([[:space:]]*\)[[:space:]]+true[[:space:]]*\)' \
    violation 'governance/defcap body is literally `true` — anyone can satisfy it'

  scan_file "$f" 'create-(module|pact)-guard' \
    violation 'deprecated guard constructor — use keyset / capability / user guards'

  scan_file "$f" '(\(!=[[:space:]]+""[[:space:]]+\(pact-id\)|\(enforce\b[^)]*\(pact-id\))' \
    violation 'pact-id used as an auth guard — gate access on a composed capability instead'

  scan_file "$f" '\b(enforce-guard|enforce-keyset)\b' \
    warn 'enforce-guard/enforce-keyset — confirm it sits inside a defcap (scoped signature), not a bare defun'

  scan_file "$f" '\b(mod|round|floor|ceiling|abs|exp|log|ln|sqrt)[[:space:]]*:=' \
    warn 'binds a native name (:=) — confirm with pact --check-shadowing (load-time error in 5.1+)'
  scan_file "$f" '\([[:space:]]*(mod|round|floor|ceiling|abs|exp|log|ln|sqrt)[[:space:]]*:' \
    warn 'native name used as a typed parameter — confirm with pact --check-shadowing'
done

printf -- '-- summary --\n'
printf 'VIOLATIONs: %d   WARNs: %d   files: %d\n' "$VIOLATIONS" "$WARNINGS" "${#FILES[@]}"

if [ "$VIOLATIONS" -gt 0 ]; then
  printf 'RESULT: FAIL (fix all VIOLATIONs before the edit/deploy is complete)\n'
  exit 1
fi
printf 'RESULT: PASS%s\n' "$( [ "$WARNINGS" -gt 0 ] && printf ' (with %d WARN — review)' "$WARNINGS" )"
exit 0
