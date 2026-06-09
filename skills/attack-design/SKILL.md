---
name: attack-design
description: "White-hat exploit development for Pact 5 smart contracts. Design and execute attack scenarios to verify security controls on KDA-CE devnet."
---
# Attack Design

## Attack Development Process
1. **Identify target** — which function/capability to exploit
2. **Hypothesize** — what could fail
3. **Design exploit** — minimal transaction to demonstrate
4. **Execute on devnet** — port 8083 (Security's dedicated devnet)
5. **Document** — success = CRITICAL finding, failure = control verified

## Attack Categories

### Authorization Attacks
```typescript
// Test: call admin function without governance keyset
const tx = Pact.builder
  .execution(`(free.dao-token.admin-function)`)
  .addSigner(attackerKey) // non-admin key
  .setMeta({ chainId: '0', sender: 'attacker', gasLimit: 150000 })
  .setNetworkId('development')
  .createTransaction();
// Expect: "Keyset failure" error
// If: success → CRITICAL FINDING
```

### Economic Attacks
```typescript
// Test: claim more dividends than entitled
// Test: vote with more tokens than balance
// Test: drain gas station
```

### State Manipulation
```typescript
// Test: exploit with-default-read zero defaults
// Test: modify config to bypass quorum
// Test: write to table without capability
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
