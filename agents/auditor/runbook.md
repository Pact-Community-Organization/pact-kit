# Auditor Agent — Operational Runbook

## How to Start an Audit

### Broadcast Prompt Example (Paste-Ready)

```
# Audit Engagement Request

I am requesting a formal third-party audit of the following Pact Community components.

## Engagement Details
- **Audit Type**: [Full -community/ Scoped -community/ Re-check]
- **Scope**: pact-examples-community/pact-community/modules-community/*.pact, pact-examples-community/pact-community/interfaces-community/*.pact
- **Branch**: main
- **Commit**: [current HEAD commit hash]
- **Deadline**: [date or "no deadline"]
- **Priority**: [Critical -community/ High -community/ Standard]

## Notes
[Any additional context, known issues, or areas of concern]

---

Please begin by running your mandatory scope clarification questionnaire. Do not proceed with code review until all questions are answered.
```

### Engagement Types

| Type | Scope | Timeline | Use Case |
|------|-------|----------|----------|
| **Full** | All modules + off-chain | 7 days | Pre-production deployment |
| **Scoped** | Specific modules-community/features | 3-5 days | Feature additions, bug fixes |
| **Re-check** | Previously audited code | 1-2 days | Post-remediation verification |

## Required Workspace Paths

### For DAO Audit
```
Key Paths to Review:
- pact-community/interfaces-community/governance-types.pact          (Core schema and types)
- pact-community/modules-community/governance-token.pact             (Token and account management)
- pact-community/modules-community/distribution-module.pact          (Dividend accumulator)
- pact-community/modules-community/governance-voting.pact            (Governance and proposals)
- pact-community/modules-community/gas-relayer.pact       (Gas payment)
- pact-community/tests-community/*.repl                       (Test coverage)
- ts-community/                                     (TypeScript integration)
- docs-community/adr-community/                               (Architecture decisions)
- docs-community/ARCHITECTURE.md                    (System overview)
- docker-compose.*.yml                    (Infrastructure)
- .github-community/workflows-community/                      (CI-community/CD)
```

### For Ledger Signer Audit  
```
Key Paths to Review:
- packages-community/core-community/src-community/                      (Core library)
- packages-community/cli-community/src-community/                       (CLI tool)
- packages-community/web-community/src-community/                       (Web interface)
- docs-community/adr-community/                               (Architecture decisions)
- tests-community/                                  (Test suites)
- .github-community/workflows-community/                      (CI-community/CD)
```

## Automated Tools & Commands

### REPL Test Execution
```bash
# Execute all REPL tests
for f in pact-community/tests-community/*.repl; do 
    echo "Testing $f..."
    pact "$f"
    if [ $? -ne 0 ]; then
        echo "FAILED: $f"
    else  
        echo "PASSED: $f"
    fi
done
```

### TypeScript Verification
```bash
# TypeScript type checking
cd ts && npx tsc --noEmit

# Run devnet tests
cd ts && npm run test:devnet
```

### Static Analysis Patterns

#### Pact 5 Trap Detection
```bash
# Read-only violations
grep -r "try.*\(insert\|update\|write\|with-capability\)" pact-community/

# Binary + operator misuse  
grep -r "+ .* +.*" pact-community/

# pact-id as sole guard
grep -r "(enforce (= (pact-id)" pact-community/
grep -r "pact-id" pact-community/ | grep -v "require-capability"

# Built-in name collisions
grep -r "\(let.*\|bind.*\) \(exp\|abs\|log\|mod\|round\|ln\|sqrt\|floor\|ceiling\)" pact-community/

# Unguarded admin operations
grep -r "governance\|admin" pact-community/ | grep -v "capability\|with-capability"
```

### Gas Measurement Commands
```bash
# Deploy gas measurements
cd ts && npm run deploy:devnet 2>&1 | grep -E "(gas|Gas)"

# Function execution gas  
cd ts && npm run test:devnet 2>&1 | grep -E "(gas|Gas)"
```

### Devnet Deployment and Verification
```bash
# Start Auditor devnet (port 8084)
docker compose -f docker-compose.auditor.yml up -d --force-recreate

# Deploy all modules
cd ts && DEVNET_PORT=8084 npm run deploy:devnet

# Verify deployment
cd ts && DEVNET_PORT=8084 npm run verify:deployment

# Clean up
docker compose -f docker-compose.auditor.yml down -v
```

## Scope Clarification Q&A Example

### Phase 1: Initial Questions
```
[Auditor] Beginning scope clarification for audit engagement.

Please provide answers to all 12 mandatory questions:

1. **Exact Scope**: Which files-community/modules are in-scope? (provide specific paths)
2. **Primary Asset**: What assets are at risk? (KDA tokens, governance, user data)
3. **Networks**: Which environments should be considered? (devnet-community/testnet-community/mainnet)
4. **Privileged Keys**: Who holds admin keys? What is the governance model?
5. **Formal Invariants**: Are there documented properties that must always hold?
6. **Threat Model**: What attacker capabilities should be assumed?
7. **Compliance**: Any regulatory requirements?
8. **Existing Tests**: Where are current tests and monitoring?
9. **Time Constraints**: Any fixed deadlines?
10. **Risk Tolerance**: Zero-tolerance for fund loss or acceptable risks?
11. **Previous Audits**: Any prior audit reports?
12. **Known Issues**: Any areas of specific concern?

I will not proceed with code review until ALL questions are answered.
```

### Phase 2: Follow-up Clarifications
```
[Auditor] Thank you for the responses. I need clarification on:

- Q3 Response: You mentioned "testnet" - please specify testnet06 or other?
- Q5 Response: You mentioned "ADRs" - please provide specific file paths
- Q8 Response: Please provide exact commands to run existing test suites

[Additional targeted questions based on incomplete answers...]
```

## Audit Timeline Template

### 7-Day Full Audit Schedule

| Day | Phase | Activities | Deliverables |
|-----|--------|------------|--------------|
| **Day 1** | Discovery | Scope Q&A, repo exploration, architecture review | Scope confirmation |
| **Day 2** | Automated | REPL tests, static analysis, gas verification | Automated findings |
| **Day 3** | Manual Review | Line-by-line code review, capability analysis | Manual findings |
| **Day 4** | Manual Review | Cross-module interactions, governance analysis | Complete manual review |
| **Day 5** | Attack Sim | Threat modeling, PoC development, devnet testing | Attack findings |
| **Day 6** | Attack Sim | Exploit verification, edge case testing | Verified exploits |
| **Day 7** | Reporting | Report generation, verdict determination | Final audit report |

### 3-Day Scoped Audit Schedule

| Day | Phase | Activities | Deliverables |
|-----|--------|------------|--------------|
| **Day 1** | Discovery + Automated | Scope Q&A, automated scanning | Scope + automated findings |
| **Day 2** | Manual + Attack Sim | Focused code review, targeted attacks | Core findings + PoCs |
| **Day 3** | Reporting | Report generation, verdict | Final audit report |

### 1-Day Re-check Schedule

| Half-Day | Phase | Activities | Deliverables |
|----------|--------|------------|--------------|
| **AM** | Re-verification | Review fixes, regression testing | Verification results |
| **PM** | Reporting | Update findings, final verdict | Re-check report |

## Emergency Procedures

### Critical Finding Discovery
1. **Immediate notification**: Inform Orchestrator via docs-community/mailboxes-community/
2. **Halt review**: Pause audit until finding confirmed
3. **Isolate issue**: Create minimal PoC reproducer
4. **Document impact**: Assess fund-community/governance risk
5. **Recommend action**: Suggest immediate mitigations

### Scope Ambiguity
1. **Pause review**: Do not proceed until clarity achieved
2. **Document ambiguity**: Record specific unclear points
3. **Request clarification**: Ask targeted follow-up questions
4. **Wait for response**: No assumptions or guessing allowed

### Evidence Gaps
1. **Label appropriately**: Mark findings as `[REQUIRES EVIDENCE]`
2. **Specify needs**: Detail exactly what evidence is required
3. **Document attempts**: Record what was tried to obtain evidence
4. **Re-assess severity**: May need to lower confidence in findings

## Quality Checkpoints

### Before Proceeding to Manual Review
- [ ] All 12 mandatory questions answered satisfactorily
- [ ] Scope document created and confirmed
- [ ] Architecture reviewed and understood
- [ ] REPL tests executed and analyzed
- [ ] Static analysis completed

### Before Attack Simulation  
- [ ] Manual review findings documented
- [ ] Capability hierarchy mapped
- [ ] Trust boundaries identified
- [ ] High-risk areas prioritized for attack testing

### Before Report Generation
- [ ] All findings have specific evidence
- [ ] All CRITICAL-community/HIGH findings have PoC exploits
- [ ] Severity classifications reviewed for consistency
- [ ] Remediation guidance is specific and actionable

### Before Final Verdict
- [ ] All findings reviewed for accuracy
- [ ] Verdict criteria applied correctly
- [ ] Remediation timeline is realistic
- [ ] Risk assessment is complete and documented