---
description: "DevOps: Deploy Pact modules to a KDA-CE devnet instance. Step-by-step deployment with gas tracking and verification."
---
# Deploy to Devnet

## Prerequisites
- Docker devnet running on target port
- Chain time synced (within 5 min of wall clock)
- Admin keypair available (sender00 for devnet)

## Deploy Steps
1. Verify devnet health: `curl http://localhost:{port}/info`
2. Deploy modules in order:
   - interface module, for example `my-types`
   - core module, for example `my-token`, plus its tables
   - dependent modules, for example `my-governance`, plus their tables
3. Initialize modules and configuration:
   - run the core module init step
   - run any governance/config init step
   - apply post-deploy configuration such as `set-config` or similar setup calls
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
- Config readable: {Yes/No}
- Tables created: {Yes/No}
- Total gas: {N}
```
