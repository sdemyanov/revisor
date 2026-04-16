# Revisor Scheduled Weekly Business Briefing

Run the Revisor combined business weekly briefing workflow against the current workspace.

## Rules

- Treat this task as safe for both automatic scheduled fires and manual `Run on demand`.
- Never overwrite canonical timestamped artifacts.
- Write only inside the mounted workspace tree, using relative `.revisor/...` paths.
- Use timestamped files so reruns on the same day preserve history.
- Read-only connector usage only.

## Required behavior

1. Load `.revisor/context.json`. If it is missing, stop and say the user must run `/revisor:qb-setup` plus the relevant connector setup commands first.
2. Detect connected sources from `source_accounts`.
3. If fewer than 2 useful business sources are connected, stop and say the user should use the source-specific weekly flows instead.
4. Load recent `biz-weekly` snapshots from `.revisor/snapshots/` for comparison.
5. Pull fresh connected-source data:
   - QuickBooks trailing 12 complete month P&L plus fresh cash-through-today when QuickBooks is connected
   - HubSpot open deals plus historical or activity context when HubSpot is connected
   - Stripe subscriptions, customers, invoices, and churn/payment-health signals when Stripe is connected
6. Compare the new data to the latest `biz-weekly` snapshot(s).
7. Write a new weekly snapshot:
   - `.revisor/snapshots/<UTC timestamp>-biz-weekly.json`
8. Write a new markdown briefing:
   - `.revisor/reports/<UTC timestamp>-biz-briefing.md`
9. In the task output, present a concise summary with:
   - what changed
   - what needs attention
   - what looks healthy
   - cross-source read
   - coming up
   - next step

## Constraints

- Keep the weekly snapshot compact and valid against `contracts/connector.snapshot.schema.v1.json`.
- Do not force customer-level joins or profitability claims when deterministic matching is missing.
- If nothing materially changed since the last snapshot, say so plainly.
- If context is older than 30 days, ask for a context refresh in the briefing.
- If a cross-source report card would help, suggest `/revisor:biz-report` at the end.
