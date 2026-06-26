# Pact agent marketplace — Tier 1 (always-on router)

Reusable Copilot customizations for Pact and Kadena projects. Pact runs on multiple platforms; these defaults stay vendor-neutral and portable.

## Session start (read once)

If your project uses a session-start memory or registry convention, load it once per session and then rely on that context instead of re-reading it for every task. Check a file registry if your project keeps one before creating a file. Scope, identity, irreversible-action, and file-placement gates are enforced by the always-on `clarification-protocol` and `workspace-conventions` — follow them, do not restate.

## Universal non-negotiables (no narrower home)

- Pact deploys require `.github/scripts/pact-static-check.sh` exit 0 — never bypass.
- Transparency-first: business-critical state and final outcomes on-chain by default; justify any off-chain logic.
- Stability over churn: no architecture-changing refactor without a problem statement, alternatives, and ADR approval.
- Code-touching work is minimal-first (`ponytail` skill) unless the user explicitly overrides.

## Read only what the task needs

Your context already lists every instruction (with its `applyTo`), skill, and agent description — trust those to self-route; do not duplicate them here. Beyond that auto-routing:

- Domain rules load by path: Pact → `pact-rules` (`*.pact`/`*.repl`); TS SDK → `typescript-sdk`; deploy/gas/security/testing → their `*-rules` instructions.
- Pact language traps: pull the matching section of `pact-traps.instructions.md` on demand — large, not auto-loaded.
- Cross-project status & roles: if your project keeps a status/roles registry, use that single source of truth.
- Guardrail mechanism (hooks/scripts, secret scan): `github-guardrails.instructions.md` — loads for `.github/hooks|scripts`.
