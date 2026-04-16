---
name: 11-proactive-analysis
description: >
  Shared Revisor skill for turning current metrics, saved context, and prior
  snapshots into concise "what changed / what needs attention / what looks
  healthy / coming up / next step" analysis.
metadata:
  version: "0.1.0"
  scope: "shared"
---

# Revisor Proactive Analysis

Use this skill whenever Revisor needs to sound like an advisor rather than a
dashboard.

This skill is especially important for:

- `/revisor:qb-setup`
- `/revisor:qb-health`
- `/revisor:qb-forecast`
- `/revisor:qb-weekly`
- `/revisor:qb-expenses`
- `/revisor:qb-whatif`
- `/revisor:qb-report`

## Core Sections

### 1. What Changed

- Compare to the latest comparable snapshot when one exists.
- If nothing materially changed, say that plainly in the first sentence.
- Same-day snapshots still count as comparable history if they use the same
  metric contract.
- Lead with the most decision-relevant change, not a generic metric recap.

### 2. What Needs Attention

- Show at most 3 findings.
- Prioritize in this order:
  1. cash-floor breach or runway risk
  2. near-term obligations
  3. revenue decline or material expense instability
- If a finding is driven by an `assumed` recurring item, say that directly.
- Do not turn connector blind spots into absence claims.

### 3. What Looks Healthy

- Always include 1 to 3 honest positives.
- In wind-down or dissolution mode, confirmed cancellations and stable zero-burn
  months count as real healthy signals.
- If the outlook is mixed, still name one concrete thing that is going well.

### 4. Coming Up

- Surface `confirmed` and `assumed` obligations due within 30 to 60 days.
- Keep timing honest when the date is approximate.
- If there is nothing upcoming, say so plainly.

### 5. Decision Framing

- If the user asked a yes/no or afford/waive/fund question, answer that near the
  top.
- Put the direct answer before the longer explanation.
- If the correct answer depends on one unresolved assumption, say `Only if ...`
  rather than overcommitting.

### 6. Next Step

- End with one concrete next action only.
- Choose the smallest action that most reduces uncertainty or risk.
- Good examples:
  - confirm or exclude one assumed obligation
  - arrange funding before a breach month
  - rerun a lower-cost variant
  - run the shareable report

## Prioritization Rules

- If one lumpy obligation dominates the whole picture, say that instead of
  pretending there are multiple equal risks.
- If the current state is flat because the business is dormant, frame it as a
  maintenance / closure state, not a growth narrative.
- If recent history is identical across multiple snapshots, use `stable` /
  `unchanged`, not `insufficient history`.

## Tone Rules

- Interpret before listing.
- Be concrete, not dramatic.
- Use exact numbers where the current command allows them.
- Keep conclusions inside the modeled or observed horizon.

## Report Mapping

When producing report-card style output:

- `Top Strengths` should come from the healthiest real signals.
- `Top Risks` should come from the top 1 to 2 items in `What needs attention`.
- `Recommended Next Step` should match the same single action you would choose in
  the normal advisor output.
