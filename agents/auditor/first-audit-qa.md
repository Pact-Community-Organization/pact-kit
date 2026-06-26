# Mandatory Audit Scope Clarification — 12 Question Protocol

This document defines the mandatory pre-audit questionnaire that the Auditor agent MUST complete before proceeding with any code review. All questions must receive satisfactory answers.

## Protocol Rules

1. **Ask ALL questions** — never skip or combine questions
2. **Wait for complete answers** — do not proceed until every question has a specific response
3. **Re-ask unclear responses** — follow up with targeted clarification requests
4. **Document all Q&A** — maintain audit trail of questions asked and answers received
5. **Scope confirmation required** — produce written scope confirmation document before Phase 2

---

## Question Set: Audit Scope Clarification

### **Category 1: Scope Definition**

#### **Q1: What is the exact scope of this audit?**

*Purpose: Define precise boundaries of what will be reviewed*

**Acceptable Answer Includes:**
- Specific file paths (e.g., `pact/modules/*.pact`)
- Explicit inclusion/exclusion statements
- Branch name and commit hash
- Off-chain components if applicable (CI/CD, deployment scripts, TypeScript)

**Follow-up Required If:**
- Only high-level descriptions provided ("the whole platform")
- No commit hash specified
- Unclear whether tests are included
- Ambiguous about off-chain scope

**Example Follow-up:**
> "You mentioned contract modules — please specify the exact `.pact` files. Should I include `pact/tests/*.repl` files? What about `ts/` TypeScript integration code?"

#### **Q2: What is the primary asset at risk?**

*Purpose: Understand impact and prioritize threat modeling*

**Acceptable Answer Includes:**
- Specific asset types (KDA tokens, governance rights, user data)
- Quantified exposure where possible ($X in treasury, Y user accounts)
- Governance impact (proposal manipulation, admin key compromise)
- Reputation/compliance risks

**Follow-up Required If:**
- Vague references to "security" or "smart contracts"
- No mention of financial exposure
- Unclear governance impact
- Missing data privacy considerations

**Example Follow-up:**
> "You mentioned 'user funds' — what is the approximate total value at risk? Are there governance tokens that could be manipulated? What admin capabilities exist?"

### **Category 2: Environment & Infrastructure**

#### **Q3: Which networks/environments are in-scope?**

*Purpose: Define testing boundaries and deployment targets*

**Acceptable Answer Includes:**
- Specific network names (testnet06, mainnet01, devnet)
- API endpoints for each network
- Network-specific considerations or constraints
- Cross-chain implications if applicable

**Follow-up Required If:**
- Generic references to "testnet" or "production"
- No API endpoints provided
- Unclear about cross-chain scope
- Missing devnet testing considerations

**Example Follow-up:**
> "You mentioned 'testnet' — please specify testnet06 or another? What are the API endpoints? Should cross-chain functionality between chains 0-19 be tested?"

#### **Q4: Who holds privileged keys and what are the upgrade/ownership patterns?**

*Purpose: Understand governance risks and admin attack vectors*

**Acceptable Answer Includes:**
- Specific keyset names and ownership
- Multisig configurations (M-of-N)
- Key rotation procedures
- Upgrade governance model
- Emergency procedures

**Follow-up Required If:**
- No specific keyset names provided
- Unclear multisig configuration
- Missing key rotation details
- Undefined emergency procedures
- No governance documentation referenced

**Example Follow-up:**
> "You mentioned 'governance keyset' — what is the exact keyset name? Is it 2-of-3 multisig? What triggers key rotation? Are there emergency admin capabilities?"

### **Category 3: Requirements & Properties**

#### **Q5: Are there formal invariants or properties that must always hold? Provide docs/ADRs.**

*Purpose: Define correctness criteria and formal verification scope*

**Acceptable Answer Includes:**
- Specific ADR or documentation references
- Mathematical invariants (supply conservation, vote≤balance)
- Business rule invariants (dividend calculations, governance thresholds) 
- File paths to relevant documentation

**Follow-up Required If:**
- No documentation references provided
- Vague statements about "working correctly"
- Missing mathematical formulations
- No business rule specifications

**Example Follow-up:**
> "Please provide specific file paths to ADRs or documentation. What mathematical properties must hold (e.g., token supply conservation)? Are there @model annotations in the Pact code?"

#### **Q6: What is the expected threat model and attacker capabilities to consider?**

*Purpose: Scope attack scenarios and adversarial testing*

**Acceptable Answer Includes:**
- Attacker sophistication level (script kiddie, professional, nation-state)
- Resource constraints (financial, computational, time)
- Access assumptions (blockchain only, off-chain access)
- Specific attack vectors of concern

**Follow-up Required If:**
- No attacker profiling provided
- Unclear resource assumptions
- Missing specific threat concerns
- No reference to industry threat models

**Example Follow-up:**
> "What level of attacker sophistication should be assumed? Should we consider attackers with significant financial resources for governance attacks? Any specific threat vectors you're particularly concerned about?"

### **Category 4: Compliance & Standards**

#### **Q7: What regulatory/compliance constraints apply (if any)?**

*Purpose: Identify compliance requirements affecting security posture*

**Acceptable Answer Includes:**
- Specific regulatory frameworks (if any)
- Compliance standards to meet
- Jurisdictional considerations
- Data protection requirements
- "No specific compliance requirements" (acceptable if true)

**Follow-up Required If:**
- Unclear about data protection
- Ambiguous jurisdictional status
- Potential financial regulations not addressed

**Example Follow-up:**
> "Are there any data protection requirements (GDPR, CCPA)? Any financial regulations that might apply to token operations? What jurisdictions are you operating in?"

#### **Q8: What existing tests and monitoring exist? Provide paths to CI, test suites, dashboards.**

*Purpose: Understand current quality assurance and monitoring coverage*

**Acceptable Answer Includes:**
- Specific file paths to test suites
- CI/CD workflow descriptions
- Monitoring/alerting configurations
- Test coverage metrics if available
- Previous test results

**Follow-up Required If:**
- No specific file paths provided
- Unclear CI/CD setup
- Missing monitoring details
- No test coverage information

**Example Follow-up:**
> "Please provide exact paths to test files. What CI platform do you use and where are the workflow files? Is there any monitoring of deployed contracts? What is the current test pass rate?"

### **Category 5: Constraints & Context**

#### **Q9: Are there time constraints or deadlines for the audit?**

*Purpose: Plan audit timeline and scope any time-based limitations*

**Acceptable Answer Includes:**
- Specific deadline dates
- Timeline constraints and rationale
- "No fixed deadline" (acceptable)
- Flexibility for follow-up questions

**Follow-up Required If:**
- Unrealistic timeline for scope
- Unclear about findings remediation timeline
- Rush requests without justification

**Example Follow-up:**
> "The requested timeline seems tight for the scope. Is this deadline flexible if critical findings are discovered? How much time would be available for remediation and re-check?"

#### **Q10: What is the risk tolerance? (zero-tolerance for fund loss vs. acceptable documented risks)**

*Purpose: Calibrate finding severity and remediation requirements*

**Acceptable Answer Includes:**
- Explicit risk tolerance statements
- Fund loss tolerance levels
- Governance attack tolerance
- Acceptable vs. unacceptable risk categories

**Follow-up Required If:**
- No explicit risk tolerance stated
- Unclear about fund loss vs. governance risks
- Ambiguous about severity thresholds

**Example Follow-up:**
> "Are you willing to accept any level of fund loss risk with proper documentation and mitigations? What about governance risks like vote manipulation? What severity findings would block deployment?"

### **Category 6: History & Known Issues**

#### **Q11: What previous audits have been conducted? Provide reports.**

*Purpose: Understand audit history and avoid duplication*

**Acceptable Answer Includes:**
- Previous audit reports or links
- Audit firm names and dates
- Findings and remediation status
- "No previous audits" (acceptable if true)

**Follow-up Required If:**
- Previous audits mentioned but no reports provided
- Unclear remediation status of prior findings
- Missing audit scope information

**Example Follow-up:**
> "You mentioned previous audits — please provide the reports or detailed summaries. What was the scope and what findings were identified? What remediation was completed?"

#### **Q12: Are there any known issues or areas of specific concern?**

*Purpose: Focus audit attention on high-risk areas and disclosed issues*

**Acceptable Answer Includes:**
- Specific code areas of concern
- Known limitations or trade-offs
- Recent changes requiring attention
- "No known issues" (acceptable if true)
- Issue tracker references

**Follow-up Required If:**
- Vague concerns without specifics
- Recent major changes not detailed
- Unclear about internal security findings

**Example Follow-up:**
> "You mentioned 'recent changes' — please specify which files/functions were modified and why they're concerning. Are there any internal security findings or concerns from the development team?"

---

## Q&A Completion Checklist

Auditor must verify ALL questions have satisfactory answers:

- [ ] **Q1**: Exact scope defined with file paths and commit hash
- [ ] **Q2**: Primary assets and exposure quantified
- [ ] **Q3**: Networks and environments clearly specified
- [ ] **Q4**: Privileged keys and governance model documented
- [ ] **Q5**: Formal invariants and properties referenced with docs
- [ ] **Q6**: Threat model and attacker capabilities defined
- [ ] **Q7**: Compliance constraints addressed (or confirmed none)
- [ ] **Q8**: Existing tests and monitoring documented with paths
- [ ] **Q9**: Timeline constraints clarified
- [ ] **Q10**: Risk tolerance explicitly defined
- [ ] **Q11**: Previous audit history provided (or confirmed none)
- [ ] **Q12**: Known issues disclosed (or confirmed none)

## Scope Confirmation Document Template

After satisfactory Q&A completion, Auditor produces:

```
[Auditor] AUDIT SCOPE CONFIRMATION

Engagement ID: AUD-{YYYY}-{MM}-{NNN}
Date: {YYYY-MM-DD}
Commit: {hash}

SCOPE:
• Files: {specific file list}
• Networks: {specific network list}  
• Timeline: {start date} to {end date}

ASSETS AT RISK:
• {asset summary with exposure}

THREAT MODEL:
• {attacker capabilities and scenarios}

INVARIANTS TO VERIFY:
• {formal properties from documentation}

GOVERNANCE MODEL:
• {keyset owners and procedures}

RISK TOLERANCE:
• {explicit risk acceptance criteria}

PREVIOUS AUDITS:
• {summary or "None"}

KNOWN ISSUES:
• {disclosed issues or "None"}

COMPLIANCE:
• {requirements or "None"}

Confirmed by: [Auditor]
Ready to proceed: Yes
Next phase: Architecture Review
```

**Only after scope confirmation document is produced and agreed should Auditor proceed to audit phases.**