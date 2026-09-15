# Technical Documentation Templates

Replace all placeholder text in `[square brackets]` with actual content.

## ADR Template

```markdown
# ADR-[NNNN]: [Title of Decision]

| Field          | Value                                      |
|----------------|--------------------------------------------|
| Status         | [Proposed | Accepted | Deprecated | Superseded by ADR-NNNN] |
| Date           | [YYYY-MM-DD]                               |
| Decision Maker | [Role or team responsible]                 |
| Consulted      | [Teams or roles consulted]                 |
| Informed       | [Teams or roles to be informed]            |

## Context

[Context description]

## Decision

[Decision statement]

## Consequences

### Positive

- [Benefit 1]
- [Benefit 2]

### Negative

- [Tradeoff or cost 1]
- [Tradeoff or cost 2]

### Neutral

- [Side effect that is neither clearly positive nor negative]

## Security Implications

[Security analysis]

## References

- [Link to relevant documentation, RFC, threat model, or prior ADR]
- [Link to discussion thread or meeting notes]
```

## Runbook Template

```markdown
# Runbook: [Descriptive Name]

| Field          | Value                          |
|----------------|--------------------------------|
| Last Updated   | [YYYY-MM-DD]                   |
| Owner          | [Team or role]                 |
| Classification | [Public | Internal | Confidential | Restricted] |
| Review Cadence | [Quarterly | After each use]   |

## Purpose

[Purpose statement]

## Prerequisites

- [ ] [Access or permission requirement]
- [ ] [Required tool or CLI version]
- [ ] [VPN, bastion host, or network requirement]
- [ ] [Required credentials -- reference vault path, not actual values]

## Procedure

### Step 1: [Action Name]

**Action:**

\`\`\`bash
[exact command with <PLACEHOLDER_VALUES> clearly marked]
\`\`\`

**Expected output:**

\`\`\`
[what the operator should see if the step succeeds]
\`\`\`

**Verification:**

[How to confirm this step succeeded before proceeding]

### Step 2: [Action Name]

**Action:**

\`\`\`bash
[command]
\`\`\`

**Expected output:**

\`\`\`
[expected output]
\`\`\`

**Verification:**

[Verification criteria]

### Step 3: [Action Name]

> **DECISION POINT:** If [condition], proceed to Step 4a. If [other condition], proceed to Step 4b.

## Rollback

### If failure occurs during Steps 1-3:

1. [Rollback action]
2. [Rollback action]

### If failure occurs during Steps 4+:

1. [Rollback action]
2. [Rollback action]

## Escalation

| Condition                              | Escalate To              | Channel          |
|----------------------------------------|--------------------------|------------------|
| [Condition requiring escalation]       | [Team or role]           | [Slack/PagerDuty/phone] |
| [Another escalation condition]         | [Team or role]           | [Channel]        |

## Verification

1. [Overall verification step]
2. [Metric or dashboard to check]
3. [Duration to monitor before considering the procedure complete]
```

## Security Advisory Template

```markdown
# Security Advisory: [SA-YYYY-NNN] [Short Title]

| Field              | Value                                      |
|--------------------|--------------------------------------------|
| Identifier         | [SA-YYYY-NNN or CVE-YYYY-NNNNN]           |
| Published          | [YYYY-MM-DD]                               |
| Last Updated       | [YYYY-MM-DD]                               |
| Severity           | [Critical | High | Medium | Low]           |
| CVSS Score         | [N.N] ([CVSS vector string])               |
| CWE                | [CWE-NNN: CWE Name]                       |
| Classification     | [Public | Internal | Confidential | Restricted] |

## Summary

[Plain-language summary]

## Affected Systems

| Component          | Affected Versions     | Fixed Version        |
|--------------------|-----------------------|----------------------|
| [Component name]   | [>= X.Y.Z, < A.B.C] | [A.B.C]             |
| [Component name]   | [version range]       | [fixed version]      |

### Affected Configurations

[Configuration details]

## Description

[Technical description]

## Impact

- **Confidentiality:** [Impact description]
- **Integrity:** [Impact description]
- **Availability:** [Impact description]

### Attack Prerequisites

- [Required access level or position]
- [Required conditions]

## Remediation

### Recommended Action

[Upgrade to version X.Y.Z or apply patch reference]

\`\`\`bash
[exact upgrade or patch command]
\`\`\`

### Workarounds

**Note:** Workarounds are temporary. Apply the patch at the earliest opportunity.

1. [Workaround with exact steps]
2. [Another workaround option if applicable]

## Timeline

| Date               | Event                                      |
|--------------------|--------------------------------------------|
| [YYYY-MM-DD]       | Vulnerability reported by [reporter]       |
| [YYYY-MM-DD]       | Vulnerability confirmed                    |
| [YYYY-MM-DD]       | Fix developed and tested                   |
| [YYYY-MM-DD]       | Affected parties notified                  |
| [YYYY-MM-DD]       | Fix released in version [X.Y.Z]           |
| [YYYY-MM-DD]       | Public disclosure                          |

## Credit

This vulnerability was reported by [name or "an anonymous researcher"] [through the organization's bug bounty program | via responsible disclosure].

## References

- [Link to CVE entry]
- [Link to patched release]
- [Link to relevant CWE]
- [Link to OWASP reference if applicable]
```

## Postmortem Template

```markdown
# Postmortem: [Incident Short Title]

| Field              | Value                                      |
|--------------------|--------------------------------------------|
| Date               | [YYYY-MM-DD]                               |
| Severity           | [SEV-1 | SEV-2 | SEV-3 | SEV-4]          |
| Duration           | [Total incident duration]                  |
| Authors            | [Roles involved in writing]                |
| Status             | [Draft | In Review | Final]                |
| Classification     | [Public | Internal | Confidential | Restricted] |

## Incident Summary

[Summary: what broke, duration, and quantified impact]

## Timeline

### Detection

| Time (UTC)   | Event                                           |
|--------------|-------------------------------------------------|
| [HH:MM]      | [Alert fired / customer report / automated detection] |
| [HH:MM]      | [On-call acknowledged]                          |

### Investigation

| Time (UTC)   | Event                                           |
|--------------|-------------------------------------------------|
| [HH:MM]      | [Investigation action taken]                    |
| [HH:MM]      | [Hypothesis formed or discarded]                |

### Mitigation

| Time (UTC)   | Event                                           |
|--------------|-------------------------------------------------|
| [HH:MM]      | [Mitigation action taken]                       |
| [HH:MM]      | [Partial recovery observed]                     |

### Resolution

| Time (UTC)   | Event                                           |
|--------------|-------------------------------------------------|
| [HH:MM]      | [Root cause addressed]                          |
| [HH:MM]      | [Full recovery confirmed]                       |

## Root Cause Analysis

### Technical Root Cause

[Description of the direct technical failure]

### Five Whys

1. **Why** did [the failure] occur? Because [reason].
2. **Why** did [reason from #1] occur? Because [deeper reason].
3. **Why** did [reason from #2] occur? Because [deeper reason].
4. **Why** did [reason from #3] occur? Because [deeper reason].
5. **Why** did [reason from #4] occur? Because [systemic root cause].

## Impact

| Dimension          | Impact                                     |
|--------------------|--------------------------------------------|
| Users affected     | [Number or percentage]                     |
| Duration           | [Minutes/hours of degraded service]        |
| Transactions lost  | [Number or dollar amount]                  |
| Data impact        | [Data loss, corruption, or exposure scope] |
| SLA budget         | [Error budget consumed]                    |
| Revenue impact     | [Estimated dollar amount if known]         |

## Contributing Factors

- [Contributing factor 1]
- [Contributing factor 2]
- [Contributing factor 3]

## Action Items

| # | Action                                                    | Owner (Role)       | Priority | Due Date     |
|---|-----------------------------------------------------------|--------------------|----------|--------------|
| 1 | [Specific, measurable action]                             | [Team or role]     | [P0-P3]  | [YYYY-MM-DD] |
| 2 | [Specific, measurable action]                             | [Team or role]     | [P0-P3]  | [YYYY-MM-DD] |
| 3 | [Specific, measurable action]                             | [Team or role]     | [P0-P3]  | [YYYY-MM-DD] |

## Lessons Learned

### What went well

- [Effective response or process that helped]
- [Tool or automation that worked as designed]

### What went poorly

- [Process failure or gap]
- [Tooling limitation]

### Where we got lucky

- [Situation that could have been much worse]
- [Coincidence that reduced impact]

## References

- [Link to incident channel or thread]
- [Link to relevant dashboards]
- [Link to related postmortems]
```

## RFC / Design Document Template

```markdown
# RFC-[NNNN]: [Title]

| Field              | Value                                      |
|--------------------|--------------------------------------------|
| Status             | [Draft | In Review | Accepted | Rejected | Withdrawn] |
| Author             | [Name and role]                            |
| Reviewers          | [Names and roles]                          |
| Created            | [YYYY-MM-DD]                               |
| Last Updated       | [YYYY-MM-DD]                               |
| Classification     | [Public | Internal | Confidential | Restricted] |
| Target Release     | [Version or quarter]                       |

## Summary

[Summary statement]

## Motivation

### Problem Statement

[Clear description of the problem]

### Evidence

- [Metric, incident reference, or user feedback]
- [Additional evidence]

### Goals

- [Goal 1: specific and measurable]
- [Goal 2]

### Non-Goals

- [Non-goal 1]
- [Non-goal 2]

## Detailed Design

### Architecture Overview

\`\`\`mermaid
graph LR
    A[Component A] --> B[Component B]
    B --> C[Component C]
\`\`\`

[Description of the architecture]

### Interface Definitions

\`\`\`
[API definition, protobuf schema, OpenAPI snippet, or similar]
\`\`\`

### Data Model

[Data model description]

### Implementation Phases

1. **Phase 1:** [Description and deliverable]
2. **Phase 2:** [Description and deliverable]
3. **Phase 3:** [Description and deliverable]

## Alternatives Considered

### Alternative 1: [Name]

**Description:** [How this alternative works]

**Pros:**
- [Advantage]

**Cons:**
- [Disadvantage]

**Why not chosen:** [Reason]

### Alternative 2: [Name]

**Description:** [How this alternative works]

**Pros:**
- [Advantage]

**Cons:**
- [Disadvantage]

**Why not chosen:** [Reason]

## Security Considerations

Address each category or explicitly state it does not apply:

- **Authentication and Authorization:** [Impact on authn/authz flows]
- **Data Protection:** [Classification, encryption at rest/in transit, retention]
- **Attack Surface:** [New endpoints, interfaces, or dependencies]
- **Dependency Risk:** [New third-party dependencies, their security posture]
- **Compliance:** [SOC 2, GDPR, PCI DSS, HIPAA as applicable]
- **Threat Model:** [Reference existing model or describe new threats]

## Rollout Plan

### Feature Flags

[Feature flag names and configuration for staged rollout]

### Deployment Phases

| Phase   | Scope                | Success Criteria                | Rollback Trigger            |
|---------|----------------------|---------------------------------|-----------------------------|
| Phase 1 | [e.g., staging]      | [Metric or condition]           | [Condition to roll back]    |
| Phase 2 | [e.g., 5% canary]   | [Metric or condition]           | [Condition to roll back]    |
| Phase 3 | [e.g., 100%]        | [Metric or condition]           | [Condition to roll back]    |

### Rollback Plan

[Exact steps to revert the change if rollout fails]

### Monitoring

[New metrics, alerts, or dashboards required to support the rollout]

## Open Questions

- [ ] [Open question 1]
- [ ] [Open question 2]

## References

- [Link to related ADRs]
- [Link to threat model]
- [Link to relevant prior art or external resources]
```
