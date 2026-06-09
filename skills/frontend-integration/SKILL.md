---
name: frontend-integration
description: "TypeScript SDK integration for Kadena Pact 5 — transaction building, signing, @kadena/client usage, decimal serialization, and wallet connection patterns."
---
# Frontend Integration

## @kadena/client Setup
```typescript
import { Pact, createClient, createSignWithKeypair } from '@kadena/client';

const client = createClient(
  `${host}/chainweb/0.0/${networkId}/chain/${chainId}/pact`
);
```

## Transaction Building
```typescript
const tx = Pact.builder
  .execution(`(free.my-module.my-function "arg1" { "decimal": "100.0" })`)
  .addSigner(publicKey, (withCap) => [
    withCap('coin.GAS'),
    withCap('free.my-module.TRANSFER', 'sender', 'receiver', { decimal: '100.0' })
  ])
  .setMeta({
    chainId: '0',
    sender: 'sender00',
    gasLimit: 150_000,
    gasPrice: 0.00000001,
    ttl: 600,
  })
  .setNetworkId('development')
  .createTransaction();
```

## Critical Rules
1. Decimals: `{ decimal: 'N.0' }` — NEVER raw JS numbers in cap args
2. Gas limit: 150_000 maximum
3. Use `pollOne()` not `listen()` for confirmation
4. Unscoped signers for deploy/admin (no cap callback)
5. Type unwrapping for Pact API responses

## Wallet Integration Patterns
- Kadena SpireKey for web-based signing
- Ledger hardware wallet via hardware-signer packages
- WalletConnect for mobile wallets
