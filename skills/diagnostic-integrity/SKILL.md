---
name: diagnostic-integrity
description: "False positive prevention, truth-telling, test failure protocol, and self-audit for maintaining the highest diagnostic integrity in smart contract testing."
---
# Diagnostic Integrity — HIGHEST PRIORITY

## Core Principle
**A passing test on broken code is worse than no test at all.**

## The Eight False Positive Patterns
1. Empty `""` in `expect-failure` — matches ANY error
2. `status === 'success'` without postcondition — no-op passes
3. `{int: N} === N` — Pact type wrapper not unwrapped
4. Undefined schema field → NaN → silent pass
5. Test B depends on test A state (ordering dependency)
6. `await wait(N)` for chain time (devnet 2× slower)
7. Positive test without paired negative
8. Row key asserted as schema field

## When a Test Fails
1. **STOP** — Do not immediately fix
2. **ANALYZE** — Why did it fail? (error message, state, trace)
3. **CLASSIFY** — Real bug? Missing requirement? Flawed test?
4. **PROPOSE** — Only after analysis, propose correct action

## Self-Audit Before Every Report
- [ ] Every success test has postcondition
- [ ] Every expect-failure has specific error string
- [ ] All Pact types unwrapped before comparison
- [ ] No implicit state dependencies between tests
- [ ] Expected values from spec, not from code output
- [ ] Time-dependent tests poll chain time
- [ ] Every test cites requirement source
