# Agent Registry

Canonical agent definitions for this repository.

## Canonical Agent Files

- `agents/admin.agent.md`: Central coordinator for delegation, quality-gate tracking, and final synthesis.
- `agents/architect.agent.md`: System design and architecture decisions for Pact implementations.
- `agents/developer.agent.md`: Implementation agent for smart contracts, integration code, and engineering fixes.
- `agents/tester.agent.md`: QA and validation agent for deterministic test execution and gate verdicts.
- `agents/security.agent.md`: Security review agent for vulnerability analysis, threat modeling, and mitigation guidance.
- `agents/auditor.agent.md`: Independent-style external audit agent for formal security and risk assessments.
- `agents/devops.agent.md`: CI/CD and deployment operations agent for reproducible release workflows.
- `agents/docs.agent.md`: Documentation agent for technical docs, changelogs, and onboarding guidance.

## Naming Rules

- Use lowercase canonical naming only: `*.agent.md`.
- Do not add case-variant duplicates (for example, `Developer.agent.md`).
- Use `Admin` as the coordination role name.

## Model Default

All canonical agents use:

- `model: ["Auto"]`
