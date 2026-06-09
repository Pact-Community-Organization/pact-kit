---
description: "Support: Troubleshoot SDK integration issues with @kadena/client, TypeScript, transaction building, signing, or Pact API interactions on KDA-CE."
---
# SDK Troubleshoot

## Diagnostic Steps
1. Identify the error message or symptom
2. Check against known issues list
3. Verify configuration (network, chain, gas)
4. Test reproduction on devnet
5. Provide solution or escalate

## Known Issues Quick Reference
| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| HTTP 504 timeout | Using `listen()` | Switch to `pollOne()` |
| "Keyset failure" | Wrong signer | Check key matches keyset |
| "Insufficient funds" | No KDA for gas | Fund account |
| NaN in comparison | Pact type not unwrapped | Use unwrapPactInt/Decimal |
| "TTL expired" | Stale creation time | Use fresh chain time |
| Wrong balance | Raw JS number in cap | Use `{ decimal: 'N.0' }` |

## Resolution Format
```markdown
## SDK Troubleshoot — {issue}

### Diagnosis
{Root cause identification}

### Solution
{Step-by-step fix}

### Code Example
{Working code snippet}

### Prevention
{How to avoid this in the future}
```
