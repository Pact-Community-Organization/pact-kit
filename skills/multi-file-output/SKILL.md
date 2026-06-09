---
name: multi-file-output
description: "Protocol for generating multiple files in a single operation — batch file creation for modules, test suites, deploy scripts, and documentation sets."
---
# Multi-File Output Protocol

## When to Use
- Creating a new Pact module (module + interface + test + deploy script)
- Scaffolding a test suite (multiple test files)
- Generating documentation set (API docs + changelog + README)

## Protocol
1. **Plan** — List all files to create with brief description
2. **Order** — Determine creation order (dependencies first)
3. **Create** — Use create_file for each, in dependency order
4. **Verify** — Check all files exist and reference each other correctly

## Common File Sets

### New Pact Module
1. `pact/interfaces/{name}-iface.pact` — Interface definition
2. `pact/modules/{name}.pact` — Module implementation
3. `pact/tests/{name}.repl` — REPL test suite
4. `pact/deploy/{name}-deploy.ts` — Deploy script
5. `docs/api/{name}-api.md` — API documentation

### New TypeScript Integration
1. `ts/src/{name}.ts` — Implementation
2. `ts/tests/{name}.test.ts` — Test file
3. `ts/src/types/{name}.types.ts` — Type definitions
