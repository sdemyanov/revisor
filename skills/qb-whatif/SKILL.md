---
name: qb-whatif
description: >
  This skill should be used when the user says "/revisor:qb-whatif", "what
  happens if", "can I afford to hire", "simulate this decision", or "model a
  QuickBooks scenario". It compares the current baseline against one explicit
  modified scenario.
metadata:
  version: "0.1.0"
---

# Revisor QuickBooks What-If

Your job is to compare the current baseline against one explicit modified
scenario using fresh QuickBooks data plus saved Revisor context.

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
- You may read the newest `.revisor/snapshots/*.json` for recent context, but do not write files or snapshots from `/revisor:qb-whatif` unless the user explicitly asks to save the scenario.
- Do not change `.revisor/context.json` from this command.
- Model one primary scenario per run. If the user gave multiple scenarios, pick the main one, say which one you modeled first, and briefly note the others as follow-up options.
- Ask at most 2 narrow clarifying questions only when amount, timing, or horizon is missing and a reasonable default would be too risky.
- If the user references unsupported detail such as a specific customer, vendor, invoice, class, pipeline, AR/AP bucket, or product line that QuickBooks-only mode cannot verify, do not fabricate the underlying baseline. Ask the user for the monthly or one-time cash impact, or use the rough impact they already provided.
- When a connector view is unavailable, say `unavailable from the current connector` rather than implying the value is zero or absent in the business.

## Supported Scenario Types

Support these scenario patterns when the user provides enough detail:

- recurring revenue increase or decrease starting in a given month
- recurring expense increase or decrease starting in a given month
- one-time cash inflow or outflow in a given month
- owner infusion or owner withdrawal
- add, remove, defer, or resize a known periodic expense
- shift the timing of a known obligation
- hiring-style scenarios expressed as annual cost or monthly cost

If the scenario is broader than the current connector can prove, translate it
into one of the patterns above instead of refusing outright.

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

## Scenario Parsing Rules

Parse the user's request into this internal shape:

- scenario label
- start month or event month
- recurring or one-time
- revenue delta, expense delta, financing delta, or periodic-expense adjustment
- horizon override if the user gave one

Defaults:

- If the user does not specify a horizon, use 6 month-end points.
- If a recurring change has no explicit start month, start it on the next full forecast month.
- If a one-time event has no explicit date, place it in the next forecast month.
- If the user asks `can I afford to hire` and gives annual cost but not monthly cost, divide by 12 and treat it as recurring monthly cash outflow.
- If the user asks to waive, remove, or defer a known assumed periodic expense, change it only in the modified scenario. Do not rewrite context.

If the scenario is still too ambiguous after reasonable defaults, ask the
smallest possible clarification, for example:

- `What monthly revenue loss should I use for Client X?`
- `Should the hire start in May or June?`

## Simulation Tasks

### 1. Build The Baseline

Use the same logic as `/revisor:qb-forecast`:

- start from the freshest period-end cash from the cash-flow window ending today
- use recent monthly QuickBooks history for the baseline operating pattern
- preserve zero months honestly
- include `confirmed` and `assumed` periodic expenses where `include_in_forecast` is true
- exclude `excluded` items
- respect configured targets such as `targets.cash_floor`

### 2. Build The Modified Scenario

Apply the user's change to the baseline:

- revenue changes adjust the projected monthly revenue line
- recurring expense changes adjust projected monthly burn
- one-time items hit only the specified month
- owner infusions or withdrawals adjust cash directly
- periodic expense changes modify only the modeled event timing/amount in the modified scenario

Keep the baseline and modified cases side by side. Do not quietly replace the
baseline.

### 3. Compare Baseline vs Modified

For both baseline and modified scenarios, compute:

- best/base/worst runway
- lowest cash point in the horizon
- first zero crossing month, if any
- first cash-floor breach month, if any
- near-term obligations due within 60 days

Then produce a month-end comparison table for the main planning case:

- `Month`
- `Baseline Base`
- `Modified Base`
- `Delta`

If the user explicitly asks for best/worst detail month by month, include it.
Otherwise keep the detailed table to baseline-vs-modified base case and use the
runway summary to represent scenario spread.

### 4. Answer The Decision

If the user framed the request as a decision question such as `can I afford...`
or `what happens if...`, answer that directly near the top:

- `Likely yes`
- `Only if ...`
- `Probably no`

Base that answer on the modified base case, while noting any important best/worst
spread.

### 5. Flag Threshold Crossings

Call out the first material difference the scenario creates:

- zero crossing
- cash-floor breach
- shift from warning to critical runway
- removal of a critical obligation risk
- no material change within the modeled horizon

If the real difference is a single lumpy event rather than ongoing burn, say that
plainly.

## Unsupported Areas

Always state plainly that the current QuickBooks connector cannot provide:

- invoice status
- AR aging
- AP aging
- vendor-level expenses
- customer revenue concentration
- class / item / product tracking

Silence on those topics reflects the connector, not the business.

When relevant, also say that obligations outside QuickBooks such as dissolution
filings, state fees, registered-agent bills, closure costs, taxes, or benefits
load may still exist even if they are not visible in the current scenario.

## Output Structure

Use `skills/11-proactive-analysis/SKILL.md` to keep the decision answer, the
material change callout, and the next step tightly prioritized.

Respond in this order:

1. `Revisor QuickBooks What-If`
2. scenario modeled
3. direct decision answer
4. analysis windows used
5. baseline assumptions
6. modeled changes
7. side-by-side summary
8. month-by-month comparison
9. what changes materially
10. blind spots
11. next step

## Presentation Rules

- Keep the answer practical and decision-oriented.
- Show `Baseline` versus `Modified` explicitly; do not bury the baseline.
- Use exact dollar values where supported.
- Label period-end cash honestly; never imply it is a live bank balance.
- If the user asked about a hire, mention whether benefits, payroll taxes, severance, or onboarding costs were included or not.
- If the scenario depends on a user-supplied rough estimate, label it as such.
- If the scenario has no visible impact within the modeled horizon, say so plainly.
- Keep conclusions inside the modeled horizon.
- End with one concrete next step, for example:
  - tighten the amount or start month
  - confirm or exclude an assumed recurring expense
  - arrange funding before the breach month
  - rerun with a lower-cost variant

## Files

Do not write files from `/revisor:qb-whatif` unless the user explicitly asks to
save the scenario.
