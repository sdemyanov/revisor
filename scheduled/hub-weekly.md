# Revisor Scheduled Weekly HubSpot Briefing

Run the Revisor weekly HubSpot briefing workflow against the current workspace.

## Rules

- Treat this task as safe for both automatic scheduled fires and manual `Run on demand`.
- Never overwrite canonical timestamped artifacts.
- Write only inside the mounted workspace tree, using relative `.revisor/...` paths.
- Use timestamped files so reruns on the same day preserve history.
- Read-only HubSpot only.

## Required behavior

1. Load `.revisor/context.json`. If it is missing, stop and say the user must run `/revisor:hub-setup` first.
2. Load recent HubSpot weekly snapshots from `.revisor/snapshots/` for comparison.
3. Pull fresh HubSpot data:
   - open deals
   - historical closed won/lost when available
   - activities and source properties when available
4. Compare the new data to the latest HubSpot weekly snapshot(s).
5. Write a new weekly snapshot:
   - `.revisor/snapshots/<UTC timestamp>-hub-weekly.json`
6. Write a new markdown briefing:
   - `.revisor/reports/<UTC timestamp>-hub-briefing.md`
7. In the task output, present a concise summary with:
   - what changed
   - what needs attention
   - what looks healthy
   - pipeline by stage
   - source and velocity notes
   - next step

## Constraints

- Keep the weekly snapshot compact and valid against `contracts/connector.snapshot.schema.v1.json`.
- Use the same HubSpot blind-spot language as the Revisor skills.
- If nothing materially changed since the last snapshot, say so plainly.
- If context is older than 30 days, ask for a context refresh in the briefing.
