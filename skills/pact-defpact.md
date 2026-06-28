---
name: pact-defpact
description: "Pact 5 multi-step pacts (defpact) and cross-chain transfers: step structure, yield/resume, SPV continuation, orphaned-transfer defense."
---
# Pact Defpact (Multi-Step & Cross-Chain)

> Canonical traps: [../instructions/pact-traps.md](../instructions/pact-traps.md)

## Structure
A `defpact` is an ordered sequence of steps executed across separate transactions.

```pact
(defpact my-flow (arg:string)
  (step EXPR)                         ;; no rollback
  (step-with-rollback STEP-EXPR ROLLBACK-EXPR))  ;; rollback runs only on later-step failure
```

Rules:
- Each `(step ...)` takes **exactly ONE expression** — wrap multiple actions in a single form: `let`/`let*` (a `let` body may hold several sequenced exprs), `with-capability`, or the `(do ...)` sequencing form (Pact 5.0+). There is **no `begin`** form in Pact 5.
- **Step 0 is an `exec` transaction.** Later progression is `cont` using persisted pact state (`pactTxHash`, `step`, `rollback`, optional SPV `proof`) rather than fresh Pact source in the continuation command.
- Rollback mode is only valid for `step-with-rollback` boundaries; terminal-step rollback attempts are rejected by continuation checks.
- Nested defpacts are allowed; the `continue` native advances a nested defpact.
- **Private/confidential defpacts are REMOVED in Pact 5.**
- Parser legacy entity step syntax may still parse for compatibility, but Pact 5 desugaring/eval reject entity-in-defpact usage with `EntityNotAllowedInDefPact`.

## Runtime State Machine (source-anchored)

Defpact execution is driven by two records (`pact/Pact/Core/DefPacts/Types.hs`):

- **`DefPactExec`** — the **persisted** state saved to the pact DB after each step:
  `stepCount`, `yield`, `step`, `defPactId`, `continuation` (def name + args),
  `stepHasRollback`, `nestedDefPactExec` (map of child execs).
- **`DefPactStep`** — the **input** a continuation command carries:
  `step`, `rollback`, `defPactId`, `resume` (the yielded object to bind).

Lifecycle (`initPact` → `applyPact` → `resumePact` in the evaluator):
- **Step 0 (`exec`)**: `initPact` builds `DefPactStep 0 False <pact-id> Nothing`; the
  top-level pact-id **is the transaction hash** (`hashToDefPactId pHash`). `applyPact`
  then discovers `stepCount = (length steps)` from the module and persists the
  `DefPactExec`.
- **One defpact per transaction**: starting a second defpact while one is active fails
  `MultipleOrNestedDefPactExecFound`.
- **Later steps (`cont`)**: the continuation command supplies `step`/`rollback`/
  `pact-id`/optional SPV `proof` — **no user Pact code runs** (`evalContinuation`
  interprets `RawCode mempty`; if a `proof` is present it is SPV-verified first, else
  `ContinuationError`). The evaluator validates against the persisted exec:
  - step outside `[0, stepCount)` → `InvalidDefPactStepSupplied`
  - wrong pact-id → `DefPactIdMismatch`
  - step not exactly previous + 1 → `DefPactStepMismatch`
  - rollback requested on a non-rollback step → `DefPactStepHasNoRollback`
  - rollback flag disagrees with the step → `DefPactRollbackMismatch`
  - continuing past the last step → `DefPactAlreadyCompleted`
  - no persisted exec found → `NoPreviousDefPactExecutionFound`
- `step-with-rollback` runs its **first** expr going forward and its **second** expr on
  rollback; a plain `step` has no rollback (`hasRollback Step{} = False`).

## Nested defpacts & `continue`

A step may invoke another module's defpact; the child runs as a **nested** defpact
recorded under `peNestedDefPactExec`. Advance the child with the **`continue`** native
(`CoreContinue`, arity 1) — distinct from the REPL-only `continue-pact`. The nested
pact-id is **derived**: `hash(parentPactId : encodeStable(continuation))`.

```pact
(defpact parent (name:string)
  (step       (child-module.flow name))            ;; starts the nested defpact
  (step       (continue (child-module.flow name))) ;; advances it in lockstep
  (step       (continue (child-module.flow name))))
```

Lockstep invariants (evaluator; verified by static tests):
- Child **step count must equal** the parent's → else `NestedDefPactParentStepCountMismatch`.
- Child **rollback-ness must match** the parent step → else `NestedDefPactParentRollbackMismatch`.
- Child must start at parent step 0; a later parent step with no prior child exec →
  `NestedDefPactDoubleExecution`; a child whose step doesn't line up (`childStep + 1 != parentStep`)
  → `NestedDefPactNeverStarted`.
- Every nested child must be advanced on each parent step → `NestedDefpactsNotAdvanced`.

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

Cross-chain: `(yield obj target-chain)` yields to a **different** chain. The
continuation is a `cont` tx submitted on `target-chain` carrying an SPV `proof` of
step 0, and provenance checks enforce that resumed data matches the expected
continuation lineage.

### Cross-chain provenance & SPV (source-anchored)
- **`(yield obj target-chain)`** stamps the yield with a **`Provenance { targetChainId,
  moduleHash }`** built from the **current calling module's hash** and the target chain
  (`coreYield` → `provenanceOf`), and records the **source chain**. Same-chain
  `(yield obj)` carries **no** provenance.
- **`resume` enforces provenance** (`enforceYield`): the yield's `Provenance` must equal
  `Provenance <currentChain> <resuming-module-hash>` **or** a `Provenance` over one of the
  module's **blessed** hashes. Mismatch → `YieldProvenanceDoesNotMatch`. **Consequence:**
  if the module was **upgraded** between the source-chain yield and the target-chain
  resume, the **old module hash must be `bless`ed** or the cross-chain resume fails. This
  is the #1 cross-chain upgrade footgun.
- **Continuation transport is SPV, not user code.** On-chain, the target-chain `cont`
  command carries an SPV `proof`; `evalContinuation` calls the platform's
  `_spvVerifyContinuation proof` which returns the source-chain **`DefPactExec`** to
  resume from. A bad/absent proof → `ContinuationError` ("Continuation error:"). The
  default `noSPVSupport` backend returns "Cross-chain continuations not supported".
- **`(verify-spv type payload)`** is a **separate** generic native: it calls the
  platform `_spvSupport` backend (e.g. `"txout"`) and returns the verified object, or
  `SPVVerificationFailure`. It is **platform-dependent** — `noSPVSupport` (and bare REPL)
  returns "SPV verification not supported". Do NOT confuse it with the defpact
  continuation-proof path above.
- **`X_YIELD` / `X_RESUME`** reserved events fire under the **`pact`** module
  (`emitXChainEvents`): `X_YIELD` params `[ target-chain-id, "<qualified-cont-name>", [args] ]`
  on the source chain; `X_RESUME` params `[ source-chain-id, "<qualified-cont-name>", [args] ]`
  on the target chain. Off-chain relayers key on these.

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
- Synthetic cross-chain events `X_YIELD` / `X_RESUME` are emitted for off-chain tracking.
- Continuation resume invariants are strict: id, step bounds, rollback mode, and prior-state checks fail with typed errors (common mismatch/lifecycle family: `DefPactIdMismatch`, `InvalidDefPactStepSupplied`, `DefPactStepMismatch`, `DefPactRollbackMismatch`, `DefPactAlreadyCompleted`, `NoPreviousDefPactExecutionFound`).
- Cross-chain continuation payload/state consistency is enforced (`CCDefPactContinuationError`) before resume.
- Nested defpacts must advance in lockstep with parent expectations (`NestedDefPactParentStepCountMismatch`, `NestedDefPactParentRollbackMismatch`, `NestedDefPactNeverStarted`, `NestedDefPactDoubleExecution`, `NestedDefpactsNotAdvanced`).

## Security
- **`pact-id` is NOT an access guard** — `(pact-id)` throws outside a defpact (see canonical traps). Use composed capabilities for authorization, not bare pact-id.
- **Re-acquire composed caps in EACH step** — capability scope does not survive across the tx boundary between steps. coin re-acquires `TRANSFER_XCHAIN` / `CREDIT` in step 1.
- **Orphaned-transfer DoS**: if step 1 is never submitted, funds sit in limbo (debited on source, never credited on target). Mitigate with a gas-station relayer that submits the `cont` step (see [gas-station-design](../skills/gas-station-design.md)) and/or a rollback/refund path with a deadline — **rollback refunds are same-chain only** (cross-chain steps cannot roll back).

## REPL Testing
- `(continue-pact step rollback pact-id)` advances a pact; `rollback` is a bool; `pact-id` is optional **but required across a `commit-tx`** boundary.
- `(pact-state)` inspects current pact execution state; `(pact-state true)` resets it.
- defpacts are called **module-qualified**: `(free.my-module.my-flow ...)`.
- `continue-pact` is a REPL helper path (desugared into `RContinuePact*` forms). On-chain progression uses continuation command payloads plus evaluator resume logic, not direct module calls to a `continue-pact` primitive.

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
