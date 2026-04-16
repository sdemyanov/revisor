---
name: hub-pipeline
description: >
  This skill should be used when the user says "/revisor:hub-pipeline", "show my
  pipeline", "analyze my HubSpot pipeline", or "pipeline coverage". It produces a
  read-only pipeline snapshot from HubSpot.
metadata:
  version: "0.1.0"
---

# Revisor HubSpot Pipeline

Your job is to explain the current HubSpot pipeline shape without mutating local
state.

Use the shared rules from:

- `skills/04-pipeline-analytics/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only HubSpot only.
- Read `.revisor/context.json` if present.
- Do not write files from `/revisor:hub-pipeline` unless the user explicitly asks to save the analysis.
- Do not invent activity history, deal-stage probability, or target coverage if the connector does not expose the needed fields.
- When a connector view is unavailable, say `unavailable from the current connector`.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Confirm safe read access to current open deals.
3. If open deals are unavailable, stop with a clear unblock message.
4. Use trailing 12 complete months of closed won/lost deal history when available to estimate stage conversion and cycle time.
5. If historical depth is thin, keep the pipeline analysis but label confidence honestly.

## Core Tasks

- show open pipeline value by stage
- show weighted pipeline value
- show deal count by stage
- compute pipeline coverage ratio if an explicit target exists in `.revisor/context.json`
- identify stalled deals when timing support exists
- flag concentration if one deal is more than about 20% of open pipeline

## Output Structure

Respond in this order:

1. `Revisor HubSpot Pipeline`
2. analysis scope used
3. at-a-glance pipeline metrics
4. what needs attention
5. what looks healthy
6. stage breakdown
7. stalled deals or pipeline drag
8. blind spots
9. next step

Use `skills/11-proactive-analysis/SKILL.md` to prioritize the most important
pipeline risk and the single best next action.
