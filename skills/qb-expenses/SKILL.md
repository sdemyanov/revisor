---
name: qb-expenses
description: >
  This skill should be used when the user says "/revisor:qb-expenses", "show my
  expense breakdown", "analyze QuickBooks expenses", or "drill into expense
  categories". It produces a read-only expense-category analysis from QuickBooks.
metadata:
  version: "0.1.0"
---

# Revisor QuickBooks Expenses

Your job is to explain where money is going at the QuickBooks category level and
surface the categories that deserve attention.

Use the shared rules from:

- `skills/03-financial-health/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only QuickBooks only. Never call `quickbooks-profile-info-update` or `quickbooks-transaction-import`.
- Read `.revisor/context.json` if present so recurring-expense statuses can be explained.
- Do not write files from `/revisor:qb-expenses` unless the user explicitly asks to save the analysis.
- Do not imply vendor-level detail; this command works at the chart-of-accounts category level only.
- When a connector view is unavailable, say `unavailable from the current connector`.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Confirm `company-info` and `profit-loss-quickbooks-account` are available.
3. If a required tool is missing, stop with a clear unblock message.
4. Call `company-info`.
5. Pull a trailing 12 complete month P&L window:
   - if today is mid-month, end at the last day of the prior month
   - otherwise end today

## Analysis Rules

- Use `reportData.data.rows` and `monthlyBreakdown.expenseAccounts`.
- Ignore `expenseAccountsAggregated`.
- Treat categories as chart-of-accounts groupings, not vendors.
- Show the top categories by trailing 12-month spend.

## Trend / Anomaly Rules

Use recent monthly category history to flag noteworthy changes.

- Flag a category when the current or most recent active month differs by roughly 20% or more from its prior 3 active-month average.
- Do not over-alert on tiny dollar changes. If the category is very small, mention the change as context rather than a major issue.
- If a spike is already explained by `periodic_expenses` or an `excluded` one-off, say that instead of treating it as unresolved.

## Recurring-Expense Context

For any category that appears in `periodic_expenses`:

- `confirmed`: say it is a known recurring obligation
- `assumed`: say it is included by default unless excluded
- `excluded`: say the category was reviewed and intentionally removed from forecasts

## Output Structure

Use `skills/11-proactive-analysis/SKILL.md` to keep the notable changes and next
step focused on the single most useful drill-down outcome.

Respond in this order:

1. `Revisor QuickBooks Expenses`
2. analysis window used
3. top expense categories
4. notable category changes
5. recurring-expense context
6. blind spots
7. next step

## Presentation Rules

- Keep the analysis concise and drill-down oriented.
- Show exact dollar values where supported.
- If the business is dormant or winding down, frame the categories as maintenance / closure costs rather than operating scale.
- End with one concrete follow-up, for example:
  - confirm or exclude an assumed recurring category
  - run `/revisor:qb-forecast` to see the cash impact
  - run `/revisor:qb-report` for a shareable health view
