# Scheduled Prompts

This directory is intentionally present in Phase 0 so the packaged plugin already
matches the planned top-level shape.

The scheduled prompts now included are:

- `qb-weekly.md`: weekly QuickBooks briefing workflow for Cowork scheduled tasks
- `hub-weekly.md`: weekly HubSpot briefing workflow for Cowork scheduled tasks
- `stripe-weekly.md`: weekly Stripe briefing workflow for Cowork scheduled tasks
- `biz-weekly.md`: unified weekly business briefing across connected sources

Use this runbook when validating it:

- `WEEKLY_RUNBOOK.md`: task setup, acceptance checks, and known scheduler behaviors

All scheduled prompts should keep the same safety properties:

- write only inside the mounted workspace tree
- use timestamped immutable artifacts
- preserve same-day history
- stop cleanly when required setup context is missing
