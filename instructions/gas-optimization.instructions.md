---
description: "Use when optimizing gas consumption, estimating gas budgets, splitting large transactions, or troubleshooting gas limit exceeded errors in Pact 5 on KDA-CE."
---
# Gas Optimization

## Hard Ceiling
- 150,000 gas per transaction — no exceptions on KDA-CE
- Measure gas via local preflight call before declaring complete

## Known Gas Costs — DAO snapshot (re-measure with env-gas; dated 2026-03-31)

> **Not authoritative.** These figures predate the Pact 5.0 gas-model revamp and
> are conservative. Re-measure with `env-gas` (see below) before relying on any
> number. Snapshot retained only as a rough ordering of cost.

| Operation | Gas |
|-----------|-----|
| dao-types interface | 1,231 |
| dao-token + 5 tables | 24,644 |
| dao-dividend + 3 tables | 14,525 |
| dao-voting + 2 tables | 17,133 |
| dao-token.initialize | 306 |
| dao-voting.initialize | 148 |
| dao-voting.set-config | 146 |

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

(my-namespace.dao-token.transfer "alice" "bob" 5.0)

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
