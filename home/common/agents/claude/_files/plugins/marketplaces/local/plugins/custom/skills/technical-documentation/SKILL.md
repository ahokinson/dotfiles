---
name: technical-documentation
description: |
  Create ADRs, runbooks, security advisories, postmortems, and design documents.
  TRIGGER when: user asks to write an ADR, runbook, postmortem, security advisory, RFC, or design document.
  DO NOT TRIGGER when: user asks for inline code comments, README updates, API docs, or general prose writing.
command: technical-documentation
---

# Technical Documentation

Produce structured technical documents for application security engineering and
software development. Each document type follows a prescribed template. See
`references/templates.md` for copy-paste-ready templates.

## Document Types

### Architecture Decision Records (ADRs)

Record a single architectural decision with its context and consequences. Use
when adopting, changing, or removing a technology choice, security control,
auth/crypto approach, or data-handling policy.

- Title with sequential number, Status, Date
- Context (forces at play, constraints, threat model considerations)
- Decision (1-2 sentences, active voice)
- Consequences (positive, negative, neutral)
- Security Implications
- References

Number sequentially: ADR-0001, ADR-0002.

### Runbooks

Step-by-step operational procedures an on-call engineer can follow under stress.
Use for incident response, routine maintenance, or any repeatable operational
task.

- Purpose (one sentence)
- Prerequisites (access, tools, permissions)
- Procedure (numbered steps with exact commands, expected output, verification
  per step)
- Rollback (undo steps keyed to procedure step numbers)
- Escalation (conditions and target roles, not individuals)
- Verification (confirm overall success)

Mark placeholders with `<ANGLE_BRACKETS>`. Use callout blocks for decision
points.

### Security Advisories

Communicate a vulnerability to affected parties following coordinated disclosure
conventions.

- Identifier (CVE or internal ID), Severity (CVSS + qualitative), CWE
- Affected Systems (versions, components, configurations)
- Summary (plain-language, one paragraph)
- Description (technical detail)
- Impact (confidentiality, integrity, availability)
- Remediation (upgrade path + exact commands)
- Workarounds (temporary mitigations)
- Timeline (discovery through disclosure)
- Credit

### Postmortems

Document an incident after resolution. Blameless, past tense, focused on
systemic improvement.

- Incident Summary (severity, duration, business impact)
- Timeline (UTC, organized by phase: Detection, Investigation, Mitigation,
  Resolution)
- Root Cause Analysis (Five Whys or fault-tree)
- Impact (quantified: users, transactions, SLA budget, revenue)
- Contributing Factors
- Action Items (table: Action, Owner role, Priority, Due Date; specific enough
  to become tickets)
- Lessons Learned (what went well, what went poorly, where we got lucky)

### RFCs / Design Documents

Propose a significant technical change for asynchronous review before
implementation.

- Summary (three sentences max)
- Motivation (problem + evidence: metrics, incidents, user feedback)
- Goals and Non-Goals
- Detailed Design (architecture, interfaces, data model, implementation phases;
  use Mermaid for diagrams)
- Alternatives Considered (at least two, honestly evaluated)
- Security Considerations (authn/authz, data protection, attack surface,
  dependencies, compliance, threat model)
- Rollout Plan (phases, feature flags, rollback triggers, success criteria)
- Open Questions

## File Naming Conventions

| Document Type     | Directory           | Filename Pattern                       |
|-------------------|---------------------|----------------------------------------|
| ADR               | `docs/adr/`        | `NNNN-title-in-lowercase.md`          |
| Runbook           | `docs/runbooks/`   | `runbook-descriptive-name.md`         |
| Security Advisory | `docs/advisories/` | `SA-YYYY-NNN-short-title.md`          |
| Postmortem        | `docs/postmortems/`| `YYYY-MM-DD-incident-short-title.md`  |
| RFC / Design Doc  | `docs/rfcs/`       | `RFC-NNNN-title-in-lowercase.md`      |
