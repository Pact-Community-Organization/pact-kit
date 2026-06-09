---
name: code-review
description: "Developer code review patterns for Pact 5 — self-review checklist, common issues, review comments format, and pre-submission validation."
---
# Code Review

## Self-Review Checklist (Before Submission)
- [ ] Code compiles in REPL without errors
- [ ] All existing tests still pass
- [ ] New tests added for new functionality
- [ ] No Pact 5 critical traps introduced
- [ ] Gas measured and within budget
- [ ] Cross-module impact assessed
- [ ] @doc annotations on all public functions
- [ ] Agent tag in commit message

## Review Comment Format
```
[Developer] {severity}: {description}

File: {path}:{line}
Issue: {what's wrong}
Suggestion: {how to fix}
Refs: {ADR, requirement, or rule reference}
```

## Common Review Findings
1. Missing capability guard on write function
2. DML inside try block
3. Ternary + operator usage
4. Empty expect-failure string
5. Implicit test state dependency
6. Missing negative (unauthorized) test
7. with-default-read missing fields
