---
description: "Architect: Create a developer handoff document with implementation spec, module structure, capability design, and schema definitions."
---
# Developer Handoff

## Document Structure
```markdown
## Developer Handoff: {feature title}

### Requirements Reference
- User Story: US-{NNN}
- ADR: ADR-{NNN}
- Acceptance Criteria: {list}

### Module Changes
| Module | Change Type | Description |
|--------|-----------|-------------|

### Schema Definitions
{New or modified schemas with field types}

### Capability Design
{New capabilities with guards and management}

### Function Signatures
{Public function signatures with @doc}

### Deploy Considerations
- Gas budget: {estimate per operation}
- Deploy order: {any changes}
- Migration: {schema evolution plan if needed}

### Testing Requirements
- REPL tests: {key scenarios}
- Devnet tests: {integration scenarios}
- Security tests: {known attack vectors to test}
```
