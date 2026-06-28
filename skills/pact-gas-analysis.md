---
name: pact-gas-analysis
description: "Gas measurement, optimization, and budget tracking for Pact 5 on KDA-CE. 150k ceiling analysis, split-deploy strategies, and gas profiling."
---
# Pact Gas Analysis

## Measurement
Budget table + measurement pattern: see `../instructions/gas-optimization.md` (canonical).

## Budget Tracking
Budget table + measurement pattern: see `../instructions/gas-optimization.md` (canonical).

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
