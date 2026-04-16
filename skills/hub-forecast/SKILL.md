---
name: hub-forecast
description: >
  This skill should be used when the user says "/revisor:hub-forecast", "forecast
  my pipeline", "predict HubSpot revenue", or "show conservative, moderate, and
  optimistic pipeline forecast". It produces a read-only HubSpot revenue forecast.
metadata:
  version: "0.1.0"
---

# Revisor HubSpot Forecast

Your job is to forecast likely pipeline outcomes from HubSpot using current open
deals, historical close rates, and cycle time when available.

Use the shared rules from:

- `skills/04-pipeline-analytics/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only HubSpot only.
- Read `.revisor/context.json` if present.
- Do not write files from `/revisor:hub-forecast` unless the user explicitly asks to save the forecast.
- Do not imply cash timing or runway; this is a pipeline forecast, not a cash forecast.
- When a connector view is unavailable, say `unavailable from the current connector`.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Confirm safe read access to:
   - open deals
   - enough historical closed won/lost deals to estimate close behavior
3. If historical data is too thin for confident forecasting, still give an honest low-confidence range rather than inventing precision.

## Default Horizon

- Default to the next 3 month-end points or the next quarter.
- If the user asks for a different horizon, honor it when the available deal timing supports it.

## Forecast Tasks

- build conservative, moderate, and optimistic forecast scenarios
- use weighted open pipeline as the main baseline
- incorporate expected close timing when close dates or historical cycle time support it
- compare the scenarios to any explicit sales target in `.revisor/context.json`
- flag stalled or over-concentrated deals that make the forecast fragile

## Output Structure

Respond in this order:

1. `Revisor HubSpot Forecast`
2. analysis scope used
3. forecast assumptions
4. at-a-glance metrics
5. scenario table
6. what changes the forecast most
7. blind spots
8. next step

Use `skills/11-proactive-analysis/SKILL.md` to keep the summary focused on the
single biggest forecast risk or opportunity.
