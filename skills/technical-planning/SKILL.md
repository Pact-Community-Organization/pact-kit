---
name: technical-planning
description: "Technical implementation sequencing, dependency planning, gas budget estimation, and milestone breakdown for Pact 5 smart contract development."
---
# Technical Planning

## Planning Process
1. **Scope** — Define what's in/out for this milestone
2. **Sequence** — Order tasks by dependency
3. **Estimate** — Gas budgets, complexity assessment
4. **Parallelize** — Identify independent work streams
5. **Risk** — Apply risk analysis to the plan

## Dependency DAG Construction
1. List all deliverables
2. For each: what must complete first?
3. Draw directed edges (dependency → dependent)
4. Verify acyclic (topological sort succeeds)
5. Identify critical path (longest chain)

## Gas Budget Planning
| Tier | Gas Range | Examples |
|------|-----------|---------|
| Light | < 5,000 | Config reads, simple updates |
| Medium | 5,000 - 30,000 | Module deploy, table creation |
| Heavy | 30,000 - 100,000 | Complex deploy with many tables |
| Splitting | > 100,000 | Must split into multiple transactions |

## Milestone Template
```
## Milestone {N}: {Title}
Target: {date}
Deliverables:
1. {deliverable with acceptance criteria}
Dependencies: {prior milestones}
Risks: {identified risks with mitigation}
```
