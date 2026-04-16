---
name: 10-formatting
description: >
  Shared Revisor skill for consistent response structure, file naming, and future
  internal/shareable report formatting.
metadata:
  version: "0.1.0"
  scope: "shared"
---

# Revisor Formatting

Use this skill to keep Revisor outputs concise, consistent, and honest.

## Standard Response Shape

Use this order unless the user asks for something narrower:

1. Title with analysis window
2. At-a-glance metrics
3. What needs attention
4. What looks healthy
5. Coming up
6. Files written
7. Next step or targeted questions

## Presentation Rules

- Keep the top-line response short and interpretive.
- Never dump raw payloads without explanation.
- Show at most 3 findings in `What needs attention`.
- Always include at least one healthy signal.
- Use direct labels like `confirmed`, `assumed`, and `excluded` when discussing recurring expenses.
- Label period-end cash honestly; never imply it is a live bank balance.

## File-Writing Rules

- Canonical artifacts use UTC timestamps formatted `YYYY-MM-DDTHH-MM-SSZ`.
- Write `.revisor/context.json` in place when setup or user corrections change durable context.
- Write snapshots to `.revisor/snapshots/<timestamp>-<flow>.json`.
- Never overwrite canonical timestamped artifacts.
- If you maintain a convenience `latest-*` file later, treat it as a copy, not the record of truth.
- Prefer workspace-relative writes inside the active project tree.
- When a schema is defined, match it exactly instead of writing a looser human-friendly variant.

### Schema-Shape Reminders

- Arrays must stay arrays even when empty. Example: `strategic_context: []`, not `""`.
- Money fields in snapshots must use the object shape `{ "currency": "USD", "amount": 123.45 }`.
- `sources` in snapshots must be an array of source records, not a keyed object.
- `highlights` in snapshots must be objects with at least `message`, not raw strings.
- If a schema only allows `best`, `base`, and `worst` under `runway_months`, move explanatory text into `alerts` or `highlights`, not extra keys.
- If a date field expects `YYYY-MM-DD`, do not write `YYYY-MM` or full timestamps.
- When a snapshot uses a trailing comparable P&L window plus a fresher cash
  refresh, keep `sources[].date_range` aligned to the comparable operating
  window and store the fresher cash date in `metrics.cash_balance_as_of`.

## QuickBooks MVP Output Expectations

### Setup

- Explain what Revisor detected automatically.
- State what is still unknown.
- Ask only the highest-value follow-up questions.

### Health And Forecast

- Lead with the top 1 to 3 findings.
- Include one concrete next step.

### Future Report Variants

- Internal variants may include exact dollars, percentages, and names.
- Shareable variants must remove dollar values and identifying details.
- Keep structure consistent across both variants even when the detail level changes.

## Failure Handling

- If a file write fails, say which path failed and why.
- If the connector is unavailable, stop early with a clear unblock step instead of writing partial state.
