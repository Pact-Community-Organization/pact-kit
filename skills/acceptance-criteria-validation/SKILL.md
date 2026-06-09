---
name: acceptance-criteria-validation
description: "Validate acceptance criteria coverage and sufficiency. Ensure Given/When/Then ACs are testable, complete, and properly mapped to test cases."
---
# Acceptance Criteria Validation

## AC Quality Checks
- [ ] Every AC has Given/When/Then format
- [ ] Every AC is independently testable
- [ ] Given conditions are achievable in test environment
- [ ] When actions are specific (not ambiguous)
- [ ] Then results are measurable (not subjective)

## Coverage Mapping
```
AC-1: "Given X, When Y, Then Z"
  → TC-001: Happy path test
  → TC-002: Negative test (missing auth)
  → TC-003: Boundary test
```

## Sufficiency Analysis
- Are all user story scenarios covered?
- Are error conditions addressed?
- Are boundary conditions specified?
- Are security scenarios included?
- Are cross-module interactions covered?

## Gap Detection
If an AC cannot be mapped to a test:
1. Is the AC too vague? → Request refinement from Product
2. Is the AC untestable? → Propose rewrite
3. Is the AC out of scope? → Flag for Product review

## Reporting
```
AC Coverage: N of M acceptance criteria have test coverage
Gaps: {list of untested ACs with reason}
Recommendation: {action needed}
```
