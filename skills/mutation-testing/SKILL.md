---
name: mutation-testing
description: "Code mutation analysis for test suite quality — inject deliberate bugs to verify tests catch them. Mutation operators for Pact 5 smart contracts."
---
# Mutation Testing

## Purpose
Verify test quality by mutating code and checking if tests catch the mutation.

## Mutation Operators for Pact

### Arithmetic
- `+` → `-`, `*` → `/`, `>` → `>=`, `<` → `<=`
- Remove or add `0.0` offset
- Change decimal precision

### Logic
- `and` → `or`, `not` removal
- `enforce` → `enforce` with negated condition
- Remove `enforce` entirely

### Capability
- Remove `with-capability` wrapper
- Change capability parameters
- Remove `compose-capability`

### Data Access
- Change table name in read/write
- Swap insert/update
- Change default values in with-default-read

## Process
1. Create mutation (one change at a time)
2. Run test suite against mutant
3. If all tests pass → **mutation survived** → test gap found
4. If any test fails → **mutation killed** → tests are effective

## Reporting
```
Mutations: {N} created
Killed: {M} ({percentage}%)
Survived: {K} — {list with descriptions}
Test gaps identified: {list}
```
