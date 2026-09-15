---
name: threat-modeling
description: |
  Structured STRIDE threat modeling to identify, classify, and prioritize security threats.
  TRIGGER when: user asks for a threat model, STRIDE analysis, attack surface review, or risk assessment of a system or feature.
  DO NOT TRIGGER when: user asks general security questions, wants a code review, or is debugging a security bug.
command: threat-modeling
---

# Threat Modeling

Perform structured threat modeling against a target system, component, or
feature. Follow the phases below in order. Adapt depth to scope. Ask clarifying
questions about system scope, users, and critical assets before starting
analysis. Reference specific files and line numbers when identifying threats
tied to implementation.

## 1: Scope and Context

Identify the subject. Define in/out-of-scope boundaries. Gather existing
artifacts (diagrams, API specs, prior models). State assumptions, constraints,
and attacker profile (opportunistic, insider, nation-state, bot).

Output a context block:

```text
Subject:      <name>
Purpose:      <one sentence>
In scope:     <components, data flows, environments>
Out of scope: <anything explicitly excluded>
Attacker:     <profile>
Prior models: <links or "none">
```

## 2: Data Flow Decomposition

Build a DFD. Use these element types:

| Symbol | Element         | Meaning                                          |
|--------|-----------------|--------------------------------------------------|
| []     | External entity | Actor or system outside the trust boundary       |
| ()     | Process         | Code that transforms or routes data              |
| [==]   | Data store      | Database, file system, cache, queue, secret store|
| -->    | Data flow       | Directed movement of data between elements       |

Mark trust boundaries. Every flow crossing a boundary is a candidate for deeper
analysis.

List assets with classification (public / internal / confidential / restricted)
and note regulatory scope if applicable.

## 3: Threat Identification (STRIDE)

Apply STRIDE to every DFD element and data flow. Refer to
`references/stride-methodology.md` for detection questions and attack patterns.

| Category                   | Property Violated | Primary Targets              |
|----------------------------|-------------------|------------------------------|
| **S**poofing               | Authentication    | External entities, processes |
| **T**ampering              | Integrity         | Data flows, data stores      |
| **R**epudiation            | Non-repudiation   | Processes, external entities |
| **I**nformation Disclosure | Confidentiality   | Data flows, data stores      |
| **D**enial of Service      | Availability      | Processes, data stores       |
| **E**levation of Privilege | Authorization     | Processes                    |

For each element, walk every applicable STRIDE category. Skip only when
structurally inapplicable; state the rationale.

### Threat Record Format

```text
ID:            THREAT-<nnn>
Element:       <DFD element name>
Category:      <STRIDE letter and name>
Description:   <What can go wrong, attacker's perspective>
Preconditions: <What must be true for the attack to succeed>
Impact:        <Consequence if realized>
```

## 4: Attack Surface Analysis

Enumerate entry points (network listeners, file ingestion, IPC, human
interfaces, supply chain inputs) and exit points (API responses, logs, exports,
error messages, outbound connections).

For each, verify:

- [ ] Is it necessary? Remove if not.
- [ ] Access restricted to minimum required principals?
- [ ] Input validated, output encoded?
- [ ] Monitored and rate-limited?
- [ ] Defaults, debug endpoints, default creds disabled?

## 5: Risk Rating and Prioritization

Score every threat using DREAD or likelihood-times-impact. See
`references/risk-assessment.md`.

Produce a summary table:

| Threat ID  | Category | Risk Score | Rating   |
|------------|----------|------------|----------|
| THREAT-001 | S        | 8.2        | High     |
| THREAT-002 | T        | 5.0        | Medium   |
| ...        | ...      | ...        | ...      |

Prioritization rules:

1. **Critical / High**: fix before shipping or within current sprint.
2. **Medium**: schedule within next two sprints. Document accepted residual risk
   if deferred.
3. **Low**: backlog. Re-evaluate if exposure changes.
4. **Informational**: note for awareness only.

Tie-break: broader blast radius first, then higher data classification.

## 6: Mitigations and Deliverables

For every threat rated Medium or above, propose at least one mitigation.

### Mitigation Record Format

```text
Threat ID:   THREAT-<nnn>
Control:     <Name of the control>
Type:        <Preventive | Detective | Corrective>
Description: <How the control reduces likelihood or impact>
Status:      <Proposed | In Place | Accepted Risk>
Owner:       <Team or individual>
```

Prefer preventive over detective controls. Favor platform-level controls over
application-level when both are viable. Layer controls; do not rely on a single
gate.

### Deliverables

1. **Threat model document**: sections 1-6 above.
2. **Threat table**: flat list of all threats with IDs, scores, mitigation
   status.
3. **Residual risk statement**: accepted threats with justification.
4. **Action items**: concrete tickets linked to mitigation records, each with
   owner and target date.

## References

- `references/stride-methodology.md`: STRIDE detection questions, attack
  patterns, mitigations.
- `references/risk-assessment.md`: DREAD scoring, risk matrices, prioritization
  frameworks.
