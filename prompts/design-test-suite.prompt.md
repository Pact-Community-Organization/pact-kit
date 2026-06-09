---
description: "Tester: Design a comprehensive test suite for a Pact module based on ADRs, acceptance criteria, and security requirements."
---
# Design Test Suite

## Input
- Module specification (ADR, requirements, ACs)
- Module source (.pact file)
- Known vulnerabilities or attack vectors

## Design Process
1. Extract testable requirements from specs
2. Design test cases for each requirement
3. Add boundary value tests
4. Add adversarial tests
5. Add cross-module integration tests
6. Map every test to its requirement source

## Output Format
```markdown
## Test Suite Design — {module}

### Coverage Matrix
| Requirement | Test Cases | Type |
|------------|-----------|------|
| ADR-001 AC1 | TC-001, TC-002 | Positive, Negative |

### Test Cases
#### TC-001: {title}
Source: {ADR/PROC/AC}
Type: {positive | negative | boundary | adversarial}
Precondition: {state}
Action: {what to test}
Expected: {from specification}

### Test Execution Plan
1. REPL tests (Phase 1-2)
2. Devnet tests (Phase 3-4)
3. Cross-module tests
```
