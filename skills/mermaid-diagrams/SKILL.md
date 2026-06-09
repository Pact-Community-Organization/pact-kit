---
name: mermaid-diagrams
description: "Generate Mermaid diagrams for architecture visualization, module relationships, capability hierarchies, data flow, and sequence diagrams for Pact 5 smart contracts."
---
# Mermaid Diagram Generation

## Supported Diagram Types
- **flowchart** — Module relationships, deploy order, capability hierarchies
- **sequenceDiagram** — Transaction flows, cross-chain operations, agent communication
- **classDiagram** — Schema relationships, interface hierarchies
- **stateDiagram** — Proposal lifecycle, token states
- **erDiagram** — Table relationships across modules

## Conventions
- One concept per diagram — don't overload
- Use consistent colors per module
- Label all edges with relationship type
- Include gas costs on transaction flow edges where known

## Common Patterns

### Module Dependency DAG
```mermaid
flowchart TD
    types[governance-types] --> token[governance-token]
    types --> dividend[distribution-module]
    types --> voting[governance-voting]
    token --> dividend
    token --> voting
    voting --> gas[gas-relayer]
```

### Transaction Flow
```mermaid
sequenceDiagram
    participant User
    participant SDK as TypeScript SDK
    participant Node as KDA-CE Node
    User->>SDK: Build transaction
    SDK->>Node: /local (preflight)
    Node-->>SDK: Gas estimate
    SDK->>Node: /send (submit)
    SDK->>Node: /poll (confirm)
    Node-->>SDK: Result
```
