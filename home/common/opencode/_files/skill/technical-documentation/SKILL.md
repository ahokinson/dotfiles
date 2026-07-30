---
name: technical-documentation
description: Create ADRs, runbooks, security advisories, postmortems, and design documents
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: documentation
---

## What I do

- Produce structured technical documents following prescribed templates
- Create ADRs, runbooks, security advisories, postmortems, and RFCs/design docs
- Enforce consistent file naming and directory conventions

## When to use me

Use this skill to write an ADR, runbook, postmortem, security advisory, RFC, or
design document. Not for inline code comments, README updates, API docs, or
general prose.

## Document Types

### Architecture Decision Records (ADRs)
Record a single architectural decision. Title with sequential number (ADR-0001),
Status, Date, Context (forces, constraints, threat model), Decision (1-2
sentences, active voice), Consequences (positive, negative, neutral), Security
Implications, References. Store in `docs/adr/`.

### Runbooks
Step-by-step operational procedures for on-call engineers. Purpose,
Prerequisites (access, tools, permissions), Procedure (numbered steps with exact
commands and expected output), Rollback (keyed to procedure steps), Escalation
(conditions and target roles), Verification. Mark placeholders with
`<ANGLE_BRACKETS>`. Store in `docs/runbooks/`.

### Security Advisories
Communicate vulnerabilities following coordinated disclosure. Identifier (CVE or
internal), Severity (CVSS + qualitative), CWE, Affected Systems, Summary,
Description, Impact, Remediation, Workarounds, Timeline, Credit. Store in
`docs/advisories/`.

### Postmortems
Blameless incident documentation. Incident Summary (severity, duration, impact),
Timeline (UTC by phase), Root Cause Analysis (Five Whys or fault-tree), Impact
(quantified), Contributing Factors, Action Items (table with owner and
priority), Lessons Learned. Store in `docs/postmortems/`.

### RFCs / Design Documents
Propose significant technical changes. Summary (three sentences max), Motivation
(problem + evidence), Goals/Non-Goals, Detailed Design (architecture,
interfaces, data model), Alternatives (at least two), Security Considerations,
Rollout Plan (phases, flags, rollback triggers), Open Questions. Store in
`docs/rfcs/`.
