---
name: qb-forecast
description: >
  This skill should be used when the user says "/revisor:qb-forecast", "show my
  cash forecast", "forecast cash from QuickBooks", or "project the next few
  months". It produces a read-only scenario forecast from saved context plus
  fresh QuickBooks data.
metadata:
  version: "0.1.0"
---

# Revisor QuickBooks Forecast

Your job is to produce a practical, scenario-based cash forecast from QuickBooks
plus saved Revisor context.

Use the shared rules from:

- `skills/02-cash-flow-forecasting/SKILL.md`
- `skills/03-financial-health/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only QuickBooks only. Never call `quickbooks-profile-info-update` or `quickbooks-transaction-import`.
- Read `.revisor/context.json` if present.
- You may read the newest `.revisor/snapshots/*.json` for recent comparison, but do not write a new snapshot from `/revisor:qb-forecast`.
- Do not change `.revisor/context.json` from this command.
- Do not imply invoice status, AR/AP aging, vendor detail, customer concentration, or class tracking.
- When a connector view is unavailable, say `unavailable from the current connector` rather than implying the value is zero or absent in the business.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Optionally load the newest `.revisor/snapshots/*.json` for recent context.
3. Confirm these tools are available:
   - `company-info`
   - `profit-loss-quickbooks-account`
   - `cash-flow-quickbooks-account`
4. If any required tool is missing, stop with a clear unblock message and do not improvise from stale files alone.
5. Call `company-info`.
6. Pull a trailing 12 complete month P&L window:
   - if today is mid-month, end at the last day of the prior month
   - otherwise end today
7. Pull cash flow twice:
   - same trailing 12 complete month window for comparable operating picture
   - a fresh window ending today so `cashAtEnd` is as current as the connector allows

## Default Forecast Horizon

- Default to the next 6 month-end points.
- If the user explicitly asks for a different horizon, honor it.
- Use month-end positions, not daily interpolation.

## Core Forecast Tasks

### 1. Establish The Starting Point

- Starting cash is `cashAtEnd` from the freshest cash-flow window ending today.
- Label it as period-end cash, not a live bank balance.
- State the forecast start date clearly.

### 2. Build The Monthly Operating Baseline

Use `profit-loss-quickbooks-account.monthlyBreakdown`.

Rules:

- Use `expenseAccounts`, not `expenseAccountsAggregated`.
- Build the recent monthly operating pattern from active months only when appropriate.
- Preserve zero months honestly; do not smooth them away if the business is dormant.
- If the business is marked as dormant, winding down, or in dissolution, do not invent future recurring burn that the context has explicitly excluded.

For revenue assumptions:

- If trailing revenue is meaningfully positive, use recent monthly history as the baseline.
- If trailing revenue is zero, keep revenue at zero unless saved context explicitly says a future launch or restart is planned.

For recurring operating burn:

- Base case: recent median active-month recurring burn, or the honest sparse-data fallback when activity is limited.
- Best case: about 15% better than base recurring burn.
- Worst case: about 20% worse than base recurring burn.

If current context leaves effectively no recurring monthly burn after exclusions, say so and keep the month-to-month line flat except for known periodic events.

### 3. Layer In Periodic Expenses As Labeled Events

- Include all `periodic_expenses` where `include_in_forecast` is true.
- Include both `confirmed` and `assumed` items by default.
- Exclude `excluded` items.
- Place periodic expenses into the exact forecast month suggested by `next_expected`.
- Label `assumed` items clearly as heuristics.

If a periodic item has only approximate timing, keep the timing honest:

- use the best supported month
- note the uncertainty in the event list

### 4. Respect Targets From Context

If `.revisor/context.json` has targets, use them.

Priority order:

1. If `targets.cash_floor` exists, treat projected cash dropping below that floor as the primary threshold.
2. If a scalar runway target exists such as `runway_threshold_months`, use it as a secondary interpretation layer.
3. Fixed critical thresholds from the shared alert rules still apply unless the business status clearly changes the framing.

If the business is marked as dormant, winding down, or in dissolution:

- frame the forecast around preserving cash, meeting final obligations, and staying above the cash floor
- avoid startup-growth framing unless the context says the business is restarting
- if a scenario depends on an external legal, tax, or filing outcome that the connector cannot verify, label it as an unconfirmed external assumption rather than a known fact

### 5. Produce Best / Base / Worst Scenarios

For each month-end in the horizon:

- start from the prior month-end cash
- add scenario revenue assumption
- subtract recurring operating burn for that scenario
- subtract any periodic expenses due that month

Keep the scenarios honest:

- best should be meaningfully but plausibly better
- base should be the main planning case
- worst should be conservative, not theatrical

If the real risk is one lumpy obligation rather than ongoing burn, say that clearly.

### 6. Identify The Decision Point

After building the table, identify:

- the lowest cash point in each scenario
- whether and when cash crosses zero
- whether and when cash crosses the configured cash floor
- the first month where intervention becomes necessary

### 7. End With One Concrete Mitigation

Tailor the mitigation to the largest visible risk, for example:

- confirm or exclude an assumed recurring expense
- arrange an owner infusion before the threshold month
- defer a planned spend
- cut or renegotiate a recurring category
- if no near-term risk is visible, state the next useful monitoring action

## Unsupported Areas

Always state plainly that the current QuickBooks connector cannot provide:

- invoice status
- AR aging
- AP aging
- vendor-level expenses
- customer revenue concentration
- class / item / product tracking

Silence on those topics reflects the connector, not the business.

When relevant, also say that obligations outside QuickBooks such as dissolution filings,
state fees, registered-agent bills, or closure costs may still exist even if they are
not visible in the current forecast.

## Output Structure

Use `skills/11-proactive-analysis/SKILL.md` to decide the single most
decision-relevant takeaway and the one concrete next step.

Respond in this order:

1. `Revisor QuickBooks Forecast`
2. analysis windows used
3. forecast assumptions
4. at-a-glance metrics
5. month-by-month forecast table
6. key events on the timeline
7. what this means
8. blind spots
9. next step

## Presentation Rules

- Default to a 6-month horizon unless the user asked for a different one.
- Use a markdown table with month columns and scenario rows.
- Show best, base, and worst scenario values for each month-end.
- Mark the month where cash crosses zero or the configured cash floor.
- If revenue is zero, say so plainly and do not over-interpret margins.
- If cash-floor risk is the real problem, lead with that ahead of generic runway language.
- If no recurring monthly burn remains after exclusions, avoid fake precision and say the forecast is dominated by the next known lumpy obligation.
- Keep conclusions inside the modeled horizon. Say `flat through the current forecast horizon` rather than `indefinitely` unless the user explicitly asked for that extrapolation.
- Do not make broad jurisdiction or regulatory claims such as how `many states` handle dissolution, franchise tax, or waivers unless the user has supplied jurisdiction-specific facts. Frame those as external assumptions to confirm.
- Do not use overconfident phrases like `indefinite stability` or `nothing else can go wrong`. If the outlook depends on assumptions or blind spots, say `under the current forecast assumptions` or `no further known cash events are visible in the current forecast`.
- End with one concrete mitigation or decision prompt.

## Files

Do not write files from `/revisor:qb-forecast` unless the user explicitly asks to save the forecast.
