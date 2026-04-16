---
name: qb-health
description: >
  This skill should be used when the user says "/revisor:qb-health", "check my
  financial health", "analyze my QuickBooks health", or "run a Revisor health
  check". It produces a read-only QuickBooks diagnostic using saved context plus
  fresh connector data.
metadata:
  version: "0.1.0"
---

# Revisor QuickBooks Health

Your job is to run the full QuickBooks-only Revisor diagnostic without mutating
state.

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
- Read the latest snapshot if present, but do not write a new snapshot from `/revisor:qb-health`.
- Do not change `.revisor/context.json` from this command.
- Do not imply invoice status, AR/AP aging, vendor detail, customer concentration, or class tracking.
- When a connector view is unavailable, say `unavailable from the current connector` rather than implying the value is zero or absent in the business.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Optionally load the newest `.revisor/snapshots/*.json` for comparison.
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

## Core Diagnostic Tasks

### 1. Resolve Profit Versus Cash Explicitly

Explain the difference between:

- trailing net income from P&L
- net cash increase from cash flow
- financing activity such as owner investment
- current period-end cash

If owner funding or financing activity is masking weak operating economics, say so directly.

### 2. Compute Best / Base / Worst Runway

- Use the cash-flow window ending today for starting cash.
- Label cash as period-end cash, not a live bank balance.
- Build monthly burn from `monthlyBreakdown` using `expenseAccounts`, not `expenseAccountsAggregated`.
- Include all `periodic_expenses` with `include_in_forecast: true`.
- Include both `confirmed` and `assumed` items by default.
- Exclude `excluded` items.

Scenario rules:

- base: recent median active-month burn when enough activity exists, otherwise the honest sparse-data fallback
- best: about 15% better than base recurring burn
- worst: about 20% worse than base recurring burn

If the business has effectively no recurring monthly burn after exclusions, do not present fake precision. It is acceptable to say:

- `base runway is not the constraining metric under current assumptions`
- `the next material lumpy obligation is the real risk`

### 3. Respect Targets From Context

If `.revisor/context.json` has targets, use them.

Priority order:

1. If `targets.cash_floor` exists, treat projected cash dropping below that floor as a high-priority health condition.
2. If a scalar runway target exists such as `runway_threshold_months`, use it to interpret runway.
3. Fixed critical thresholds from the shared alert rules still apply unless the business status clearly changes the framing.

If the business is marked as dormant, winding down, or in dissolution:

- still calculate the numbers honestly
- but frame the diagnostic around preserving cash, meeting obligations, and avoiding negative cash, not around growth-stage runway narratives

### 4. Include Expense-Category Mix And Recurring Baseline

Surface:

- top expense categories from the trailing P&L
- the current recurring-expense baseline separated into:
  - `confirmed`
  - `assumed`
  - `excluded`

For `assumed` items:

- say they are included by default unless excluded
- make the confidence and uncertainty explicit

### 5. Compare To Prior Snapshot When Helpful

If a prior snapshot exists:

- compare current cash, expenses, runway, and upcoming recurring obligations
- if nothing materially changed, say that succinctly
- when naming the prior snapshot, prefer the exact snapshot timestamp or say `UTC` explicitly so midnight-boundary runs do not look like a wrong local date
- do not write a new snapshot

## Unsupported Areas

Always state plainly that the current QuickBooks connector cannot provide:

- invoice status
- AR aging
- AP aging
- vendor-level expenses
- customer revenue concentration
- class / item / product tracking

Silence on those topics reflects the connector, not the business.

## Output Structure

Build `What needs attention`, `What looks healthy`, `Coming up`, and `Next step`
using the prioritization from `skills/11-proactive-analysis/SKILL.md`.

Respond in this order:

1. `Revisor QuickBooks Health`
2. analysis windows used
3. at-a-glance metrics
4. what needs attention
5. what looks healthy
6. coming up
7. blind spots
8. next step

## Presentation Rules

- Show at most 3 findings in `What needs attention`.
- Always include at least one healthy signal.
- Use precise numbers where supported.
- If revenue is zero, say margins are not meaningful instead of over-interpreting them.
- If cash-floor risk is the real problem, lead with that ahead of generic runway commentary.
- Do not use overconfident phrases like `indefinite stability` or `nothing else can go wrong`. If the outlook depends on excluded assumptions or connector blind spots, say `under the current forecast assumptions` or `no further known cash events are visible in the current forecast`.
- End with one concrete next action, for example:
  - confirm or exclude an assumed recurring item
  - run `/revisor:qb-forecast`
  - arrange a funding or payment plan for an upcoming obligation
  - run `/revisor:qb-setup` again only if context has materially changed

## Files

Do not write files from `/revisor:qb-health` unless the user explicitly asks to save the analysis.
