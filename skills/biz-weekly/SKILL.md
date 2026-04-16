---
name: biz-weekly
description: >
  This skill should be used when the user says "/revisor:biz-weekly", "run the
  combined business weekly briefing", or "give me one weekly briefing across
  QuickBooks, HubSpot, and Stripe". It writes a cross-source weekly snapshot and
  briefing using all honestly connected sources.
metadata:
  version: "0.1.0"
---

# Revisor Business Weekly

Your job is to run the recurring cross-source business briefing loop: compare to
prior business snapshots, write a new cross-source weekly snapshot, write a
markdown briefing, and present the summary to the user.

Use the shared rules from:

- `skills/02-cash-flow-forecasting/SKILL.md`
- `skills/03-financial-health/SKILL.md`
- `skills/04-pipeline-analytics/SKILL.md`
- `skills/06-subscription-intelligence/SKILL.md`
- `skills/07-cross-source-synthesis/SKILL.md`
- `skills/08-entity-matching/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only connector usage only.
- Read `.revisor/context.json` if present.
- Load recent `biz-weekly` snapshots from `.revisor/snapshots/` for comparison.
- Write one new canonical connector snapshot and one new canonical markdown briefing.
- Never overwrite canonical timestamped artifacts.
- Do not force customer-level joins when deterministic support is missing.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Detect connected sources from `source_accounts`.
3. If fewer than 2 useful business sources are connected, stop and say the user should use the source-specific weekly flows instead.
4. Load the most recent relevant `biz-weekly` snapshots, ideally the latest 3, for comparison.
5. Pull the freshest safe reads available from connected sources:
   - QuickBooks: trailing 12 complete month P&L, comparable cash-flow window, and fresh cash-through-today window
   - HubSpot: open deals plus historical or activity context when available
   - Stripe: subscriptions, customers, invoices, and cancellation/payment-health signals when available

## Artifact Writes

Write these files:

- `.revisor/snapshots/<UTC timestamp>-biz-weekly.json`
- `.revisor/reports/<UTC timestamp>-biz-briefing.md`

Snapshot rules:

- use `schema_version: "revisor.connector.snapshot.v1"`
- use `flow_slug: "biz-weekly"`
- match `contracts/connector.snapshot.schema.v1.json` exactly
- keep metrics compact and decision-relevant
- use one `sources[]` entry per connected source actually used
- keep QuickBooks `date_range.to` on the comparable operating window even when `cash_balance_as_of` is fresher

Use compact metrics such as:

- cash balance
- cash balance as of
- base runway months
- current MRR
- active subscriber count
- open pipeline value
- weighted pipeline value
- stalled deal count
- confirmed entity mapping count

## Weekly Logic

### 1. Compare To Prior Business Snapshots

Use recent `biz-weekly` snapshots to answer:

- what changed materially across cash, pipeline, and revenue state
- whether the main business risk improved, worsened, or stayed flat
- whether the product-transition story changed

If nothing materially changed, say so plainly.

### 2. Build The Weekly Snapshot

The snapshot should preserve only the compact cross-source state needed for the
next-week comparison, not every raw connector detail.

### 3. Build The Weekly Briefing

The weekly briefing should include:

1. `Revisor Business Weekly`
2. `What changed`
3. `What needs attention`
4. `What looks healthy`
5. `Cross-source read`
6. `Coming up`
7. `Blind spots`
8. `Next step`

Rules:

- show at most 3 findings in `What needs attention`
- always include at least one healthy signal
- lead with the biggest combined business change, not a connector-by-connector recap
- if the current business state is a product-transition gap, say that plainly
- use `skills/11-proactive-analysis/SKILL.md` for section ordering and prioritization

### 4. Cross-Source Read

The `Cross-source read` section should say something no single source can say
alone.

Examples:

- short runway plus zero MRR plus stalled pipeline means financing is bridging a product-transition gap
- healthy Stripe payment collection but frozen HubSpot pipeline means the immediate problem is demand generation, not billing

### 5. Coming Up

Surface only the most decision-relevant near-term items:

- confirmed or assumed QuickBooks obligations due soon
- major expected pipeline milestones when timing support is credible
- customer renewal or churn risk only when Stripe exposes it clearly

## Output

After writing both artifacts, return the briefing summary in the same structure
as the markdown file and include the two written paths.
