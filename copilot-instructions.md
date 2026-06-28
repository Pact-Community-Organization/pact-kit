# Pact 5 / KDA-CE — Copilot Instructions

Reusable instructions for Pact and Kadena projects. Vendor-neutral; AGENTS.md is the primary
always-on context for tools that read it natively (Gemini CLI, Cursor, Windsurf, and others).
These instructions target GitHub Copilot specifically.

## Session start

Load project context once per session; do not re-read it for every task. Check the project's
module registry before creating a file. Scope, identity, and file-placement gates are enforced
by `clarification-protocol` and `workspace-conventions` (in `~/.claude/instructions/`).

## Non-negotiables

- Static analysis: `~/.claude/scripts/pact-static-check.sh` must exit 0 before any `.pact`/`.repl` change ships. Never bypass.
- Transparency-first: business-critical state lives on-chain by default; justify any off-chain logic.
- No architecture change without an ADR.
- Minimal-first: stop at the first rung that holds — reuse, then stdlib, then one line, then minimum that works.

## Load on demand

Skills in `~/.claude/skills/`, instructions in `~/.claude/instructions/`. Pull the relevant
section of `pact-traps.md` on any `.pact`/`.repl` edit — it is large and not auto-loaded.

Before shipping any module, invoke `pact-auditor` (`~/.claude/agents/pact-auditor.md`) for an
independent security review.
