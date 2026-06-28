# Pact 5 / KDA-CE — Agent Rules

You are working on a Pact 5 smart contract project targeting Kadena Community Edition (KDA-CE).

## Non-negotiables

- **Static analysis gate**: `.github/scripts/pact-static-check.sh` must exit 0 before any `.pact`/`.repl` change is complete. Never bypass.
- **Transparency-first**: business-critical state (governance, balances, votes, dividends) lives on-chain by default. Justify any off-chain logic explicitly.
- **Gas ceiling**: every on-chain operation must stay under 150,000 gas.
- **ADR before architecture changes**: no module design or upgrade decision without a recorded ADR.
- **Minimal-first**: stop at the first rung that holds — reuse before writing, stdlib before custom, one line before fifty. Never cut security guards, capability checks, or input validation at trust boundaries.

## Language

Pact 5.4ce (KDA-CE fork of kadena-io/pact-5). Key traps are in `.github/instructions/pact-traps.instructions.md`. Language rules in `.github/instructions/pact-rules.instructions.md`.

## Skills — load from `.github/skills/` as needed

**Core language**: `pact-capabilities`, `pact-guards`, `pact-schema-design`, `pact-module-design`,
`pact-interface-design`, `pact-defpact`, `pact-events`, `pact-architecture`, `pact-invariants`

**Testing & tooling**: `pact-repl-testing`, `pact-devnet-testing`, `pact-module-validation`,
`pact-cli-tooling`, `debug-pact`, `static-analysis`

**Security & audit**: `pact-security-review`, `capability-analysis`, `compliance-verification`,
`formal-verification`

**Gas & cross-chain**: `pact-gas-analysis`, `gas-station-design`, `cross-chain-design`

**Platform**: `kda-ce-compliance`, `devnet-management`

## Agents — load from `.github/agents/` as needed

| Agent | Role |
|-------|------|
| `Admin` | Coordinator — task delegation, quality-gate tracking, final synthesis |
| `Architect` | System design — ADRs, API design, cross-chain flows, gas budgets |
| `Developer` | Implementation — smart contracts, integration code, REPL tests |
| `Tester` | QA — adversarial validation, GO/NO-GO decisions |
| `Security` | Threat modeling, capability audit, deployment blocking |
| `Auditor` | External-style audit — formal verdict, PoC exploits |
| `DevOps` | CI/CD, deployments, release operations |
| `Docs` | API docs, guides, changelogs, Mermaid diagrams |
