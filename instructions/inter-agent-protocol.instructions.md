---
description: "Inter-agent message protocol: identity tags, task lifecycle, veto powers, terminal delegation. Use when coordinating agents or routing tasks."
# Inter-Agent Communication Protocol

## Identity
- All agents share the same GitHub user
- Identity is established via **prefix tags**: `[Admin]`, `[Architect]`, etc.
- Every external output (PR comment, issue comment, commit message) MUST be prefixed

## Communication Channels

### External (GitHub)
- PR/issue comments prefixed with `[AgentName]`
- Used for: reviews, findings, approvals, go/no-go decisions

**Note**: For GitHub operations, prefer GitHub MCP tools (`issues`, `pull_requests` toolsets) over `gh` CLI when available. The `[AgentName]` prefix requirement still applies for all comments. GitHub MCP provides structured data and audit logging versus terminal stdout parsing.

### Internal (File-based)
- Task queue, agent mailboxes, and a status dashboard can be used if your project keeps an internal coordination area.

**Note**: File-based operations SHOULD go through your MCP coordination tools when available rather than direct file manipulation. This keeps audit logging, schema validation, and race-condition handling consistent with the project’s conventions.

## Task Lifecycle

```
Product creates story → Admin decomposes →
  Gate 1: Product → Architect → Developer
  Gate 2: Developer → Tester + Security → Admin
  Gate 3: Tester GO + Security APPROVE → DevOps → Admin
```

## Delegation Rules
1. Admin is the ONLY agent that decomposes and delegates
2. Agents may request re-delegation via mailbox message
3. Veto powers:
   - **Tester**: Can block any merge (NO-GO)
   - **Security**: Can block any deployment (CRITICAL finding)
   - **Admin**: Can redirect or cancel any task
4. Agents MUST NOT communicate directly with the user (except Admin)

## Terminal Command Delegation (MANDATORY)

Admin does NOT have terminal access. When any workflow requires running shell commands (tests, Docker, deployment, builds, etc.), Admin MUST delegate to an agent with terminal access.

### Agents with Terminal Access
| Agent | Terminal Use Cases |
|-------|-----------------|
| **Developer** | Build, test (REPL + devnet), lint, compile, Docker devnet |
| **DevOps** | Deploy, Docker management, CI/CD, infrastructure |
| **Tester** | Independent test execution, devnet verification |
| **Security** | Security scanning, penetration testing |

### Rules
1. Admin MUST NOT suggest commands for the user to run — delegate to the appropriate agent instead
2. The delegated agent MUST execute the commands and report results back
3. If a command fails, the delegated agent MUST diagnose and fix (not bounce back to Admin without analysis)
4. Long-running commands (test suites, deployments): the agent MUST wait for completion before reporting

## Message Format
```json
{
  "from": "[AgentName]",
  "to": "[AgentName]",
  "type": "task|finding|approval|question|status",
  "priority": "critical|high|medium|low",
  "subject": "Brief description",
  "body": "Detailed content",
  "references": ["task-id", "pr-number"],
  "timestamp": "ISO-8601"
}
```

## Severity Classification
- `[CRITICAL]` — Security vulnerability, data loss risk, blocks deployment
- `[HIGH]` — Functional bug, incorrect behavior, blocks merge
- `[MEDIUM]` — Non-critical issue, performance concern
- `[LOW]` — Style, documentation gap, minor improvement
- `[UNCERTAIN]` — Finding that cannot be confirmed without more context
