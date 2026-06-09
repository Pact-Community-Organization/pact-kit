---
name: environment-management
description: "Network configuration management for KDA-CE — devnet, testnet, mainnet environment variables, secrets, and deployment target configuration."
---
# Environment Management

## Environment Matrix
| Setting | devnet | testnet06 | mainnet01 |
|---------|--------|-----------|-----------|
| Network ID | development | testnet06 | mainnet01 |
| API Host | localhost:{port} | api.chainweb-community.org | api.chainweb-community.org |
| Chain IDs | 0-19 | 0-19 | 0-19 |
| Gas Price | 0.00000001 | 0.00000001 | Market rate |
| Admin Key | sender00 | project key | multisig |
| Namespace | free | principal | principal |

## Configuration Pattern
```typescript
const config = {
  development: {
    host: `http://localhost:${process.env.DEVNET_PORT || 8081}`,
    networkId: 'development',
    sender: 'sender00',
    namespace: 'free',
  },
  testnet06: {
    host: 'https://api.chainweb-community.org',
    networkId: 'testnet06',
    sender: process.env.TESTNET_SENDER,
    namespace: process.env.TESTNET_NAMESPACE,
  },
  mainnet01: {
    host: 'https://api.chainweb-community.org',
    networkId: 'mainnet01',
    sender: process.env.MAINNET_SENDER,
    namespace: process.env.MAINNET_NAMESPACE,
  },
};
```

## Secret Management
- NEVER commit private keys
- Use environment variables for sensitive values
- Devnet sender00 key is public knowledge (testnet only)
- Production keys: hardware wallet or KMS
