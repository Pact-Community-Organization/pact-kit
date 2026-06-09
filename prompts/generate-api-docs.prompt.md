---
description: "Docs: Generate API reference documentation from Pact module source code. Extract function signatures, capabilities, schemas, and gas costs."
---
# Generate API Docs

## Input
- Pact module file (.pact)
- Gas measurements (if available)

## Process
1. Parse module for public functions, capabilities, schemas
2. Extract @doc annotations
3. Document parameter types and return types
4. Note capability requirements per function
5. Include gas cost where measured

## Output Format
```markdown
# {module-name} API Reference

## Overview
{Module @doc string}

## Dependencies
- {use statements}

## Schemas
### {schema-name}
| Field | Type | Description |
|-------|------|-------------|

## Capabilities
### {CAP-NAME}
{@doc string, guard, @managed info}

## Functions
### `{function-name}`
**Signature**: `({function-name}:{return-type} {params})`
**Description**: {@doc string}
**Parameters**: {table}
**Returns**: {type and description}
**Requires**: {capability}
**Gas**: ~{N}
**Example**: {usage example}
```
