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
