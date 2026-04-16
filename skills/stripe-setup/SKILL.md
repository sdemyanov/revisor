---
name: stripe-setup
description: >
  This skill should be used when the user says "/revisor:stripe-setup", "set up
  Revisor for Stripe", "scan my Stripe account", or "initialize Revisor from
  Stripe". It creates or refreshes Stripe-derived context and delivers an initial
  subscription analysis.
metadata:
  version: "0.1.0"
---

# Revisor Stripe Setup

Your job is to create or refresh a first-pass Revisor workspace from the current
Stripe connection.

Use the shared rules from:

- `skills/01-business-context/SKILL.md`
- `skills/06-subscription-intelligence/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only Stripe only.
- Stay inside the current workspace. Write only under `.revisor/`.
- Preserve user-authored context where possible.
- Do not invent subscription fields, pricing model, churn reasons, or payment status that the connector does not expose.
- If `.revisor/context.json` is missing, create a valid minimal `revisor.context.v1` shell rather than writing a partial file.
- When a connector view is unavailable, say `unavailable from the current connector`.

## Required Reads

1. Load existing `.revisor/context.json` if it exists.
2. Confirm the current Stripe connector exposes safe read access to:
   - subscriptions
   - customers
3. If those core objects are unavailable, stop with a clear unblock message and do not write partial context.
4. When available, also use:
   - invoices
   - charges or payment intents
   - cancellation data

Default historical window:

- trailing 12 complete months when available
- otherwise all available subscription history

## Context Write Rules

Write or refresh `.revisor/context.json` using `contracts/context.schema.v1.json`.

At minimum:

- preserve all existing top-level fields
- refresh `last_updated`
- add or refresh one `source_accounts` entry for `system: "stripe"`
- keep `entity_mappings` untouched unless the user has already confirmed mappings

Stripe source-account guidance:

- use a stable in-session Stripe account identifier when available
- include account name when available
- set `status: "connected"`
- include `connected_at` when known
- put facts such as pricing cadence mix, active subscriber count, or visible objects into `metadata`

## Inference Rules

Use Stripe evidence to improve context conservatively:

- `business_profile.type`: if recurring subscription billing is dominant and the context is empty or ambiguous, you may strengthen the note toward `SaaS` or `subscription` patterns
- `product_lines`: infer only when products/plans are materially distinct and visible
- `strategic_context`: add only dated subscription-relevant facts that are clearly supported, like a strong annual-plan mix or recent expansion-heavy growth pattern

Every inferred item must carry `source` and `date`.

## Initial Analysis Tasks

Produce an initial Stripe-first analysis covering:

- current normalized MRR when support exists
- recent MRR movement trend
- churn signal and whether voluntary/involuntary split is available
- at-risk customers or failed-payment pattern when support exists
- if QuickBooks is already connected in `source_accounts`, mention that unit-economics enrichment can be unlocked later, but do not fabricate it yet

## Follow-Up Questions

Ask only the 3 to 5 highest-value questions, prioritizing:

1. whether the pricing model or plan mix looks right
2. whether annual plans should be treated differently in interpretation
3. which retention or churn targets Revisor should track
4. whether any customer segment deserves special monitoring

## Response

Use this structure:

1. `Revisor Stripe Setup`
2. analysis scope used
3. at-a-glance subscription metrics
4. what needs attention
5. what looks healthy
6. blind spots
7. files written
8. targeted follow-up questions

Build `what needs attention`, `what looks healthy`, and the question
prioritization using `skills/11-proactive-analysis/SKILL.md`.
