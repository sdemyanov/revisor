---
name: hub-sources
description: >
  This skill should be used when the user says "/revisor:hub-sources", "analyze
  lead sources", "show pipeline by source", or "which channels drive HubSpot
  pipeline". It produces a read-only HubSpot source and attribution analysis.
metadata:
  version: "0.1.0"
---

# Revisor HubSpot Sources

Your job is to explain where pipeline appears to be coming from in HubSpot and
whether source attribution is good enough to trust.

Use the shared rules from:

- `skills/04-pipeline-analytics/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only HubSpot only.
- Read `.revisor/context.json` if present.
- Do not write files from `/revisor:hub-sources` unless the user explicitly asks
  to save the analysis.
- Do not invent attribution when source properties are missing or low quality.
- When a connector view is unavailable, say `unavailable from the current connector`.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Confirm safe read access to open deals.
3. Use lead-source or attribution properties when available.
4. Use trailing 12 complete months of closed won/lost history when available.
5. If source properties are sparse or inconsistent, still provide an attribution
   quality analysis rather than pretending the source breakdown is robust.

## Core Tasks

- show open pipeline by source when support exists
- show weighted pipeline by source when support exists
- show closed won by source when historical data supports it
- estimate unknown or unattributed source rate
- flag concentration in one source or channel
- say whether the source picture is decision-grade or only directional

## Output Structure

Respond in this order:

1. `Revisor HubSpot Sources`
2. analysis scope used
3. at-a-glance source metrics
4. what needs attention
5. what looks healthy
6. source breakdown
7. attribution quality
8. blind spots
9. next step

Use `skills/11-proactive-analysis/SKILL.md` to keep the next step focused on the
single best attribution improvement or growth question.
