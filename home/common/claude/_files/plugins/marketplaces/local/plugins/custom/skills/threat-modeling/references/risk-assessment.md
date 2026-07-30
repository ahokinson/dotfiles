# Risk Assessment Reference

Score, prioritize, and document risk for threats identified during threat
modeling.

---

## DREAD Scoring

Rate each factor 1 (low) to 10 (high). Score = (D + R + E + A + D) / 5.

| Factor              | Question                                    |
|---------------------|---------------------------------------------|
| **D**amage          | How severe is the impact if realized?       |
| **R**eproducibility | How reliably can the attack be reproduced?  |
| **E**xploitability  | How much skill/tooling does the attacker need? |
| **A**ffected users  | How many users/tenants are impacted?        |
| **D**iscoverability | How easy is it to find the vulnerability?   |

### Interpretation

| Score Range  | Rating        | Action                                            |
|--------------|---------------|---------------------------------------------------|
| 8.0-10.0     | Critical      | Stop the release. Fix immediately.                |
| 6.0-7.9      | High          | Fix before shipping or within current sprint.     |
| 4.0-5.9      | Medium        | Schedule fix within next two sprints.             |
| 2.0-3.9      | Low           | Backlog. Revisit if exposure changes.             |
| 1.0-1.9      | Informational | Document for awareness. No action required.       |

---

## Risk Matrix (5x5 Likelihood vs. Impact)

```text
                        IMPACT
                 Negligible  Minor  Moderate  Major  Severe
             +----------+-------+----------+-------+--------+
  Almost     |  Medium  | Medium|   High   |Critical|Critical|
  Certain    |          |       |          |        |        |
             +----------+-------+----------+-------+--------+
  Likely     |   Low    | Medium|  Medium  | High   |Critical|
             |          |       |          |        |        |
             +----------+-------+----------+-------+--------+
L Possible   |   Low    |  Low  |  Medium  | High   | High   |
I            |          |       |          |        |        |
K +----------+----------+-------+----------+-------+--------+
E Unlikely   |   Info   |  Low  |   Low    | Medium | High   |
L            |          |       |          |        |        |
I +----------+----------+-------+----------+-------+--------+
H Rare       |   Info   |  Info |   Low    |  Low   | Medium |
O            |          |       |          |        |        |
O +----------+----------+-------+----------+-------+--------+
D
```

---

## Prioritization

Sort by risk score descending. Tie-break:

1. **Blast radius**: broader impact wins.
2. **Data classification**: restricted > confidential > internal.
3. **Remediation cost**: cheaper fix first to reduce open risk count faster.

### Effort-vs-Risk Quadrant

```text
                LOW remediation effort    HIGH remediation effort
HIGH risk    |  Fix immediately (Q1)    |  Plan and resource (Q2)   |
             |  Quick wins that remove  |  Significant work but     |
             |  serious risk cheaply    |  necessary for high risk  |
             +-------------------------+---------------------------+
LOW risk     |  Fix opportunistically   |  Accept or defer (Q4)     |
             |  (Q3) -- during nearby   |  Document residual risk   |
             |  refactors or sprints    |  and review periodically  |
             +-------------------------+---------------------------+
```

Priority order: Q1 > Q2 > Q3 > Q4.

---

## Risk Acceptance

Accept a threat only when ALL conditions hold:

1. Rating is Medium or below after existing controls.
2. Mitigation cost materially exceeds annualized expected loss.
3. A compensating control limits practical impact.
4. A named risk owner formally accepts and records rationale.
5. A review date is set (max 12 months out).

### Risk Acceptance Record Format

```text
Threat ID:             THREAT-<nnn>
Risk Rating:           <score and label>
Accepted By:           <name and role>
Date:                  <YYYY-MM-DD>
Rationale:             <Why mitigation is not pursued>
Compensating Controls: <Controls that limit residual risk>
Review Date:           <YYYY-MM-DD, max 12 months out>
```

Re-evaluate accepted risks when exposure increases, a related vuln is
disclosed/exploited, regulatory requirements change, or an incident reveals the
compensating control is insufficient.
