---
name: deployment-management
description: "Pact smart contract deployment scripts and management on KDA-CE. Deploy order, gas budgets, environment config, rollback, and deploy verification."
---
# Deployment Management

## Deploy Order (Illustrative)
```
1. my-types (interface)      — 1,231 gas (illustrative)
2. my-token + tables         — 24,644 gas (illustrative)
3. my-dividend + tables      — 14,525 gas (illustrative)
4. my-governance + tables    — 17,133 gas (illustrative)
5. my-gas-station + tables   — TBD
6. Initialize my-token       — 306 gas (illustrative)
7. Initialize my-governance  — 148 gas (illustrative)
8. Configure my-governance   — 146 gas (illustrative)
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
| host | localhost:{port} | api.chainweb-community.org | api.chainweb-community.org |
| gasPrice | 0.00000001 | 0.00000001 | market rate |

## Rollback
- Pact modules can be upgraded (governance keyset) but NOT rolled back
- Tables persist across upgrades — data migration only
- Rollback = deploy previous version as upgrade
