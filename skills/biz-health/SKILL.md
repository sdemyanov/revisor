---
name: biz-health
description: >
  This skill should be used when the user says "/revisor:biz-health", "check my
  business health", "combine QuickBooks and HubSpot", or "give me the cross-
  source Revisor health view". It produces a read-only business-level diagnostic
  using all connected sources that can be honestly combined.
metadata:
  version: "0.1.0"
---

# Revisor Business Health

Your job is to combine the connected Revisor sources into one clear business
health view without mutating local state.

Use the shared rules from:

- `skills/02-cash-flow-forecasting/SKILL.md`
- `skills/03-financial-health/SKILL.md`
- `skills/04-pipeline-analytics/SKILL.md`
- `skills/06-subscription-intelligence/SKILL.md`
- `skills/07-cross-source-synthesis/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only only. Never call mutating connector tools.
- Read `.revisor/context.json` if present.
- Load recent relevant snapshots for context when helpful, but do not write new
  files from `/revisor:biz-health`.
- Do not force customer-level joins without deterministic support.
- When a connector view is unavailable, say `unavailable from the current connector`.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Detect connected sources from `source_accounts`.
3. For each connected source, use the freshest safe read surface available:
   - QuickBooks: company info, trailing 12 complete month P&L, comparable cash
     flow window, fresh cash-through-today window
   - HubSpot: open deals, and historical closed won/lost or activity fields when
     available
   - Stripe: subscriptions, customers, invoices, and payment-health or
     cancellation signals when available
4. If only one source is connected, still provide a useful source-aware answer
   and say that the cross-source view is limited.

## Core Diagnostic Tasks

### 1. Source Availability

State which sources were used and what each one contributed.

### 2. Resolve The Business Engine

Explain the difference between:

- cash and obligations from QuickBooks
- future sales opportunity from HubSpot
- current recurring revenue and product-state signal from Stripe

Make it explicit that:

- open pipeline is not cash
- pre-revenue Stripe products do not fix runway by themselves
- product transition can create a gap where the old product is gone before the
  new one converts

### 3. Produce One Cross-Source Read

Deliver at least one business-level conclusion that no single source provides
alone.

Examples:

- short runway plus frozen pipeline plus zero MRR means financing is carrying
  the business while go-to-market is not yet converting
- healthy payment collection but weak demand generation means billing is not the
  main problem

### 4. Compare To Recent State When Helpful

If recent source-specific snapshots exist, use them to say whether the current
state is materially different or still basically unchanged.

## Output Structure

Build `What needs attention`, `What looks healthy`, `Cross-source read`, and
`Next step` using the prioritization from `skills/11-proactive-analysis/SKILL.md`.

Respond in this order:

1. `Revisor Business Health`
2. sources used
3. analysis windows used
4. at-a-glance cross-source metrics
5. what needs attention
6. what looks healthy
7. cross-source read
8. blind spots
9. next step

## Presentation Rules

- Show at most 3 findings in `What needs attention`.
- Always include at least one healthy signal.
- Be explicit about which source drives each major conclusion.
- If QuickBooks is connected, cash and runway should normally anchor urgency.
- If HubSpot pipeline is stale or low-confidence, say so instead of counting it
  as dependable near-term relief.
- If Stripe shows zero current MRR, say so directly even if lifetime revenue
  exists.
- End with one concrete next action.
