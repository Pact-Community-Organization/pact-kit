---
name: api-documentation
description: "API reference documentation generation from Pact module signatures. Function docs, parameter tables, capability requirements, and gas costs for KDA-CE contracts."
---
# API Documentation

## Function Documentation Template
```markdown
### `module-name.function-name`
**Signature**: `(function-name:return-type param1:type1 param2:type2)`

**Description**: What this function does.

**Parameters**:
| Name | Type | Description |
|------|------|-------------|
| param1 | type1 | Description |
| param2 | type2 | Description |

**Returns**: `return-type` — Description

**Capabilities Required**: `CAP-NAME (args)`

**Gas Cost**: ~{N} gas

**Example**:
    (module-name.function-name "value1" 100.0)
```

## Module Documentation Structure
1. Overview and purpose
2. Dependencies (use statements)
3. Table schemas
4. Capabilities
5. Public functions (alphabetical)
6. Admin functions
7. Events
