---
name: cross-chain-design
description: "Cross-chain design patterns for KDA-CE 20-chain architecture. Defpact continuations, SPV proofs, hub-and-spoke patterns, and cross-chain token transfers."
---
# Cross-Chain Design

## KDA-CE Chain Architecture
- 20 chains (0-19) in braided proof-of-work
- Chain 0 = hub convention (governance, config)
- Chains 1-19 = satellite (operations)

## Cross-Chain Transfer (defpact)
```pact
(defpact cross-chain-transfer:string
  (sender:string receiver:string amount:decimal target-chain:string)
  (step
    (with-capability (TRANSFER sender receiver amount)
      (debit sender amount)))
  (step
    (with-capability (CREDIT receiver amount)
      (credit receiver amount))))
```

## SPV Proofs
- Required for verifying events on other chains
- Chainweb provides SPV endpoint: `/spv`
- Must wait for sufficient confirmation depth

## Design Considerations
- Gas paid on initiating chain (step 1)
- Target chain gas paid separately (step 2)
- Each step = exactly ONE expression
- Failure in step 2 requires manual recovery
- Consider timeout/rollback mechanisms

## Local Testing — DEVNET-ONLY (HARD RULE)
**You cannot test cross-chain in the bare REPL. Full stop.** SPV is unsupported there
(`noSPVSupport` → `SPVVerificationFailure`), and SPV is how a cross-chain continuation
is transported — so a `.repl` file physically cannot exercise a cross-chain step. Any
`.repl` that appears to "pass" a cross-chain test is a false positive.
- **To test cross-chain locally → multi-chain devnet ONLY:**
  1. Deploy the module to ≥2 chains (e.g. source `0`, target `1`).
  2. Submit step 0 (`exec`) on the source chain; wait for confirmation depth.
  3. Fetch the SPV proof from the `/spv` endpoint for the target chain.
  4. Submit the `cont` (step 1) with that proof on the target chain; verify credit.
- The REPL is limited to same-chain defpact scope (step decomposition, same-chain
  yield/resume, rollback shape). See [testing-rules](../instructions/testing-rules.md)
  and [pact-defpact](pact-defpact.md).
