---
name: kda-ce-compliance
description: "KDA-CE (Kadena Community Edition) specific patterns, conventions, and compliance requirements. Chainweb API, network IDs, chain management, and platform constraints."
---
# KDA-CE Compliance

## Network Configuration
| Network | ID | API | Explorer |
|---------|-----|-----|---------|
| devnet | development | http://localhost:{port} | — |
| testnet | testnet06 | https://api.chainweb-community.org | https://explorer.chainweb-community.org |
| mainnet | mainnet01 | https://api.chainweb-community.org | https://explorer.chainweb-community.org |

## Platform Constraints
- 150,000 gas per transaction (hard ceiling)
- 20 chains (0-19) braided proof-of-work
- Pact 5 runtime (not Pact 4)
- ~30 second block time
- No circular module dependencies

## Chainweb API Endpoints
- `/chainweb/0.0/{network}/chain/{chainId}/pact`
  - `/local` — Preflight/dry-run
  - `/send` — Submit transaction
  - `/poll` — Check transaction status
  - `/listen` — (avoid: nginx 504 timeout)
- `/chainweb/0.0/{network}/chain/{chainId}/header` — Block headers
- `/info` — Node information
- `/spv` — SPV proof generation

## Compliance Checklist
- [ ] NetworkId matches target environment
- [ ] Gas limit ≤ 150,000
- [ ] ChainId valid (0-19)
- [ ] Pact 5 syntax only (no Pact 4 patterns)
- [ ] pollOne used for transaction confirmation
