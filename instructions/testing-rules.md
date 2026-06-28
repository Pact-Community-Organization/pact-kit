---
description: "Test-writing rules for Pact 5: REPL patterns, devnet patterns, TypeScript test patterns, and the dual-scope mandate. Use when writing or reviewing tests."
applyTo: ["**/*.repl", "**/*.test.ts", "pact-examples/pact/tests/**"]
# Testing Rules

## Fundamental Principle
Tests are designed from SPECIFICATIONS (ADRs, requirements, acceptance criteria), NOT from reading source code. Expected values come from the specification.

## Dual-Scope Mandate
Every PR review MUST include BOTH:

### 1. Isolated Testing (Component-Level)
- Test ONLY the changed/new functions in isolation
- Focused REPL tests and devnet tests for specific changes
- Cover: happy path, error paths, boundary cases, adversarial scenarios

### 2. Full Regression Testing (System-Level)
- Run the FULL existing test suite after changes
- Deploy ALL modules (not just changed ones) to devnet
- Run end-to-end lifecycle tests across all modules
- Verify no existing functionality was broken

## REPL Test Rules (.repl files)
- Use `expect` for positive assertions
- Use `expect-failure` with SPECIFIC error string (never `""`)
- Reset state between tests — no implicit dependencies
- Comment each test block: `; Tests: ADR-NNN / PROC-NNN / AC-NNN`
- Test both authorized and unauthorized paths

## Devnet Test Rules (TypeScript)
- Use vitest as test runner
- Use `client.pollOne()` not `client.listen()`
- Unwrap Pact API types before comparison
- Poll chain time for time-dependent tests
- Verify postconditions via localCall or direct read
- Name test functions descriptively (function + scenario + expected outcome)

## Coverage Requirements
- Every public function: at least happy path + one error path
- Every capability: authorized + unauthorized test
- Every cross-module interaction: integration test
- Every mathematical formula: boundary value analysis

## Four-Phase Testing
1. **REPL Analysis** — Static analysis of .repl test files
2. **REPL Execution** — Run .repl tests, verify results
3. **Devnet Deploy** — Deploy all modules to devnet
4. **Devnet Verification** — Integration + adversarial testing on devnet
