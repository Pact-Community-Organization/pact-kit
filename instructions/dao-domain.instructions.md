---
description: "Use when working on the DAO project modules (governance-types, governance-token, distribution-module, governance-voting, gas-relayer). Domain-specific knowledge, module relationships, and business rules."
applyTo: ["pact-examples/**"]
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
- `governance-token` credit/debit must update dividend correction factors
- Config changes in `governance-voting` must align with tally schema

## File Locations
- Pact modules: `pact-examples/pact-community/modules/`
- Pact interfaces: `pact-examples/pact-community/interfaces/`
- REPL tests: `pact-examples/pact-community/tests/`
- Deploy scripts: `pact-examples/pact-community/deploy/`
- TypeScript: `pact-examples/ts/`
- Documentation: `pact-examples/docs/`
