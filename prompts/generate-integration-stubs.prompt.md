---
description: "Developer: Generate TypeScript integration stubs for interacting with deployed Pact modules via @kadena/client SDK."
---
# Generate Integration Stubs

## Input
- Module name and public functions
- Target network (devnet/testnet/mainnet)

## Output
```typescript
import { Pact, createClient } from '@kadena/client';

const client = createClient(`${host}/chainweb/0.0/${networkId}/chain/${chainId}/pact`);

// Read function (local call)
export async function getBalance(account: string): Promise<number> {
  const tx = Pact.builder
    .execution(`(free.{module}.get-balance "${account}")`)
    .setMeta({ chainId: '0', sender: '', gasLimit: 10000 })
    .setNetworkId(networkId)
    .createTransaction();
  const result = await client.local(tx, {
    preflight: false,
    signatureVerification: false,
  });
  return unwrapPactDecimal(result.result.data);
}

// Write function (submit + poll)
export async function transfer(
  sender: string, receiver: string, amount: string,
  signerKey: string
): Promise<any> {
  const tx = Pact.builder
    .execution(`(free.{module}.transfer "${sender}" "${receiver}" ${amount})`)
    .addSigner(signerKey, (w) => [
      w('coin.GAS'),
      w('free.{module}.TRANSFER', sender, receiver, { decimal: amount }),
    ])
    .setMeta({ chainId: '0', sender, gasLimit: 150000, gasPrice: 0.00000001 })
    .setNetworkId(networkId)
    .createTransaction();
  // Sign, submit, pollOne
}
```
