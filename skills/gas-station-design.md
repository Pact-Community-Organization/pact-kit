---
name: gas-station-design
description: "Pact 5 gas station design: GAS_PAYER capability, capability-guard payer account, drain defense, tx introspection, defpact relaying."
---
# Gas Station Design

> Canonical traps: [../instructions/pact-traps.md](../instructions/pact-traps.md)

## What a Gas Station Is
An **autonomous account that pays gas on behalf of users' transactions**, enabling:
- **Gasless UX** — users transact without holding KDA for gas.
- **Defpact continuation relaying** — a relayer can submit `cont` steps funded by the station to reduce orphan risk for cross-chain flows (see [pact-defpact](../skills/pact-defpact.md)).

The station account is a **principal backed by a capability guard**, so only the constrained `GAS_PAYER` logic can spend from it.

## GAS_PAYER Pattern
The station provides `coin.GAS` by acquiring its own `GAS_PAYER` capability. The account is `(create-principal (create-capability-guard (GAS_PAYER ...)))`.

```pact
(module gas-station GOVERNANCE
  (defcap GOVERNANCE () (enforce-guard (keyset-ref-guard "free.admin")))

  (defcap GAS_PAYER (user:string limit:integer price:decimal)
    @doc "Constrains WHICH txs this station will fund"
    ;; Portable checks based on canonical GAS_PAYER args
    (enforce (<= price 0.000001) "gas policy")
    (enforce (<= limit 1500) "gas policy")
    ;; Optional project-specific context checks can read request data,
    ;; but key names/shape are app-defined rather than Pact-canonical.
    (compose-capability (ALLOW_GAS)))

  (defcap ALLOW_GAS () true)

  ;; capability-guard-backed station account
  (defconst GAS_STATION:string
    (create-principal (create-capability-guard (ALLOW_GAS))))

  (defun init ()
    (coin.create-account GAS_STATION
      (create-capability-guard (ALLOW_GAS))))
)
```

Tx introspection: rely first on canonical `GAS_PAYER` arguments (`user`, `limit`, `price`). If you inspect extra request context via `read-msg`, treat those keys as project-defined and validate them defensively. Scope `GAS` tightly via `compose-capability` so the guard releases gas only after all policy checks pass.

## Drain-Attack Defense
A gas station holds spendable KDA — an unconstrained station is a free-money faucet:
- **Constrain the funded operation** — only specific module + function calls (allowlist), reject arbitrary calls.
- **Bound gas price and gas limit** per tx.
- **Enforce per-tx and rate limits** (e.g., per-user counters with a time window).
- **Reject batched / multi-step exec code** unless explicitly intended.
- Keep the `GAS_PAYER` cap composition minimal — release `ALLOW_GAS` only after all checks pass.

## Cross-Chain Role
A gas station can fund defpact continuation (`cont`) submissions by a relayer, which reduces the chance of orphaned cross-chain flow state. It does not guarantee completion by itself; pair it with robust continuation monitoring/retry logic and the underlying defpact rollback strategy. See [pact-defpact](../skills/pact-defpact.md).

## Limits
- **150,000 gas per transaction hard ceiling** — the station cannot fund a tx that exceeds it; bound `limit` well under the ceiling.
- Formal verification of gas-station guards is limited — favor narrow, explicit allowlists over clever predicates, and back them with adversarial REPL tests.
