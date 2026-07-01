---
description: "Test-writing rules for Pact 5: REPL patterns, devnet patterns, TypeScript test patterns, and the dual-scope mandate. Use when writing or reviewing tests."
applyTo: ["**/*.repl", "**/*.test.ts", "pact-examples/pact/tests/**"]
# Testing Rules

## Fundamental Principle
Tests are designed from SPECIFICATIONS (ADRs, requirements, acceptance criteria), NOT from reading source code. Expected values come from the specification.

## HARD RULE — Cross-chain is DEVNET-ONLY locally
**Cross-chain defpacts CANNOT be exercised in the bare REPL. There is NO local
REPL path for a cross-chain step.** A cross-chain step's continuation transport is
an SPV proof, and SPV is unsupported in the bare REPL (`noSPVSupport` →
`SPVVerificationFailure`; `verify-spv` / continuation-proof natives do not resolve).
So to *locally* test anything cross-chain — `(yield obj target)` with a target chain,
cross-chain `continue-pact`, SPV verification, cross-chain transfers — you **MUST use
a multi-chain devnet**, never a `.repl` file.
- **REPL scope for defpacts = same-chain only:** step decomposition, yield/resume
  *within one chain*, rollback shape, per-step capability re-acquisition.
- **Cross-chain scope = devnet only** (Phase 3/4). Deploy to ≥2 chains, run step 0 on
  the source chain, fetch the SPV proof from the `/spv` endpoint, continue on the target chain.
- Never write a `.repl` that claims to prove cross-chain behavior — it is impossible and
  any "passing" such test is a false positive. If a task needs cross-chain verification and
  no devnet is available, STOP and say so (rule 4: ask before acting).

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
