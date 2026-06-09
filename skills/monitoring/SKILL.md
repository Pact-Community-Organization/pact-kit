---
name: monitoring
description: "Health checks, gas tracking, and operational monitoring for Pact 5 smart contracts on KDA-CE. Node status, contract health, and alert patterns."
---
# Monitoring

## Health Checks

### Node Health
```typescript
async function checkNodeHealth(host: string): Promise<boolean> {
  const res = await fetch(`${host}/info`);
  return res.ok;
}
```

### Contract Health
```typescript
async function checkContractHealth(host: string, chainId: string) {
  const tx = Pact.builder
    .execution('(free.governance-token.get-total-supply)')
    .setMeta({ chainId, sender: '', gasLimit: 10000 })
    .setNetworkId('development')
    .createTransaction();
  const result = await client.local(tx, { preflight: false, signatureVerification: false });
  return result.result.status === 'success';
}
```

## Gas Tracking
- Record gas usage for every operation in CI
- Compare against baseline
- Alert if gas increases > 10% from baseline
- Track gas trends over releases

## Metrics to Monitor
- Transaction confirmation time
- Gas per operation (vs budget)
- Node block height (is it syncing?)
- Chain time vs wall clock (devnet)
- Error rates per function
