---
description: "Use when writing tests, designing test strategy, reviewing test quality, or running QA for Pact 5 contracts. Covers REPL testing, devnet testing, TypeScript test patterns, and the dual-scope mandate."
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
- Tag all test output with `[Tester]` or `[Security]` prefix

## Coverage Requirements
- Every public function: at least happy path + one error path
- Every capability: authorized + unauthorized test
- Every cross-module interaction: integration test
- Every mathematical formula: boundary value analysis

## Four-Phase Testing (Tester Agent)
1. **REPL Analysis** — Static analysis of .repl test files
2. **REPL Execution** — Run .repl tests, verify results
3. **Devnet Deploy** — Deploy all modules to dedicated devnet
4. **Devnet Verification** — Integration + adversarial testing on devnet

## UI Acceptance Criteria — Visual Evidence Mandate

Applies to every PR touching UI / visual / UX surfaces (web apps, marketing, admin, any rendered component). The dual-scope mandate (isolated + full regression) applies to UI identically to backend.

### Evidence Requirement
Every UI AC verdict (PASS or FAIL) MUST cite all of:
- **Playwright test ID** in the form `[AC-US-XXX-NN]` (tag present in the `test()` title)
- **Screenshot artifact path** (committed baseline or actual run output under `test-results/` / `playwright-report/`)
- **Trace path** — MANDATORY for any FAIL; optional for PASS
- For visual-regression FAIL: **diff image path** in addition to the trace

### Forbidden Verdicts
The following are treated as false positives and MUST be rejected in self-audit:
- "Looks good" / "renders correctly" / "matches design" without artifact citations
- "Component source shows X, therefore UI renders X" (inference from code, not observation)
- Citing a test name without confirming the test actually ran in this PR's CI and produced an artifact

### AC Coverage Matrix
Every UI PR review MUST include a filled AC Coverage Matrix (template: [ux-requirements/AC-MATRIX-TEMPLATE.md](../skills/ux-requirements/AC-MATRIX-TEMPLATE.md)). No `[GO]` verdict may be posted unless every UI AC has a row with all required columns populated.

### Source of Truth
The AC Coverage Matrix reporter emits `docs/artifacts/ac-matrix-latest.json`. Tester MUST reconcile every `[AC-...]` ID cited in the review against that file; any ID not present is a missing test, not a pass.

### Independent Live Verification
For any UI PR, Tester MUST also drive the changed flows via Playwright MCP (live browser) and capture independent evidence screenshots. Trusting only the committed tests is insufficient — Tester owns independent validation.

### New-Baseline Rule
A first-run screenshot that auto-accepts is a **new baseline**, not a passing regression. Matrix MUST distinguish `PASS (new baseline)` from `PASS (regression)`. New baselines require visual confirmation that the baseline itself is correct before acceptance.
