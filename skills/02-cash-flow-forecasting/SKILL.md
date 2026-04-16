---
name: 02-cash-flow-forecasting
description: >
  Shared Revisor skill for cash runway and cash-forecast reasoning using the
  currently proven QuickBooks surface.
metadata:
  version: "0.1.0"
  scope: "shared"
---

# Revisor Cash-Flow Forecasting

Use this skill for `/revisor:qb-setup`, `/revisor:qb-health`, `/revisor:qb-forecast`,
`/revisor:qb-whatif`, and `/revisor:qb-weekly`.

## Truths About The Current Connector

- `cash-flow-quickbooks-account` returns period-bounded cash flow and `cashAtEnd`.
- `cashAtEnd` is period-end cash for the requested window, not a live bank balance.
- `profit-loss-quickbooks-account` returns monthly P&L detail via `monthlyBreakdown`.
- `monthlyBreakdown.expenseAccounts` is usable; `expenseAccountsAggregated` appears to double-count and should not be trusted for math.
- There is no invoice, AR/AP, vendor, or customer-level input in the QuickBooks-only MVP.

## Required Inputs

- A trailing 12 complete month P&L window
- A cash-flow window ending today when possible, so `cashAtEnd` is as current as the connector allows
- `.revisor/context.json` if present

## Monthly Burn Series

Build a month-by-month operating series from `monthlyBreakdown`:

- `monthly_net = totalIncome - totalExpenses`
- `monthly_burn = max(totalExpenses - totalIncome, 0)`
- Preserve zero or profitable months; do not smooth them away.
- Keep recurring expenses as explicit spikes instead of flattening them into a naive average.

If fewer than 3 months show meaningful activity, label the forecast as low-confidence.

## Scenario Rules

### Base Case

- Use the median of the last 6 monthly burn values when at least 3 active months exist.
- If activity is sparse, fall back to the average monthly burn across the full trailing 12 month window.
- Include all `periodic_expenses` with `include_in_forecast: true`.

### Best Case

- Improve the non-periodic recurring burn by roughly 15% versus base.
- Still include `confirmed` periodic expenses.
- Include `assumed` periodic expenses unless the user has excluded them.

### Worst Case

- Worsen the non-periodic recurring burn by roughly 20% versus base.
- Include all `confirmed` and `assumed` periodic expenses in full.
- Do not include `excluded` items.

If the business is consistently cash-positive, say the runway is effectively greater than 12 months under current assumptions instead of inventing a false ceiling.

## Runway Simulation

- Start from `cashAtEnd` taken from the freshest window ending today when available.
- Simulate month by month rather than dividing cash by a flat burn rate.
- Report best, base, and worst runway in months.
- Round user-facing values sensibly, but keep internal calculations honest.

## Periodic Expense Rules

- `confirmed` and `assumed` items count by default when `include_in_forecast` is true.
- `excluded` items never count unless the user explicitly re-enables them.
- Surface periodic expenses due within 60 days as upcoming events.
- Label `assumed` items clearly as heuristics, not facts.

## Confidence And Caveats

Always say when any of these are true:

- cash is period-end, not live bank cash
- recent months are sparse or zero-heavy
- recurring expenses are inferred at category level only
- the connector cannot prove AR/AP, invoices, vendor detail, or customer concentration
