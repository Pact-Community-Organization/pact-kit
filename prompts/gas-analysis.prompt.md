---
description: "Developer/Tester: Measure and analyze gas consumption for Pact module operations. Compare against 150k ceiling and baseline measurements."
---
# Gas Analysis

## Process
1. Deploy module to devnet
2. Execute each public function via local preflight
3. Record gas consumption
4. Compare against budget (150k ceiling) and baseline

## Output Format
```markdown
## Gas Analysis Report — {module}
Date: {date}
Network: devnet (port {port})

### Results
| Function | Gas Used | Budget | Status |
|----------|---------|--------|--------|
| function1 | {N} | 150,000 | ✅ / ⚠️ / ❌ |

### Summary
- Total functions measured: {N}
- All within budget: {Yes/No}
- Highest consumer: {function} at {N} gas
- Compared to baseline: {+/-}%

### Recommendations
- {optimization suggestions if any function > 100k}
```
