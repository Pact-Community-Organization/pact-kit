---
description: "Mandatory clarification protocol for ALL agents before any non-trivial task. Prevents hallucinations, false assumptions, and costly reversals."
applyTo: "**"
---
# Clarification Protocol — Never Assume, Always Ask

> **Priority: HIGHEST.** Overrides any default "proceed confidently" behavior. Every agent MUST follow this before acting on ambiguous requests.

## Core Rule

**If you are not 100% certain what the user wants, STOP and ask before doing anything.** Do not: infer intent from partial info and proceed; make "reasonable assumptions" and hope; start implementing then correct course mid-way; ask one question, then assume everything else.

## When to Ask (Mandatory Triggers)

Ask before proceeding whenever ANY is true:

| Trigger | Example |
|---------|---------|
| Ambiguous SCOPE | "clean up the tests" — which tests? which project? |
| Ambiguous BEHAVIOR | "fix the dividend logic" — expected behavior? |
| Multiple valid interpretations | "update the docs" — reflect what change? |
| Irreversible change | deleting files, dropping tables, pushing to remote |
| Unsure which file/module is canonical | two files look like the same |
| Requirement contradicts memory | new instruction conflicts with an ADR |
| Touches multiple projects/modules | cross-cutting, unclear blast radius |
| Would CREATE a new file/dir | confirm the right location first |
| About to archive or delete anything | confirm what is safe to remove |
| Test failing, fix non-obvious | do not silently weaken the test |

## How to Ask

1. **Batch ALL unclear questions** in a single questions-tool call — never serialize questions you already know you need.
2. **Be specific** — ask about the exact ambiguity, not "Can you clarify?".
3. **Show what you found** before asking (e.g. "`payments.pact` (current) vs `payments-v1.pact` (archived) — which?").
4. **Offer options** when a selection works better than free-form text.
5. **Do not ask about optional parameters** — only things that materially change your action.
6. **Max 5 questions per batch** — prioritize blocking ones.

Never: say "I'll assume X and proceed" then proceed; ask what you can determine from the codebase; ask for info you already have (re-read memory first); ask the user to repeat info already in `docs/memory/`.

## Research Before Asking

1. If your project uses a session-start memory or registry convention, consult it once per session and re-read only if it changed or became stale.
2. Search the codebase for relevant files.
3. Read relevant instruction/skill files for the domain.

Then ask only about what REMAINS unclear — targeted questions, not lazy "explain more".

## Uncertainty Communication

Mark uncertain findings (not requests) explicitly, e.g. `[UNCERTAIN] code path looks correct but not verified on-chain`. Never present uncertain findings as confirmed facts.

## Scope Creep Prevention

**Only do what was asked.** If you find related issues: (1) complete the original task, (2) REPORT additional findings with severity, (3) ask whether to address them separately. Do NOT silently expand scope.

## Mandatory Pre-Task Checklist (writing/deleting files)

- [ ] If your project uses session-start memory, referenced it — re-read only if changed.
- [ ] If your project uses a file registry, checked it for related canonical files.
- [ ] Understand exactly which files will be created/modified/deleted.
- [ ] New file: confirmed correct location in `workspace-conventions.md`.
- [ ] Scope unclear: asked the user to confirm before proceeding.
