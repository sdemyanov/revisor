---
name: stripe-churn
description: >
  This skill should be used when the user says "/revisor:stripe-churn", "analyze
  churn", "show churn risk", or "subscription retention". It produces a read-only
  churn and retention analysis from Stripe.
metadata:
  version: "0.1.0"
---

# Revisor Stripe Churn

Your job is to explain customer and revenue churn from Stripe using only the
connector surface actually available in the current session.

Use the shared rules from:

- `skills/06-subscription-intelligence/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only Stripe only.
- Read `.revisor/context.json` if present.
- Do not write files from `/revisor:stripe-churn` unless the user explicitly asks to save the analysis.
- Do not classify churn as voluntary or involuntary unless the connector provides explicit support for that distinction.
- When a connector view is unavailable, say `unavailable from the current connector`.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Confirm safe read access to subscriptions and cancellation or payment-status history.
3. If churn-supporting history is too thin, still provide an honest limited analysis rather than inventing a stable trend.

## Core Tasks

- estimate recent logo churn and revenue churn when possible
- separate voluntary, involuntary, and unknown churn only when supported
- identify at-risk customers or subscriptions when failed-payment or scheduled-cancel evidence exists
- say whether churn is improving, worsening, or too sparse to interpret confidently

## Output Structure

Respond in this order:

1. `Revisor Stripe Churn`
2. analysis scope used
3. at-a-glance retention metrics
4. what needs attention
5. what looks healthy
6. churn breakdown
7. at-risk customers or accounts
8. blind spots
9. next step

Use `skills/11-proactive-analysis/SKILL.md` to keep the main churn risk and next
step tightly prioritized.
