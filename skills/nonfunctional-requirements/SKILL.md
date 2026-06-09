---
name: nonfunctional-requirements
description: "Non-functional requirements specification for KDA-CE smart contracts. Gas performance, security properties, scalability limits, and compatibility requirements."
---
# Non-Functional Requirements

## Categories

### Performance
- Gas consumption per function ≤ budget
- Transaction confirmation time expectations
- Block time considerations (~30s per block on KDA-CE)

### Security
- All privileged operations capability-guarded
- No unguarded write paths
- Formal verification where applicable
- STRIDE analysis completed

### Scalability
- Table scan avoidance (O(1) lookups preferred)
- Per-transaction vs batch operation trade-offs
- Cross-chain parallelism utilization

### Compatibility
- Fungible-v2 interface compliance for tokens
- Kadena client SDK compatibility
- Ledger hardware wallet support (ledger-signer project)

### Operability
- Module upgradeable via governance keyset
- Schema evolvable via with-default-read
- Configuration externalized to config tables

## NFR Template
```
NFR-{NNN}: {Title}
Category: Performance | Security | Scalability | Compatibility | Operability
Requirement: {measurable statement}
Metric: {how to measure}
Target: {acceptable value}
```
