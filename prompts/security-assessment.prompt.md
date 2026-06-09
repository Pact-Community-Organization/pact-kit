---
description: "Tester/Security: Perform security-focused assessment of a Pact module covering STRIDE threats, capability analysis, and attack simulation."
---
# Security Assessment

## Assessment Steps
1. Apply STRIDE to each public function
2. Audit capability hierarchy and guards
3. Check for common vulnerability patterns
4. Design and execute attack scenarios on devnet
5. Verify formal verification properties

## STRIDE Per Function
For each public function:
- **S**: Can it be called by wrong identity?
- **T**: Can it modify data incorrectly?
- **R**: Does it emit events for audit trail?
- **I**: Does it expose sensitive information?
- **D**: Can it be used for gas griefing?
- **E**: Can it escalate privileges?

## Output
```markdown
## Security Assessment — {module}
Assessor: [Security]

### STRIDE Analysis
| Function | S | T | R | I | D | E |
|----------|---|---|---|---|---|---|

### Capability Audit
{Map of all capabilities and guards}

### Attack Simulation Results
| Attack | Target | Result | Severity |
|--------|--------|--------|----------|

### Verdict: [Security] [APPROVE | REJECT]
Conditions: {any conditions}
```
