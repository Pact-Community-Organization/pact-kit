---
description: "Use when running tests, reviewing test results, or producing QA reports. Diagnostic integrity is the HIGHEST PRIORITY for Tester and Security agents. Covers false positive prevention, test failure protocol, and self-audit requirements."
# Diagnostic Integrity Rules — HIGHEST PRIORITY

These rules override ALL other behavioral guidance for Tester and Security agents.

## Core Principle
**Failing tests are successes.** They prove the agent is doing its job. Testers are truth-tellers, not fixers.

## Absolute Prohibitions

1. **NEVER** modify a test solely to make it pass
2. **NEVER** weaken assertions without evidence the original was wrong
3. **NEVER** produce false positives — a passing test on broken code is worse than no test
4. **NEVER** optimize for green test results — the goal is truthful diagnostics
5. **NEVER** modify code solely to eliminate test failures — root cause analysis first

## When a Test Fails — Mandatory Protocol

1. **STOP** — Do not immediately attempt to fix
2. **ANALYZE** — Explain WHY it failed with evidence (error message, state, trace)
3. **CLASSIFY** — Determine if:
   - **Real bug** in contract code → document finding with severity
   - **Missing requirement** → document and escalate to Architect/Product
   - **Ambiguous specification** → document with `[UNCERTAIN]` tag
   - **Flawed test** → fix with justification, mark as test correction
4. **PROPOSE** — Only after analysis, propose the correct action

## False Positive Patterns to Watch

### Pact / Backend
1. Empty `""` in `expect-failure` — matches ANY error (tautological)
2. `result.status === 'success'` without postcondition → no-op passes
3. `{int: N} === N` → false (Pact type not unwrapped)
4. Reading non-existent field → `undefined` → `NaN` → silent pass
5. Test B depends on test A having run first (state dependency)
6. `await wait(N)` for chain time — devnet ~2× slower
7. Positive test without paired negative test
8. Row key asserted as schema field — always `undefined`

### UI / Visual
9. Agent reads component source and concludes "UI looks correct" without running the test or observing a screenshot — **forbidden**
10. `toHaveScreenshot` mask region swallows the exact element the AC asserts (e.g., balance text masked while AC asserts balance renders) — the test becomes tautological
11. Visual test passes because no baseline exists yet and the first run auto-accepted — this is `PASS (new baseline)`, NOT a regression pass; must be flagged and the baseline visually confirmed
12. Agent cites a stale screenshot from a prior PR as evidence for the current PR
13. `[AC-...]` ID cited in review is not present in `docs/artifacts/ac-matrix-latest.json` — the test does not exist or did not run
14. Playwright test passes because selector never matched (element missing) and the assertion was an absence check — verify the element was actually rendered before the assertion
15. Trusting the test name (`ensure-balance-renders.spec.ts`) instead of opening the produced screenshot file

## Test Design Rules

- Every success test MUST have postcondition (state change verified)
- Every positive auth test MUST have paired negative (no-auth expects failure)
- Every `expect-failure` MUST use specific error string, never `""`
- Every test MUST be self-contained (no implicit state dependency)
- Every test MUST cite requirement source (ADR, PROC, AC, or invariant)
- Devnet time-dependent tests MUST poll chain time, never static wait

## Self-Audit Requirement
Before submitting ANY report, complete the self-audit checklist in `.github/instructions/self-audit-checklist.instructions.md`.
