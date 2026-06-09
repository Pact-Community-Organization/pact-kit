---
description: "Mandatory clarification and question-asking protocol for ALL agents. Apply before starting any non-trivial task. Prevents hallucinations, false assumptions, and costly reversals."
applyTo: "**"
# Clarification Protocol — Never Assume, Always Ask

> **Priority: HIGHEST.** This protocol overrides any default "proceed confidently" behavior.
> Every agent MUST follow this before acting on ambiguous requests.

---

## Core Rule

**If you are not 100% certain what the user wants, STOP and ask before doing anything.**

Do not:
- Infer intent from partial information and proceed
- Make "reasonable assumptions" and hope they are correct
- Start implementing and correct course mid-way
- Ask one clarifying question, get an answer, then assume everything else

---

## When to Ask (Mandatory Triggers)

Ask before proceeding whenever ANY of the following is true:

| Trigger | Example |
|---------|---------|
| The request is ambiguous about SCOPE | "clean up the tests" — which tests? which project? |
| The request is ambiguous about BEHAVIOR | "fix the dividend logic" — what's the expected behavior? |
| Multiple valid interpretations exist | "update the docs" — update to reflect what change? |
| The request would cause irreversible changes | deleting files, dropping tables, pushing to remote |
| You are unsure which file/module is the canonical one | two files look like they could be the same |
| A requirement contradicts something in memory | new instruction conflicts with an ADR |
| The request touches multiple projects/modules | cross-cutting change with unclear blast radius |
| You would need to CREATE a new file or directory | always confirm the right location first |
| You are about to archive or delete anything | always confirm what is safe to remove |
| A test is failing and the fix is non-obvious | do not silently weaken the test |

---

## How to Ask

### Question quality rules

1. **Ask ALL unclear questions at once** — batch them in a single call to the questions tool. Do not ask one question, wait for answer, then ask another one you already knew you needed.
2. **Be specific** — do not ask vague questions like "Can you clarify?". Ask about the exact ambiguity.
3. **Show what you found** — briefly state what you observed before asking. Example: "I see two files: `dao.pact` (current) and `dao-token.pact` (archived). Which did you mean?"
4. **Offer options when possible** — gives the user concrete choices. Do not make them write a long free-form answer when a selection would work.
5. **Do not ask about optional parameters** — only ask about things that materially change your action.
6. **Maximum 5 questions per batch** — if you have more, prioritize the blocking ones.

### What NOT to do

- Do NOT say "I'll assume X and proceed" and then proceed
- Do NOT ask about things you can determine yourself from the codebase
- Do NOT ask for information you already have (re-read memory files first)
- Do NOT ask the user to repeat information already in `docs/memory/`

---

## Research Before Asking

Before asking questions, do this:

1. Read `docs/memory/INDEX.md` and `PROJECT-STATE.md`
2. Search the codebase for the relevant files
3. Read the relevant instruction/skill files for the domain

Only after this research, ask about anything that REMAINS unclear.

The goal is targeted, specific questions — not lazy "please explain more" requests.

---

## Uncertainty Communication

When you are uncertain about a finding (not a request), mark it explicitly:

```
[UNCERTAIN] I cannot confirm this without running devnet. 
The code path looks correct but I have not verified it on-chain.
```

Never present uncertain findings as confirmed facts.

---

## Scope Creep Prevention

**Only do what was asked.** If during your work you find related issues:

1. Complete the original task
2. Then REPORT the additional findings with severity
3. Ask if the user wants you to address them separately

Do NOT silently expand the scope of the task.

---

## Mandatory Pre-Task Checklist (for non-trivial tasks)

Before starting any task that involves writing or deleting files:

- [ ] I have read `docs/memory/INDEX.md`
- [ ] I have checked `FILE-REGISTRY.md` for canonical files related to this task
- [ ] I understand exactly which files will be created, modified, or deleted
- [ ] If creating a new file: I have confirmed the correct location in `workspace-conventions.instructions.md`
- [ ] If the scope is unclear: I have asked the user to confirm before proceeding
