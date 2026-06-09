---
name: pact-devnet-testing
description: "On-chain devnet testing patterns for Pact 5 on KDA-CE. TypeScript test scripts, pollOne confirmation, type unwrapping, chain time polling, and local preflight."
---
# Pact Devnet Testing

## Test Setup
```typescript
import { Pact, createClient } from '@kadena/client';

const DEVNET_HOST = process.env.DEVNET_HOST || 'http://localhost:8081';
const client = createClient(`${DEVNET_HOST}/chainweb/0.0/development/chain/0/pact`);
```

## Transaction Pattern
```typescript
// Build transaction
const tx = Pact.builder
  .execution(`(free.my-module.my-function "arg1" 100.0)`)
  .addSigner(publicKey)
  .setMeta({ chainId: '0', sender: 'sender00', gasLimit: 150000, gasPrice: 0.00000001 })
  .setNetworkId('development')
  .createTransaction();

// Sign and submit
const signed = await sign(tx);
const submitted = await client.submit(signed);
const result = await client.pollOne(submitted, { timeout: 600_000, interval: 5_000 });
```

## Critical Patterns
1. **pollOne not listen** — `listen()` → nginx 504 timeout
2. **Type unwrapping** — `{int: N}` and `{decimal: "N"}` must be unwrapped
3. **Chain time polling** — never `await wait(N)`, poll header `creationTime / 1_000_000`
4. **Local preflight** — `client.local(tx)` for gas estimation before submit
5. **Postcondition verification** — always verify state changed via localCall after tx

## Devnet Ports
- Developer: 8081
- Tester: 8082
- Security: 8083
