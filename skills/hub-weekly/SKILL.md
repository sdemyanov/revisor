---
name: hub-weekly
description: >
  This skill should be used when the user says "/revisor:hub-weekly", "run the
  weekly HubSpot briefing", "generate a weekly CRM briefing", or "do the HubSpot
  weekly check". It writes a HubSpot weekly snapshot and briefing, then returns
  the briefing summary.
metadata:
  version: "0.1.0"
---

# Revisor HubSpot Weekly

Your job is to run the recurring HubSpot briefing loop: compare to prior
HubSpot snapshots, write a new weekly snapshot, write a markdown briefing, and
present the summary to the user.

Use the shared rules from:

- `skills/04-pipeline-analytics/SKILL.md`
- `skills/11-proactive-analysis/SKILL.md`
- `skills/10-formatting/SKILL.md`

If those sibling files are not available in the runtime, follow the condensed
rules below directly.

## Guardrails

- Read-only HubSpot only.
- Read `.revisor/context.json` if present.
- Load recent HubSpot weekly snapshots from `.revisor/snapshots/` for comparison.
- Write one new canonical connector snapshot and one new canonical markdown
  briefing.
- Never overwrite canonical timestamped artifacts.
- When a connector view is unavailable, say `unavailable from the current connector`.

## Required Inputs

1. Load `.revisor/context.json` if it exists.
2. Load the most recent relevant HubSpot weekly snapshots, ideally the latest 3,
   for comparison.
3. Confirm safe read access to open deals.
4. When available, also use:
   - historical closed won and closed lost deals
   - companies
   - activities
   - lead source properties
5. If open deals are unavailable, stop with a clear unblock message and do not
   write partial artifacts.
6. Use a trailing 12 complete month historical window when enough deal history
   exists. Otherwise, use all available comparable history and say so.

## Artifact Writes

Write these files:

- `.revisor/snapshots/<UTC timestamp>-hub-weekly.json`
- `.revisor/reports/<UTC timestamp>-hub-briefing.md`

Snapshot rules:

- use `schema_version: "revisor.connector.snapshot.v1"`
- use `flow_slug: "hub-weekly"`
- match `contracts/connector.snapshot.schema.v1.json` exactly
- keep metrics compact and decision-relevant
- prefer numeric metrics and money objects where possible
- store the comparable historical analysis window in `sources[].date_range`

Use these snapshot metrics when support exists:

- open pipeline value
- weighted pipeline value
- deal count
- stalled deal count
- coverage ratio
- average days past due close
- unknown source rate

Briefing rules:

- markdown only
- timestamped immutable filename
- concise, readable, and safe to diff over time

## Weekly Logic

### 1. Compare To Prior Snapshots

Use recent HubSpot weekly snapshots to answer:

- what changed in open pipeline
- whether weighted pipeline improved or worsened
- whether stalled deals expanded or cleared
- whether source quality improved or degraded

If nothing materially changed, say so plainly.

### 2. Build The Weekly Snapshot

The snapshot should preserve the compact state needed for next-week comparison,
not every raw CRM detail.

### 3. Build The Weekly Briefing

The weekly briefing should include:

1. `Revisor HubSpot Weekly`
2. `What changed`
3. `What needs attention`
4. `What looks healthy`
5. `Pipeline by stage`
6. `Source and velocity notes`
7. `Blind spots`
8. `Next step`

Rules:

- show at most 3 findings in `What needs attention`
- always include healthy signals
- if context is older than 30 days, include a context-refresh prompt
- lead with the most decision-relevant pipeline change, not generic totals
- if a cross-source view would help, mention that `/revisor:biz-*` skills will
  become more useful once the cross-source layer exists
- use the section ordering and prioritization from
  `skills/11-proactive-analysis/SKILL.md`

### 4. Blind Spots

Always state plainly that the current HubSpot loop may be limited by:

- missing activity history
- missing or low-quality lead-source properties
- missing line items or product mix
- no true cash timing without QuickBooks in a later cross-source layer

## Output

After writing both artifacts, return the briefing summary in the same structure
as the markdown file and include the two written paths.
