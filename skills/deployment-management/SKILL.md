---
name: deployment-management
description: "Pact smart contract deployment scripts and management on KDA-CE. Deploy order, gas budgets, environment config, rollback, and deploy verification."
---
# Deployment Management

## Deploy Order (DAO)
```
1. governance-types (interface)     — 1,231 gas
2. governance-token + tables        — 24,644 gas
3. distribution-module + tables     — 14,525 gas
4. governance-voting + tables       — 17,133 gas
5. gas-relayer + tables  — TBD
6. Initialize governance-token      — 306 gas
7. Initialize governance-voting     — 148 gas
8. Configure governance-voting      — 146 gas
```

## Deploy Script Pattern
```typescript
import { Pact, createClient, createSignWithKeypair } from '@kadena/client';

async function deploy(modulePath: string, tables: string[]) {
  const code = readFileSync(modulePath, 'utf8');
  const tx = Pact.builder
    .execution(code)
    .addSigner(adminPublicKey) // UNSCOPED for deploy
    .setMeta({ chainId: '0', sender: 'sender00', gasLimit: 150000 })
    .setNetworkId(networkId)
    .createTransaction();
  // Sign, submit, pollOne
}
```

## Environment Config
| Key | devnet | testnet | mainnet |
|-----|--------|---------|---------|
| networkId | development | testnet06 | mainnet01 |
| host | localhost:{port} | api.chainweb.org | api.chainweb.org |
| gasPrice | 0.00000001 | 0.00000001 | market rate |

## Rollback
- Pact modules can be upgraded (governance keyset) but NOT rolled back
- Tables persist across upgrades — data migration only
- Rollback = deploy previous version as upgrade
