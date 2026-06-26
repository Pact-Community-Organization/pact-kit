#!/usr/bin/env bash
# Stop (session-end) hook — scans modified files for potential secret leakage.
# Exits non-zero only when SCAN_MODE=block and findings are present.

set -euo pipefail

run_customization_guard() {
  if [[ "${CUSTOMIZATION_GUARD_ENABLE:-true}" != "true" ]]; then
    return 0
  fi

  local agent_max_lines="${AGENT_FILE_MAX_LINES:-320}"
  local guard_log_dir="${CUSTOMIZATION_GUARD_LOG_DIR:-.github/logs/copilot/customization-guard}"
  local guard_log_file="$guard_log_dir/scan.log"
  local warning_count=0

  mkdir -p "$guard_log_dir"

  for file in .github/agents/*.agent.md; do
    [[ -f "$file" ]] || continue

    local line_count
    line_count=$(wc -l < "$file")
    if (( line_count > agent_max_lines )); then
      ((warning_count += 1))
      printf 'CUSTOMIZATION_GUARD_WARN|oversize_agent|%s|lines=%d|max=%d\n' "$file" "$line_count" "$agent_max_lines"
    fi

    if grep -qiE 'current per-project status:|no active project' "$file"; then
      ((warning_count += 1))
      printf 'CUSTOMIZATION_GUARD_WARN|stale_project_state_literal|%s\n' "$file"
    fi
  done

  printf '{"timestamp":"%s","event":"customization_guard","status":"complete","warning_count":%d,"agent_max_lines":%d}\n' \
    "$(date -u +%FT%TZ)" "$warning_count" "$agent_max_lines" >> "$guard_log_file"
}

if [[ "${SKIP_SECRETS_SCAN:-}" == "true" ]]; then
  run_customization_guard
  exit 0
fi

SCAN_MODE="${SCAN_MODE:-warn}"
SCAN_SCOPE="${SCAN_SCOPE:-diff}"
SECRETS_LOG_DIR="${SECRETS_LOG_DIR:-.github/logs/copilot/secrets}"
SECRETS_ALLOWLIST="${SECRETS_ALLOWLIST:-}"

mkdir -p "$SECRETS_LOG_DIR"
LOG_FILE="$SECRETS_LOG_DIR/scan.log"

if [[ "$SCAN_SCOPE" == "staged" ]]; then
  mapfile -t CANDIDATE_FILES < <(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)
else
  mapfile -t CANDIDATE_FILES < <(git diff --name-only --diff-filter=ACMR HEAD 2>/dev/null || true)
fi

if [[ ${#CANDIDATE_FILES[@]} -eq 0 ]]; then
  printf '{"timestamp":"%s","event":"scan_complete","mode":"%s","scope":"%s","status":"no_files"}\n' \
    "$(date -u +%FT%TZ)" "$SCAN_MODE" "$SCAN_SCOPE" >> "$LOG_FILE"
  run_customization_guard
  exit 0
fi

is_text_file() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  file "$file" 2>/dev/null | grep -qiE 'text|json|xml|yaml|script|ascii|utf-8'
}

is_skipped_file() {
  local file="$1"
  [[ "$file" =~ (^|/)pnpm-lock\.yaml$|(^|/)package-lock\.json$|(^|/)yarn\.lock$|(^|/)\.git/ ]]
}

is_placeholder_match() {
  local value="$1"
  printf '%s' "$value" | grep -qiE 'example|changeme|your[_-]|placeholder|dummy|test[_-]?key'
}

matches_allowlist() {
  local value="$1"
  if [[ -z "$SECRETS_ALLOWLIST" ]]; then
    return 1
  fi
  IFS=',' read -r -a ALLOW_PATTERNS <<< "$SECRETS_ALLOWLIST"
  for pattern in "${ALLOW_PATTERNS[@]}"; do
    pattern="$(printf '%s' "$pattern" | xargs)"
    [[ -z "$pattern" ]] && continue
    if printf '%s' "$value" | grep -qiE "$pattern"; then
      return 0
    fi
  done
  return 1
}

PATTERNS=(
  'AWS_ACCESS_KEY|critical|AKIA[0-9A-Z]{16}'
  'GITHUB_PAT|critical|ghp_[A-Za-z0-9_]{20,}'
  'GITHUB_FINE_GRAINED_PAT|critical|github_pat_[A-Za-z0-9_]{20,}'
  'SLACK_TOKEN|high|xox[baprs]-[A-Za-z0-9-]{10,}'
  'STRIPE_SECRET_KEY|critical|sk_(live|test)_[A-Za-z0-9]{16,}'
  'PRIVATE_KEY|critical|-----BEGIN (RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY-----'
  "GENERIC_SECRET|high|(api[_-]?key|secret|password|token)[[:space:]]*[:=][[:space:]]*[\"']?[A-Za-z0-9_\-\.]{10,}"
  'JWT_TOKEN|medium|eyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}'
  'CONNECTION_STRING|high|(postgres(ql)?|mysql|mongodb(\+srv)?|redis)://[^[:space:]]+'
)

FINDINGS=()
SCANNED=0

for path in "${CANDIDATE_FILES[@]}"; do
  if is_skipped_file "$path"; then
    continue
  fi

  if ! is_text_file "$path"; then
    continue
  fi

  ((SCANNED += 1))

  for entry in "${PATTERNS[@]}"; do
    IFS='|' read -r name severity regex <<< "$entry"
    while IFS=: read -r lineno line; do
      [[ -n "$lineno" ]] || continue
      if is_placeholder_match "$line"; then
        continue
      fi
      if matches_allowlist "$line"; then
        continue
      fi
      redacted="$(printf '%s' "$line" | cut -c1-80)"
      FINDINGS+=("$path|$lineno|$name|$severity|$redacted")
    done < <(grep -nE "$regex" "$path" 2>/dev/null || true)
  done
done

if [[ ${#FINDINGS[@]} -eq 0 ]]; then
  echo "No secrets detected in $SCANNED scanned file(s)."
  printf '{"timestamp":"%s","event":"scan_complete","mode":"%s","scope":"%s","status":"clean","files_scanned":%d}\n' \
    "$(date -u +%FT%TZ)" "$SCAN_MODE" "$SCAN_SCOPE" "$SCANNED" >> "$LOG_FILE"
  run_customization_guard
  exit 0
fi

echo "Potential secrets detected: ${#FINDINGS[@]} finding(s)."
echo "FILE|LINE|PATTERN|SEVERITY|SNIPPET"
for item in "${FINDINGS[@]}"; do
  echo "$item"
done

printf '{"timestamp":"%s","event":"secrets_found","mode":"%s","scope":"%s","files_scanned":%d,"finding_count":%d}\n' \
  "$(date -u +%FT%TZ)" "$SCAN_MODE" "$SCAN_SCOPE" "$SCANNED" "${#FINDINGS[@]}" >> "$LOG_FILE"

if [[ "$SCAN_MODE" == "block" ]]; then
  run_customization_guard
  echo "Session blocked due to potential secret exposure."
  exit 2
fi

run_customization_guard

exit 0
