# Pact Agent Marketplace

Reusable Copilot agents, skills, instructions, prompts, and hooks so Pact and Kadena developers can start building smart contracts fast.

[License: Apache-2.0](LICENSE)

## What's in This Repo

| Category | Description | Folder | Count |
|---|---|---:|---:|
| Agents | Eight role-based Copilot agents for coordination, delivery, QA, security, and documentation. | [agents](agents) | 8 |
| Instructions | Always-on and scoped guidance files for behavior, validation, security, and Pact-specific rules. | [instructions](instructions) | 18 |
| Skills | Pact smart-contract workflow skills: design, capabilities, schema, testing, gas, security, and KDA-CE platform. | [skills](skills) | 24 |
| Prompts | Reusable task prompts for Pact architecture, implementation, review, security, and validation workflows. | [prompts](prompts) | 24 |
| Hooks | Copilot hook definitions that call portable runtime scripts in `.github/scripts/`. | [hooks](hooks) | 4 |

## Installation

Install everything or copy only the pieces you want into a target repository's `.github/` folder.

### Folder Mapping

- `agents/` → `.github/agents/`
- `instructions/` → `.github/instructions/`
- `skills/` → `.github/skills/`
- `prompts/` → `.github/prompts/`
- `hooks/` → `.github/hooks/`
- `.github/scripts/` → `.github/scripts/`
- `copilot-instructions.md` → `.github/copilot-instructions.md`

### Copy Example

```bash
git clone https://github.com/Pact-Community-Organization/github-marketplace.git
cd github-marketplace
mkdir -p /path/to/target-repo/.github
cp -R agents /path/to/target-repo/.github/
cp -R instructions /path/to/target-repo/.github/
cp -R skills /path/to/target-repo/.github/
cp -R prompts /path/to/target-repo/.github/
cp -R hooks /path/to/target-repo/.github/
mkdir -p /path/to/target-repo/.github/scripts
cp .github/scripts/*.sh /path/to/target-repo/.github/scripts/
cp copilot-instructions.md /path/to/target-repo/.github/copilot-instructions.md
```

You can also install a single agent, instruction, skill, prompt, or hook instead of the full set.

## Agents

| Agent | Description |
|---|---|
| Admin | Lead coordinator and sole user-facing orchestration agent. Uses `Admin` as the coordinator name. |
| Architect | System design agent for ADRs, API design, cross-chain flows, gas budgets, and handoff docs. |
| Developer | Implementation agent for smart contracts, integration code, tests, and validation support. |
| Tester | Independent QA agent for adversarial validation, regression testing, and GO/NO-GO decisions. |
| Security | Security audit agent for threat modeling, capability analysis, and deployment blocking. |
| Auditor | External-style audit agent for evidence-based reviews and formal verdicts. |
| DevOps | CI/CD and infrastructure agent for pipelines, deployments, and release operations. |
| Docs | Documentation agent for API docs, guides, changelogs, and Mermaid diagrams. |

## Skills

This repository ships **only Pact smart-contract language skills** — no generic software-engineering skills. The catalog is grouped by theme for selective install. See [skills](skills) for the full catalog.

- Pact Core: `pact-module-design`, `pact-capabilities`, `pact-schema-design`, `pact-interface-design`, `pact-guards`, `pact-defpact`, `pact-events`, `pact-architecture`, `pact-invariants`.
- Testing & Tooling: `pact-repl-testing`, `pact-devnet-testing`, `pact-module-validation`, `pact-cli-tooling`, `debug-pact`, `static-analysis`.
- Security & Audit: `pact-security-review`, `capability-analysis`, `compliance-verification`, `formal-verification`.
- Gas & Cross-chain: `pact-gas-analysis`, `gas-station-design`, `cross-chain-design`.
- Platform: `kda-ce-compliance`, `devnet-management`.

## Instructions

The repository ships a focused set of instructions files for behavior and validation:

- `clarification-protocol.instructions.md`: ask before acting when scope, behavior, or placement is unclear.
- `workspace-conventions.instructions.md`: keep files in the correct location and avoid duplication.
- `architecture-rules.instructions.md`: apply architecture decision and design constraints.
- `coding-rules.instructions.md`: follow Pact and TypeScript implementation conventions.
- `commit-conventions.instructions.md`: use conventional commit formatting.
- `cross-module-rules.instructions.md`: protect module boundaries and interface consistency.
- `deployment-rules.instructions.md`: enforce safe deploy sequencing and approval requirements.
- `diagnostic-integrity-rules.instructions.md`: keep tests and reviews truthful and reproducible.
- `gas-optimization.instructions.md`: reason about gas use and optimization.
- `github-guardrails.instructions.md`: protect hook and script behavior.
- `inter-agent-protocol.instructions.md`: route messages and tasks between agents cleanly.
- `pact-rules.instructions.md`: load Pact language-specific rules for `.pact` and `.repl` files.
- `pact-traps.instructions.md`: reference known Pact pitfalls and verified behaviors.
- `quality-gate-rules.instructions.md`: apply the multi-gate quality model.
- `refactoring-rules.instructions.md`: preserve behavior during code transformations.
- `security-rules.instructions.md`: apply security review expectations and threat controls.
- `self-audit-checklist.instructions.md`: check your own work before reporting outcomes.
- `testing-rules.instructions.md`: write and evaluate tests with correct Pact patterns.

## Prompts

Prompts are grouped by the work they support:

- Coordination and planning: `assign-task`, `task-decomposition`, `team-status`, `synthesize-results`.
- Architecture and design: `architecture-lockdown`, `architecture-review`, `design-defpact`, `new-pact-module`.
- Implementation and validation: `developer-handoff`, `generate-integration-stubs`, `generate-repl-tests`, `validate-pact-module`, `verify-pact-module`, `design-test-suite`.
- Security and review: `capability-audit`, `full-security-audit`, `pact-security-audit`, `security-assessment`, `threat-model`, `review-pr`.
- Deployment and operations: `deploy-to-devnet`, `gas-analysis`.
- Migration: `migrate-pact-schema`.
- Analysis and triage: `analyze-feature`, `task-decomposition`, `team-status`.

## Hooks

The bundle ships four hook files: `pre-tool-use.json`, `post-tool-use.json`, `session-start.json`, and `session-end.json`. Runtime scripts live in `.github/scripts/`.

## Naming Conventions

- Agent files use lowercase `*.agent.md`.
- Skills use `skills/<name>/SKILL.md`.
- Instructions use `*.instructions.md`.
- Prompts use `*.prompt.md`.
- Admin is the coordinator name.

## Community Health

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- [SECURITY.md](SECURITY.md)
- [SUPPORT.md](SUPPORT.md)
- [LICENSE](LICENSE)
