---
name: 08-entity-matching
description: >
  Shared Revisor skill for deterministic cross-source account and customer
  matching across QuickBooks, HubSpot, and Stripe. Use it when a command needs
  to group records across systems without fabricating joins.
metadata:
  version: "0.1.0"
  scope: "shared"
---

# Revisor Entity Matching

Use this skill for:

- `/revisor:biz-customers`
- `/revisor:biz-weekly`
- later any cross-source customer or account rollup

## Core Principle

Only persist or rely on joins that are deterministic enough to stay stable over
time. If the match is weak, keep it as a suggestion instead of pretending the
business model is fully unified.

## Required Inputs

1. Read `.revisor/context.json` first.
2. Load existing `entity_mappings` before proposing any new join.
3. Use the freshest available read surfaces from connected systems:
   - HubSpot companies, domains, open deals, and company identifiers when available
   - Stripe customers, email domains, subscription/customer identifiers, and product relationships when available
   - QuickBooks customer or account records only when the current connector actually exposes them

## Matching Order

Try joins in this order:

1. existing user-confirmed `entity_mappings`
2. exact root-domain match
3. exact normalized company-name match

Do not skip ahead to fuzzy matching just because a report would look nicer.

## Normalization Rules

When comparing names:

- lowercase
- trim whitespace
- remove punctuation that does not change identity
- normalize common legal suffixes such as `inc`, `llc`, `corp`, `ltd`, and `pllc`
- keep the original display label for output

When comparing domains:

- prefer the company website or primary business email domain
- strip `www.`
- compare the root business domain, not a full path
- ignore free email domains as deterministic identity signals unless the user has already confirmed the match

## Match Buckets

Classify every potential join into one of these buckets:

- `confirmed`: already stored in `entity_mappings` or explicitly confirmed by the user in this run
- `deterministic`: clean exact-domain or exact-normalized-name match, but not yet user-confirmed
- `possible`: weak or partial signal that could be right, but needs confirmation
- `unmatched`: no honest cross-source join available

## How To Use Each Bucket

- `confirmed`: safe to use for customer-level rollups and recurring future runs
- `deterministic`: safe for grouped narrative or ranked watchlists, but still label it as inferred rather than confirmed
- `possible`: surface it only in a `matches needing confirmation` section
- `unmatched`: leave it unjoined

Do not fold `possible` matches into revenue, pipeline, churn, or customer
priority rankings.

## Persistence Rules

Only write to `.revisor/context.json` when the user explicitly confirms a match
during the current run.

When persisting a confirmation, append a new `entity_mappings` record using the
existing schema shape:

- `entity_type`
- `label`
- `sources`
- `confirmed_by`
- `confirmed_at`
- optional `notes`

Never delete or rewrite older mappings unless the user explicitly asks.

## Cross-Source Customer Rules

- Do not claim true customer profitability unless the current QuickBooks connector exposes customer-level financial detail.
- If QuickBooks customer detail is unavailable, describe the output as an
  `account priority` or `customer watchlist`, not a profitability table.
- Stripe can contribute current or historical subscription value, churn, and
  payment risk.
- HubSpot can contribute open pipeline, stale-deal risk, and source quality.
- QuickBooks can contribute customer economics only when the connector truly exposes them.

## Blind Spots

Always state these clearly when relevant:

- deterministic joins may still be incomplete when companies use multiple brands or domains
- QuickBooks customer-level detail may be unavailable from the current connector
- free email domains do not prove identity
- similar firm names are not enough for an automatic match

## Tone Rules

- Explain why a match is believed, not just that it exists.
- Prefer a smaller trustworthy matched set over a larger speculative one.
- When in doubt, ask for confirmation instead of forcing the join.
