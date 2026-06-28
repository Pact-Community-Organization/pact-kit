---
description: "Optimize gas, estimate budgets, split large transactions, or troubleshoot gas-limit-exceeded errors in Pact 5 on KDA-CE."
---
# Gas Optimization

> Budget-tracking workflow skill: `pact-gas-analysis`.

## Hard Ceiling
- 150,000 gas per transaction — no exceptions on KDA-CE
- Measure gas via local preflight call before declaring complete

## Example gas costs (illustrative — re-measure with `env-gas` for your modules)

> **Not authoritative.** These figures are illustrative only and should be
> re-measured in your project before relying on any number. Treat them as a
> rough ordering of cost, not a budget.

| Operation | Gas |
|-----------|-----|
| my-types interface | 1,231 |
| my-token + 5 tables | 24,644 |
| my-governance + 3 tables | 14,525 |
| my-governance + 2 tables | 17,133 |
| my-token.initialize | 306 |
| my-governance.initialize | 148 |
| my-governance.set-config | 146 |

## Optimization Strategies
1. **Split large modules** — if deploy > 150k, separate module + create-table into two txs
2. **Minimize table scans** — use direct key reads over fold/map when possible
3. **Reduce capability checks** — compose capabilities to minimize nested checks
4. **Batch operations** — combine related writes in single transaction
5. **Pre-compute off-chain** — compute complex values off-chain, pass as arguments

## Gas Measurement Pattern (TypeScript)
```typescript
const result = await client.local(tx);
console.log(`Gas used: ${result.gas}`);
// result.gas < 150_000 or redesign
```

## Gas Measurement Pattern (REPL-native — fastest CI check)

Measure gas **without devnet** directly in a `.repl`. This is the fastest gas
check and belongs in CI alongside the test suite.

```pact
(env-gasmodel "table")     ; use the real on-chain table gas model
(env-gaslog)               ; start a per-op gas log
(env-gas 0)                ; reset the counter to 0

(free.my-token.transfer "alice" "bob" 5.0)

(env-gaslog)               ; prints per-operation gas breakdown
(expect "transfer under budget" true (< (env-gas) 150000))
```

- `env-gasmodel` selects the gas model (`"table"` matches chain).
- `env-gas` reads or resets the cumulative counter.
- `env-gaslog` emits a per-operation breakdown — use it to find the hot op.

Prefer this for every PR; reserve devnet `local` preflight for end-to-end checks.

## Pact 5 gas notes

- **5.0** revamped the gas model (generally **cheaper**) and ships a **faster
  interpreter**. Treat all Pact-4-era budgets as conservative — **re-benchmark**
  with `env-gas` rather than trusting old numbers.
- **5.1** computes the **smallest dependency set** on load, **shrinking deploy
  size** (and thus deploy gas) versus earlier versions.
- **Integers below 10^80 incur no size penalty** — normal-range arithmetic is not
  a gas concern.
- **`enforce` is evaluated lazily** — a passing guard short-circuits; ordering
  cheap checks first can save gas on the failure path.

## Bounded-growth rule (unchanged, still mandatory)
- The 150k ceiling is absolute.
- **No unbounded `select` / `keys` / `fold` / list growth on-chain** — their cost
  scales with table/data size and will eventually exceed budget non-
  deterministically. Those reads belong in **`/local`** queries, never in a
  transactional path.
