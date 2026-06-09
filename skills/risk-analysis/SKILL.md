---
name: risk-analysis
description: "Risk identification, assessment matrices, and mitigation planning for Pact Community projects. Technical, security, and schedule risks for Pact 5 on KDA-CE."
---
# Risk Analysis

## Risk Matrix
| Probability ↓ / Impact → | Low | Medium | High | Critical |
|---------------------------|-----|--------|------|----------|
| **Likely** | Medium | High | Critical | Critical |
| **Possible** | Low | Medium | High | Critical |
| **Unlikely** | Low | Low | Medium | High |
| **Rare** | Low | Low | Low | Medium |

## Common Risks (Smart Contracts)

### Technical
- Gas limit exceeded on complex operations
- Cross-module dependency creates circular reference
- Schema migration breaks existing data

### Security
- Unguarded admin function discovered post-deploy
- Capability bypass via composition gap
- Front-running on time-dependent operations

### Schedule
- Devnet timing issues cause false test failures
- Underestimated complexity of cross-chain operations

## Mitigation Template
```
Risk: {description}
Probability: {Likely|Possible|Unlikely|Rare}
Impact: {Critical|High|Medium|Low}
Mitigation: {preventive action}
Contingency: {reactive plan if risk materializes}
Owner: {responsible agent}
```
