---
name: feature-prioritization
description: "MoSCoW prioritization, value/effort mapping, and feature ranking for Pact Community product decisions. Priority assessment framework for DAO and Ledger Signer."
---
# Feature Prioritization

## MoSCoW Framework
| Category | Criteria | Examples |
|----------|----------|---------|
| **Must** | Core, security-critical, blocks others | Token transfer, governance cap |
| **Should** | Important, workarounds exist | Gas station, dividend auto-claim |
| **Could** | Nice-to-have, improves UX | Batch operations, event search |
| **Won't** | Out of scope this milestone | Cross-chain voting, staking |

## Value/Effort Matrix
```
        High Value
           │
    Quick  │  Strategic
    Wins   │  Priorities
───────────┼───────────
    Fill-  │  Avoid /
    Ins    │  Defer
           │
        Low Value
  Low Effort ←→ High Effort
```

## Prioritization Process
1. List all candidate features
2. Classify each by MoSCoW
3. Plot on value/effort matrix
4. Order: Quick Wins → Strategic → Fill-Ins → Defer
5. Validate with user (via Orchestrator)
