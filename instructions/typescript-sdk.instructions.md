---
description: "Use when writing TypeScript integration code for KDA-CE Kadena client SDK, building transactions, signing, or interacting with Pact modules from TypeScript."
applyTo: ["**/*.ts", "**/*.js"]
---
# TypeScript SDK Conventions

## Transaction Building
```typescript
import { Pact, createClient } from '@kadena/client';

const client = createClient(`http://localhost:${port}/chainweb/0.0/development/chain/0/pact`);

// Build transaction
const tx = Pact.builder
  .execution(`(module-name.function-name arg1 arg2)`)
  .addSigner(publicKey) // unscoped for admin ops
  .setMeta({ chainId: '0', sender: 'sender00', gasLimit: 150000, gasPrice: 0.00000001 })
  .setNetworkId('development')
  .createTransaction();
```

## Critical Rules
- **Decimal values**: Always `{ decimal: 'N.0' }` in cap args — never raw JS numbers
- **Gas limit**: Always 150_000 maximum
- **Confirmation**: `client.pollOne()` not `client.listen()` (nginx 504)
- **Scoped signers** cannot satisfy `enforce-keyset` — use unscoped for deploy/admin
- **Type unwrapping**: `{int: N}` → extract `.int`, `{decimal: "N"}` → extract `.decimal`

## Utility Helpers
```typescript
function unwrapPactInt(val: any): number {
  return typeof val === 'object' && 'int' in val ? val.int : val;
}

function unwrapPactDecimal(val: any): number {
  if (typeof val === 'object' && 'decimal' in val) return parseFloat(val.decimal);
  return typeof val === 'number' ? val : parseFloat(val);
}
```
