# Revisor Scheduled Weekly QuickBooks Briefing

Run the Revisor weekly QuickBooks briefing workflow against the current workspace.

## Rules

- Treat this task as safe for both automatic scheduled fires and manual `Run on demand`.
- Never overwrite canonical timestamped artifacts.
- Write only inside the mounted workspace tree, using relative `.revisor/...` paths.
- Use timestamped files so reruns on the same day preserve history.
- Read-only QuickBooks only. Never call `quickbooks-profile-info-update` or `quickbooks-transaction-import`.

## Required behavior

1. Load `.revisor/context.json`. If it is missing, stop and say the user must run `/revisor:qb-setup` first.
2. Load recent snapshots from `.revisor/snapshots/` for comparison.
3. Pull fresh QuickBooks data:
   - trailing 12 complete month P&L window
   - fresh cash-flow window ending today
4. Compare the new data to the latest snapshot(s).
5. Write a new weekly snapshot:
   - `.revisor/snapshots/<UTC timestamp>-qb-weekly.json`
6. Write a new markdown briefing:
   - `.revisor/reports/<UTC timestamp>-briefing.md`
7. In the task output, present a concise summary with:
   - what changed
   - what needs attention
   - what looks healthy
   - coming up
   - next step

## Constraints

- Keep the weekly snapshot compact and schema-valid.
- Use the same QuickBooks-only blind-spot language as the Revisor skills.
- If nothing materially changed since the last snapshot, say so plainly.
- If context is older than 30 days, ask for a context refresh in the briefing.
- If a shareable report would help, suggest `/revisor:qb-report` at the end.
