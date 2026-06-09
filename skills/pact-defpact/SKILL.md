---
name: pact-defpact
description: "Pact 5 multi-step pacts (defpact) and cross-chain transfers — step/step-with-rollback structure, yield/resume, SPV continuation, and orphaned-transfer defense for KDA-CE."
---
# Pact Defpact (Multi-Step & Cross-Chain)

> Canonical traps: [.github/instructions/pact-traps.instructions.md](../../instructions/pact-traps.instructions.md)

## Structure
A `defpact` is an ordered sequence of steps executed across separate transactions.

```pact
(defpact my-flow (arg:string)
  (step EXPR)                         ;; no rollback
  (step-with-rollback STEP-EXPR ROLLBACK-EXPR))  ;; rollback runs only on later-step failure
```

Rules:
- Each `(step ...)` takes **exactly ONE expression** — wrap multiple actions in `let`/`with-capability`/`begin...`-style single forms.
- **Step 0 is an `exec` transaction.** Later steps are `cont` transactions that carry **NO Pact code** — only `pactTxHash` (the pact-id), `step`, `rollback` flag, and an optional SPV `proof`.
- The **last step cannot have a rollback**.
- Nested defpacts are allowed; the `continue` native advances a nested defpact.
- **Private/confidential defpacts are REMOVED in Pact 5.**

## yield / resume
`yield` passes a typed object to the next step; `resume` binds it in the next step.

```pact
(step
  (let ((payload { "amount": amount, "to": receiver }))
    (yield payload)))            ;; same-chain yield
(step
  (resume { "amount" := amt, "to" := to }
    (credit to amt)))
```

Cross-chain: `(yield obj target-chain)` yields to a **different** chain. The continuation is a `cont` tx submitted on `target-chain` carrying an SPV `proof` of step 0.

## Canonical Example — coin.transfer-crosschain
- **Step 0** (source chain): debits sender + `(yield { "receiver":..., "receiver-guard":..., "amount":..., "source-chain":... } target-chain)`.
- **Step 1** (target chain): `resume`s the yielded object + credits on the target chain.
- **Step 1 MUST re-validate `amount` FROM THE RESUMED YIELD**, never from fresh tx data — the continuation tx carries no user code, and trusting fresh data would break value conservation.
- Enforce `target-chain != source-chain` and `target-chain ∈ valid chain IDs`.

```pact
(defpact transfer-crosschain (sender:string receiver:string receiver-guard:guard target-chain:string amount:decimal)
  (step
    (with-capability (TRANSFER_XCHAIN sender receiver amount target-chain)
      (enforce (!= target-chain (at 'chain-id (chain-data))) "cannot xchain to same chain")
      (enforce (> amount 0.0) "amount must be positive")
      (debit sender amount)
      (let ((payload { "receiver": receiver
                     , "receiver-guard": receiver-guard
                     , "amount": amount
                     , "source-chain": (at 'chain-id (chain-data)) }))
        (yield payload target-chain))))
  (step
    (resume { "receiver" := rcv, "receiver-guard" := rg, "amount" := amt }
      ;; re-validate from the RESUMED yield, not from tx data
      (enforce (> amt 0.0) "amount must be positive")
      (with-capability (CREDIT rcv)
        (credit rcv rg amt)))))
```

## Verified Rules
- **Rollback + cross-chain are mutually exclusive**: "steps with rollbacks disallowed with cross-chain yields".
- The last step cannot have a rollback.
- Synthetic cross-chain events `X_YIELD` / `X_RESUME` are emitted for off-chain tracking.

## Security
- **`pact-id` is NOT an access guard** — `(pact-id)` throws outside a defpact (see canonical traps). Use composed capabilities for authorization, not bare pact-id.
- **Re-acquire composed caps in EACH step** — capability scope does not survive across the tx boundary between steps. coin re-acquires `TRANSFER_XCHAIN` / `CREDIT` in step 1.
- **Orphaned-transfer DoS**: if step 1 is never submitted, funds sit in limbo (debited on source, never credited on target). Mitigate with a gas-station relayer that submits the `cont` step (see [gas-station-design](../gas-station-design/SKILL.md)) and/or a rollback/refund path with a deadline — **rollback refunds are same-chain only** (cross-chain steps cannot roll back).

## REPL Testing
- `(continue-pact step rollback pact-id)` advances a pact; `rollback` is a bool; `pact-id` is optional **but required across a `commit-tx`** boundary.
- `(pact-state)` inspects current pact execution state; `(pact-state true)` resets it.
- defpacts are called **module-qualified**: `(free.my-module.my-flow ...)`.

```pact
(begin-tx "step 0")
(env-data { "amt": 5.0 })
(env-chain-data { "chain-id": "0" })
(use free.my-module)
(my-flow "alice" "bob" 5.0)          ;; executes step 0, yields
(commit-tx)

(begin-tx "step 1 — resume")
(env-chain-data { "chain-id": "0" })
;; pact-id must be passed explicitly across the commit-tx boundary
(continue-pact 1 false "<pact-id-from-step-0>")
(expect "credited" 5.0 (get-balance "bob"))
(commit-tx)
```
