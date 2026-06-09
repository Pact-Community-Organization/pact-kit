---
description: "Tester: Run 4-phase validation on a Pact module — REPL analysis, REPL execution, devnet deploy, devnet verification. Produce comprehensive validation report."
---
# Validate Pact Module

## Four-Phase Protocol

### Phase 1: REPL Analysis
- Read .repl test files for the module
- Check for false positive patterns
- Verify test independence and requirement traceability

### Phase 2: REPL Execution
- Run all .repl tests
- Document pass/fail with evidence
- Flag any suspicious passes

### Phase 3: Devnet Deploy
- Deploy all modules in order to devnet (port 8082)
- Use unscoped signers for admin ops
- Record gas consumption per operation

### Phase 4: Devnet Verification
- Run integration tests on devnet
- Execute adversarial tests
- Verify cross-module interactions
- Measure gas on every operation

## Report
```markdown
## Module Validation — {module}
Phase 1: {PASS | N findings}
Phase 2: {N of M tests passed}
Phase 3: {PASS | FAIL — gas: N}
Phase 4: {N tests, N findings}

Verdict: [Tester] [GO | NO-GO]
Justification: {evidence}
```
