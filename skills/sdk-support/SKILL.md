---
name: sdk-support
description: "API and SDK usage troubleshooting for @kadena/client, TypeScript integration, transaction building, and common developer errors when working with KDA-CE."
---
# SDK Support

## Common Issues & Quick Answers

### "Transaction timeout / 504"
**Cause**: Using `client.listen()` which hits nginx 504
**Fix**: Use `client.pollOne({ timeout: 600_000, interval: 5_000 })`

### "Insufficient funds"
**Cause**: Account doesn't have enough KDA for gas
**Fix**: Fund account on devnet using sender00

### "Keyset failure"
**Cause**: Signer doesn't match required keyset
**Fix**: Check env-sigs match the expected keyset, use unscoped signer for admin ops

### "Cannot resolve module"
**Cause**: Module not deployed or wrong namespace
**Fix**: Check deploy order, verify namespace

### "Gas limit exceeded"
**Cause**: Operation exceeds 150,000 gas
**Fix**: Split into multiple transactions, optimize code

### Number precision issues
**Cause**: Using raw JS numbers instead of `{ decimal: 'N.0' }`
**Fix**: Always use decimal wrapper in SDK calls

### "creation time too far in the future"
**Cause**: Fresh devnet hasn't caught up to wall clock
**Fix**: Wait for chain sync, fetch actual chain time from header

## Escalation
If issue not in quick answers → route to Developer via Orchestrator
