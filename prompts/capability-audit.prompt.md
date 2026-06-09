---
description: "Security: Deep audit of Pact capability hierarchy — verify guards, managed caps, composition chains, and cross-module capability boundaries."
---
# Capability Audit

## Audit Steps
1. List all `defcap` in the module
2. For each capability:
   - What guard does it enforce?
   - Is it @managed? What does the manager check?
   - What capabilities does it compose?
   - Which functions use `with-capability` for it?
3. Map the full capability tree
4. Check for bypass paths
5. Verify cross-module boundaries

## Output
```markdown
## Capability Audit — {module}

### Capability Map
```
GOVERNANCE → enforce-guard(keyset-ref-guard)
├── ADMIN → compose(GOVERNANCE)
├── TRANSFER → @managed amount
│   ├── DEBIT → enforce-guard(account)
│   └── CREDIT → (auto)
```

### Findings
| Cap | Issue | Severity |
|-----|-------|----------|

### Unguarded Functions
{Functions that write without capability — CRITICAL}

### Cross-Module Analysis
{How capabilities interact across module boundaries}
```
