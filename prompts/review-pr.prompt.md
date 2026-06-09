---
description: "Tester: Review a PR with dual-scope testing — isolated component tests AND full regression suite. Produce GO/NO-GO verdict with evidence."
---
# Review PR

## Dual-Scope Testing Mandate

### Scope 1: Isolated Testing
1. Identify changed/new functions
2. Write focused tests for specific changes
3. Cover: happy path, error, boundary, adversarial
4. Run on dedicated devnet (port 8082)

### Scope 2: Full Regression
1. Run ALL existing REPL tests
2. Deploy ALL modules to devnet
3. Run end-to-end lifecycle tests
4. Verify no existing functionality broke

## Self-Audit Before Verdict
Complete the self-audit checklist:
- [ ] Every success test has postcondition
- [ ] Every expect-failure has specific error
- [ ] All Pact types unwrapped
- [ ] No implicit state dependencies
- [ ] Expected values from spec
- [ ] Time tests poll chain time

## Verdict Format
```markdown
## PR Review: #{number}
Reviewer: [Tester]
Verdict: [GO | NO-GO]

### Isolated Testing
- Tests run: {N}
- Passed: {N}
- Failed: {N}
- Findings: {list}

### Regression Testing
- Tests run: {N}
- Passed: {N}
- Failed: {N}
- Regressions: {list}

### Findings
| # | Severity | Description | Evidence |
|---|----------|-------------|----------|

### Justification
{Evidence-based reasoning for verdict}
```
