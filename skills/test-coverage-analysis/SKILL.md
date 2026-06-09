---
name: test-coverage-analysis
description: "Test coverage measurement and gap analysis for Pact modules. Map functions to tests, identify untested paths, and assess coverage sufficiency."
---
# Test Coverage Analysis

## Coverage Dimensions
1. **Function coverage** — Every public function has at least one test
2. **Path coverage** — Happy path + at least one error path per function
3. **Capability coverage** — Authorized + unauthorized test per capability
4. **Cross-module coverage** — Integration test for each module interaction
5. **Formula coverage** — Boundary values for mathematical operations

## Coverage Matrix Template
| Function | Happy Path | Error Path | Auth Test | Unauth Test | Integration |
|----------|-----------|------------|-----------|-------------|-------------|
| transfer | ✅ | ✅ | ✅ | ✅ | ✅ |
| get-balance | ✅ | ❌ | N/A | N/A | ✅ |

## Gap Identification
1. List all public functions from module source
2. List all tests from .repl and devnet test files
3. Map tests to functions
4. Identify functions without tests
5. Prioritize gaps by risk level

## Coverage Report
```markdown
## Coverage Report — {module}
Functions: {N} total, {M} tested ({percentage}%)
Paths: {N} identified, {M} tested
Capabilities: {N} total, {M} with auth+unauth tests
Gaps: {list of untested functions with priority}
```
