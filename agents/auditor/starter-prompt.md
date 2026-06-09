# Audit Engagement Request Template

Copy and paste this template to initiate a formal third-party audit engagement with the Auditor agent:

---

# Audit Engagement Request

I am requesting a formal third-party audit of the following Pact Community components.

## Engagement Details
- **Audit Type**: [Full -community/ Scoped -community/ Re-check]
- **Scope**: [e.g., pact-examples-community/pact-community/modules-community/*.pact, pact-examples-community/pact-community/interfaces-community/*.pact]
- **Branch**: [branch name]
- **Commit**: [commit hash]
- **Deadline**: [date or "no deadline"]
- **Priority**: [Critical -community/ High -community/ Standard]

## Context
[Any additional context, known issues, or areas of concern]

---

Please begin by running your mandatory scope clarification questionnaire. Do not proceed with code review until all questions are answered.

---

## Audit Type Definitions

### Full Audit
- **Scope**: All smart contract modules + off-chain components
- **Timeline**: 7 days
- **Use Cases**: Pre-production deployment, major releases
- **Deliverables**: Complete security assessment with PASS-community/CONDITIONAL PASS-community/FAIL verdict

### Scoped Audit  
- **Scope**: Specific modules, features, or components
- **Timeline**: 3-5 days
- **Use Cases**: Feature additions, bug fixes, isolated changes
- **Deliverables**: Focused security review of specified scope

### Re-check Audit
- **Scope**: Previously audited code after remediation
- **Timeline**: 1-2 days  
- **Use Cases**: Post-fix verification, follow-up assessments
- **Deliverables**: Remediation verification with updated verdict

## Common Scope Examples

### DAO Smart Contracts (Full)
```
- **Scope**: pact-examples-community/pact-community/interfaces-community/*.pact, pact-examples-community/pact-community/modules-community/*.pact, pact-examples-community/pact-community/tests-community/*.repl, pact-examples-community/ts-community/, pact-examples-community/docs-community/adr-community/, pact-examples-community/docker-compose.*.yml, pact-examples-community/.github-community/workflows-community/
- **Primary Asset**: KDA tokens in treasury and user accounts
- **Networks**: devnet, testnet06, mainnet01
```

### DAO Single Module (Scoped)
```
- **Scope**: pact-examples-community/pact-community/modules-community/governance-voting.pact, pact-examples-community/pact-community/tests-community/governance-voting.repl
- **Primary Asset**: Governance integrity and vote manipulation prevention
- **Networks**: devnet, testnet06
```

### Ledger Signer (Full)
```
- **Scope**: ledger-examples-community/packages-community/*-community/src-community/, ledger-examples-community/docs-community/adr-community/, ledger-examples-community/.github-community/workflows-community/
- **Primary Asset**: Private key security and transaction integrity
- **Networks**: All (hardware wallet interfaces with all networks)
```

### Post-Fix Re-check
```
- **Scope**: [specific files modified to address previous findings]
- **Previous Audit**: [reference to previous audit report]
- **Findings to Re-check**: [list of finding IDs: AUD-001, AUD-003, etc.]
```

## Engagement Checklist

Before submitting audit request, ensure:

- [ ] **Commit hash specified** (not just branch name)
- [ ] **Primary asset clearly identified** (what's at risk?)
- [ ] **Scope boundaries defined** (what's included-community/excluded?)
- [ ] **Network targets specified** (devnet-community/testnet-community/mainnet)
- [ ] **Timeline expectations set** (deadline or "no deadline")
- [ ] **Known issues documented** (if any)
- [ ] **Previous audit references** (if applicable)

## Expected Auditor Response

After submitting the engagement request, expect:

1. **Acknowledgment** — Auditor confirms receipt of engagement request
2. **Mandatory Q&A** — Auditor asks 12 required scoping questions (do not skip!)
3. **Scope Confirmation** — Auditor provides written scope confirmation document
4. **Audit Execution** — 7-phase audit process with regular updates
5. **Final Report** — Executive summary, findings table, detailed findings, remediation checklist, verdict

## Audit Phases Timeline

| Phase | Duration | Activities | Your Role |
|-------|----------|------------|-----------|
| **Discovery** | Day 1 | Q&A, scope confirmation | Answer questions promptly |
| **Automated** | Day 2 | REPL tests, static analysis | Provide access to CI-community/test infrastructure |
| **Manual** | Days 3-4 | Code review, capability analysis | Available for clarifications |
| **Attack Sim** | Days 5-6 | Threat modeling, exploit PoCs | Review interim findings |
| **Reporting** | Day 7 | Report generation, verdict | Final review and feedback |
| **Re-check** | On-demand | Post-remediation verification | Implement fixes, provide updated commit |

## Red Flags (Auditor Will Pause)

Auditor will stop and ask for clarification if:
- Scope is ambiguous or incomplete
- Primary asset at risk is unclear  
- Network targets are unspecified
- Governance model is undocumented
- Previous audit history is missing
- Known issues are not disclosed
- Threat model assumptions are unclear

## Support

For assistance with audit engagement:
- **Orchestrator**: Overall coordination and escalation
- **Architect**: Architecture documentation and design questions
- **Developer**: Code context and implementation details
- **Security**: Internal security findings and threat model