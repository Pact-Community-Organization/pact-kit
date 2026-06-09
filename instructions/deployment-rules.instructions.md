---
description: "Use when deploying Pact modules to devnet, testnet, or mainnet. Covers deploy order, gas budgets, signer requirements, and infrastructure rules."
applyTo: ["pact-examples/pact-community/deploy/**", "pact-examples/ts/scripts/**"]
# Deployment Rules

## Deploy Order (CRITICAL)
Module deployment order is strict — no forward references allowed:
1. Interface modules first (e.g., governance-types)
2. Core modules next (e.g., governance-token)
3. Dependent modules last (e.g., distribution-module, governance-voting, gas-relayer)
4. Initialization calls after all modules deployed

## Signer Requirements

### Scoped vs Unscoped (CRITICAL)
- **Scoped signers** (`addSigner(pubKey, (w) => [w('coin.GAS')])`) CANNOT satisfy `enforce-keyset`
- **Unscoped signers** (`addSigner(pubKey)`) handle gas + keyset enforcement
- For deploy/admin ops: ALWAYS use unscoped signers

## Table Creation
- `create-table` MUST be in the same tx as module deploy
- Separate tx for create-table fails: "Module admin is necessary"

## Gas Budgets
- 150,000 gas per transaction hard ceiling
- Module deploy > 150k gas → split into deploy + create-table txs
- Always measure gas via local preflight before declaring complete

## Infrastructure
- Use `client.pollOne()` NOT `client.listen()` (nginx 504 timeout)
- Chain time ~2× slower than wall clock on fresh devnet
- Unwrap Pact API types before comparison: `{int: N}`, `{decimal: "N.M"}`

## Approval Requirements
| Target | Required Approvals |
|--------|-------------------|
| devnet (any) | None |
| testnet06 | Tester GO + Security APPROVE |
| mainnet01 | Tester GO + Security APPROVE + Orchestrator |
