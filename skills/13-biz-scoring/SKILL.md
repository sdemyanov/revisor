---
name: 13-biz-scoring
description: >
  Shared Revisor skill for the current cross-source Business Health Report
  grading model: the five proven QuickBooks dimensions plus a sixth Pipeline
  Health dimension when HubSpot is available.
metadata:
  version: "0.1.0"
  scope: "shared"
---

# Revisor Business Scoring

Use this skill for:

- `/revisor:biz-report`
- later any `biz-*` weekly flow that needs a stable cross-source scorecard

## Current 6-Dimension Set

Upgrade the QuickBooks-only 5-dimension report by adding `Pipeline Health` when
HubSpot is connected and current pipeline data is available.

Current dimensions:

1. `Cash Runway`
2. `Revenue Activity`
3. `Margins`
4. `Expense Stability`
5. `Obligation Readiness`
6. `Pipeline Health`

Stripe may materially influence narrative and recommendations, but it does not
yet add a separate scored dimension in this version of the report.

## Grade Output

Allowed dimension states:

- `A`
- `B`
- `C`
- `D`
- `F`
- `N/A`

Use `N/A` when a dimension is structurally not meaningful or the required source
is not connected.

## QuickBooks-Core Dimensions

For the first 5 dimensions, reuse the same rules as `skills/12-health-scoring/SKILL.md`.

That means:

- same grade thresholds
- same `N/A` behavior
- same weighting rules
- same trend-arrow rules whenever comparable QuickBooks snapshots exist

## Pipeline Health

This dimension is only scoreable when HubSpot is connected and open pipeline can
be read.

If HubSpot is not connected, use `N/A`.

If pipeline exists but source quality is too thin for precision, still score it
conservatively rather than pretending it is unavailable.

### Pipeline Health Rules

- `A`: weighted pipeline comfortably exceeds target or near-term need, stalled
  exposure is low, and recent activity / timing support suggests live movement
- `B`: weighted pipeline is healthy enough to matter, velocity is acceptable,
  and stalled exposure is limited
- `C`: some live pipeline exists, but timing confidence is mediocre or coverage
  is only modest
- `D`: pipeline is thin against need, materially stalled, or heavily dependent on
  a small number of neglected deals
- `F`: no credible near-term pipeline, or all meaningful pipeline is effectively
  frozen / non-actionable

### Pipeline Interpretation Rules

Use the following evidence in priority order:

1. explicit coverage versus a known target
2. stalled-deal share and timing drag
3. recency of deal activity
4. concentration in one or two large deals
5. source quality / attribution confidence

If the business has very short runway and HubSpot pipeline is stale, it is
reasonable for Pipeline Health to score `D` or `F` even if nominal raw pipeline
value looks large.

## Direction Arrows

Use the relevant source-specific snapshots when available.

- QuickBooks-driven dimensions may use `qb-setup`, `qb-snapshot`, and
  `qb-weekly` snapshots the same way `skills/12-health-scoring/SKILL.md` does.
- `Pipeline Health` may use `hub-weekly` snapshots when available.
- If no comparable history exists for a dimension, use `?`.
- If a prior comparable snapshot exists and the dimension is materially
  unchanged, use `→`.

## Overall Grade

- Compute from scored dimensions only; exclude `N/A`
- Weight `Cash Runway` 2x
- Weight `Revenue Activity` 2x when it is scored
- Weight all other scored dimensions 1x

Map numeric average to:

- `A`: >= 4.5
- `B`: >= 3.5 and < 4.5
- `C`: >= 2.5 and < 3.5
- `D`: >= 1.5 and < 2.5
- `F`: < 1.5

Use `Overall: N/A` only if fewer than 2 dimensions can honestly be scored.

## Tone Rules

- This report should upgrade cleanly from the QuickBooks-only version, not read
  like a completely different product.
- If Pipeline Health is the only new scored dimension, say so plainly.
- If Stripe changes the interpretation of a grade, explain that in the narrative,
  not by silently changing the grading rules.
