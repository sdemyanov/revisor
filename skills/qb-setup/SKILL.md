---
name: qb-setup
description: >
  This skill should be used when the user says "/revisor:qb-setup", "set up
  Revisor for QuickBooks", "initialize Revisor", or "scan my QuickBooks account".
  It builds or refreshes the local Revisor context, saves the first snapshot, and
  asks only the highest-value follow-up questions.
metadata:
  version: "0.1.0"
---

# Revisor QuickBooks Setup

Your job is to create or refresh a first-pass Revisor workspace from the current
QuickBooks connection.

Use the shared rules from:

- `skills/01-business-context/SKILL.md`
- `skills/02-cash-flow-forecasting/SKILL.md`
- `skills/03-financial-health/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only QuickBooks only. Never call `quickbooks-profile-info-update` or `quickbooks-transaction-import`.
- Stay inside the current workspace. Write only under `.revisor/`.
- Preserve user-authored context where possible.
- Do not imply invoice status, AR/AP aging, vendor detail, customer concentration, or class tracking.
- Treat QuickBooks recurring detections as category-level heuristics unless the user confirms them.
- When a connector view is unavailable, say `unavailable from the current connector` rather than implying the value is zero or absent in the business.

## Required QuickBooks Reads

1. Load existing `.revisor/context.json` if it exists.
2. Confirm these tools are available:
   - `company-info`
   - `profit-loss-quickbooks-account`
   - `cash-flow-quickbooks-account`
3. If any required tool is missing, stop with a clear unblock message and do not write partial files.
4. Call `company-info`.
5. Pull a trailing 12 complete month P&L window:
   - if today is mid-month, end at the last day of the prior month
   - otherwise end today
6. Pull cash flow for:
   - the same trailing 12 complete month window
   - a fresh window ending today, so `cashAtEnd` is as current as the connector allows

## First-Pass Context Rules

Write or refresh `.revisor/context.json` with this shape:

- `schema_version: "revisor.context.v1"`
- `business_profile`
- `product_lines`
- `strategic_context`
- `key_clients`
- `targets`
- `source_accounts`
- `entity_mappings`
- `periodic_expenses`
- `last_updated`

Match `contracts/context.schema.v1.json` exactly. In particular:

- `strategic_context` must always be an array, even if empty.
- `source_accounts` entries must use:
  - `system`
  - `account_id`
  - `account_name`
  - `status`
  - optional `connected_at` as `YYYY-MM-DD`
  - optional `provenance`
  - optional `metadata`
- `last_updated` must be a plain date string `YYYY-MM-DD`, not a timestamp.

### Mapping Guidance

- `business_profile.type`: infer honestly from revenue and industry signals
- `business_profile.detected_from`: explain the evidence
- `business_profile.confirmed_by_user`: false unless already confirmed
- `product_lines`: only include material or user-confirmed lines
- `strategic_context`, `key_clients`: keep empty if QuickBooks cannot prove them and the user has not provided them
- `strategic_context`: use `[]` when empty, never an empty string
- `targets`: preserve existing targets; otherwise initialize as an empty object
- `source_accounts`: always include the connected QuickBooks account using schema field names
- `entity_mappings`: initialize as `[]` for QuickBooks-only setup

## Recurring Expense Detection

Use `profit-loss-quickbooks-account.monthlyBreakdown`.

Rules:

- Ignore `expenseAccountsAggregated`; use `expenseAccounts` and top-level month totals.
- Only consider materially sized categories. Default floor: about $500 annual spend unless the context already tracks a smaller item.
- Auto-add only category-level candidates as `assumed`.
- Preserve existing `confirmed` and `excluded` items.
- Keep exclusions sticky; do not re-add the same category as `assumed` on the same run.

Candidate heuristics:

- `annual` or `semiannual`: 1 or 2 material months dominate the annual spend
- `quarterly`: 3 to 5 nonzero months with roughly quarterly spacing
- `monthly`: at least 6 nonzero months with reasonably stable amounts

If the user later confirms an item was not truly recurring, keep the record with
`status: "excluded"` and use `frequency: "irregular"` when that is the most honest label.

For setup, add only the top 5 most material new candidates.

Each inferred candidate should include:

- `vendor`: honest bucket label like `Software renewals bucket`
- `category`
- `amount_last`
- `frequency`
- `status: "assumed"`
- `include_in_forecast: true`
- `last_paid`
- `next_expected`
- `confidence`
- `notes`
- `source: "inferred from QuickBooks monthly expense categories"`
- `date`
- `last_reviewed`

Date formatting rules:

- `last_paid`, `next_expected`, `date`, and `last_reviewed` must be full dates `YYYY-MM-DD`
- do not write partial months like `2025-06`
- if only the month is known, choose an honest anchor date and explain that approximation in `notes`

## Snapshot Write

Write one timestamped snapshot to:

- `.revisor/snapshots/<UTC timestamp>-qb-setup.json`

Use:

- `schema_version: "revisor.snapshot.v1"`
- `flow_slug: "qb-setup"`

Snapshot fields should stay compact and honest. Include:

- `captured_at`
- `sources`
- `metrics.cash_balance`
- `metrics.cash_balance_as_of`
- `metrics.trailing_revenue`
- `metrics.gross_profit`
- `metrics.total_expenses`
- `metrics.net_income`
- `metrics.gross_margin`
- `metrics.net_margin`
- `metrics.runway_months`
- `metrics.periodic_expenses_next_60_days`
- `alerts`
- `highlights`

Match `contracts/snapshot.schema.v1.json` exactly. In particular:

- `sources` must be an array, not an object
- each source record should include:
  - `system`
  - `account_id`
  - `pulled_at`
  - optional `date_range` with `from` / `to`
  - optional `capabilities_used`
- money fields must use `{ "currency": "USD", "amount": <number> }`
- `gross_margin` and `net_margin` must be numbers; if revenue is zero, use `0` and explain the limitation in an alert rather than writing `null`
- `runway_months` may contain only `best`, `base`, and `worst`
- each `periodic_expenses_next_60_days` item must use:
  - `vendor`
  - `category`
  - `expected_on` as a full date
  - `amount` as a money object
- each highlight must be an object with at least `message`, and optionally `category` and `direction`

## Forecast And Alert Logic

- Use period-end cash from the freshest cash-flow window ending today.
- Label it as period-end cash, not a live bank balance.
- Build monthly burn from the P&L `monthlyBreakdown`.
- Base runway: recent median burn plus included recurring events.
- Best runway: about 15% better than base recurring burn.
- Worst runway: about 20% worse than base recurring burn.
- Include `confirmed` and `assumed` recurring expenses by default when `include_in_forecast` is true.
- Exclude `excluded` items.
- If revenue is zero, set gross and net margins to `0` and add an explanatory alert instead of using `null`.

Use QuickBooks-only alert rules:

- critical if base runway < 3 months
- critical if worst runway < 1 month
- warning if base runway < 6 months
- warning if worst runway < 3 months
- warning if a material recurring expense is due within 30 days
- warning if revenue declined 2 consecutive active months
- info if setup is creating the first baseline and trends are therefore limited

When you need to preserve narrative details like blind spots, unusual bookkeeping gaps, or runway-method caveats:

- put them in `alerts` or `highlights`
- do not add ad hoc keys that the snapshot schema does not define

## Response

Build the `what needs attention`, `what looks healthy`, `coming up`, and
follow-up-question prioritization using `skills/11-proactive-analysis/SKILL.md`.

Respond using this structure:

1. `Revisor QuickBooks Setup`
2. analysis window used
3. at-a-glance metrics
4. what needs attention
5. what looks healthy
6. coming up
7. files written
8. 3 to 5 highest-value follow-up questions

Follow-up questions should focus on:

- confirming the business type or product mix
- excluding false-positive recurring expenses
- confirming major recurring obligations
- setting a runway threshold or target
- adding strategic context or key clients that QuickBooks cannot reveal

Skip any question already answered in `.revisor/context.json`.
