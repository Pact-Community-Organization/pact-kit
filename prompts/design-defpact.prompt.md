---
description: "Architect/Developer: Design a multi-step or cross-chain defpact — step decomposition, yield/resume schema, SPV placement, rollback rules, per-step capability re-acquisition, orphan/continuation strategy, synthetic events, and a REPL test plan."
---
# Design a Defpact (multi-step / cross-chain)

> Canonical traps: [../instructions/pact-traps.instructions.md](../instructions/pact-traps.instructions.md)
> Skills: [pact-defpact](../skills/pact-defpact/SKILL.md), [gas-station-design](../skills/gas-station-design/SKILL.md)

## 1. Define the steps
- Each `(step ...)` takes **exactly ONE expression** — wrap multiple actions in a single `let`/`begin`-style form.
- Number the steps and state, per step: actor, chain, preconditions, state writes, what is yielded.
- Same-chain defpact: linear steps execute in one transaction context across blocks.
- Cross-chain: a `(step-with-rollback ...)` or `yield`-with-`target-chain` hands off to another chain.

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

## 8. REPL test plan
- Drive the pact with `continue-pact` and inspect with `pact-state`.
- Cover: full happy path (all steps), each rollback path, a stalled continuation (orphan), and a replay attempt.
- Assert yielded/resumed objects field-by-field and assert `X_YIELD`/`X_RESUME` via `env-events`.
- For cross-chain, simulate the SPV handoff per the pact-defpact skill.

## Output
- Numbered step table (actor / chain / writes / yield).
- Yield/resume schema block.
- Rollback + orphan-recovery decision with justification.
- REPL test matrix (scenario → expected state/events).
