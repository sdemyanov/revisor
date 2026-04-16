---
name: 03-financial-health
description: >
  Shared Revisor skill for QuickBooks-first alerting, finding prioritization, and
  healthy-signal detection.
metadata:
  version: "0.1.0"
  scope: "shared"
---

# Revisor Financial Health

Use this skill to turn metrics into findings, alerts, and one clear next step.

## QuickBooks-Only Alert Rules

### Critical

- Cash runway base case under 3 months
- Cash runway worst case under 1 month
- Payroll coverage under 2 months if a payroll-like expense bucket is visible and current cash is available
- Revenue declined 3 or more consecutive active months

### Warning

- Cash runway base case under 6 months
- Cash runway worst case under 3 months
- Revenue declined 2 consecutive active months
- Any expense category increased more than 30% versus its 3-month rolling average and the absolute change is material
- Gross margin declined more than 5 points versus the prior quarter
- A `confirmed` or `assumed` periodic expense is due within 30 days
- The gap between best and worst case runway is greater than 6 months

### Info

- A periodic expense is due within 60 days
- Margin changed more than 2 points in either direction
- Revenue changed materially versus prior month
- This run created the first baseline snapshot, so trend language is still limited

## Unsupported In QuickBooks-Only Mode

Do not claim any alert that depends on:

- invoice status
- AR aging
- AP aging
- customer concentration
- vendor detail
- class or item tracking

If one of those would matter, say it is unavailable in the current connector surface.
Never convert a blind spot into an absence claim. For example, say
`AR/AP aging is unavailable from the current connector`, not `no AR/AP shown`.

## Finding Prioritization

- Show at most 3 findings.
- Sort existential issues first: runway, cash pressure, revenue decline.
- Then show material expense anomalies or near-term recurring obligations.
- Prefer precise, decision-relevant findings over generic summaries.

## Healthy Signals

Always include 1 to 3 healthy signals, for example:

- runway above the owner threshold
- margin improving
- expenses stabilizing
- no material recurring expenses due soon
- cash increasing versus the prior window

If the data is mixed, still find at least one honest positive signal.

## Targets

- Use the user's configured runway threshold when available to interpret health.
- Fixed critical thresholds still apply even if the user's target is lower.

## Follow-Up Behavior

Always end with one next best action:

- answer the targeted setup questions
- run `/revisor:qb-health`
- run `/revisor:qb-forecast`
- run `/revisor:qb-whatif`
- confirm or exclude assumed recurring expenses
