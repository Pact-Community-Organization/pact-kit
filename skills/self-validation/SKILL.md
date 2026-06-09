---
name: self-validation
description: "Pre-output correctness validation for all agents. Check work before submitting — verify Pact syntax, TypeScript types, gas limits, and cross-module consistency."
---
# Self-Validation

## Pre-Output Checklist (All Agents)

### Pact Code
- [ ] No read-only violations (DML inside `try`)
- [ ] Binary `+` operator only (not ternary)
- [ ] No built-in name collisions (exp, abs, log, mod, etc.)
- [ ] `with-default-read` has ALL schema fields in default
- [ ] `install-capability` for `@managed` inside `with-capability`
- [ ] Each defpact step has exactly ONE expression
- [ ] Gas estimate within 150k ceiling

### TypeScript Code
- [ ] Decimal values use `{ decimal: 'N.0' }` format
- [ ] `pollOne()` used instead of `listen()`
- [ ] Pact API types unwrapped before comparison
- [ ] No static `wait()` for time-dependent operations

### Documentation
- [ ] Agent tag prefix on all outputs
- [ ] Severity classification applied
- [ ] Evidence included for all findings
- [ ] Requirement traceability present

### Cross-Module
- [ ] Module dependency order preserved
- [ ] No circular references introduced
- [ ] Balance-changing functions update all related state
