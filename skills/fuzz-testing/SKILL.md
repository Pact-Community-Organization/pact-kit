---
name: fuzz-testing
description: "Random and boundary input testing for Pact 5 — generate edge-case inputs, stress test functions, and discover unexpected behavior in smart contracts."
---
# Fuzz Testing

## Input Categories
1. **Boundary values** — 0, -1, MAX_INT, MIN_INT, 0.0, -0.0
2. **Type confusion** — string where int expected, etc.
3. **Empty values** — "", [], {}, null equivalents
4. **Special strings** — very long, unicode, format strings
5. **Decimal precision** — many decimal places, very small/large

## Pact-Specific Fuzz Targets
- Transfer amounts: 0, negative, very large, many decimal places
- Account names: empty, very long, special characters
- Proposal text: Unicode, format exploits
- Time values: past, far future, boundary epoch values
- Chain IDs: negative, >19, non-integer

## Fuzz Test Pattern
```typescript
const fuzzValues = [
  0, -1, 0.0000000001, 999999999999,
  '', 'a'.repeat(10000),
  { decimal: '0.0' }, { decimal: '-1.0' },
];

for (const val of fuzzValues) {
  it(`should handle fuzz input: ${val}`, async () => {
    // Expect either success with valid output or graceful failure
    // NEVER: crash, hang, or corrupt state
  });
}
```

## Reporting
Document interesting findings:
- Input that causes unexpected behavior
- Input that causes gas spike
- Input that bypasses validation
