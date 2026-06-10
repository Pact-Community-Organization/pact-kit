---
name: mcp-tool-use
description: "Practical guide for selecting and using Pact Community MCP tools safely, including when to use MCP versus direct edits, category mapping, decision checklists, examples, safety controls, troubleshooting, and a quick reference."
---

# MCP Tool Use

## Purpose

Use this skill to choose and invoke Pact Community MCP tools safely and consistently.
The goal is to reduce fragile shell workflows, preserve auditability, and make tool behavior predictable for maintainers.

This guide covers:
1. When MCP tools are preferred versus direct file edits.
2. How tool categories map to common tasks.
3. A checklist to pick the right tool quickly.
4. Example call patterns with expected outputs.
5. Safety rules for read-only and destructive actions.
6. Common errors and practical troubleshooting.
7. A minimal quick-reference table for daily use.

## 1) When to use MCP tools vs direct file edits

Use MCP tools first when the operation involves stateful systems, APIs, or structured transactions.
Use direct edits for local source changes where no external system interaction is required.

Use MCP tools when:
- You are running Pact REPL checks, static scans, or chain operations.
- You are reading or updating coordination state (tasks, mailbox, status, memory logs).
- You are interacting with GitHub resources (issues, PRs, workflows, repo files).
- You need schema-validated arguments and machine-readable responses.
- You want a clear, auditable action trail.

Use direct file edits when:
- You are implementing source code changes in local files.
- You are updating markdown, comments, or local configuration content.
- The task is purely local and does not depend on remote or shared state.
- No dedicated MCP capability exists for the requested operation.

Rule of thumb:
- External or shared state: use MCP.
- Local code content: edit files directly.

## 2) Tool category map

### Pact MCP

Primary domain: Pact language development and contract validation.

Typical use cases:
- Run `.repl` test files.
- Scan Pact modules for known traps and anti-patterns.
- Validate contract behavior before chain submission.

Typical outputs:
- Structured test/scan result.
- Error text with location hints.
- Gas metrics or execution summaries.

### Chainweb MCP

Primary domain: chain interactions and transaction lifecycle.

Typical use cases:
- Get network or chain metadata.
- Preflight Pact code with local simulation.
- Submit signed transactions.
- Poll request keys to final completion.

Typical outputs:
- Chain/network info objects.
- Preflight success or failure payload.
- Request keys from send operations.
- Final transaction result payload from polling.

### Coordination MCP

Primary domain: shared workflow state for agent/task systems.

Typical use cases:
- Create, read, and update task records.
- Send and acknowledge mailbox messages.
- Set status and append memory entries.

Typical outputs:
- Normalized task objects.
- Message arrays with IDs and timestamps.
- Confirmation responses for status/memory updates.

### GitHub MCP

Primary domain: repository and collaboration operations.

Typical use cases:
- Read or update repository files.
- Create/read/update issues and pull requests.
- Inspect workflow/action results.

Typical outputs:
- Repository metadata and file content.
- Issue/PR objects and review threads.
- CI run summaries and status fields.

## 3) Decision checklist for tool selection

Before invoking any tool, answer these questions:

1. Does this action touch remote, on-chain, or shared state?
2. Is there an MCP tool that explicitly models this action?
3. Do I need structured output instead of parsing free-form terminal text?
4. Can I run read-only first to validate assumptions?
5. Does the action modify, delete, or publish something irreversible?
6. If destructive, do I already have explicit human confirmation?

If the first three answers are yes, choose MCP.
If the action is local-only source editing, use direct file edits.

## 4) Example call patterns and expected outputs

### Pact example: run REPL test

```json
{
  "method": "tools/call",
  "params": {
    "name": "pact.repl_run",
    "arguments": {
      "replPath": "pact/tests/token.repl"
    }
  }
}
```

Expected output shape:
- `success` boolean.
- `stdout` and `stderr` text fields.
- Optional gas or execution summary fields.

### Chainweb example: preflight then send then poll

```json
{
  "method": "tools/call",
  "params": {
    "name": "chainweb.local",
    "arguments": {
      "networkId": "development",
      "chainId": "0",
      "pactCode": "(coin.get-balance \"alice\")",
      "keyPairs": []
    }
  }
}
```

Expected output shape:
- Preflight result object with success/failure indicators.
- Gas estimate or consumption details.
- Error metadata when simulation fails.

Follow-up calls:
- `chainweb.send` returns request key(s).
- `chainweb.poll` returns final transaction result.

### Coordination example: task update

```json
{
  "method": "tools/call",
  "params": {
    "name": "coord.task_update",
    "arguments": {
      "id": "task-123",
      "status": "in_progress",
      "notes": "Implemented capability checks and added tests"
    }
  }
}
```

Expected output shape:
- Updated task object with status, timestamps, and metadata.
- Locking or validation error if concurrent edits conflict.

### GitHub example: read file content

```json
{
  "method": "tools/call",
  "params": {
    "name": "get_file_contents",
    "arguments": {
      "owner": "pact-community",
      "repo": "example-repo",
      "path": "README.md",
      "ref": "main"
    }
  }
}
```

Expected output shape:
- File content plus encoding metadata.
- Blob SHA and path details.
- Not-found error structure when path/ref is invalid.

## 5) Safety rules

Safety defaults:
- Start with read-only operations whenever possible.
- Validate inputs before submit/update calls.
- Keep destructive actions blocked until explicit human confirmation.

Required controls:
1. Read before write: inspect current state first.
2. Preflight before send: do not submit transactions without local validation.
3. Confirm target identity: repo, branch, network, and chain must be explicit.
4. Never auto-delete or force-update on inferred intent.
5. Record intent and outcome for traceability when workflow requires it.

Actions that require explicit human confirmation:
- Deleting files, branches, issues, comments, or task records.
- Force pushes, force updates, or irreversible publish operations.
- On-chain actions with permanent state impact.

## 6) Common errors and troubleshooting

`INVALID_INPUT`
- Cause: missing required arguments or wrong argument shape.
- Fix: compare payload fields with tool schema; send minimal valid args first.

`NOT_FOUND`
- Cause: wrong ID/path/ref/network/chain value.
- Fix: run a read/list call to discover canonical identifiers, then retry.

`LOCK_HELD` or concurrency conflict
- Cause: another process updated the same coordination object.
- Fix: re-read latest state, merge intent, retry once.

`PREFLIGHT_FAILED`
- Cause: Pact code failed simulation or signatures/caps are incomplete.
- Fix: inspect error payload, correct code or signer/cap set, rerun preflight.

`NETWORK_ID_MISMATCH`
- Cause: tool arguments target the wrong network.
- Fix: explicitly set network and chain values; verify against info call.

`AUTHORIZATION` or permission errors
- Cause: token scope, repo access, or signing authority is insufficient.
- Fix: verify credentials and permissions; avoid repeated blind retries.

General troubleshooting sequence:
1. Reproduce with the smallest valid input.
2. Run read-only inspection to validate IDs and current state.
3. Retry once after correcting the specific error cause.
4. Escalate with error payload if still unresolved.

## 7) Minimal quick-reference table

| Need | Preferred tool family | Safe first call | Follow-up |
|---|---|---|---|
| Run Pact REPL tests | Pact MCP | `pact.repl_run` | `pact.module_scan` |
| Check chain metadata | Chainweb MCP | `chainweb.info` | `chainweb.chain_time` |
| Simulate transaction | Chainweb MCP | `chainweb.local` | `chainweb.send`, then `chainweb.poll` |
| Update task workflow | Coordination MCP | `coord.task_get` or `coord.task_list` | `coord.task_update` |
| Read repo file | GitHub MCP | `get_file_contents` | issue/PR/action tools as needed |
| Local source change | Direct edit | read file and patch | run tests/lint as needed |

## Final reminders

- Prefer MCP for operations that touch remote, on-chain, or shared state.
- Prefer direct edits for local code content changes.
- Default to read-only inspection first.
- Require explicit human confirmation before destructive actions.
- Use structured error payloads to fix root causes, not guess-and-retry loops.