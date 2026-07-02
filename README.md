# Pact Kit

Domain knowledge and workflow automation for Pact 5 / KDA-CE smart contract development —
packaged for Claude Code, Codex, and Gemini CLI.

[![License: Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue?style=flat-square)](LICENSE)
[![npm](https://img.shields.io/npm/v/@pact-community/pact-kit?style=flat-square&color=cb3837)](https://www.npmjs.com/package/@pact-community/pact-kit)
[![Release](https://img.shields.io/github/v/release/Pact-Community-Organization/pact-kit?style=flat-square)](https://github.com/Pact-Community-Organization/pact-kit/releases)

---

## Requirements

- **Claude Code**, **Codex**, or **Gemini CLI** — see [Tool Support](docs/agent-portability.md) for per-host details
- **git** and **bash** — only needed for the curl-pipe installer
- **Pact 5.4ce** — the [KDA-CE](https://github.com/kadena-community/kadena-ce) fork of kadena-io/pact-5

---

## Install

**Claude Code**
```bash
claude plugins add Pact-Community-Organization/pact-kit
```

**Codex**
```bash
codex plugins add Pact-Community-Organization/pact-kit
```

**Gemini CLI**
```bash
gemini extension install https://github.com/Pact-Community-Organization/pact-kit
```

**Any host — installs directly into `~/.claude/`**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Pact-Community-Organization/pact-kit/main/scripts/install.sh)
```

The installer merges into `~/.claude/` and never removes existing files. Safe to run again after updates.

---

## Getting Started

After installing, open a Pact project in Claude Code:

```
/new-pact-module          scaffold a new module with REPL tests and a deploy script
/validate-pact-module     run the 4-phase validation: REPL analysis → devnet deploy → verify
/gas-analysis             measure gas per function against the 150k ceiling
security review           invoke the independent auditor before shipping any module
```

Copy the starter configuration and fill in the identity placeholder:

```bash
cp ~/.claude/CLAUDE.md.template ~/.claude/CLAUDE.md
```

Then add the hooks snippet from `~/.claude/CLAUDE.md.template` to `~/.claude/settings.json`
to enable automatic static analysis on every `.pact` and `.repl` edit.

---

## What's Included

### Skills

24 domain skills covering the full Pact 5 / KDA-CE surface. Loaded on demand — your AI
assistant draws on precise, current knowledge for the task without carrying it in every session.

| Area | What it covers |
|---|---|
| Core language | Capabilities, guards, schema design, module architecture, interfaces, defpacts, events, invariants |
| Testing & validation | REPL test patterns, devnet workflows, 4-phase module validation, CLI tooling, debugging |
| Security & correctness | Security review, capability audits, fungible-v2 / xchain-v1 compliance, formal verification |
| Gas & cross-chain | Gas analysis against the 150k ceiling, gas station design, cross-chain transfer patterns |
| Platform | KDA-CE network compliance, devnet lifecycle management |

### Slash Commands

20 commands covering the full development lifecycle. Type `/command-name` in Claude Code.

| Command | What it does |
|---|---|
| `/new-pact-module` | Scaffold module + REPL tests + deploy script |
| `/design-defpact` | defpact steps, yield/resume, SPV, rollback, and test plan |
| `/generate-repl-tests` | REPL test suite from an ADR or acceptance criteria |
| `/generate-integration-stubs` | TypeScript `@kadena/client` stubs for a module |
| `/validate-pact-module` | 4-phase validation: REPL analysis → REPL exec → devnet deploy → verify |
| `/verify-pact-module` | Formal verification and typecheck |
| `/capability-audit` | Capability hierarchy map with bypass path analysis |
| `/pact-security-audit` | Security-focused code review checklist |
| `/full-security-audit` | 5-phase audit (in-session; use `pact-auditor` for pre-ship reviews) |
| `/security-assessment` | STRIDE per public function with attack simulation |
| `/threat-model` | STRIDE threat model with attack trees and mitigations |
| `/analyze-feature` | 7-step impact analysis before implementing a feature |
| `/architecture-lockdown` | Architecture freeze: options → decision → ADR outputs |
| `/architecture-review` | Review an ADR or proposal for gas, DAG acyclicity, KDA-CE compliance |
| `/design-test-suite` | Test suite design from ADRs and acceptance criteria |
| `/deploy-to-devnet` | Ordered deploy with gas tracking and a verification report |
| `/gas-analysis` | Gas per function vs. 150k ceiling with baseline comparison |
| `/migrate-pact-schema` | New table, admin migration functions, bless list, row-count test |
| `/developer-handoff` | Implementation spec: schemas, capabilities, gas estimate, deploy notes |
| `/review-pr` | Dual-scope review: isolated diff + full regression |

### Behavioral Instructions

16 instruction files that load automatically based on the files you're editing. Opening a
`.pact` or `.repl` file activates Pact language rules, trap avoidance, and security checklists.
Deployment, testing, gas, and refactoring rules activate for their respective contexts.

### Security Auditor

`pact-auditor` opens a fresh context with no implementation history. Invoke it by saying
`security review` or `ready to ship` in Claude Code. It runs a 5-step protocol — static
analysis, capability audit, Pact 5.4ce trap check, security checklist, and STRIDE per public
function — and returns a structured finding table.

### Examples

`examples/example-token.pact` + `examples/example-token.repl` — a runnable, CI-verified
reference module demonstrating the conventions the kit enforces (capability layering,
managed caps, principal discipline, trust-boundary validation, node-safe enforce patterns).

### Reference Repositories

[docs/reference-repos.md](docs/reference-repos.md) — the vetted primary sources (language
repo, official docs, pact-util-lib, production contracts) and the idioms they agree on.
When in doubt, primary sources beat web search results and model memory.

### CI Scripts

`pact-static-check.sh` is a two-tier static analysis gate (Pact CLI + semantic greps).
Configure it as a `PostToolUse` hook to run automatically on every `.pact` and `.repl` edit.
`session-end-secrets-scan.sh` scans modified files for credential patterns at session end.
The hooks configuration snippet is in `~/.claude/CLAUDE.md.template`.

---

## Contributing

Open an issue or discussion before submitting a PR. See [CONTRIBUTING.md](CONTRIBUTING.md).

---

[Apache-2.0 License](LICENSE) · [Changelog](CHANGELOG.md) · [Security Policy](SECURITY.md) · [Code of Conduct](CODE_OF_CONDUCT.md)
