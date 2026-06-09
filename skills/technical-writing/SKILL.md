---
name: technical-writing
description: "Architecture documentation, design documents, technical guides, and explanation of Pact 5 module design decisions for Pact Community projects."
---
# Technical Writing

## Architecture Document Template
```markdown
# {Module/System} Architecture
## Overview
{1-2 paragraph description}

## Components
{Component diagram with Mermaid}

## Data Flow
{Sequence diagram with Mermaid}

## Design Decisions
{Reference to relevant ADRs}

## Security Considerations
{Summary of security model}

## Constraints
{Gas limits, platform constraints}
```

## Writing Principles
- Lead with the conclusion/summary
- Use diagrams for complex relationships
- Link to ADRs for design rationale
- Include practical examples
- Keep language precise and unambiguous
- Target audience: developers familiar with blockchain but not Pact/Kadena specifically
