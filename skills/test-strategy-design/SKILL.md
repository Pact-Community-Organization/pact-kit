---
name: test-strategy-design
description: "Test strategy design — test pyramid, technique selection, risk-based testing, coverage planning, and test suite architecture for Pact 5 on KDA-CE."
---
# Test Strategy Design

## Test Pyramid
```
         /  E2E  \        — Devnet lifecycle tests
        / Integration \    — Cross-module devnet tests
       /   Unit (REPL)  \  — Individual function tests
      /   Static Analysis \— Automated trap detection
```

## Strategy Selection by Risk
| Risk Level | Approach |
|-----------|----------|
| CRITICAL (funds, governance) | REPL + Devnet + Adversarial + Formal |
| HIGH (logic, state) | REPL + Devnet + Boundary |
| MEDIUM (config, display) | REPL + Happy/Error path |
| LOW (cosmetic) | REPL only |

## Coverage Planning
- Every public function: happy + error paths
- Every capability: authorized + unauthorized
- Every cross-module call: integration test
- Every formula: boundary value analysis
- Every time-dependent operation: chain time polling test

## Strategy Document Template
```markdown
## Test Strategy — {feature/module}
Risk: {CRITICAL|HIGH|MEDIUM|LOW}
Techniques: {REPL, Devnet, Adversarial, Formal, Fuzz}
Coverage: {what's tested}
Exclusions: {what's not tested and why}
Requirements: {ADR/PROC/AC references}
```
