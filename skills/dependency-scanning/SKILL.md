---
name: dependency-scanning
description: "Supply chain security for Pact 5 projects — npm dependency audit, module dependency verification, and cross-module trust analysis."
---
# Dependency Scanning

## Pact Module Dependencies
- Map all `use` statements across modules
- Verify no circular dependencies
- Check each dependency's governance model
- Verify imported functions are used safely

## TypeScript Dependencies
```bash
# Audit npm dependencies
npm audit
pnpm audit

# Check for outdated packages
npm outdated
pnpm outdated
```

## Cross-Module Trust Analysis
For each module dependency:
- Who controls the governance keyset?
- Can the module be upgraded independently?
- What happens if the dependency is upgraded?
- Are there assumptions about dependency behavior?

## Findings Template
```
Dependency: {module or package}
Type: {Pact module | npm package}
Risk: {what could go wrong}
Severity: {CRITICAL|HIGH|MEDIUM|LOW}
Recommendation: {pin version, audit, replace}
```
