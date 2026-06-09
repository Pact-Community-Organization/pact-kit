---
name: feedback-collection
description: "User feedback analysis, routing, and synthesis for Pact Community. Collect, categorize, and route developer feedback to appropriate agents."
---
# Feedback Collection

## Feedback Categories
| Category | Route To | Action |
|----------|----------|--------|
| Bug report | Support → Developer | Triage and fix |
| Feature request | Product | Backlog addition |
| Documentation gap | Docs | Update docs |
| Security concern | Security | Urgent assessment |
| UX improvement | Product | Prioritize |
| Performance issue | Developer + Architect | Investigate |

## Feedback Report Template
```markdown
## Feedback Report — {period}
### Summary
Total feedback items: {N}
By category: {breakdown}

### Key Themes
1. {theme}: {frequency}, {recommended action}

### Priority Items
- {item}: {category}, {recommended agent}

### Trends
- {improving/declining areas}
```

## Processing Protocol
1. Receive feedback
2. Classify by category
3. Deduplicate against existing issues
4. Route to appropriate agent via Orchestrator
5. Track resolution
