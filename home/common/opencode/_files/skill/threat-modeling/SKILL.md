---
name: threat-modeling
description: Structured STRIDE threat modeling to identify, classify, and prioritize security threats
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: security
---

## What I do

- Perform structured STRIDE threat modeling against systems, components, or
  features
- Decompose data flows, identify trust boundaries, and enumerate attack surfaces
- Rate risks using DREAD scoring and produce actionable mitigation plans

## When to use me

Use this skill for threat models, STRIDE analysis, attack surface reviews, or
risk assessments. Not for general security questions, code reviews, or debugging
security bugs.

## Process

### 1: Scope and Context
Identify the subject, define in/out-of-scope boundaries, gather existing
artifacts, state assumptions and attacker profile (opportunistic, insider,
nation-state, bot).

### 2: Data Flow Decomposition
Build a DFD with external entities `[]`, processes `()`, data stores `[==]`, and
data flows `-->`. Mark trust boundaries. Every flow crossing a boundary is a
candidate for deeper analysis. Classify assets (public / internal / confidential
/ restricted).

### 3: Threat Identification (STRIDE)
Apply STRIDE to every DFD element and data flow:

| Category | Property Violated | Primary Targets |
|----------|-------------------|-----------------|
| **S**poofing | Authentication | External entities, processes |
| **T**ampering | Integrity | Data flows, data stores |
| **R**epudiation | Non-repudiation | Processes, external entities |
| **I**nformation Disclosure | Confidentiality | Data flows, data stores |
| **D**enial of Service | Availability | Processes, data stores |
| **E**levation of Privilege | Authorization | Processes |

### 4: Attack Surface Analysis
Enumerate entry/exit points. For each, verify: is it necessary, access
restricted, input validated, monitored, defaults/debug disabled.

### 5: Risk Rating and Prioritization
Score threats using DREAD. Critical/High: fix before shipping. Medium: schedule
within two sprints. Low: backlog.

### 6: Mitigations and Deliverables
For every threat rated Medium or above, propose at least one mitigation
(Preventive > Detective > Corrective). Prefer platform-level over
application-level controls. Layer controls.

**Deliverables:** Threat model document, threat table, residual risk statement,
action items with owners and target dates.
