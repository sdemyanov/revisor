# Scheduled Weekly Runbook

Use this runbook to validate recurring weekly Revisor flows in Cowork.

## Preconditions

- plugin installed and up to date
- `.revisor/context.json` already exists from the relevant setup flow
- the source connectors needed by the chosen weekly flow are connected in Cowork
- working folder set to `/Users/sergey/Projects/revisor-plugin`

## Task Setup

1. Open Cowork scheduled tasks.
2. Create a task using the prompt from one of:
   - [`qb-weekly.md`](./qb-weekly.md)
   - [`hub-weekly.md`](./hub-weekly.md)
   - [`stripe-weekly.md`](./stripe-weekly.md)
   - [`biz-weekly.md`](./biz-weekly.md)
3. Set the working folder to the repo root.
4. Save the task.

## First Validation Pass

Start with `Run on demand`.

Expected result:

- one new timestamped weekly snapshot for the chosen flow
- one new timestamped weekly briefing for the chosen flow
- no overwrite of prior same-day artifacts
- task output includes:
  - what changed
  - what needs attention
  - what looks healthy
  - either `coming up` or `cross-source read`, depending on the flow
  - next step

## What To Inspect

### Snapshot

Check that the newest weekly snapshot:

- matches the correct schema for the chosen flow:
  - `contracts/snapshot.schema.v1.json` for `qb-weekly`
  - `contracts/connector.snapshot.schema.v1.json` for `hub-weekly`, `stripe-weekly`, and `biz-weekly`
- uses the correct `flow_slug`
- keeps each `sources[].date_range` on the comparable operating window
- keeps fresher as-of dates in explicit metrics fields instead of stretching the comparable window

### Briefing

Check that the newest briefing:

- leads with what changed
- does not invent unsupported connector views
- keeps the most important risk near the top
- suggests the relevant follow-on report only when useful

## Known Scheduler Behaviors

- `Run on demand` should be treated as equivalent to an automatic scheduled run
  for artifact-writing safety
- scheduled tasks must write only inside the mounted workspace tree
- scheduled tasks should not assume process `cwd` equals the selected workspace
  folder
- repeated same-day runs must preserve history with timestamped filenames

## Recommended Manual Acceptance

1. `Run on demand` once
2. let one real scheduled fire happen later
3. confirm both runs produced distinct timestamped artifacts
4. confirm the second run compares against the prior weekly snapshot cleanly
