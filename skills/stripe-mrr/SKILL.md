---
name: stripe-mrr
description: >
  This skill should be used when the user says "/revisor:stripe-mrr", "show my
  MRR", "analyze Stripe MRR", or "subscription revenue trend". It produces a
  read-only recurring-revenue analysis from Stripe.
metadata:
  version: "0.1.0"
---

# Revisor Stripe MRR

Your job is to explain recurring-revenue movement from Stripe without mutating
local state.

Use the shared rules from:

- `skills/06-subscription-intelligence/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only Stripe only.
- Read `.revisor/context.json` if present.
- Do not write files from `/revisor:stripe-mrr` unless the user explicitly asks to save the analysis.
- Normalize mixed billing cadences honestly and say when annual plans are being translated into monthly equivalents.
- When a connector view is unavailable, say `unavailable from the current connector`.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Confirm safe read access to subscriptions and enough historical billing data to estimate recurring revenue movement.
3. If recurring-revenue normalization is not supportable from the available fields, stop with a clear unblock message.

## Core Tasks

- calculate current normalized MRR
- show recent movement categories:
  - new
  - expansion
  - contraction
  - churn
  - reactivation
- show trend over the trailing 12 complete months when possible
- call out concentration in a single plan or movement source when visible

## Output Structure

Respond in this order:

1. `Revisor Stripe MRR`
2. analysis scope used
3. at-a-glance subscription metrics
4. what needs attention
5. what looks healthy
6. MRR movement breakdown
7. blind spots
8. next step

Use `skills/11-proactive-analysis/SKILL.md` to keep the key movement and next
step focused on the most decision-relevant revenue signal.
