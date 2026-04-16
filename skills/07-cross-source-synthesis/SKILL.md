---
name: 07-cross-source-synthesis
description: >
  Shared Revisor skill for combining QuickBooks, HubSpot, and Stripe into one
  business-level view without fabricating joins, cash timing, or customer-level
  facts that the connected sources do not truly support.
metadata:
  version: "0.1.0"
  scope: "shared"
---

# Revisor Cross-Source Synthesis

Use this skill for:

- `/revisor:biz-health`
- `/revisor:biz-forecast`
- `/revisor:biz-report`
- `/revisor:biz-customers`
- `/revisor:biz-weekly`

## Core Principle

Cross-source synthesis should make the business easier to understand, not more
magical. When sources do not line up cleanly, say so.

## Source Roles

Treat each source as authoritative for a different layer:

- QuickBooks: cash, expenses, burn, runway, obligations
- HubSpot: open pipeline, stage shape, timing drag, source quality
- Stripe: recurring revenue, churn, payment collection, product transition signal

Do not let one source overclaim another source's job.

Examples:

- open HubSpot pipeline is not cash
- Stripe billing is not the same thing as QuickBooks cash balance
- product interest in HubSpot is not the same thing as customer profitability

## Availability Rules

- Read `.revisor/context.json` first to see which sources are connected.
- Use fresh connector reads when the command is meant to describe current state.
- Use snapshots only for trend context, not as the sole source of truth when a
  live connector is available.
- If only one or two sources are connected, degrade gracefully and say which
  pieces are unavailable.

## Join Rules

Only use deterministic customer or account joins in this order:

1. user-confirmed mapping stored in `entity_mappings`
2. exact domain match
3. exact normalized company-name match

If none of those exist:

- do not force a customer-level join
- do not fabricate profitability by account
- keep the synthesis at the business level

Use `skills/08-entity-matching/SKILL.md` for the detailed persistence and
match-bucket rules whenever a command needs to surface or store candidate joins.

## Safe Cross-Source Insights

Good cross-source insights include:

- runway is short while weighted pipeline is stale
- recurring revenue is zero while a new-product pipeline exists
- old product fully churned before the new pipeline converts
- business depends on financing because operating revenue and pipeline conversion
  are both weak
- payment collection is healthy, but demand generation is weak

## Forecast Rules

When combining sources in a forecast:

- starting cash should come from QuickBooks when available
- recurring expense baseline should come from QuickBooks when available
- current recurring revenue should come from Stripe when available
- future pipeline upside should come from HubSpot only when timing support exists
- if HubSpot history is thin or all deals are stalled, treat pipeline as low-
  confidence upside rather than dependable base-case revenue
- if Stripe MRR is zero, do not assume future MRR appears without explicit
  evidence or a user-stated scenario

## Product Transition Rules

Call out a product transition when supported by the connected sources.

Examples:

- Stripe shows an older product fully churned and a newer product pre-revenue
- HubSpot pipeline targets the newer product
- QuickBooks shows the business still carrying burn while the new go-to-market
  engine is not converting yet

That is a business-model transition, not just a metric change.

## Blind Spots

Always say what still cannot be known even with multiple sources:

- exact customer profitability without deterministic joins
- CAC without attributable marketing spend
- collections quality without invoice-aging support
- exact conversion timing when HubSpot has no trustworthy close history
- complete unit economics when source granularity is missing

## Tone Rules

- Be explicit about which sources are driving each conclusion.
- Prefer "directional" over fake precision when source quality is weak.
- The more sources are connected, the more honest you should be about what is
  still unresolved.
