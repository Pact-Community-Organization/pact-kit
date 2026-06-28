---
description: "Runtime guardrails: Claude Code hooks, blocked terminal commands, and session-end secrets scan. Read when configuring hooks or reviewing guardrail rules."
---
# Runtime Guardrails

## Claude Code Hooks (configured in <project>/.claude/settings.json)

| Event | Script | Purpose |
|---|---|---|
| `Stop` | `.github/scripts/session-end-secrets-scan.sh` | Scan git-modified files for leaked secrets |
| `PostToolUse` (`.pact`/`.repl` edits) | `.github/scripts/pact-static-check.sh` | Static analysis gate on every Pact file change |

Hook scripts live in `.github/scripts/` (version-controlled with the project, also used by CI).

## Session-End Secrets Scan

Scans git diff / staged files for high-signal secret patterns:
- AWS access keys (`AKIA[A-Z0-9]{16}`)
- GitHub PATs (`ghp_[...]`, `github_pat_[...]`)
- Stripe secret keys (`sk_live_[...]`, `sk_test_[...]`)
- PEM private keys (`-----BEGIN ... PRIVATE KEY-----`)
- JWTs (`eyJ[...].[...].[...]`)
- DB connection strings (`postgres://`, `mongodb://`, `redis://`, etc.)
- Generic secrets (`api_key`, `secret`, `password`, `token` = value)

Placeholder values (example, changeme, your-key, dummy, test-key) are skipped.
Default mode: `warn`. Set `SCAN_MODE=block` to block on findings. Set `SKIP_SECRETS_SCAN=true` for emergency bypass (document why; restore default after).

## Blocked Terminal Commands

The following patterns are blocked by discipline (not by a pre-tool hook — follow these manually):
- `rm -rf` — recursive deletion without review
- `git reset --hard` — discards uncommitted work
- `git push --force` — overwrites remote history
- `git commit --amend` — rewrites published commits
- `docker rm -f` — forced container deletion
- `curl | bash` / `wget | sh` — remote code execution
- `chmod 777` — world-writable permissions
- `sudo` in project scripts — escalation without audit trail
- `npm publish` — without version and changelog review
- Any Pact deploy command before `pact-static-check.sh` exits 0

Break-glass: bypass only for emergency debugging. Document the reason. Restore defaults immediately after.

## Static Analysis Gate

`pact-static-check.sh` runs automatically as a `PostToolUse` hook on `.pact`/`.repl` edits.
Manual run: `bash .github/scripts/pact-static-check.sh [file ...]`

Exit codes: `0` = PASS (fix any WARNs). `1` = FAIL (VIOLATIONs present — fix before proceeding).
