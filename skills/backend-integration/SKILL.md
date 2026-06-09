---
name: backend-integration
description: "Backend API handlers for KDA-CE — chain polling, transaction monitoring, balance queries, local preflight, and server-side Pact interaction patterns."
---
# Backend Integration

## Chain Polling Pattern
```typescript
async function waitForChainTime(targetTime: number): Promise<void> {
  while (true) {
    const header = await fetchCurrentHeader();
    const chainTime = header.creationTime / 1_000_000;
    if (chainTime >= targetTime) return;
    await new Promise(r => setTimeout(r, 5000));
  }
}
```

## Local Preflight (Read-Only)
```typescript
async function localCall(pactCode: string): Promise<any> {
  const tx = Pact.builder
    .execution(pactCode)
    .setMeta({ chainId: '0', sender: '', gasLimit: 150000, gasPrice: 0 })
    .setNetworkId('development')
    .createTransaction();
  return client.local(tx, { preflight: false, signatureVerification: false });
}
```

## Type Unwrapping Helpers
```typescript
function unwrapPactInt(val: any): number {
  return typeof val === 'object' && 'int' in val ? val.int : val;
}
function unwrapPactDecimal(val: any): number {
  if (typeof val === 'object' && 'decimal' in val) return parseFloat(val.decimal);
  return typeof val === 'number' ? val : parseFloat(val);
}
```

## Error Handling
- HTTP 504: `listen()` timeout → switch to `pollOne()`
- "TTL expired": transaction creationTime too old → use fresh chain time
- "creation time too far in the future": chain hasn't caught up → wait for chain sync
