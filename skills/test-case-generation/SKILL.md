---
name: test-case-generation
description: "Generate test cases from specifications, acceptance criteria, and ADRs. Map requirements to testable scenarios with expected values from specs, not code."
---
# Test Case Generation

## Core Rule
**Expected values come from the SPECIFICATION, not from what code currently returns.**

## Generation Process
1. Read the specification (ADR, PROC, AC, user story)
2. Extract testable assertions
3. Design test scenarios for each assertion
4. Derive expected values from the spec
5. If spec is ambiguous → flag as `[UNCERTAIN]`

## Test Case Template
```
TC-{NNN}: {Title}
Source: {ADR-NNN / PROC-NNN / AC-NNN}
Precondition: {state before test}
Action: {what to do}
Expected: {what should happen — from spec}
Type: {positive | negative | boundary | adversarial}
```

## Coverage Patterns
- **Equivalence partitioning**: group inputs → test one per group
- **Boundary values**: min, min+1, max-1, max, min-1, max+1
- **Decision tables**: all combination of conditions
- **State transitions**: each state + each valid/invalid transition

## Anti-Patterns
- ❌ Testing what code does (circular validation)
- ❌ Using code output as expected value
- ❌ Skipping negative tests
- ❌ Assuming behavior without specification
