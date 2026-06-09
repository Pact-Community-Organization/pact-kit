---
name: threat-modeling
description: "STRIDE threat modeling for Pact 5 smart contracts on KDA-CE. Attack trees, threat identification, risk assessment, and mitigation planning for blockchain applications."
---
# Threat Modeling — STRIDE

## STRIDE Applied to Pact

### Spoofing (Identity)
- Can a user impersonate another via forged keyset?
- Can pact-id be exploited as sole guard?
- Are capability guards properly enforced?

### Tampering (Data Integrity)
- Can table data be modified without proper capability?
- Are with-default-read defaults exploitable?
- Can configuration be tampered during upgrade?

### Repudiation (Non-Repudiation)
- Are all critical operations emitting events (@event)?
- Can actions be attributed to specific signers?
- Is there an audit trail for governance actions?

### Information Disclosure
- Do read functions expose sensitive data?
- Can table scans leak information?
- Are error messages leaking internal state?

### Denial of Service
- Can operations be gas-griefed?
- Can table scans be triggered by user input?
- Can governance be blocked by a single actor?

### Elevation of Privilege
- Can capabilities be composed to bypass guards?
- Can module upgrade bypass governance?
- Can cross-module calls escalate permissions?

## Threat Model Document
```markdown
## Threat Model — {module}
Date: YYYY-MM-DD
Scope: {what's being analyzed}

### Assets
- {valuable resources to protect}

### Threats (STRIDE)
| Category | Threat | Likelihood | Impact | Mitigation |
|----------|--------|-----------|--------|------------|

### Attack Trees
- {diagram of attack paths}

### Residual Risks
- {accepted risks with justification}
```
