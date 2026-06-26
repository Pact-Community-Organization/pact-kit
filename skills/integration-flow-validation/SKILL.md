---
name: integration-flow-validation
description: "End-to-end lifecycle testing across all Pact modules — buy, transfer, vote, claim dividend flows on devnet. Cross-module integration validation."
---
# Integration Flow Validation

## Lifecycle Test Flows

### Token Lifecycle
```
1. Deploy all modules (my-types → my-token → my-dividend → my-governance → my-gas-station)
2. Initialize token (set supply, admin config)
3. Buy tokens (transfer KDA → receive my-token tokens)
4. Transfer tokens between accounts
5. Verify balances across both modules
```

### Governance Lifecycle
```
1. Create proposal (voting module)
2. Vote on proposal (requires token balance)
3. Wait for voting period to end (poll chain time)
4. Tally votes (verify quorum, majority)
5. Execute proposal if passed
```

### Dividend Lifecycle
```
1. Distribute dividends (add to pool)
2. Verify accumulator state (pps update)
3. Holder claims dividend
4. Verify correction factor after transfer
5. New holder claims (should get post-transfer amount only)
```

### Cross-Module Flow
```
1. Buy tokens → check dividend state updated
2. Transfer tokens → check correction factors
3. Vote → check token balance constraint
4. Claim dividend → verify formula: owed = balance × (pps - last_points) + correction
```

## Validation Rules
- Deploy ALL modules, not just the changed one
- Use dedicated devnet port (Tester: 8082)
- Verify postconditions at every step via localCall
- Time-dependent operations: poll chain time, never static wait
