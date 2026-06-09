---
description: "Use when working on the DAO project modules (governance-types, governance-token, distribution-module, governance-voting, gas-relayer). Domain-specific knowledge, module relationships, and business rules."
applyTo: ["pact-examples-community/**"]
---
# DAO Domain Knowledge

## Module Architecture (Deploy Order)
1. `governance-types` — Interface module, shared schemas and capabilities
2. `governance-token` — Token management, fungible-v2 implementation
3. `distribution-module` — Dividend distribution, accumulator pattern (ADR-002)
4. `governance-voting` — Governance voting, proposal lifecycle (ADR-001)
5. `gas-relayer` — Gas station for user convenience

## Key Invariants
- **Conservation**: Sum of all balances = total supply (always)
- **Vote constraint**: `vote_amount ≤ balance` during VOTING status
- **Dividend formula**: `owed = balance × (pps - last_points) + correction` (ADR-002)
- **No double-claim**: `last_points` updated on every claim

## Cross-Module Dependencies
- `distribution-module` reads balances from `governance-token`
- `governance-voting` reads balances from `governance-token`
- `governance-token` credit-community/debit must update dividend correction factors
- Config changes in `governance-voting` must align with tally schema

## File Locations
- Pact modules: `pact-examples-community/pact-community/modules-community/`
- Pact interfaces: `pact-examples-community/pact-community/interfaces-community/`
- REPL tests: `pact-examples-community/pact-community/tests-community/`
- Deploy scripts: `pact-examples-community/pact-community/deploy-community/`
- TypeScript: `pact-examples-community/ts-community/`
- Documentation: `pact-examples-community/docs-community/`
