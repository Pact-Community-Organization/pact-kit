---
name: red-team-testing
description: "Offensive red-team testing for Pact 5 / KDA-CE contracts: two-engine method (reverse-coverage + invariant hunting), eight attack blocks, a 20-mutation depth standard, differential-oracle testing with a negative control, and a REPL-artifact filter that keeps 'held' credible."
---
# Red-Team Testing

> Defensive counterpart: [../agents/pact-auditor.md](../agents/pact-auditor.md) reads code and finds bugs statically. This skill is the **offensive** side — it *executes real attacks* in the Pact interpreter and proves whether an invariant actually breaks. Canonical traps: [../instructions/pact-traps.md](../instructions/pact-traps.md).

A red-team pass attacks a contract to find flaws *before a real attacker does*, while the value is still test-only. Every attack is **executed** against a copy of the contract with the `pact` CLI (Pact 5.4+), not argued on paper. Each attempt is binary: **HELD** (defense stands) or **BROKEN** (a forbidden state change actually occurred, proven by before/after state).

## The two engines

- **Engine A — Reverse coverage.** *A well-built contract is an attack manual written backwards*: every defense is the fingerprint of an attack someone anticipated. Invert the known defenses. **Honest limit:** this only reproduces attacks someone already stopped. A hardened contract passes all of Engine A by construction (that is *why* it was hardened).
- **Engine B — Invariant hunting.** The *new* bug lives in the properties the contract satisfies but never states. These do not come from inverting an `enforce`; they come from reasoning about what is impossible. This is where findings appear on good targets.

Engine A tells you **where not to look** (already defended). Engine B tells you **where to look**.

## The eight attack blocks (bombard from every angle)

1. **Economic** — reserve/gas-station drain, double- or over-claim of dividends, over-mint, break solvency, rounding in the attacker's favor.
2. **Temporal** — release time-locks early, vote/claim after close, exact boundaries (`==`), front-run a short window, miner block-time skew.
3. **Identity & authorization** — sensitive function without a guard, acquiring a capability you shouldn't (weak-body cap composed on a public path), satisfying a key-less account's guard, stealth delegate registration / owner lockout, payout-account squatting, the path the **runtime** grants (magic caps, defpact SPV resume, gas-buy) when the obvious path bounces.
4. **State & accounting** — drift between the contract's O(1) aggregate and the O(n) reality, vote double-counting via transfer, orphan/dangling rows after a freeze, inflating a loop/select with free-choice ids (Pact has no `delete`), control-counters drained for free (DoS).
5. **Composition & capabilities** — map the full composition tree of every weak-body cap, cross-function reentrancy (live write cap + call into a user modref + effect after), managed-cap argument exactness, `install-capability` from tx-code, crossing cap-guards between accounts.
6. **Arithmetic & boundaries** — non-binary `+`, `enforce` reading the DB, ceilings with only `<=`/`>=` (try ≤0), floor sub-additivity, off-by-one thresholds (`floor(L)` passes, `floor(L)-1 quantum` bounces), decimals/units, overflow.
7. **Cross-chain & ceremony** — operational divergence when replicating params to N chains (not enforced on-chain), false "passed" from partial aggregates, transfer/report SPV step-2 (unforgeable on-chain, falsely passable in a single-DB REPL). **Only provable on a multi-chain devnet** — flag as residual, not a break.
8. **Two layers** — the web/keeper that *signs*: deployer key live in the process, login without fail-closed, gate only in front-end JS, keeper as an unvalidated signing oracle, secrets in cleartext. A perfect Pact module can be insecure through the machine that operates it. Audit both layers.

## Depth standard: 20 mutations per front (mandatory)

A front is never tested once — it is swept with **20 executed mutations**. Bugs live in the odd combination, not the happy path. Combine six mutation dimensions to reach 20: **amount** (0, negative, 1e-12 quantum, MAX, MAX±1 quantum, 13-decimal, balance-exact, balance+1) · **time/block** (before/at/after a window, ±1s, clock backward, far future) · **operation order** (A→B→C vs reversed; repeat an op) · **identity** (fresh vs existing account, `k:`/`w:`/`c:` principal vs vanity, split one actor into 5 sub-accounts, squatted, phantom) · **prior state** (fresh, with float, reserves moved, post-upgrade, mid-migration window) · **repetition** (fill a counter to the cap then +1, N txs to exhaust a bound, one string with multiple forms). If a front cannot yield 20 distinct mutations, it is under-scoped — split it.

## Engine B tooling

- **Invariant properties** — assert after *every* operation of a long, randomized suite. The recurring five: supply conservation (Σ balances constant), exact solvency (the contract's O(1) aggregate `==` the naive O(n) sum), rounding sub-additivity (`Σ floor(owed_i) ≤ floor(Σ owed_i)` — splitting never wins; note this inequality is *always* true, so asserting it alone is tautological — the real bug is the contract paying `Σ floor` while owing `floor(Σ)`, which the negative control below forces into a strict `<`), vesting monotonicity (`released(t)` non-decreasing and ≤ total), and `Σ votes ≤ circulating` with weight ≤ balance.
- **Differential testing** — write the naive O(n) reference (walk every account) and assert exact equality with the contract's materialized O(1) shortcut after each step. Aggregate-accounting drift is the most dangerous DeFi bug class; two independent engines computing the same number expose it.
- **Negative control (anti-tautology)** — a differential oracle only catches bugs if both sides are *independent* computations. Before declaring HELD on "O1 == On always", run a control that deliberately amputates On (omit one account) and confirm it **diverges** from O1. If it does, the test would catch a real double-count; if it doesn't, the oracle is tautological and worthless. To stress floor sub-additivity for real, inject a micro-account whose owed falls **below 1e-12** (floor→0): then `Σ floor(owed_i) < floor(Σ owed_i)` strictly, proving splitting *loses* money.
- **Boundary fuzzing** — sweep each parameter over {0, negative, 1e-12, MAX, MAX±1 quantum, threshold±1 quantum}. The boundary is where an `enforce` is wrong on one side.

## L1 — real break vs REPL artifact (non-negotiable)

Before declaring a break, rule out that it depends on a **REPL-only primitive**:
- `test-capability` grants a cap bypassing guards → does not exist on-chain.
- `coin.GAS` (the gas magic-cap) → only the miner puts it in scope during gas-buy, never the attacker.
- **Single shared DB for 20 chains** → false partial-aggregate "passed" / release on chain≠0. On-chain: per-chain DB + unforgeable cross-chain SPV proof.
- REPL-vs-node divergence on DB reads inside `enforce` — the 5.3+ REPL permits the read, but the KDA-CE chainweb-node rejects it (devnet-verified; see `pact-traps`). A "break" that only lands because the REPL let a read-in-`enforce` through is an artifact, not a finding.

If the break needs those crutches, it is an **artifact, not a finding**. Companion rule: when Pact blocks the obvious path (e.g. acquiring another module's cap needs module-admin), hunt the path the **runtime** grants (magic caps, defpact SPV resume, gas-buy) and check the caller's guard *there* — that is where a naïve gas station drains even though the obvious path bounces.

## The honest residual (what no attack takes down)

If a target survives reverse-coverage *and* invariants, that does not mean "secure" — it means the remaining risk is a different kind: **upgrade trust** (a module upgradeable under a keyset is not trustless), **cross-chain / replication ceremony** (identical params across N chains are not enforceable on-chain without SPV; the vector is operational, provable only on devnet), and the **two-layer** risk (the web/keeper that signs). State those plainly instead of implying total safety. The L1 discipline — honestly dropping "successes" that were REPL artifacts — is what makes a "held" verdict credible.

## Ethics

Own contract: full freedom. Third-party contract: only with the owner's permission (or an invited testnet engagement), read only public source, run only against a local/testnet copy, never against a live third-party system, never move anyone's funds, and report privately to the owner or their security channel first.
