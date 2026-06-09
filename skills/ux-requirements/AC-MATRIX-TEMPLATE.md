# AC Coverage Matrix — Template

Tester MUST fill this matrix in every PR review that touches UI / visual / UX surfaces. No `[GO]` verdict may be posted unless every UI AC has a populated row.

## Source of Truth
The WebDev AC Matrix reporter emits `docs/artifacts/ac-matrix-latest.json` on every Playwright run. Every `[AC-...]` ID below MUST be present in that file; IDs not present = missing test, not a pass.

## Required Columns
- **AC ID** — Exact ID assigned by Product (e.g., `AC-US-002-01`). Do NOT invent IDs.
- **Test** — Playwright spec file + line number of the `test()` block.
- **Status** — One of: `PASS (regression)`, `PASS (new baseline)`, `FAIL`, `SKIP`, `MISSING`.
- **Screenshot** — Artifact path (committed baseline or `test-results/` output). Required for every row.
- **Trace** — Path to Playwright trace. **Required** for `FAIL`; optional for `PASS`.
- **Notes** — Diff image path for visual FAIL; baseline-review note for new baselines; reason for SKIP.

## Matrix

| AC ID | Test | Status | Screenshot | Trace | Notes |
|-------|------|--------|------------|-------|-------|
| AC-US-XXX-01 | `path/to.spec.ts:NN` | PASS (regression) | `path/to/screenshot.png` | — | |
| AC-US-XXX-02 | `path/to.spec.ts:NN` | PASS (new baseline) | `path/to/screenshot.png` | — | Baseline visually confirmed — see diff image |
| AC-US-XXX-03 | `path/to.spec.ts:NN` | FAIL | `path/to/actual.png` | `path/to/trace.zip` | 3.2% pixel diff — `path/to/diff.png` |
| AC-US-XXX-04 | — | MISSING | — | — | No test maps to this AC — blocker |

## Status Definitions

| Status | Meaning | Allowed in `[GO]` verdict? |
|--------|---------|----------------------------|
| `PASS (regression)` | Test ran against existing baseline and matched | Yes |
| `PASS (new baseline)` | First run auto-accepted — baseline must be visually confirmed by Tester | Yes, **only if baseline confirmed** |
| `FAIL` | Test ran and failed | No — blocks merge |
| `SKIP` | Test intentionally skipped — must include justification | Only with Architect approval |
| `MISSING` | No test maps to this AC | No — blocks merge |

## Independent Verification Record

For every UI PR, Tester MUST drive the changed flows via Playwright MCP (live browser) and record:

| AC ID | Independent Screenshot | Notes |
|-------|------------------------|-------|
| AC-US-XXX-01 | `path/to/independent.png` | Matches committed baseline |

## Self-Audit Before Submitting
- [ ] Every UI AC from the linked story has a row (no silent omissions)
- [ ] Every `[AC-...]` ID cross-referenced against `ac-matrix-latest.json`
- [ ] Every screenshot path opened and visually inspected by Tester
- [ ] No masks hide the element the AC actually asserts
- [ ] All FAIL rows include both trace AND diff image paths
- [ ] Independent Playwright MCP verification captured for changed flows
