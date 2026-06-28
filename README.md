# Pact Agent Marketplace

**24 skills · 16 instructions · 20 slash commands · 1 security agent**

A Claude Code package for Pact 5 / KDA-CE smart contract development. One command installs
the full Pact/Kadena knowledge base into `~/.claude/` — skills, instructions, slash commands,
a security auditor agent, CI scripts, and project templates.

[![License: Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue?style=flat-square)](LICENSE)
[![Release](https://img.shields.io/github/v/release/Pact-Community-Organization/github-marketplace?style=flat-square&label=release)](https://github.com/Pact-Community-Organization/github-marketplace/releases)

---

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Pact-Community-Organization/github-marketplace/main/scripts/install.sh)
```

Or clone first:
```bash
git clone https://github.com/Pact-Community-Organization/github-marketplace.git
bash github-marketplace/scripts/install.sh
```

After running, follow the 4-step guide the script prints:
1. Copy `CLAUDE.md.template` to `~/.claude/CLAUDE.md` and fill in the identity placeholder.
2. Copy `project-templates/CLAUDE.md.project` into each Pact project root.
3. Configure hooks in `~/.claude/settings.json` (snippet in the template).
4. Invoke `pact-auditor` before shipping any module.

### Claude Code plugin (alternative)
```bash
claude plugins add Pact-Community-Organization/github-marketplace
```

### Codex plugin (alternative)
```bash
codex plugins add Pact-Community-Organization/github-marketplace
```

### Gemini CLI (AGENTS.md always-on context)
```bash
gemini extension install https://github.com/Pact-Community-Organization/github-marketplace
```

See [docs/agent-portability.md](docs/agent-portability.md) for per-tool details.

---

## Why Not a Multi-Agent System?

The previous version of this package shipped 8 Copilot agents (Architect, Developer, Tester,
Security, etc.). That model has a fundamental problem: **7 of the 8 agents were knowledge
containers**, not roles that need separate model invocations. They carried copies of the same
Pact facts, which caused drift, duplication, and coordination overhead for a solo developer.

This package replaces them with:

- **24 skills** — Pact/KDA-CE reference knowledge, loaded on demand. One source of truth per topic.
- **16 instructions** — behavioral rules, loaded when relevant. No duplication.
- **20 slash commands** — workflow prompts that combine skills + instructions into structured task
  flows, equivalent to what the agents' slash commands did — without a separate model boundary.
- **1 agent** (`pact-auditor`) — the only role that genuinely needs fresh context: an independent
  security reviewer with no implementation history, to prevent confirmation bias before shipping.

---

## What You Get

### Skills (24) — Pact 5 / KDA-CE domain only

Load with the skill picker or reference in a slash command. No generic software-engineering
skills — ponytail covers the general case.

| Theme | Skills |
|---|---|
| Core language | `pact-capabilities`, `pact-guards`, `pact-schema-design`, `pact-module-design`, `pact-interface-design`, `pact-defpact`, `pact-events`, `pact-architecture`, `pact-invariants` |
| Testing & tooling | `pact-repl-testing`, `pact-devnet-testing`, `pact-module-validation`, `pact-cli-tooling`, `debug-pact`, `static-analysis` |
| Security & audit | `pact-security-review`, `capability-analysis`, `compliance-verification`, `formal-verification` |
| Gas & cross-chain | `pact-gas-analysis`, `gas-station-design`, `cross-chain-design` |
| Platform | `kda-ce-compliance`, `devnet-management` |

### Slash Commands (20)

Type `/command-name` in Claude Code to invoke a structured Pact workflow.

| Command | What it does |
|---|---|
| `/new-pact-module` | Scaffold module + REPL tests + deploy script |
| `/design-defpact` | defpact: steps, yield/resume, SPV, rollback, test plan |
| `/generate-repl-tests` | .repl test suite from ADR/acceptance criteria |
| `/generate-integration-stubs` | TypeScript @kadena/client stubs |
| `/validate-pact-module` | 4-phase: REPL analysis → REPL exec → devnet deploy → verify |
| `/verify-pact-module` | Formal verification + typecheck |
| `/capability-audit` | Capability hierarchy map with bypass path check |
| `/pact-security-audit` | Security-focused code review checklist |
| `/full-security-audit` | 5-phase audit (prefer pact-auditor for independence) |
| `/security-assessment` | STRIDE per public function + attack simulation |
| `/threat-model` | STRIDE threat model with attack trees and mitigations |
| `/analyze-feature` | 7-step impact analysis before implementing a feature |
| `/architecture-lockdown` | Architecture freeze: options → decision → ADR outputs |
| `/architecture-review` | Review ADR/proposal: gas, DAG acyclicity, KDA-CE compliance |
| `/design-test-suite` | Test suite design from ADRs and acceptance criteria |
| `/deploy-to-devnet` | Ordered deploy with gas tracking and verification report |
| `/gas-analysis` | Gas per function vs 150k ceiling with baseline comparison |
| `/migrate-pact-schema` | New table, admin migration fns, bless list, row-count test |
| `/developer-handoff` | Implementation spec: schemas, caps, gas estimate, deploy notes |
| `/review-pr` | Dual-scope: isolated changes + full regression |

### Instructions (16)

Always-on guidance, auto-loaded by applyTo glob patterns: `pact-rules`, `pact-traps`,
`coding-rules`, `testing-rules`, `security-rules`, `architecture-rules`, `deployment-rules`,
`gas-optimization`, `clarification-protocol`, `workspace-conventions`, `cross-module-rules`,
`diagnostic-integrity-rules`, `refactoring-rules`, `self-audit-checklist`,
`commit-conventions`, `github-guardrails`.

### Security Agent (1)

`agents/pact-auditor.md` — the only sub-agent in this package. Invoked before shipping any
module. Reads code cold (no implementation history), runs a 5-step protocol: Tier 2 static
greps, capability audit, Pact 5.4ce trap check, security checklist, STRIDE per public function.
Returns a structured finding table. PASS = exactly zero confirmed findings.

### Scripts

- `scripts/pact-static-check.sh` — Tier 1 (pact CLI) + Tier 2 (semantic greps) static analysis
  gate. Must exit 0 before any `.pact`/`.repl` change ships.
- `scripts/session-end-secrets-scan.sh` — session-end hook that scans modified files for
  credential patterns.

---

## File Layout (post-install)

```
~/.claude/
  skills/          ← 24 Pact/KDA-CE skill files
  instructions/    ← 16 instruction files
  commands/        ← 20 slash command files
  agents/
    pact-auditor.md
  scripts/
    pact-static-check.sh
    session-end-secrets-scan.sh
  CLAUDE.md        ← from CLAUDE.md.template (you fill in project identity)
```

---

## Community Health

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- [SECURITY.md](SECURITY.md)
- [SUPPORT.md](SUPPORT.md)
- [CHANGELOG.md](CHANGELOG.md)
- [LICENSE](LICENSE)
