---
name: debug-pact
description: "Debug Pact 5 smart contract issues — REPL debugging, devnet error diagnosis, transaction failure analysis, gas profiling, and common error messages."
---
# Debug Pact

## Common Error Messages

| Error | Cause | Fix |
|-------|-------|-----|
| "Keyset failure" | Missing or wrong signer | Check env-sigs / addSigner |
| "row not found" | Key doesn't exist in table | Use with-default-read or insert first |
| "Module admin is necessary" | create-table in wrong tx | Same tx as module deploy |
| "TTL expired" | creationTime too old | Use fresh chain time |
| "creation time too far in future" | Chain hasn't caught up | Wait for devnet sync |
| "Tx Failed: Insufficient funds" | Not enough KDA for gas | Fund account first |
| "Cannot resolve module" | Module not deployed | Check deploy order |

## REPL Debugging
```pact
;; Print intermediate values
(let ((val (read my-table key)))
  (enforce false (format "DEBUG: {}" [val])))
;; The enforce-failure shows the value in error output
```

## Devnet Debugging
```typescript
// Check transaction details
const result = await client.pollOne(submitted, { timeout: 600_000, interval: 5_000 });
console.log('Status:', result.result.status);
console.log('Error:', result.result.error);
console.log('Gas:', result.gas);
console.log('Logs:', result.logs);
```

## Gas Profiling
- Use `client.local(tx)` for gas measurement without submitting
- Compare gas across function calls to identify expensive operations
- Target: each function well under 150k (leave room for gas station overhead)
