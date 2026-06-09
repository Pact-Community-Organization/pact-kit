# Pact Community — community workspace

**Pact Community** builds Pact 5 smart contracts on **Kadena Community Edition (KDA-CE)** — a 20-chain braided proof-of-work blockchain.

## Quick Reference

| Resource | Path | When to Read |
|---|---|---|
| Project state & task status | `docs/memory/INDEX.md` → `PROJECT-STATE.md` | START of every non-trivial task |
| File registry (anti-duplication) | `docs/memory/FILE-REGISTRY.md` | BEFORE creating any new file |
| Workspace layout & naming | `.github/instructions/workspace-conventions.instructions.md` | Before adding files/dirs |
| Pact 5 critical traps | `.github/instructions/pact-traps.instructions.md` | All Pact work |
| Agent registry & roles | `docs/memory/AGENT-REGISTRY.md` | Multi-agent coordination |
| Quality gates | `.github/instructions/quality-gate-rules.instructions.md` | Before merging/deploying |

## Stack

Pact 5 · KDA-CE · TypeScript/Node.js · devnet (Docker) / testnet06 / mainnet01  
Gas ceiling: **150,000** per tx · API: `https://api.chainweb-community.org`

## Non-Negotiables (Every Agent, Every Task)

1. **Read `docs/memory/INDEX.md` first** on every non-trivial task — no exceptions.
2. **Check `FILE-REGISTRY.md` before creating files** — update a canonical file instead.
3. **All Pact deploys require `pact-static-check.sh` exit 0** — no bypasses.
4. **Decimal serialization**: always `{ decimal: 'N.0' }` in TypeScript SDK — never raw JS numbers.
5. **`pact-id` is NOT a sufficient access guard** — use composed capabilities.
6. **Never assume — ask** when scope, file identity, or irreversible actions are unclear.
7. **Transparency-first blockchain design**: business-critical state transitions and final outcomes are on-chain by default; minimize off-chain logic and justify it.
8. **Stability over churn**: no architecture-changing refactor without an explicit problem statement, alternatives, and ADR-backed approval.

## Output Conventions

All agents prefix outputs with `[AgentName]`. Severity: `[CRITICAL]` · `[HIGH]` · `[MEDIUM]` · `[LOW]`. Uncertain findings: `[UNCERTAIN]`. Deployment verdicts: `[GO]` / `[NO-GO]`.

## Projects

| Project | Path | Status |
|---|---|---|
| DAO (smart contracts) | `pact-examples/` | Active — Gate-2 GO, testnet pending |
| Ledger Signer | `ledger-examples/` | Active — MVP complete |
| Website | `web-examples/` | Active — Sprint 5 complete |
| MCP servers | `mcp/` | Active |

_Archived (not in scope): `_archive/equity/`, `_archive/pact-examples/`, `_archive/website-root-stale/`_
