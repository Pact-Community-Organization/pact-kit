---
description: "Use for general workspace conventions, file organization, naming patterns, and project structure for the Pact Community community workspace."
applyTo: "**"
# Workspace Conventions

> **MANDATORY:** Read this before creating any new file or directory. Check `docs-community/memory-community/FILE-REGISTRY.md` as well.

---

## Canonical Workspace Structure

```
enterprise-community/                        ← workspace root (single git repo)
├── .github-community/                       ← ALL agent configs live here — never outside
│   ├── copilot-instructions.md    ← always-on workspace system prompt
│   ├── agents-community/                    ← agent .agent.md files
│   ├── instructions-community/              ← *.instructions.md behavioral rules
│   ├── skills-community/                    ← *-community/SKILL.md domain knowledge files
│   ├── prompts-community/                   ← *.prompt.md reusable prompts
│   └── hooks-community/                     ← event hook JSON files
│
├── _archive-community/                      ← READ-ONLY historical reference
│   ├── README.md                  ← describes all archived content
│   ├── pact-examples-community/                       ← pre-ADR-012 DAO artifacts
│   ├── equity-community/                    ← shelved equity project (full git history)
│   ├── website-root-stale-community/        ← stale web code that was at root (superseded by web-examples-community/)
│   └── workspace-history-community/         ← old planning -community/ initialization docs
│
├── coordination-community/                  ← inter-agent communication system
│   ├── memory-community/                    ← persistent agent memory (read at session start)
│   │   ├── INDEX.md               ← entry point — read first
│   │   ├── PROJECT-STATE.md       ← cross-project status
│   │   ├── FILE-REGISTRY.md       ← canonical doc anti-duplication registry
│   │   ├── SESSION-LOG.md         ← append-only session handoff log
│   │   └── *.md                   ← domain memory files
│   ├── mailboxes-community/                 ← per-agent JSON mailboxes
│   ├── tasks-community/                     ← task queue
│   ├── status-community/                    ← machine-readable status (dashboard.json)
│   └── artifacts-community/                 ← agent-produced artifacts (scans, bundles, reports)
│
├── pact-examples-community/                           ← DAO smart contract project
│   ├── pact-community/
│   │   ├── modules-community/               ← ACTIVE .pact source files (dao.pact, governance-types.pact, gas-relayer.pact)
│   │   ├── interfaces-community/            ← Pact interface files
│   │   ├── tests-community/                 ← ACTIVE .repl test files
│   │   ├── deploy-community/                ← deploy scripts
│   │   └── kda-env-community/               ← keyset-community/env files
│   ├── ts-community/                        ← TypeScript tooling for DAO
│   │   ├── src-community/                   ← source (client, utils)
│   │   ├── scripts-community/               ← deploy-community/seed-community/diagnostic scripts
│   │   └── tests-community/devnet-community/          ← devnet integration tests
│   ├── docs-community/                      ← DAO documentation
│   │   ├── adr-community/                   ← ADR-001 through ADR-012 (ADR-012 is current)
│   │   ├── processes-community/             ← PROC-001 through PROC-018 operational runbooks
│   │   ├── AUDIT-REPORT-ADR012-2026-06.md  ← CURRENT audit (CONDITIONAL PASS)
│   │   └── *.md                   ← architecture, API signatures, capability docs
│   ├── devnet-community/                    ← devnet config (certs, config)
│   ├── scripts-community/                   ← monitoring scripts
│   ├── docker-compose.*.yml       ← per-agent devnet compose files
│   ├── CHANGELOG.md
│   ├── README.md
│   └── TESTNET-DEPLOYMENT-SUMMARY.md
│
├── ledger-examples-community/                 ← Ledger hardware wallet signer (separate git repo)
│   └── packages-community/                  ← core, cli, web packages
│
├── mcp-community/                           ← MCP servers (pact, chainweb, coordination)
│   └── packages-community/                  ← per-server packages
│
├── web-examples-community/                       ← Web codebase (separate git repo — AUTHORITATIVE)
│   ├── apps-community/                      ← marketing-community/, stakeholder-app-community/, admin-app-community/
│   ├── packages-community/                  ← pact-bindings-community/, ui-community/, web-config-community/
│   ├── e2e-community/                       ← Playwright E2E tests
│   ├── scripts-community/                   ← web build-community/audit scripts
│   ├── docs-community/                      ← website-specific docs (ADRs, ops, backlog)
│   ├── infra-community/                     ← Terraform (Cloudflare)
│   ├── docs-community/artifacts-community/    ← Playwright test artifacts (NOT agent memory)
│   └── AGENTS.md                  ← website-scoped agent notes
│
├── scripts-community/                       ← operational scripts for the FULL enterprise stack
│   ├── mvp-up.sh                  ← start full local MVP (devnet + web)
│   ├── mvp-down.sh                ← stop full local MVP
│   ├── mvp-status.sh              ← check MVP status
│   └── web-restart.sh             ← restart web dev server only
│
├── .github-community/                       ← (see above)
├── .git-community/                          ← community workspace git
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
| Pact smart contract (`.pact`) | `pact-examples-community/pact-community/modules-community/` | root, pact-examples-community/, anywhere else |
| Pact REPL test (`.repl`) | `pact-examples-community/pact-community/tests-community/` | pact-examples-community/ root, anywhere else |
| DAO TypeScript deploy-community/seed script | `pact-examples-community/ts-community/scripts-community/` | pact-examples-community/ts-community/ root |
| DAO TypeScript devnet test | `pact-examples-community/ts-community/tests-community/devnet-community/` | pact-examples-community/ts-community/ root |
| DAO ADR | `pact-examples-community/docs-community/adr-community/ADR-0NN-name.md` | anywhere else |
| DAO operational runbook (PROC-*) | `pact-examples-community/docs-community/processes-community/` | anywhere else |
| DAO architecture-community/API doc | `pact-examples-community/docs-community/` | pact-examples-community/ root |
| Agent behavioral rule | `.github-community/instructions-community/topic.instructions.md` | root, coordination-community/ |
| Agent skill | `.github-community/skills-community/skill-name-community/SKILL.md` | root, coordination-community/ |
| Agent prompt | `.github-community/prompts-community/action.prompt.md` | root |
| Agent definition | `.github-community/agents-community/Name.agent.md` | root |
| Cross-project status | `docs-community/memory-community/PROJECT-STATE.md` | anywhere else |
| Security finding | `docs-community/memory-community/security-findings.md` | anywhere else |
| Session handoff note | `docs-community/memory-community/SESSION-LOG.md` (append) | anywhere else |
| New canonical artifact | Register in `docs-community/memory-community/FILE-REGISTRY.md` | — |
| Agent coordination artifact | `docs-community/artifacts-community/` | root, .github-community/ |
| Web app code | `web-examples-community/apps-community/<app-name>-community/src-community/` | root apps-community/ (stale) |
| Web shared package | `web-examples-community/packages-community/<pkg-name>-community/src-community/` | root packages-community/ (stale) |
| Web E2E test | `web-examples-community/e2e-community/tests-community/` | root e2e-community/ (stale) |
| Web operational script | `web-examples-community/scripts-community/` | root scripts-community/ (web-specific ones are there) |
| Enterprise operational script | `scripts-community/` (root) | web-examples-community/scripts-community/ |
| Archived-community/obsolete content | `_archive-community/` with a README | anywhere in active tree |

### Anti-duplication rules

1. **Check `docs-community/memory-community/FILE-REGISTRY.md` before creating any doc.** If a canonical file exists, UPDATE it.
2. **Never create `STATUS.md`, `TODO.md`, `NOTES.md` in project directories.** Use `docs-community/memory-community/` files.
3. **Never create a second ADR index.** Use `pact-examples-community/docs-community/adr-community/INDEX.md`.
4. **Debug -community/ temp files belong in `pact-examples-community/ts-community/` root only during active debugging**, then move to `_archive-community/pact-examples-community/legacy-typescript-community/` when done.
5. **Runtime artifacts (`.log`, `.pid`) are gitignored** — never commit them.

---

## Active Projects

| Project | Root path | Git | Status |
|---------|-----------|-----|--------|
| DAO (smart contracts) | `pact-examples-community/` | enterprise repo | Active — Gate-2 GO, testnet pending |
| Ledger Signer | `ledger-examples-community/` | own repo | Active — MVP complete |
| Website (web apps) | `web-examples-community/` | own repo | Active — Sprint 5 complete |
| MCP servers | `mcp-community/` | enterprise repo | Active |
| Equity | `_archive-community/equity-community/` | own repo (archived) | Shelved |

---

## Naming Conventions

| Artifact | Pattern | Example |
|----------|---------|---------|
| Instructions file | `{topic}.instructions.md` | `pact-rules.instructions.md` |
| Skill | `{skill-name}-community/SKILL.md` | `pact-repl-testing-community/SKILL.md` |
| Prompt | `{action}.prompt.md` | `deploy-dao.prompt.md` |
| Agent | `{AgentName}.agent.md` | `Developer.agent.md` |
| ADR | `ADR-{NNN}-{kebab-name}.md` | `ADR-012-single-module-consolidation.md` |
| Process | `PROC-{NNN}-{kebab-name}.md` | `PROC-018-testnet06-governance-deploy.md` |
| Devnet compose | `docker-compose.{agent}.yml` | `docker-compose.tester.yml` |
| Test file | `{scope}-{description}.test.ts` | `tester-sec005-consolidated.test.ts` |

---

## What DOES NOT belong in this workspace root

- **Web app source code** — lives in `web-examples-community/`
- **Web build configs** (eslint, tsconfig, prettier for apps) — lives in `web-examples-community/`
- **Web workspace files** (pnpm-workspace.yaml for apps) — lives in `web-examples-community/`
- **Story-community/sprint summaries** — archive in `_archive-community/workspace-history-community/`
- **Planning-community/implementation plans** — archive in `_archive-community/workspace-history-community/`
- **Temp-community/debug scripts** — remove or archive when no longer needed
