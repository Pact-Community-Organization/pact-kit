---
description: "Security: Create a STRIDE threat model for a Pact module or system component, identifying threats, attack trees, and mitigation strategies."
---
# Threat Model

## Input
- Module or component to analyze
- Architecture context (dependencies, data flow)

## Process
1. Identify assets (what's valuable)
2. Draw trust boundaries
3. Apply STRIDE to each component
4. Build attack trees for CRITICAL/HIGH threats
5. Propose mitigations

## Output
```markdown
## Threat Model — {component}
Date: {date}
Author: [Security]

### Assets
1. {asset}: {why valuable}

### Trust Boundaries
{Diagram or description}

### Threats
| ID | Category | Description | Likelihood | Impact | Severity |
|----|----------|-------------|-----------|--------|----------|

### Attack Trees
{Per CRITICAL/HIGH threat}

### Mitigations
| Threat ID | Mitigation | Status |
|-----------|-----------|--------|

### Residual Risks
{Accepted risks with justification}
```
