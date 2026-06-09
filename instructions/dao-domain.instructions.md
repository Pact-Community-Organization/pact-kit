---
description: "Use when working on the DAO project modules (dao-types, dao-token, dao-dividend, dao-voting, dao-gas-station). Domain-specific knowledge, module relationships, and business rules."
applyTo: ["pact-examples/**"]
---
# DAO Domain Knowledge

## Module Architecture (Deploy Order)
1. `dao-types` — Interface module, shared schemas and capabilities
2. `dao-token` — Token management, fungible-v2 implementation
3. `dao-dividend` — Dividend distribution, accumulator pattern (ADR-002)
4. `dao-voting` — Governance voting, proposal lifecycle (ADR-001)
5. `dao-gas-station` — Gas station for user convenience

## Key Invariants
- **Conservation**: Sum of all balances = total supply (always)
- **Vote constraint**: `vote_amount ≤ balance` during VOTING status
- **Dividend formula**: `owed = balance × (pps - last_points) + correction` (ADR-002)
- **No double-claim**: `last_points` updated on every claim

## Cross-Module Dependencies
- `dao-dividend` reads balances from `dao-token`
- `dao-voting` reads balances from `dao-token`
- `dao-token` credit/debit must update dividend correction factors
- Config changes in `dao-voting` must align with tally schema

## File Locations
- Pact modules: `pact-examples/pact/modules/`
- Pact interfaces: `pact-examples/pact/interfaces/`
- REPL tests: `pact-examples/pact/tests/`
- Deploy scripts: `pact-examples/pact/deploy/`
- TypeScript: `pact-examples/ts/`
- Documentation: `pact-examples/docs/`
