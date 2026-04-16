---
name: hub-setup
description: >
  This skill should be used when the user says "/revisor:hub-setup", "set up
  Revisor for HubSpot", "scan my HubSpot CRM", or "initialize Revisor from
  HubSpot". It creates or refreshes HubSpot-derived context and delivers an
  initial pipeline analysis.
metadata:
  version: "0.1.0"
---

# Revisor HubSpot Setup

Your job is to create or refresh a first-pass Revisor workspace from the current
HubSpot connection.

Use the shared rules from:

- `skills/01-business-context/SKILL.md`
- `skills/04-pipeline-analytics/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only HubSpot only.
- Stay inside the current workspace. Write only under `.revisor/`.
- Preserve user-authored context where possible.
- Do not invent pipeline stages, lead sources, deal probabilities, or activity history that the connector does not expose.
- If `.revisor/context.json` is missing, create a valid minimal `revisor.context.v1` shell rather than writing a partial file.
- When a connector view is unavailable, say `unavailable from the current connector`.

## Required Reads

1. Load existing `.revisor/context.json` if it exists.
2. Confirm the current HubSpot connector exposes safe read access to:
   - deals
   - companies or accounts
3. If those core objects are unavailable, stop with a clear unblock message and do not write partial context.
4. When available, also use:
   - contacts
   - activities
   - lead source properties
   - product or line-item details

Default historical window:

- trailing 12 complete months when available
- otherwise all available closed-deal history

## Context Write Rules

Write or refresh `.revisor/context.json` using `contracts/context.schema.v1.json`.

At minimum:

- preserve all existing top-level fields
- refresh `last_updated`
- add or refresh one `source_accounts` entry for `system: "hubspot"`
- keep `entity_mappings` untouched unless the user has already confirmed mappings

HubSpot source-account guidance:

- use a stable in-session HubSpot account identifier when available
- include account name when available
- set `status: "connected"`
- include `connected_at` when known
- put connector facts such as visible pipelines, deal count, history window, or accessible objects into `metadata`

## Inference Rules

Use HubSpot evidence to improve context conservatively:

- `product_lines`: infer only when deal categories, product objects, line items, or naming patterns make the split materially visible
- `strategic_context`: add dated facts only when the CRM clearly shows something future-relevant, like a major late-stage launch pipeline or repeated enterprise expansion motion
- `key_clients`: do not add names unless the CRM clearly exposes companies and the user is likely to benefit from tracking them; if uncertain, ask instead of writing
- `business_profile.notes`: you may append a short note about pipeline shape or sales motion if it is materially clear

Every inferred item must carry `source` and `date`.

## Initial Analysis Tasks

Produce an initial HubSpot-first analysis covering:

- open pipeline by stage
- weighted pipeline estimate
- stalled deals, if stage timing or age supports it
- lead source signal when available
- if QuickBooks is already connected in `source_accounts`, mention where cross-source insights could be unlocked later, but do not fabricate them yet

## Follow-Up Questions

Ask only the 3 to 5 highest-value questions, prioritizing:

1. whether the detected stage map and pipeline target are right
2. whether specific product lines or motions should be tracked separately
3. whether any key accounts should be treated as strategic
4. what quarterly sales target Revisor should use for coverage interpretation

Skip any question already answered in context.

## Response

Use this structure:

1. `Revisor HubSpot Setup`
2. analysis scope used
3. at-a-glance pipeline metrics
4. what needs attention
5. what looks healthy
6. blind spots
7. files written
8. targeted follow-up questions

Build `what needs attention`, `what looks healthy`, and the question
prioritization using `skills/11-proactive-analysis/SKILL.md`.
