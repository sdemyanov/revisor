---
name: qb-weekly
description: >
  This skill should be used when the user says "/revisor:qb-weekly", "run the
  weekly briefing", "generate a weekly QuickBooks briefing", or "do the Revisor
  weekly check". It writes a weekly snapshot and briefing, then returns the
  briefing summary.
metadata:
  version: "0.1.0"
---

# Revisor QuickBooks Weekly

Your job is to run the recurring QuickBooks briefing loop: compare to prior
snapshots, write a new weekly snapshot, write a markdown briefing, and present
the summary to the user.

Use the shared rules from:

- `skills/02-cash-flow-forecasting/SKILL.md`
- `skills/03-financial-health/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`
- `skills/12-health-scoring/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only QuickBooks only. Never call `quickbooks-profile-info-update` or `quickbooks-transaction-import`.
- Read `.revisor/context.json` if present.
- Load recent snapshots from `.revisor/snapshots/` for comparison.
- Write one new canonical snapshot and one new canonical markdown briefing.
- Never overwrite canonical timestamped artifacts.
- When a connector view is unavailable, say `unavailable from the current connector` rather than implying the value is zero or absent in the business.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Load the most recent relevant snapshots, ideally the latest 3, for comparison.
3. Confirm these tools are available:
   - `company-info`
   - `profit-loss-quickbooks-account`
   - `cash-flow-quickbooks-account`
4. If any required tool is missing, stop with a clear unblock message and do not write partial artifacts.
5. Call `company-info`.
6. Pull a trailing 12 complete month P&L window:
   - if today is mid-month, end at the last day of the prior month
   - otherwise end today
7. Pull cash flow twice:
   - same trailing 12 complete month window for comparable operating picture
   - a fresh window ending today so `cashAtEnd` is as current as the connector allows

## Artifact Writes

Write these files:

- `.revisor/snapshots/<UTC timestamp>-qb-weekly.json`
- `.revisor/reports/<UTC timestamp>-briefing.md`

Snapshot rules:

- use `schema_version: "revisor.snapshot.v1"`
- use `flow_slug: "qb-weekly"`
- match `contracts/snapshot.schema.v1.json` exactly
- in `sources[].date_range`, store the trailing comparable operating window
  used for P&L and comparable cash flow, not the fresher cash refresh through
  today
- represent the fresher cash refresh separately via `metrics.cash_balance_as_of`
- if today is mid-month, `sources[].date_range.to` should normally be the last
  day of the prior month, while `metrics.cash_balance_as_of` may still be today
- example on 2026-04-15:
  - `sources[].date_range`: `2025-04-01` to `2026-03-31`
  - `metrics.cash_balance_as_of`: `2026-04-15`

Briefing rules:

- markdown only
- timestamped immutable filename
- concise, readable, and safe to diff over time

## Weekly Logic

### 1. Compare To Prior Snapshots

Use recent snapshots to answer:

- what changed since last week
- whether cash, runway, or obligations improved or worsened
- whether the current state is basically unchanged

If nothing materially changed, say so plainly.

### 2. Build The Weekly Snapshot

Use the same compact metric set as `/revisor:qb-snapshot`:

- cash balance
- cash balance as of date
- trailing revenue
- gross profit
- total expenses
- net income
- gross margin
- net margin
- runway best/base/worst
- periodic expenses next 60 days
- concise alerts
- concise highlights

### 3. Build The Weekly Briefing

The weekly briefing should include:

1. `Revisor QuickBooks Weekly`
2. `What changed`
3. `What needs attention`
4. `What looks healthy`
5. `Coming up`
6. `Blind spots`
7. `Next step`

Rules:

- show at most 3 findings in `What needs attention`
- always include healthy signals
- if context is older than 30 days, include a context-refresh prompt
- lead with the most decision-relevant change, not generic numbers
- if a shareable report would be useful, mention `/revisor:qb-report` at the end
- use the section ordering and prioritization from
  `skills/11-proactive-analysis/SKILL.md`

### 4. Recurring Expense Handling

- include `confirmed` and `assumed` items by default when `include_in_forecast` is true
- exclude `excluded` items
- treat `assumed` items as heuristics and label them clearly
- surface 30-day and 60-day `Coming up` items

### 5. Blind Spots

Always state plainly that the current QuickBooks connector cannot provide:

- invoice status
- AR aging
- AP aging
- vendor-level expenses
- customer revenue concentration
- class / item / product tracking

## Output

After writing both artifacts, return the briefing summary in the same structure as the markdown file and include the two written paths.
