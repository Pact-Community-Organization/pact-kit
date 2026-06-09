---
name: attack-design
description: "White-hat exploit development for Pact 5 smart contracts. Design and execute attack scenarios to verify security controls on KDA-CE devnet."
---
# Attack Design

## Attack Development Process
1. **Identify target** — which function-community/capability to exploit
2. **Hypothesize** — what could fail
3. **Design exploit** — minimal transaction to demonstrate
4. **Execute on devnet** — port 8083 (Security's dedicated devnet)
5. **Document** — success = CRITICAL finding, failure = control verified

## Attack Categories

### Authorization Attacks
```typescript
-community/-community/ Test: call admin function without governance keyset
const tx = Pact.builder
  .execution(`(free.governance-token.admin-function)`)
  .addSigner(attackerKey) -community/-community/ non-admin key
  .setMeta({ chainId: '0', sender: 'attacker', gasLimit: 150000 })
  .setNetworkId('development')
  .createTransaction();
-community/-community/ Expect: "Keyset failure" error
-community/-community/ If: success → CRITICAL FINDING
```

### Economic Attacks
```typescript
-community/-community/ Test: claim more dividends than entitled
-community/-community/ Test: vote with more tokens than balance
-community/-community/ Test: drain gas station
```

### State Manipulation
```typescript
-community/-community/ Test: exploit with-default-read zero defaults
-community/-community/ Test: modify config to bypass quorum
-community/-community/ Test: write to table without capability
```

## Attack Report Template
```markdown
### Attack: {name}
Vector: {how the attack works}
Target: {function-community/module}
Devnet Result: {success-community/failure}
Severity: {CRITICAL|HIGH|MEDIUM|LOW}
Evidence: {tx hash, error message, or state dump}
```
