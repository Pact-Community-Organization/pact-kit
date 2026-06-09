---
name: research-methodology
description: "Structured research framework with source hierarchy, evidence grading, and citation requirements. Used for investigating Pact 5, KDA-CE, blockchain patterns, and technical decisions."
---
# Research Methodology

## Source Hierarchy (Trust Order)
1. **Official Pact 5 documentation** (https://kda-chain.org/docs)
2. **KDA-CE source code** (chainweb-node, pact repositories)
3. **On-chain evidence** (devnet test results, transaction data)
4. **Architecture Decision Records** (project ADRs)
5. **Community resources** (verified by on-chain testing)

## Research Protocol
1. **Define the question** — precise, testable hypothesis
2. **Search available sources** — in hierarchy order
3. **Verify empirically** — test on devnet when possible
4. **Document findings** — with source citations
5. **Record confidence** — HIGH / MEDIUM / LOW / UNCERTAIN

## Evidence Grading
- **Empirical** — Verified by devnet test (highest confidence)
- **Documentary** — Supported by official docs
- **Inferential** — Derived from source code analysis
- **Anecdotal** — Community knowledge (requires empirical verification)

## Citation Format
```
Source: {document/URL}
Verified: {Yes/No} — {method of verification}
Confidence: {HIGH/MEDIUM/LOW}
```
