---
name: stripe-weekly
description: >
  This skill should be used when the user says "/revisor:stripe-weekly", "run
  the weekly Stripe briefing", "generate a weekly subscription briefing", or "do
  the Stripe weekly check". It writes a Stripe weekly snapshot and briefing,
  then returns the briefing summary.
metadata:
  version: "0.1.0"
---

# Revisor Stripe Weekly

Your job is to run the recurring Stripe briefing loop: compare to prior Stripe
snapshots, write a new weekly snapshot, write a markdown briefing, and present
the summary to the user.

Use the shared rules from:

- `skills/06-subscription-intelligence/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only Stripe only.
- Read `.revisor/context.json` if present.
- Load recent Stripe weekly snapshots from `.revisor/snapshots/` for comparison.
- Write one new canonical connector snapshot and one new canonical markdown
  briefing.
- Never overwrite canonical timestamped artifacts.
- When a connector view is unavailable, say `unavailable from the current connector`.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Load the most recent relevant Stripe weekly snapshots, ideally the latest 3,
   for comparison.
3. Confirm safe read access to subscriptions.
4. When available, also use:
   - customers
   - invoices
   - charges or payment intents
   - cancellation and status-transition history
5. If subscriptions are unavailable, stop with a clear unblock message and do
   not write partial artifacts.
6. Use a trailing 12 complete month historical window when enough billing
   history exists. Otherwise, use all available comparable history and say so.

## Artifact Writes

Write these files:

- `.revisor/snapshots/<UTC timestamp>-stripe-weekly.json`
- `.revisor/reports/<UTC timestamp>-stripe-briefing.md`

Snapshot rules:

- use `schema_version: "revisor.connector.snapshot.v1"`
- use `flow_slug: "stripe-weekly"`
- match `contracts/connector.snapshot.schema.v1.json` exactly
- keep metrics compact and decision-relevant
- prefer numeric metrics and money objects where possible
- store the comparable historical analysis window in `sources[].date_range`

Use these snapshot metrics when support exists:

- current normalized MRR
- active subscribers
- lifetime gross revenue
- logo churn rate
- revenue churn rate
- failed payment count last 30 days
- at-risk subscriber count

Briefing rules:

- markdown only
- timestamped immutable filename
- concise, readable, and safe to diff over time

## Weekly Logic

### 1. Compare To Prior Snapshots

Use recent Stripe weekly snapshots to answer:

- what changed in MRR
- whether churn improved or worsened
- whether payment risk expanded or cleared
- whether the current state is basically unchanged

If nothing materially changed, say so plainly.

### 2. Build The Weekly Snapshot

The snapshot should preserve the compact recurring-revenue state needed for
next-week comparison, not every raw Stripe object.

### 3. Build The Weekly Briefing

The weekly briefing should include:

1. `Revisor Stripe Weekly`
2. `What changed`
3. `What needs attention`
4. `What looks healthy`
5. `MRR movement`
6. `Churn and collection notes`
7. `Blind spots`
8. `Next step`

Rules:

- show at most 3 findings in `What needs attention`
- always include healthy signals
- if context is older than 30 days, include a context-refresh prompt
- lead with the most decision-relevant subscription change, not generic totals
- if a cross-source view would help, mention that `/revisor:biz-*` skills will
  become more useful once the cross-source layer exists
- use the section ordering and prioritization from
  `skills/11-proactive-analysis/SKILL.md`

### 4. Blind Spots

Always state plainly that the current Stripe loop may be limited by:

- missing payment-attempt history
- missing cancellation reasons
- approximate MRR normalization when pricing data is incomplete
- no CAC, margin, or full unit-economics view without QuickBooks in a later
  cross-source layer

## Output

After writing both artifacts, return the briefing summary in the same structure
as the markdown file and include the two written paths.
