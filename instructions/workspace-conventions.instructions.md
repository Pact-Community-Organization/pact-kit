---
description: "Use for general workspace conventions, file organization, naming patterns, and project structure for the Pact Community community workspace."
applyTo: "**"
# Workspace Conventions

> **MANDATORY:** Read this before creating any new file or directory. Check `docs/memory/FILE-REGISTRY.md` as well.

---

## Canonical Workspace Structure

```
enterprise/                        ← workspace root (single git repo)
├── .github/                       ← ALL agent configs live here — never outside
│   ├── copilot-instructions.md    ← always-on workspace system prompt
│   ├── agents/                    ← agent .agent.md files
│   ├── instructions/              ← *.instructions.md behavioral rules
│   ├── skills/                    ← */SKILL.md domain knowledge files
│   ├── prompts/                   ← *.prompt.md reusable prompts
│   └── hooks/                     ← event hook JSON files
│
├── _archive/                      ← READ-ONLY historical reference
│   ├── README.md                  ← describes all archived content
│   ├── pact-examples/                       ← pre-ADR-012 DAO artifacts
│   ├── equity/                    ← shelved equity project (full git history)
│   ├── website-root-stale/        ← stale web code that was at root (superseded by web-examples/)
│   └── workspace-history/         ← old planning / initialization docs
│
├── coordination/                  ← inter-agent communication system
│   ├── memory/                    ← persistent agent memory (read at session start)
│   │   ├── INDEX.md               ← entry point — read first
│   │   ├── PROJECT-STATE.md       ← cross-project status
│   │   ├── FILE-REGISTRY.md       ← canonical doc anti-duplication registry
│   │   ├── SESSION-LOG.md         ← append-only session handoff log
│   │   └── *.md                   ← domain memory files
│   ├── mailboxes/                 ← per-agent JSON mailboxes
│   ├── tasks/                     ← task queue
│   ├── status/                    ← machine-readable status (dashboard.json)
│   └── artifacts/                 ← agent-produced artifacts (scans, bundles, reports)
│
├── pact-examples/                           ← DAO smart contract project
│   ├── pact-community/
│   │   ├── modules/               ← ACTIVE .pact source files (dao.pact, governance-types.pact, gas-relayer.pact)
│   │   ├── interfaces/            ← Pact interface files
│   │   ├── tests/                 ← ACTIVE .repl test files
│   │   ├── deploy/                ← deploy scripts
│   │   └── kda-env/               ← keyset/env files
│   ├── ts/                        ← TypeScript tooling for DAO
│   │   ├── src/                   ← source (client, utils)
│   │   ├── scripts/               ← deploy/seed/diagnostic scripts
│   │   └── tests/devnet/          ← devnet integration tests
│   ├── docs/                      ← DAO documentation
│   │   ├── adr/                   ← ADR-001 through ADR-012 (ADR-012 is current)
│   │   ├── processes/             ← PROC-001 through PROC-018 operational runbooks
│   │   ├── AUDIT-REPORT-ADR012-2026-06.md  ← CURRENT audit (CONDITIONAL PASS)
│   │   └── *.md                   ← architecture, API signatures, capability docs
│   ├── devnet/                    ← devnet config (certs, config)
│   ├── scripts/                   ← monitoring scripts
│   ├── docker-compose.*.yml       ← per-agent devnet compose files
│   ├── CHANGELOG.md
│   ├── README.md
│   └── TESTNET-DEPLOYMENT-SUMMARY.md
│
├── ledger-examples/                 ← Ledger hardware wallet signer (separate git repo)
│   └── packages/                  ← core, cli, web packages
│
├── mcp/                           ← MCP servers (pact, chainweb, coordination)
│   └── packages/                  ← per-server packages
│
├── web-examples/                       ← Web codebase (separate git repo — AUTHORITATIVE)
│   ├── apps/                      ← marketing/, stakeholder-app/, admin-app/
│   ├── packages/                  ← pact-bindings/, ui/, web-config/
│   ├── e2e/                       ← Playwright E2E tests
│   ├── scripts/                   ← web build/audit scripts
│   ├── docs/                      ← website-specific docs (ADRs, ops, backlog)
│   ├── infra/                     ← Terraform (Cloudflare)
│   ├── docs/artifacts/    ← Playwright test artifacts (NOT agent memory)
│   └── AGENTS.md                  ← website-scoped agent notes
│
├── scripts/                       ← operational scripts for the FULL enterprise stack
│   ├── mvp-up.sh                  ← start full local MVP (devnet + web)
│   ├── mvp-down.sh                ← stop full local MVP
│   ├── mvp-status.sh              ← check MVP status
│   └── web-restart.sh             ← restart web dev server only
│
├── .github/                       ← (see above)
├── .git/                          ← community workspace git
├── .gitignore
├── enterprise.code-workspace      ← VS Code workspace config
├── package.json                   ← minimal: format scripts only (no app workspace)
├── README.md                      ← community workspace overview
├── AGENTS.md                      ← website-scoped agent notes (loaded by VS Code)
├── COOKBOOK.md                    ← developer quick-reference (live doc)
└── MVP-USER-MANUAL.md             ← end-user guide for local MVP (live doc)
```

---

## File Placement Rules

### New files MUST go here:

| File type | Correct location | NEVER put in |
|-----------|-----------------|--------------|
| Pact smart contract (`.pact`) | `pact-examples/pact-community/modules/` | root, pact-examples/, anywhere else |
| Pact REPL test (`.repl`) | `pact-examples/pact-community/tests/` | pact-examples/ root, anywhere else |
| DAO TypeScript deploy/seed script | `pact-examples/ts/scripts/` | pact-examples/ts/ root |
| DAO TypeScript devnet test | `pact-examples/ts/tests/devnet/` | pact-examples/ts/ root |
| DAO ADR | `pact-examples/docs/adr/ADR-0NN-name.md` | anywhere else |
| DAO operational runbook (PROC-*) | `pact-examples/docs/processes/` | anywhere else |
| DAO architecture/API doc | `pact-examples/docs/` | pact-examples/ root |
| Agent behavioral rule | `.github/instructions/topic.instructions.md` | root, coordination/ |
| Agent skill | `.github/skills/skill-name/SKILL.md` | root, coordination/ |
| Agent prompt | `.github/prompts/action.prompt.md` | root |
| Agent definition | `.github/agents/Name.agent.md` | root |
| Cross-project status | `docs/memory/PROJECT-STATE.md` | anywhere else |
| Security finding | `docs/memory/security-findings.md` | anywhere else |
| Session handoff note | `docs/memory/SESSION-LOG.md` (append) | anywhere else |
| New canonical artifact | Register in `docs/memory/FILE-REGISTRY.md` | — |
| Agent coordination artifact | `docs/artifacts/` | root, .github/ |
| Web app code | `web-examples/apps/<app-name>/src/` | root apps/ (stale) |
| Web shared package | `web-examples/packages/<pkg-name>/src/` | root packages/ (stale) |
| Web E2E test | `web-examples/e2e/tests/` | root e2e/ (stale) |
| Web operational script | `web-examples/scripts/` | root scripts/ (web-specific ones are there) |
| Enterprise operational script | `scripts/` (root) | web-examples/scripts/ |
| Archived/obsolete content | `_archive/` with a README | anywhere in active tree |

### Anti-duplication rules

1. **Check `docs/memory/FILE-REGISTRY.md` before creating any doc.** If a canonical file exists, UPDATE it.
2. **Never create `STATUS.md`, `TODO.md`, `NOTES.md` in project directories.** Use `docs/memory/` files.
3. **Never create a second ADR index.** Use `pact-examples/docs/adr/INDEX.md`.
4. **Debug / temp files belong in `pact-examples/ts/` root only during active debugging**, then move to `_archive/pact-examples/legacy-typescript/` when done.
5. **Runtime artifacts (`.log`, `.pid`) are gitignored** — never commit them.

---

## Active Projects

| Project | Root path | Git | Status |
|---------|-----------|-----|--------|
| DAO (smart contracts) | `pact-examples/` | enterprise repo | Active — Gate-2 GO, testnet pending |
| Ledger Signer | `ledger-examples/` | own repo | Active — MVP complete |
| Website (web apps) | `web-examples/` | own repo | Active — Sprint 5 complete |
| MCP servers | `mcp/` | enterprise repo | Active |
| Equity | `_archive/equity/` | own repo (archived) | Shelved |

---

## Naming Conventions

| Artifact | Pattern | Example |
|----------|---------|---------|
| Instructions file | `{topic}.instructions.md` | `pact-rules.instructions.md` |
| Skill | `{skill-name}/SKILL.md` | `pact-repl-testing/SKILL.md` |
| Prompt | `{action}.prompt.md` | `deploy-dao.prompt.md` |
| Agent | `{AgentName}.agent.md` | `Developer.agent.md` |
| ADR | `ADR-{NNN}-{kebab-name}.md` | `ADR-012-single-module-consolidation.md` |
| Process | `PROC-{NNN}-{kebab-name}.md` | `PROC-018-testnet06-governance-deploy.md` |
| Devnet compose | `docker-compose.{agent}.yml` | `docker-compose.tester.yml` |
| Test file | `{scope}-{description}.test.ts` | `tester-sec005-consolidated.test.ts` |

---

## What DOES NOT belong in this workspace root

- **Web app source code** — lives in `web-examples/`
- **Web build configs** (eslint, tsconfig, prettier for apps) — lives in `web-examples/`
- **Web workspace files** (pnpm-workspace.yaml for apps) — lives in `web-examples/`
- **Story/sprint summaries** — archive in `_archive/workspace-history/`
- **Planning/implementation plans** — archive in `_archive/workspace-history/`
- **Temp/debug scripts** — remove or archive when no longer needed
