---
name: 06-subscription-intelligence
description: >
  Shared Revisor skill for Stripe subscription metrics, MRR movement categories,
  churn framing, and at-risk customer interpretation.
metadata:
  version: "0.1.0"
  scope: "shared"
---

# Revisor Subscription Intelligence

Use this skill for:

- `/revisor:stripe-setup`
- `/revisor:stripe-mrr`
- `/revisor:stripe-churn`
- `/revisor:stripe-payments`
- `/revisor:stripe-weekly`

## Connector Truths

- Only use Stripe objects and fields that are actually available in the current
  connector session.
- Prefer subscription and invoice/payment records over inferring recurring
  revenue from one-time charges.
- If a key classification is unavailable, label it `unknown` or `unavailable`
  instead of guessing.

## Core Inputs

When available, use:

- subscriptions
- customers
- invoices
- charges or payment intents
- subscription status transitions
- cancellation timestamps and reasons

Default historical window:

- trailing 12 complete months
- if less than 12 months are available, use all available history and say so

## MRR Rules

Normalize recurring revenue into monthly terms:

- monthly plan: use monthly recurring amount directly
- annual plan: divide recurring annual amount by 12
- quarterly plan: divide by 3
- mixed cadences: normalize all plans before summing

If the connector does not expose enough information to normalize accurately, say
that the MRR estimate is approximate.

## MRR Movement Categories

Classify changes month over month into:

- `new`
- `expansion`
- `contraction`
- `churn`
- `reactivation`

Use the most honest customer- or subscription-level evidence available.

## Churn Rules

### Logo Churn

- `logo_churn_rate = customers_lost / customers_active_at_start`

### Revenue Churn

- `revenue_churn_rate = mrr_lost / mrr_at_start`

### Voluntary vs Involuntary

- `voluntary`: explicit cancellation or downgrade choice is visible
- `involuntary`: failed payment, dunning exhaustion, or payment-collection loss
  is visible
- otherwise: classify as `unknown`, not voluntary or involuntary

## At-Risk Signals

Surface customers or subscriptions as at-risk when supported by the connector:

- failed payment
- repeated payment retries
- past_due or unpaid status
- scheduled cancellation
- meaningful downgrade pattern

## Payment Health Rules

- Prefer invoice, charge, or payment-intent evidence over subscription-status
  inference when analyzing collection risk.
- If failed payment attempts are visible, count them over a recent window such as
  30 or 90 days and say which window you used.
- Only describe retry or recovery behavior when repeated attempts are actually
  exposed.
- Distinguish clearly between:
  - `payment failure risk`
  - `churn risk`
  - `recognized revenue`
- Do not imply bank-settlement timing or QuickBooks cash accounting from
  Stripe-only payment data.

## Healthy Signals

Good healthy signals include:

- net positive MRR movement
- expansion offsetting churn
- improving recovery on failed payments
- low churn and low involuntary churn
- stable or growing active subscriber count
- low unpaid or past_due exposure

## Blind Spots

Say these explicitly when relevant:

- CAC requires QuickBooks or other spend data
- LTV is approximate without enough retention history
- support burden and profitability require cross-source data
- churn reason quality depends on what the connector exposes
