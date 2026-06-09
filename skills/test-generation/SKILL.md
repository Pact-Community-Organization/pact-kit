---
name: test-generation
description: "Test suite scaffolding — generate REPL test files and TypeScript devnet test suites from Pact module definitions and acceptance criteria."
---
# Test Generation

## From Acceptance Criteria
```
Given: [context/setup]
When: [action]
Then: [expected result]
```
Maps to:
```pact
(begin-tx "Test: {AC description}")
;; Given: setup env-data, env-sigs
;; When: call function
;; Then: expect result
(commit-tx)
```

## Test Generation Checklist
For each public function:
- [ ] Happy path test
- [ ] At least one error path
- [ ] Authorization test (with sigs)
- [ ] Unauthorized test (without sigs → expect-failure)
- [ ] Boundary values (zero, max, negative)
- [ ] Postcondition verification (read state after write)

## TypeScript Devnet Test Template
```typescript
import { describe, it, expect } from 'vitest';

describe('{module-name}', () => {
  it('should {expected behavior}', async () => {
    // Arrange: build transaction
    // Act: submit and poll
    // Assert: verify postcondition
  });

  it('should fail when {unauthorized}', async () => {
    // Arrange: build without proper signer
    // Act: submit
    // Assert: expect failure message
  });
});
```
