---
name: biz-forecast
description: >
  This skill should be used when the user says "/revisor:biz-forecast",
  "forecast the whole business", "pipeline to cash forecast", or "combine
  QuickBooks, HubSpot, and Stripe into one forecast". It produces a read-only
  cross-source forecast.
metadata:
  version: "0.1.0"
---

# Revisor Business Forecast

Your job is to forecast the business using the connected sources without
pretending weak pipeline or pre-revenue product signals are dependable cash.

Use the shared rules from:

- `skills/02-cash-flow-forecasting/SKILL.md`
- `skills/04-pipeline-analytics/SKILL.md`
- `skills/06-subscription-intelligence/SKILL.md`
- `skills/07-cross-source-synthesis/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only only. Never call mutating connector tools.
- Read `.revisor/context.json` if present.
- Do not write files from `/revisor:biz-forecast` unless the user explicitly
  asks to save the forecast.
- Do not treat pipeline as cash.
- Do not assume future Stripe MRR appears without explicit evidence or a stated
  scenario.
- When a connector view is unavailable, say `unavailable from the current connector`.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Detect connected sources from `source_accounts`.
3. Use the freshest safe reads available from each connected source:
   - QuickBooks for starting cash, recurring baseline, and obligations
   - HubSpot for open pipeline and timing confidence
   - Stripe for current MRR, churn, and payment-health context
4. If only one source is connected, still provide a useful source-aware forecast
   and say that the cross-source view is limited.

## Default Horizon

- Default to the next 3 month-end points or next quarter.
- If the user asks for a different horizon, honor it when the available source
  timing supports it.

## Scenario Rules

Build conservative, base, and optimistic scenarios.

### Conservative

- QuickBooks burn and obligations use a cautious view
- HubSpot contributes no dependable near-term conversion unless timing support is
  strong
- Stripe contributes current MRR only; if current MRR is zero, keep it zero

### Base

- QuickBooks baseline follows the recent operating and obligation pattern
- HubSpot contributes only the portion of pipeline that is honestly actionable in
  the modeled horizon
- If HubSpot has no close history or all deals are materially stalled, base case
  should usually count pipeline contribution as zero and explain why
- Stripe contributes current MRR only unless there is explicit evidence of new
  paid activation already in progress

### Optimistic

- Allow plausible, not theatrical, upside from pipeline conversion or first
  subscriber activation
- If all available evidence says pipeline is frozen and current MRR is zero, keep
  optimism constrained and label it low-confidence upside

## Output Structure

Respond in this order:

1. `Revisor Business Forecast`
2. sources used
3. forecast assumptions
4. at-a-glance starting position
5. scenario table
6. what changes the forecast most
7. blind spots
8. next step

## Presentation Rules

- Keep the forecast decision-oriented.
- Distinguish current cash, current recurring revenue, and speculative upside.
- If near-term survival depends more on financing than on current pipeline or
  MRR, say so directly.
- End with one concrete next action.
