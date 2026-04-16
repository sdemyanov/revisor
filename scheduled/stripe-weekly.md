# Revisor Scheduled Weekly Stripe Briefing

Run the Revisor weekly Stripe briefing workflow against the current workspace.

## Rules

- Treat this task as safe for both automatic scheduled fires and manual `Run on demand`.
- Never overwrite canonical timestamped artifacts.
- Write only inside the mounted workspace tree, using relative `.revisor/...` paths.
- Use timestamped files so reruns on the same day preserve history.
- Read-only Stripe only.

## Required behavior

1. Load `.revisor/context.json`. If it is missing, stop and say the user must run `/revisor:stripe-setup` first.
2. Load recent Stripe weekly snapshots from `.revisor/snapshots/` for comparison.
3. Pull fresh Stripe data:
   - subscriptions
   - customers
   - invoices or payment health signals when available
   - cancellation/status history when available
4. Compare the new data to the latest Stripe weekly snapshot(s).
5. Write a new weekly snapshot:
   - `.revisor/snapshots/<UTC timestamp>-stripe-weekly.json`
6. Write a new markdown briefing:
   - `.revisor/reports/<UTC timestamp>-stripe-briefing.md`
7. In the task output, present a concise summary with:
   - what changed
   - what needs attention
   - what looks healthy
   - MRR movement
   - churn and collection notes
   - next step

## Constraints

- Keep the weekly snapshot compact and valid against `contracts/connector.snapshot.schema.v1.json`.
- Use the same Stripe blind-spot language as the Revisor skills.
- If nothing materially changed since the last snapshot, say so plainly.
- If context is older than 30 days, ask for a context refresh in the briefing.
