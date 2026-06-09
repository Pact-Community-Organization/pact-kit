---
name: regression-detection
description: "Detect regressions from schema migrations, interface drift, cross-module changes, and deploy order modifications in Pact 5 smart contracts."
---
# Regression Detection

## Regression Sources
1. **Schema migration** — New fields changing with-default-read behavior
2. **Interface drift** — Implementation diverging from interface contract
3. **Deploy order change** — New module inserted, changing resolution order
4. **Cross-module impact** — Change in module N breaks module N+1
5. **Config change** — New config parameter with invalid default

## Detection Strategy
1. Run FULL existing test suite (not just changed module tests)
2. Deploy ALL modules to devnet in production order
3. Run end-to-end lifecycle tests
4. Compare gas measurements against baseline
5. Verify all cross-module calls still resolve

## Regression Test Checklist
- [ ] Module deploy order unchanged (or intentionally changed)
- [ ] All existing REPL tests pass
- [ ] All existing devnet tests pass
- [ ] Gas measurements within ±10% of baseline
- [ ] Interface compliance verified
- [ ] Cross-module integration tests pass
- [ ] No new `[UNCERTAIN]` findings from existing tests

## When a Regression is Found
1. Stop — do not attempt to fix the test
2. Classify: is this a real regression or a test issue?
3. Document: what changed, what broke, evidence
4. Report to Orchestrator with `[HIGH]` severity
