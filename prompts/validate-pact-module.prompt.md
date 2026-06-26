---
description: "Tester: Run 4-phase validation on a Pact module — REPL analysis, REPL execution, devnet deploy, devnet verification. Produce comprehensive validation report."
---
# Validate Pact Module

> Canonical traps: [../instructions/pact-traps.instructions.md](../instructions/pact-traps.instructions.md)
> Skills: [pact-cli-tooling](../skills/pact-cli-tooling/SKILL.md), [pact-defpact](../skills/pact-defpact/SKILL.md), [pact-module-validation](../skills/pact-module-validation/SKILL.md). Diagnostic integrity: [diagnostic-integrity-rules](../instructions/diagnostic-integrity-rules.instructions.md).

## Four-Phase Protocol

### Phase 1: REPL Analysis
- Read .repl test files for the module
- Check for false positive patterns
- Verify test independence and requirement traceability
- Verify no module code depends on REPL-only helpers (`continue-pact`, `pact-state`, `expect*`)
- For defpacts, verify tests cover continuation invariants (step mismatch, rollback mismatch, duplicate continuation, already completed)

### Phase 2: REPL Execution
- Run all .repl tests
- Document pass/fail with evidence
- Flag any suspicious passes
- Use correct static invocation first: `pact FILE.pact` (bare load) and `pact --check-shadowing FILE.pact`
- Record exact error substrings for failure-path assertions

### Phase 3: Devnet Deploy
- Deploy all modules in order to devnet (port 8082)
- Use unscoped signers for admin ops
- Record gas consumption per operation
- For defpacts, verify continuation lifecycle on-chain: init step, continuation step progression, rollback legality

### Phase 4: Devnet Verification
- Run integration tests on devnet
- Execute adversarial tests
- Verify cross-module interactions
- Measure gas on every operation
- For cross-chain defpacts, validate SPV continuation acceptance and mismatch handling
- Validate synthetic event behavior (`X_YIELD`/`X_RESUME`) where applicable

## Mandatory Source-Anchored Assertions
- Confirm continuation-state errors are exercised where relevant: `DefPactStepMismatch`, `DefPactRollbackMismatch`, `DefPactAlreadyCompleted`, `DefPactIdMismatch`, `NoPreviousDefPactExecutionFound`
- Confirm nested defpact invariants where nested flows exist (`NestedDefPact*` family)
- Confirm `yield`/`resume` guardrails where used (`YieldOutsideDefPact`, `NoYieldInDefPactStep`, provenance mismatch)
- If legacy entity step syntax appears, classify as invalid for modern defpact usage (entity not allowed in defpact)

## Report
```markdown
## Module Validation — {module}
Phase 1: {PASS | N findings}
Phase 2: {N of M tests passed}
Phase 3: {PASS | FAIL — gas: N}
Phase 4: {N tests, N findings}

Source-anchored checks:
- REPL-only vs on-chain builtin boundary: {PASS|FAIL}
- Defpact continuation invariants: {PASS|FAIL}
- yield/resume invariants: {PASS|FAIL}

Verdict: [Tester] [GO | NO-GO]
Justification: {evidence}
```
