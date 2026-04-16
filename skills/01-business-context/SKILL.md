---
name: 01-business-context
description: >
  Shared Revisor skill for turning QuickBooks evidence and brief user answers into
  canonical business context. Use this when writing or refreshing
  `.revisor/context.json`.
metadata:
  version: "0.1.0"
  scope: "shared"
---

# Revisor Business Context

Use this skill when Revisor needs to infer or refresh business context from the
currently proven QuickBooks surface.

## Core Rules

- User-stated facts always override inferred facts.
- Every inferred or learned item should carry `source` and `date`.
- Update `.revisor/context.json` in place instead of appending contradictory facts.
- If a field is unknown, leave it empty or keep the existing value. Do not invent precision.
- Do not imply customer-level, vendor-level, invoice-level, AR/AP, or class-level detail that the current QuickBooks connector does not expose.

## What QuickBooks Can Safely Support Today

- Company identity and industry code via `company-info`
- Income and expense account structure via `profit-loss-quickbooks-account`
- Monthly seasonality hints via `monthlyBreakdown`
- Expense category cadence at the chart-of-accounts level

## What Must Still Come From The User

- Strategic plans, launches, hiring, fundraising, pricing changes
- Key clients and concentration risk
- Targets such as runway threshold, revenue goal, or hiring plan
- Confirmation or exclusion of assumed recurring expenses
- Corrections to business type or product-line inference

## Context Mapping Rules

### `business_profile`

- Set `type` from the strongest honest signal available:
  - `SaaS` when software/subscription revenue dominates
  - `Services` when consulting, professional services, or project revenue dominates
  - `Ecommerce` when product sales / COGS patterns dominate
  - hybrid labels like `SaaS + services hybrid` when multiple material lines exist
- Use `detected_from` to explain the inference basis.
- Keep `confirmed_by_user` false until the user agrees.
- Only fill `fiscal_year_start`, `seasonality`, or `notes` when the connector or user gives real support.

### `product_lines`

- Add a product line only when it is user-confirmed or materially visible in revenue accounts.
- A line is material when it is roughly 10% or more of trailing revenue, or obviously strategic from user input.
- Use readable names, but stay close to the source wording.
- If revenue is absent or ambiguous, prefer an empty array over invented lines.

### `strategic_context`

- Store only dated facts that matter to future interpretation.
- Examples: hiring plans, launches, pricing changes, fundraising, planned cutbacks.
- If setup has no such facts yet, initialize as an empty array.

### `key_clients`

- Do not infer client names from QuickBooks-only data.
- Keep this empty until the user provides names or later sources prove them.

### `targets`

- Store user goals and guardrails in plain language or simple numeric fields.
- If the user has not provided targets, keep an empty object.

### `source_accounts`

- Always add or refresh the connected QuickBooks account.
- Include:
  - `system: "quickbooks"`
  - stable account identifier available in-session
  - account name
  - connection status
  - connection date when known
  - provenance
  - metadata such as industry code and display currency when available

### `entity_mappings`

- Initialize to an empty array for QuickBooks-only setup.
- Only populate this with user-confirmed cross-source joins later.

### `periodic_expenses`

- Preserve all existing `confirmed` and `excluded` entries unless the user changes them.
- New QuickBooks-only recurring detections must be category-level and stored as `assumed`.
- If vendor detail is unavailable, use an honest bucket label like `Software renewals bucket`.

## Follow-Up Question Strategy

Ask only the 3 to 5 highest-value questions after writing the first-pass context.

Prioritize:

1. Is the detected business mix right?
2. Which assumed recurring expenses are false positives?
3. What runway threshold or target should Revisor use?
4. Are there any major clients or renewals I should track?
5. Are there near-term strategic changes that would change how I interpret the numbers?

Skip any question that the current context already answers.
