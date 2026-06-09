---
description: "Use when refactoring Pact modules, restructuring code, renaming functions, or performing any code transformation that should preserve behavior."
applyTo: ["**/*.pact"]
# Refactoring Rules

## Core Principle
Refactoring MUST preserve behavior. Every refactoring is verified by existing tests passing unchanged.

## Refactor Admission Criteria (Mandatory)
- Refactor is blocked unless at least one trigger is present: correctness bug, security issue, gas ceiling risk, or compliance failure.
- Attach evidence for the trigger (failing tests, audit finding, or measured metrics) before work starts.
- Quantify the expected benefit (for example: reduced failure rate, gas reduction, or compliance gap closure).
- Repeated redesigns of the same module require Architect + Tester sign-off and a CTO risk note.

## Before Refactoring
1. Ensure full test coverage on current behavior
2. Document the refactoring goal and scope
3. Identify cross-module impact (deploy-order neighbors)
4. Estimate gas impact of the change
5. Get Architect approval for structural changes

## Cross-Module Impact Assessment
When modifying module N:
1. Review module N-1 (dependency) — does it rely on changed interfaces?
2. Review module N+1 (dependent) — does it use changed functions/capabilities?
3. Check all `use` statements referencing the module
4. Verify interface compliance still holds after changes
5. Run cross-module integration tests

## Refactoring Checklist
- [ ] All existing tests pass before starting
- [ ] Change is the minimum necessary for the goal
- [ ] No feature additions mixed with refactoring
- [ ] Gas measurement before and after (must not exceed budget)
- [ ] All existing tests pass after completion
- [ ] Cross-module tests pass after completion
- [ ] Deploy order preserved
- [ ] API compatibility maintained (or migration documented)

## Naming Changes
- Update ALL references across ALL modules
- Update deploy scripts
- Update test files
- Update documentation
- Use find-and-replace with manual verification
