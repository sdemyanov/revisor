---
name: 04-pipeline-analytics
description: >
  Shared Revisor skill for HubSpot pipeline analytics, weighted forecasting,
  stalled-deal logic, and pipeline-health interpretation.
metadata:
  version: "0.1.0"
  scope: "shared"
---

# Revisor Pipeline Analytics

Use this skill for:

- `/revisor:hub-setup`
- `/revisor:hub-pipeline`
- `/revisor:hub-forecast`
- `/revisor:hub-weekly`
- `/revisor:hub-velocity`
- `/revisor:hub-sources`
- later `/revisor:biz-*` cross-source skills

## Connector Truths

- Only use HubSpot objects and fields that are actually available in the current
  connector session.
- If deals are available but activities or line items are not, still provide
  stage, amount, and forecast analysis without inventing the missing pieces.
- If required reads are missing, stop with a clear unblock message instead of
  guessing.

## Core Inputs

When available, use:

- open deals with stage, amount, owner, create date, and expected close date
- historical closed won and closed lost deals
- company and contact linkage
- activity timestamps
- lead source or attribution properties

Default historical window:

- trailing 12 complete months
- if less than 12 months are available, use all available history and say so

## Core Metrics

### Open Pipeline

- `open_pipeline_value`: total amount across active open deals
- `deal_count`: count of active open deals
- `stage_mix`: deal count and pipeline value by stage

### Win Rate

- Prefer stage-aware historical win rates when enough comparable history exists.
- If stage-specific history is thin, fall back to overall win rate and label the
  result low-confidence.
- Do not fabricate precision when only a handful of historical deals exist.

### Weighted Pipeline

- `weighted_pipeline_value = sum(deal_amount * close_probability)`
- Prefer historical probabilities over static defaults.
- If only coarse history exists, use honest rounded probabilities and say that.

### Pipeline Coverage

- If an explicit quarterly sales target exists in `.revisor/context.json`, compute:
  - `pipeline_coverage_ratio = weighted_pipeline_value / quarterly_target`
- If no suitable target exists, say coverage ratio is unavailable until the user
  sets a target.

### Deal Concentration

- Flag when one active deal is more than roughly 20% of open pipeline value.
- This is pipeline concentration, not customer revenue concentration.

## Cycle-Time And Stalled Logic

- Use stage duration when stage history is available.
- If stage duration is not available, fall back to total deal age or time since
  last meaningful activity.
- A deal is `stalled` when it sits in a stage for more than about 2x the
  historical median or average for that stage.
- If stage-level timing history is unavailable, say stalled logic is approximate.

## Velocity Rules

- Prefer median days to close over mean when historical wins are sparse or skewed.
- If historical won-deal timing is unavailable, fall back to:
  - deal age
  - days past expected close
  - time since last meaningful activity
- Flag stage drag when a stage or small set of deals carries most of the delay.
- Be explicit about whether the velocity read is:
  - `high confidence`
  - `directional`
  - `too sparse to trust`

## Source Analysis Rules

- Use the best available lead-source or attribution property only if it is
  materially populated.
- Show `unknown` or `unattributed` share honestly when source coverage is weak.
- Distinguish:
  - source mix in current open pipeline
  - source mix in closed won history
- Do not imply true ROI or CAC from HubSpot-only data.

## Forecast Scenarios

For HubSpot-only forecasting:

- `conservative`: close rates about 15% worse than current historical rates and
  cycle times about 20% longer
- `moderate`: current historical rates and cycle times
- `optimistic`: close rates about 10% better and cycle times about 15% shorter

Keep scenarios plausible, not theatrical.

## Healthy Signals

Good healthy signals include:

- improving close rates
- shorter cycle time
- diversified stage mix
- no stalled deals
- weighted pipeline comfortably above target
- improving source quality with low unattributed share

## Blind Spots

Say these explicitly when relevant:

- product line / line item mix may be unavailable
- attribution quality may be limited by missing source properties
- support load and profitability require cross-source data
- cash timing requires QuickBooks for a true pipeline-to-cash view
