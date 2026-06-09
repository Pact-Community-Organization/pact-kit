---
description: "Orchestrator: Decompose a user request into agent tasks and assign them. Creates task DAG with dependencies and quality gate checkpoints."
---
# Assign Task

## Input
- User request or feature description
- Priority level

## Process
1. Classify the request (feature, bug, security, docs, support)
2. Decompose into agent-assignable tasks
3. Build dependency DAG
4. Assign to agents based on expertise
5. Set quality gate checkpoints

## Output Format
```json
{
  "tasks": [
    {
      "id": "TASK-001",
      "title": "...",
      "assignee": "[AgentName]",
      "dependencies": [],
      "gate": "1",
      "priority": "high",
      "acceptance_criteria": ["AC1", "AC2"]
    }
  ]
}
```

## Routing Guidelines
- Requirements/stories → Product
- Architecture/design → Architect
- Implementation → Developer
- Testing/QA → Tester
- Security review → Security
- Deployment → DevOps
- Documentation → Docs
- Issue triage → Support
