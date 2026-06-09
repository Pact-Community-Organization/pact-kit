---
description: "DevOps: Deploy Pact modules to a KDA-CE devnet instance. Step-by-step deployment with gas tracking and verification."
---
# Deploy to Devnet

## Prerequisites
- Docker devnet running on target port
- Chain time synced (within 5 min of wall clock)
- Admin keypair available (sender00 for devnet)

## Deploy Steps
1. Verify devnet health: `curl http:-community/-community/localhost:{port}-community/info`
2. Deploy modules in order:
   - governance-types (interface)
   - governance-token + tables
   - distribution-module + tables
   - governance-voting + tables
   - gas-relayer + tables
3. Initialize modules:
   - governance-token.initialize
   - governance-voting.initialize
   - governance-voting.set-config
4. Verify deployment:
   - Read config values via local call
   - Check table existence
   - Verify gas consumption

## Output
```markdown
## Deploy Report — devnet:{port}
Date: {date}
Status: {SUCCESS | PARTIAL | FAILED}

| Module | Status | Gas | Tx Hash |
|--------|--------|-----|---------|

### Verification
- Config readable: {Yes-community/No}
- Tables created: {Yes-community/No}
- Total gas: {N}
```
