---
name: qb-snapshot
description: >
  This skill should be used when the user says "/revisor:qb-snapshot", "save a
  snapshot", "capture current QuickBooks metrics", or "write a Revisor
  snapshot". It writes a compact, schema-valid point-in-time snapshot artifact.
metadata:
  version: "0.1.0"
---

# Revisor QuickBooks Snapshot

Your job is to capture the current QuickBooks-derived state in one compact,
diff-friendly JSON snapshot.

Use the shared rules from:

- `skills/02-cash-flow-forecasting/SKILL.md`
- `skills/03-financial-health/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only QuickBooks only. Never call `quickbooks-profile-info-update` or `quickbooks-transaction-import`.
- Read `.revisor/context.json` if present.
- Do not change `.revisor/context.json` from this command.
- Write exactly one new canonical snapshot file under `.revisor/snapshots/`.
- Keep the snapshot compact and diff-friendly. Do not dump raw connector payloads.
- Do not imply invoice status, AR/AP aging, vendor detail, customer concentration, or class tracking.
- When a connector view is unavailable, say `unavailable from the current connector` rather than implying the value is zero or absent in the business.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Optionally load the latest `.revisor/snapshots/*.json` only to help choose concise alerts/highlights. Do not rewrite old snapshots.
3. Confirm these tools are available:
   - `company-info`
   - `profit-loss-quickbooks-account`
   - `cash-flow-quickbooks-account`
4. If any required tool is missing, stop with a clear unblock message and do not write a partial snapshot.
5. Call `company-info`.
6. Pull a trailing 12 complete month P&L window:
   - if today is mid-month, end at the last day of the prior month
   - otherwise end today
7. Pull cash flow twice:
   - same trailing 12 complete month window for comparable operating picture
   - a fresh window ending today so `cashAtEnd` is as current as the connector allows

## Snapshot File

Write one timestamped file to:

- `.revisor/snapshots/<UTC timestamp>-qb-snapshot.json`

Use:

- `schema_version: "revisor.snapshot.v1"`
- `flow_slug: "qb-snapshot"`

The file must match `contracts/snapshot.schema.v1.json` exactly.

## Snapshot Content Rules

### `sources`

- Must be an array, not an object.
- Include one QuickBooks source record with:
  - `system`
  - `account_id`
  - `pulled_at`
  - `date_range`
  - `capabilities_used`
- Use `date_range` for the trailing comparable operating window.
- Do not stretch `date_range.to` to today's cash refresh if the P&L window ends
  at the prior month-end; capture the fresher cash date in
  `metrics.cash_balance_as_of` instead.
- Example on a mid-month run:
  - `date_range.from`: `2025-04-01`
  - `date_range.to`: `2026-03-31`
  - `metrics.cash_balance_as_of`: `2026-04-15`

### `metrics`

Always include:

- `cash_balance`
- `cash_balance_as_of`
- `trailing_revenue`
- `gross_profit`
- `total_expenses`
- `net_income`
- `gross_margin`
- `net_margin`
- `runway_months`

When supported, also include:

- `periodic_expenses_next_60_days`

Formatting rules:

- All money fields must use `{ "currency": "USD", "amount": <number> }`.
- `cash_balance` must come from the freshest cash-flow window ending today and must be interpreted as period-end cash, not a live bank balance.
- Use `monthlyBreakdown.expenseAccounts`, not `expenseAccountsAggregated`, for expense reasoning.
- If revenue is zero, set `gross_margin` and `net_margin` to `0` and explain the limitation in an alert rather than using `null`.

### `runway_months`

- Must contain only `best`, `base`, and `worst`.
- Compute using the same scenario logic as the shared cash-flow skill:
  - include `confirmed` and `assumed` periodic expenses by default when `include_in_forecast` is true
  - exclude `excluded` items
  - use month-by-month burn, not a naive flat average when history supports better detail
- If current context leaves effectively no recurring monthly burn after exclusions, use honest values and put the nuance in alerts/highlights, not in extra schema fields.

### `periodic_expenses_next_60_days`

- Include only items with `include_in_forecast: true` whose `next_expected` falls within the next 60 days.
- Each item must use:
  - `vendor`
  - `category`
  - `expected_on`
  - `amount`

## Alerts And Highlights

Keep both sections concise.

### Alerts

- Include 1 to 5 compact alert objects.
- Use shared QuickBooks-first alert thresholds.
- Good candidates:
  - cash window / period-end cash caveat
  - cash-floor risk
  - runway below threshold
  - material assumed recurring item due soon
  - margins not meaningful because revenue is zero
  - connector blind spots when they materially affect interpretation

### Highlights

- Include 1 to 5 short highlight objects.
- Each highlight must be an object with at least `message`, and optionally `category` and `direction`.
- Prefer durable observations such as:
  - cash improved or declined
  - expense mix concentrated in one category
  - no recurring monthly burn remains after exclusions
  - current snapshot materially unchanged from the prior one

## Comparison To Prior Snapshot

If a prior snapshot exists:

- compare current cash, expenses, runway, and near-term periodic expenses
- if nothing materially changed, it is fine to include a compact `info` alert or highlight stating that
- do not mutate or overwrite the earlier snapshot

## Output

After writing the file, reply briefly with:

1. `Revisor QuickBooks Snapshot`
2. analysis windows used
3. key metrics
4. file written
5. one-sentence note about whether anything materially changed versus the prior snapshot, if a prior snapshot existed

Do not turn `/revisor:qb-snapshot` into a long narrative diagnosis. Its primary job is writing the artifact.
