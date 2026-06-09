---
name: adversarial-testing
description: "Attack-oriented test design for Pact 5 smart contracts. Exploit capability gaps, test authorization bypass, front-running, gas griefing, and privilege escalation."
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
