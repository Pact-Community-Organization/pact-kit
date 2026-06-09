---
description: "Use before submitting any test report, security audit, or QA verdict. Mandatory self-audit checklist to prevent false positives and ensure diagnostic integrity."
# Self-Audit Checklist

Complete this checklist before submitting ANY report or verdict.

## Test Quality Self-Audit

### Postcondition Verification
- [ ] Every "success" test verifies a postcondition (state changed)
- [ ] No test merely checks `status === 'success'` without verifying effect
- [ ] All expected values derive from specification, not from what code returns

### Error Specificity
- [ ] Every `expect-failure` uses a specific error substring (never `""`)
- [ ] Auth tests have paired positive AND negative cases
- [ ] Error messages distinguish between different failure modes

### Type Safety
- [ ] All Pact `{int: N}` values unwrapped before comparison
- [ ] All Pact `{decimal: "N.M"}` values unwrapped before comparison
- [ ] No schema fields assumed without verifying against `.pact` source
- [ ] Row keys not treated as schema fields

### Independence
- [ ] Each test is self-contained (no implicit state dependency)
- [ ] Tests can run in any order with same results
- [ ] `expect-failure` rollback behavior accounted for

### Timing
- [ ] No `await wait(N)` for time-dependent operations
- [ ] Chain time polled from header endpoint
- [ ] Timeout values account for 2× devnet slowdown

### Requirement Traceability
- [ ] Every test cites its requirement source (ADR, PROC, AC, invariant)
- [ ] Test failure can be mapped to specific requirement violation

## Report Quality Self-Audit
- [ ] All findings include evidence (error messages, state dumps, traces)
- [ ] Severity classification applied consistently
- [ ] `[UNCERTAIN]` tag used for unconfirmed findings
- [ ] No findings based on assumption without verification
- [ ] Recommendations are actionable and specific

## UI / Visual Evidence Self-Audit
Applies to any PR touching UI, visual, or UX surfaces.
- [ ] I actually ran the Playwright test (or drove Playwright MCP live) and observed a screenshot — I am NOT inferring from component source
- [ ] Every `[AC-...]` ID in my report maps to a real test ID present in `docs/artifacts/ac-matrix-latest.json`
- [ ] For every failing visual regression, I attached the diff image path (not just the trace)
- [ ] I verified each screenshot mask is NOT hiding the thing the AC is actually asserting (e.g., AC asserts "balance renders" and balance is not masked out)
- [ ] I distinguished `PASS (new baseline)` from `PASS (regression)` — first-run auto-accepts are NOT regression evidence
- [ ] Screenshots cited are from THIS PR's run, not stale artifacts from a prior PR
- [ ] **Before submitting: I opened the actual screenshot files and looked at them — I am not trusting the test name alone**
- [ ] AC Coverage Matrix is attached to the review and every UI AC row is populated
- [ ] For any UI PR, I performed independent live verification via Playwright MCP, not only the committed test suite
