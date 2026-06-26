---
name: adversarial-testing
description: "Attack-oriented test design for Pact 5 smart contracts: capability bypass, front-running, gas griefing, privilege escalation."
---
# Adversarial Testing

## Attack Categories

### 1. Authorization Bypass
- Call privileged function without required capability
- Call with wrong keyset
- Call with expired/revoked permissions
- Attempt cross-module capability exploitation

### 2. State Manipulation
- Write to table without proper guard
- Exploit `with-default-read` zero defaults
- Modify config to invalid values
- Race condition on state updates

### 3. Economic Attacks
- Zero-amount transfers (gas waste)
- Self-transfers for side effects
- Dividend claim without proper balance
- Vote inflation via rapid buy/vote/sell

### 4. Denial of Service
- Gas exhaustion via large input
- Table scan triggering
- Recursive cross-module calls
- Blocking governance operations

### 5. Logic Exploitation
- Integer boundary conditions
- Decimal precision manipulation
- Time-dependent operation front-running
- Pact continuation hijacking

## Adversarial Test Template
```pact
(begin-tx "Attack: {category} — {specific attack}")
;; Setup: attacker's position
;; Action: exploitation attempt
(expect-failure "specific expected error"
  (module.function attack-args))
(commit-tx)
```

## Rules
- Every positive test MUST have a paired adversarial negative
- Document the attack vector in test comments
- If attack succeeds → CRITICAL finding

## Attack Development Process
1. **Identify target** — which function/capability to exploit
2. **Hypothesize** — what could fail
3. **Design exploit** — minimal transaction to demonstrate
4. **Execute on devnet** — port 8083 (Security's dedicated devnet)
5. **Document** — success = CRITICAL finding, failure = control verified

## TypeScript Devnet Exploit Template
```typescript
// Test: call admin function without governance keyset
const tx = Pact.builder
  .execution(`(free.my-token.admin-function)`)
  .addSigner(attackerKey) // non-admin key
  .setMeta({ chainId: '0', sender: 'attacker', gasLimit: 150000 })
  .setNetworkId('development')
  .createTransaction();
// Expect: "Keyset failure" error
// If: success → CRITICAL FINDING
```

## Attack Report Template
```markdown
### Attack: {name}
Vector: {how the attack works}
Target: {function/module}
Devnet Result: {success/failure}
Severity: {CRITICAL|HIGH|MEDIUM|LOW}
Evidence: {tx hash, error message, or state dump}
```
