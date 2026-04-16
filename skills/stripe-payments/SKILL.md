---
name: stripe-payments
description: >
  This skill should be used when the user says "/revisor:stripe-payments",
  "analyze failed payments", "show Stripe payment health", or "collection risk".
  It produces a read-only Stripe payment and collection analysis.
metadata:
  version: "0.1.0"
---

# Revisor Stripe Payments

Your job is to explain payment collection health from Stripe without mutating
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
- Do not write files from `/revisor:stripe-payments` unless the user explicitly
  asks to save the analysis.
- Do not imply GAAP cash collection or bank settlement timing; stay inside the
  Stripe connector surface.
- Do not classify dunning state or recovery rate unless the connector exposes
  enough evidence.
- When a connector view is unavailable, say `unavailable from the current connector`.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Confirm safe read access to subscriptions.
3. Use invoices, charges, payment intents, or payment-failure signals when
   available.
4. If no payment-health data is exposed beyond subscription status, stop with a
   clear unblock message instead of pretending to know collection behavior.

## Core Tasks

- count recent failed payments when support exists
- identify past_due, unpaid, or otherwise at-risk subscriptions when support exists
- estimate recovery or retry behavior only when the connector makes it visible
- call out concentration in a small number of failing accounts when visible
- say whether payment risk is improving, worsening, or too sparse to interpret

## Output Structure

Respond in this order:

1. `Revisor Stripe Payments`
2. analysis scope used
3. at-a-glance payment health metrics
4. what needs attention
5. what looks healthy
6. failed payment and collection breakdown
7. at-risk accounts
8. blind spots
9. next step

Use `skills/11-proactive-analysis/SKILL.md` to keep the summary focused on the
single biggest payment-health risk.
