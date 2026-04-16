---
name: hub-velocity
description: >
  This skill should be used when the user says "/revisor:hub-velocity", "analyze
  sales velocity", "show HubSpot cycle time", or "which deals are stalled". It
  produces a read-only HubSpot velocity and stage-drag analysis.
metadata:
  version: "0.1.0"
---

# Revisor HubSpot Velocity

Your job is to explain how fast deals move through the current HubSpot pipeline
and where timing drag is building.

Use the shared rules from:

- `skills/04-pipeline-analytics/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only HubSpot only.
- Read `.revisor/context.json` if present.
- Do not write files from `/revisor:hub-velocity` unless the user explicitly asks
  to save the analysis.
- Do not invent stage-duration history or cycle-time precision when the
  connector does not expose it.
- When a connector view is unavailable, say `unavailable from the current connector`.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Confirm safe read access to open deals.
3. Use trailing 12 complete months of closed won and closed lost history when
   available.
4. Use stage history or activity timestamps when exposed.
5. If historical depth is thin, still produce an honest low-confidence analysis
   using deal age and expected close dates.

## Core Tasks

- estimate median days to close when historical wins support it
- show stage drag or stage duration hotspots when support exists
- show how many open deals are materially past expected close
- identify the small number of deals creating most of the timing risk
- say whether velocity is improving, worsening, or too sparse to interpret

## Output Structure

Respond in this order:

1. `Revisor HubSpot Velocity`
2. analysis scope used
3. at-a-glance velocity metrics
4. what needs attention
5. what looks healthy
6. stage drag and stalled deals
7. timing confidence
8. blind spots
9. next step

Use `skills/11-proactive-analysis/SKILL.md` to keep the summary focused on the
single biggest timing bottleneck.
