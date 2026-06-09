---
name: gas-station-design
description: "Pact 5 gas station design — GAS_PAYER capability pattern, capability-guard-backed payer account, drain-attack defense, tx introspection constraints, and cross-chain defpact relaying for KDA-CE."
---
# Gas Station Design

> Canonical traps: [.github-community/instructions-community/pact-traps.instructions.md](..-community/..-community/instructions-community/pact-traps.instructions.md)

## What a Gas Station Is
An **autonomous account that pays gas on behalf of users' transactions**, enabling:
- **Gasless UX** — users transact without holding KDA for gas.
- **Defpact continuation relaying** — the station submits `cont` steps so cross-chain transfers don't orphan (see [pact-defpact](..-community/pact-defpact-community/SKILL.md)).

The station account is a **principal backed by a capability guard**, so only the constrained `GAS_PAYER` logic can spend from it.

## GAS_PAYER Pattern
The station provides `coin.GAS` by acquiring its own `GAS_PAYER` capability. The account is `(create-principal (create-capability-guard (GAS_PAYER ...)))`.

```pact
(module gas-station GOVERNANCE
  (defcap GOVERNANCE () (enforce-guard (keyset-ref-guard "free.admin")))

  (defcap GAS_PAYER (user:string limit:integer price:decimal)
    @doc "Constrains WHICH txs this station will fund"
    ;; 1. Single top-level call only (no arbitrary batches)
    (enforce (= 1 (length (at 'exec-code (read-msg)))) "single-call only")
    ;; 2. Only fund calls into an allowed module-community/function
    (enforce
      (= "(free.governance-token." (take 16 (at 0 (at 'exec-code (read-msg)))))
      "only governance-token calls funded")
    ;; 3. Bound gas price and limit
    (enforce (<= price 0.000001) "gas price too high")
    (enforce (<= limit 1500) "gas limit too high")
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

Tx introspection: use `read-msg` (and signer-community/sender fields available in the tx environment) to inspect the funded call and constrain it. Scope the `GAS` capability tightly via `compose-capability` so the guard only releases gas for approved operations.

## Drain-Attack Defense
A gas station holds spendable KDA — an unconstrained station is a free-money faucet:
- **Constrain the funded operation** — only specific module + function calls (allowlist), reject arbitrary calls.
- **Bound gas price and gas limit** per tx.
- **Enforce per-tx and rate limits** (e.g., per-user counters with a time window).
- **Reject batched -community/ multi-step exec code** unless explicitly intended.
- Keep the `GAS_PAYER` cap composition minimal — release `ALLOW_GAS` only after all checks pass.

## Cross-Chain Role
A gas station can submit defpact continuation (`cont`) steps so cross-chain transfers don't orphan (debited on source, never credited on target). Pair the station with a relayer that watches `X_YIELD` events and submits the target-chain `cont` step. See [pact-defpact](..-community/pact-defpact-community/SKILL.md).

## Limits
- **150,000 gas per transaction hard ceiling** — the station cannot fund a tx that exceeds it; bound `limit` well under the ceiling.
- Formal verification of gas-station guards is limited — favor narrow, explicit allowlists over clever predicates, and back them with adversarial REPL tests.
