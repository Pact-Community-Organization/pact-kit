---
name: pact-module-validation
description: "Comprehensive Pact module validation — 4-phase testing (REPL analysis, REPL execution, devnet deploy, devnet verification) for smart contract quality assurance."
---
# Pact Module Validation

## Four-Phase Testing Protocol

### Phase 1: REPL Analysis
- Read .repl test files
- Check for false positive patterns (empty expect-failure, missing postconditions)
- Verify test independence (no implicit state dependencies)
- Verify requirement traceability (every test cites source)

### Phase 2: REPL Execution
- Run all .repl tests
- Verify all `expect` assertions pass
- Verify all `expect-failure` assertions catch specific errors
- Document any failures with evidence

### Phase 3: Devnet Deploy
- Deploy all modules in order to dedicated devnet (port 8082)
- Use unscoped signers for admin operations
- Verify gas consumption within budgets
- Confirm all tables created successfully

### Phase 4: Devnet Verification
- Run TypeScript integration tests against deployed modules
- Execute lifecycle flows (buy → transfer → vote → claim)
- Run adversarial tests (unauthorized access, edge cases)
- Verify cross-module interactions
- Measure gas on every operation

## Validation Report Template
```markdown
## Module Validation Report — {module-name}
Phase 1 (REPL Analysis): {PASS|FINDINGS}
Phase 2 (REPL Execution): {PASS|FAIL — N of M tests}
Phase 3 (Devnet Deploy): {PASS|FAIL — gas: N}
Phase 4 (Devnet Verification): {PASS|FAIL — N findings}
Verdict: [Tester] [GO|NO-GO]
```
