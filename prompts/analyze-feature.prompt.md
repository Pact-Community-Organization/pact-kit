---
description: "Architect: Analyze a feature request to determine architecture impact, gas budget, module changes, and cross-chain requirements."
---
# Analyze Feature

## Input
- Feature request or user story
- Current architecture context

## Analysis Steps
1. **Scope**: Which modules are affected?
2. **Gas**: Estimate gas for new/modified operations
3. **Dependencies**: Does this change the module DAG?
4. **Cross-chain**: Does this need defpact/SPV?
5. **Schema**: Does this require new tables or schema changes?
6. **Security**: What new attack surface is created?
7. **Testing**: What test strategy is needed?

## Output Format
```markdown
## Feature Analysis: {title}

### Impact Assessment
- Modules affected: {list}
- New modules needed: {list}
- Schema changes: {list}
- Gas estimate: {per-operation estimates}

### Architecture Decision
{ADR if needed, or "No architectural change required"}

### Risk Assessment
{Identified risks with severity}

### Recommendation
{Proceed / Needs design / Needs clarification}

### Handoff to Developer
{Specific implementation guidance}
```
