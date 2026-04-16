---
name: biz-customers
description: >
  This skill should be used when the user says "/revisor:biz-customers", "show me
  my cross-source customers", "rank accounts across HubSpot and Stripe", or "what
  customers matter most right now". It produces a cross-source customer or
  account-priority view without inventing unsupported joins.
metadata:
  version: "0.1.0"
---

# Revisor Business Customers

Your job is to combine the connected customer, account, and pipeline signals
from QuickBooks, HubSpot, and Stripe into one clear priority view.

Use the shared rules from:

- `skills/04-pipeline-analytics/SKILL.md`
- `skills/06-subscription-intelligence/SKILL.md`
- `skills/07-cross-source-synthesis/SKILL.md`
- `skills/08-entity-matching/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only by default.
- Read `.revisor/context.json` if present.
- Only update `entity_mappings` when the user explicitly confirms a match during this run.
- Never fabricate customer profitability if the current QuickBooks connector does not expose customer-level financial detail.
- When a source or field is unavailable, say `unavailable from the current connector`.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Detect connected sources from `source_accounts`.
3. Pull the freshest safe customer/account reads available:
   - HubSpot companies and open deals
   - Stripe customers, subscriptions, invoices, and payment-health signals
   - QuickBooks customer detail only if the connector actually exposes it
4. Load `entity_mappings` and apply the deterministic matching rules from `skills/08-entity-matching/SKILL.md`.

## Matching Logic

Group records into these buckets:

- confirmed matches
- deterministic inferred matches
- possible matches needing confirmation
- unmatched source-specific records

If fewer than 2 sources are connected, say that this view is source-limited and
degrade gracefully.

## Ranking Logic

### If customer-level QuickBooks detail is available

You may produce a true customer ranking that combines:

- recognized revenue or balances from QuickBooks
- current or historical subscription value from Stripe
- active pipeline and deal timing from HubSpot
- payment or churn risk from Stripe

### If customer-level QuickBooks detail is unavailable

Do **not** call the output profitability.

Instead produce an `account priority view` using the best connected signals:

- active or recent Stripe revenue
- churned versus active product relationship
- failed-payment or collection risk
- open pipeline amount and staleness
- concentration in one product or one opportunity

## Output Structure

Use `skills/11-proactive-analysis/SKILL.md` for `What needs attention`,
`What looks healthy`, and `Next step`.

Respond in this order:

1. `Revisor Business Customers`
2. sources used
3. matching status
4. what needs attention
5. what looks healthy
6. ranked customers or accounts
7. matches needing confirmation
8. blind spots
9. next step

## Ranked Output Rules

- Show at most 5 ranked rows.
- For each row, include:
  - display label
  - sources present
  - current relationship state such as `active subscriber`, `churned legacy customer`, `open prospect`, or `mixed`
  - the strongest revenue, pipeline, or risk signal available
  - one short reason it matters now
- If no honest cross-source ranking is possible, say so plainly instead of padding the list.

## Confirmation Rules

If the user explicitly confirms a suggested match in the current run:

1. update `.revisor/context.json`
2. append a new `entity_mappings` entry that matches the schema
3. set `confirmed_by: "user"`
4. set `confirmed_at` to today’s date
5. update `last_updated`
6. mention the file write in the response

Do not auto-confirm deterministic matches without user approval.

## Blind Spots

Always state these clearly when relevant:

- QuickBooks customer detail may be unavailable from the current connector
- pipeline value is not realized revenue
- churned Stripe customers may not line up to CRM companies without confirmed mappings
- a ranked list can still be incomplete when entity coverage is partial

## Tone Rules

- Keep the ranking decision-oriented, not encyclopedic.
- Separate active revenue customers from speculative prospects when that distinction matters.
- Prefer a small honest matched set over a broad speculative table.
