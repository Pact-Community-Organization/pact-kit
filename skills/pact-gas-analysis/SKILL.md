---
name: pact-gas-analysis
description: "Gas measurement, optimization, and budget tracking for Pact 5 on KDA-CE. 150k ceiling analysis, split-deploy strategies, and gas profiling."
---
# Pact Gas Analysis

## Measurement
```typescript
// Local preflight for gas measurement
const result = await client.local(tx);
console.log(`Gas used: ${result.gas}`);
// Must be < 150,000
```

## Budget Tracking
| Module | Deploy Gas | Init Gas | Heaviest Function |
|--------|-----------|----------|-------------------|
| dao-types | 1,231 | — | — |
| dao-token | 24,644 | 306 | transfer |
| dao-dividend | 14,525 | — | claim-dividends |
| dao-voting | 17,133 | 148 | tally-votes |

## Optimization Strategies
1. **Direct reads** over table scans (`read` vs `fold`/`map`)
2. **Minimize capability nesting** — fewer checks = less gas
3. **Pre-compute off-chain** — pass computed values as arguments
4. **Split large deploys** — module in tx1, create-table in tx2
5. **Batch writes** — combine related updates in single tx

## Gas Ceiling Alert
If any operation approaches 100k gas:
1. Profile individual function calls
2. Identify the most expensive operations
3. Consider splitting into multiple transactions
4. Document gas budget in ADR
