---
description: "Architect/Developer: Design a multi-step or cross-chain defpact — step decomposition, yield/resume schema, SPV placement, rollback rules, per-step capability re-acquisition, orphan/continuation strategy, synthetic events, and a REPL test plan."
---
# Design a Defpact (multi-step / cross-chain)

> Canonical traps: [../instructions/pact-traps.md](../instructions/pact-traps.md)
> Skills: [pact-defpact](../skills/pact-defpact.md), [gas-station-design](../skills/gas-station-design.md)

## 1. Define the steps
- Each `(step ...)` takes **exactly ONE expression** — wrap multiple actions in a single `let`/`begin`-style form.
- Number the steps and state, per step: actor, chain, preconditions, state writes, what is yielded.
- Same-chain defpact: linear steps execute in one transaction context across blocks.
- Cross-chain: a `(step-with-rollback ...)` or `yield`-with-`target-chain` hands off to another chain.
- Avoid legacy entity step forms (`(step ENTITY EXPR)`): parser accepts legacy syntax, but Pact 5 defpact desugaring/eval rejects entity usage.

## 2. Yield / resume object schema
- Define the **exact** object yielded at each boundary: field names + types.
- `resume` must bind only the fields it consumes (mirror the `with-default-read` rule — the bound set, not the full schema).
- Keep the payload minimal and self-describing; never yield secrets or unbounded data.

## 3. Where SPV applies
- Cross-chain continuation requires an **SPV proof** of the source-chain step output.
- State the proof type (`pact` continuation proof), who fetches it, and which step consumes it on the target chain.
- Same-chain steps need NO SPV.

## 4. Rollback rules
- Provide rollback ONLY where it is legal: **no rollback on the last step**, and **no rollback after a cross-chain `yield`** (the burn already committed on the source chain).
- Cross-chain value transfer = burn-on-source / mint-on-target; design it so a missing target step cannot double-spend.

## 5. Re-acquire composed capabilities per step
- Each step re-acquires the capabilities it needs via `with-capability` / `compose-capability`.
- **NEVER** gate a step on `(pact-id)` — it throws outside a defpact and proves no identity inside one. Bind authority to a composed capability instead (canonical traps).
- Do not assume caps from an earlier step are still in scope.

## 6. Orphan / continuation strategy
- A cross-chain transfer whose continuation never lands is **orphaned** (value burned, never minted).
- Choose a recovery path:
  - **Gas-station relayer** that submits the continuation (see gas-station-design — drain-defense + tx-introspection constraints), or
  - a **deadline + refund** path that re-mints on the source chain after expiry.
- Document who pays gas for the continuation and how griefing is bounded.

## 7. Synthetic events
- Emit `X_YIELD` on the source step and `X_RESUME` on the target step so off-chain indexers can pair the two halves of a cross-chain flow.
- Define event names + parameters; keep them stable for indexers.

## 7.1 Continuation Integrity Checklist (required)
- Show how `defpact-id`, next `step`, and `rollback` expectations stay consistent across cont calls.
- Define behavior for stale/duplicate/incorrect continuation submissions (map to expected failures like `DefPactStepMismatch`, `DefPactRollbackMismatch`, `DefPactAlreadyCompleted`).
- For cross-chain, include a mismatch-handling note for continuation/SPV inconsistency (`CCDefPactContinuationError`).

## 8. Test plan — REPL for same-chain, DEVNET for cross-chain
- **REPL covers SAME-CHAIN scope ONLY.** Drive the pact with `continue-pact` and inspect
  with `pact-state`. Cover: full happy path (all steps *on one chain*), each rollback path,
  a stalled continuation (orphan), and a replay attempt. Assert yielded/resumed objects
  field-by-field and assert `X_YIELD`/`X_RESUME` via `env-events`.
- **🔴 CROSS-CHAIN IS DEVNET-ONLY — do NOT simulate the SPV handoff in a `.repl`.** SPV is
  unsupported in the bare REPL (`noSPVSupport` → `SPVVerificationFailure`), so a cross-chain
  step cannot be exercised there; any "passing" cross-chain `.repl` is a FALSE POSITIVE.
  Put every cross-chain scenario on a **multi-chain devnet**: deploy to ≥2 chains → step 0
  (`exec`) on the source chain → fetch the SPV proof from `/spv` → `cont` (step 1) with that
  proof on the target chain. See [testing-rules](../instructions/testing-rules.md) HARD RULE
  and the [pact-defpact](../skills/pact-defpact.md) skill.
- Explicitly note that `continue-pact` is REPL-only harness support, not on-chain module code.

## Output
- Numbered step table (actor / chain / writes / yield).
- Yield/resume schema block.
- Rollback + orphan-recovery decision with justification.
- REPL test matrix (scenario → expected state/events).
