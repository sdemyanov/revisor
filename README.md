# Revisor

Revisor is a local-first Claude Cowork plugin for business diagnostics and weekly financial briefings.

This repo has completed Phase 0, locked the Phase 1 contracts, and now includes
the first Phase 2/3 implementation slice:

- package and install the plugin shell
- verify `/revisor:ping` works
- confirm the local marketplace entry can be used for install testing
- lock the initial QuickBooks/file-contract decisions before entrypoint authoring starts
- ship the first shared Revisor reasoning skills plus `/revisor:qb-setup`

## Current Contents

- `.claude-plugin/plugin.json`: plugin manifest
- `skills/ping/SKILL.md`: minimal smoke-test skill
- `skills/qb-setup/SKILL.md`: first real QuickBooks setup flow
- `skills/qb-health/SKILL.md`: read-only QuickBooks diagnostic flow
- `skills/qb-forecast/SKILL.md`: read-only scenario forecast flow
- `skills/qb-snapshot/SKILL.md`: compact point-in-time snapshot writer
- `skills/qb-weekly/SKILL.md`: recurring weekly briefing flow
- `skills/qb-report/SKILL.md`: owner-facing + shareable health report flow
- `skills/qb-expenses/SKILL.md`: expense-category drill-down flow
- `skills/qb-whatif/SKILL.md`: baseline-vs-modified decision simulation flow
- `skills/hub-setup/SKILL.md`: first-pass HubSpot CRM setup flow
- `skills/hub-pipeline/SKILL.md`: HubSpot pipeline snapshot and coverage analysis
- `skills/hub-forecast/SKILL.md`: HubSpot weighted forecast flow
- `skills/hub-velocity/SKILL.md`: HubSpot cycle-time and stalled-deal analysis
- `skills/hub-sources/SKILL.md`: HubSpot source and attribution analysis
- `skills/hub-weekly/SKILL.md`: recurring HubSpot weekly briefing flow
- `skills/biz-health/SKILL.md`: read-only cross-source business diagnostic
- `skills/biz-forecast/SKILL.md`: read-only cross-source business forecast
- `skills/biz-report/SKILL.md`: cross-source owner-facing + shareable health report flow
- `skills/biz-customers/SKILL.md`: cross-source customer or account-priority view
- `skills/biz-weekly/SKILL.md`: recurring unified business weekly briefing flow
- `skills/stripe-setup/SKILL.md`: first-pass Stripe subscription setup flow
- `skills/stripe-mrr/SKILL.md`: Stripe recurring-revenue analysis flow
- `skills/stripe-churn/SKILL.md`: Stripe churn and retention flow
- `skills/stripe-payments/SKILL.md`: Stripe payment-health and collection analysis
- `skills/stripe-weekly/SKILL.md`: recurring Stripe weekly briefing flow
- `skills/01-business-context/SKILL.md`: shared context inference rules
- `skills/02-cash-flow-forecasting/SKILL.md`: shared runway and burn logic
- `skills/03-financial-health/SKILL.md`: shared QuickBooks-first alert logic
- `skills/04-pipeline-analytics/SKILL.md`: shared HubSpot pipeline logic
- `skills/07-cross-source-synthesis/SKILL.md`: shared cross-source synthesis rules
- `skills/08-entity-matching/SKILL.md`: shared deterministic cross-source matching rules
- `skills/06-subscription-intelligence/SKILL.md`: shared Stripe subscription logic
- `skills/11-proactive-analysis/SKILL.md`: shared advisor-style section logic
- `skills/12-health-scoring/SKILL.md`: shared QuickBooks-only scorecard rules
- `skills/13-biz-scoring/SKILL.md`: shared cross-source scorecard rules
- `skills/10-formatting/SKILL.md`: shared output and file-writing rules
- `scheduled/qb-weekly.md`: scheduled weekly briefing prompt
- `scheduled/hub-weekly.md`: scheduled HubSpot weekly briefing prompt
- `scheduled/stripe-weekly.md`: scheduled Stripe weekly briefing prompt
- `scheduled/biz-weekly.md`: scheduled unified business weekly briefing prompt
- `scheduled/README.md`: scheduled prompt notes
- `scheduled/WEEKLY_RUNBOOK.md`: scheduled weekly validation flow
- `validation/README.md`: validation entrypoint and recommended test order
- `validation/run-local-checks.sh`: local manifest/build/schema check runner
- `validation/fresh-install-checklist.md`: first-time install validation checklist
- `validation/qb-command-smoke-tests.md`: live QuickBooks smoke suite
- `validation/hubspot-stripe-smoke-tests.md`: live HubSpot and Stripe smoke suite
- `validation/biz-command-smoke-tests.md`: live cross-source business smoke suite
- `test-marketplace/.claude-plugin/marketplace.json`: local install-test marketplace entry

## Phase 1 Contract Artifacts

- `phase1/quickbooks-capability-matrix.md`: current QuickBooks proof status and remaining connector checks
- `phase1/quickbooks-live-probe.md`: live connector probe results for the current QuickBooks surface
- `phase1/report-artifact-contract.md`: settled artifact naming and redaction rules
- `contracts/context.schema.v1.json`: versioned `context.json` schema
- `contracts/snapshot.schema.v1.json`: versioned snapshot schema
- `contracts/connector.snapshot.schema.v1.json`: generic connector weekly snapshot schema for HubSpot and Stripe
- `examples/context.v1.example.json`: concrete `context.json` example
- `examples/qb-weekly.snapshot.v1.example.json`: concrete snapshot example
- `examples/hub-weekly.snapshot.v1.example.json`: concrete HubSpot weekly snapshot example
- `examples/stripe-weekly.snapshot.v1.example.json`: concrete Stripe weekly snapshot example
- `examples/biz-weekly.snapshot.v1.example.json`: concrete cross-source weekly snapshot example

## Build

From the repo root:

```bash
./build.sh
```

This creates `revisor.plugin`.

## Command Surface

| Command | Purpose | Writes files by default |
|---|---|---|
| `/revisor:qb-setup` | Create or refresh local business context from QuickBooks | Yes |
| `/revisor:qb-health` | Read-only diagnostic and risk summary | No |
| `/revisor:qb-forecast` | Read-only best/base/worst cash forecast | No |
| `/revisor:qb-snapshot` | Save one compact point-in-time metrics artifact | Yes |
| `/revisor:qb-weekly` | Save weekly snapshot plus briefing | Yes |
| `/revisor:qb-report` | Save internal plus shareable report artifacts | Yes |
| `/revisor:qb-expenses` | Read-only expense category drill-down | No |
| `/revisor:qb-whatif` | Read-only baseline-vs-modified scenario modeling | No |
| `/revisor:hub-setup` | Create or refresh local business context from HubSpot CRM | Yes |
| `/revisor:hub-pipeline` | Read-only HubSpot pipeline snapshot and coverage analysis | No |
| `/revisor:hub-forecast` | Read-only HubSpot weighted forecast | No |
| `/revisor:hub-velocity` | Read-only HubSpot cycle-time and stalled-deal analysis | No |
| `/revisor:hub-sources` | Read-only HubSpot source and attribution analysis | No |
| `/revisor:hub-weekly` | Save HubSpot weekly snapshot plus briefing | Yes |
| `/revisor:biz-health` | Read-only combined business diagnostic across connected sources | No |
| `/revisor:biz-forecast` | Read-only combined business forecast across connected sources | No |
| `/revisor:biz-report` | Save internal plus shareable cross-source health report artifacts | Yes |
| `/revisor:biz-customers` | Read-only cross-source customer or account-priority view | No |
| `/revisor:biz-weekly` | Save cross-source weekly snapshot plus briefing | Yes |
| `/revisor:stripe-setup` | Create or refresh local business context from Stripe subscriptions | Yes |
| `/revisor:stripe-mrr` | Read-only Stripe recurring-revenue analysis | No |
| `/revisor:stripe-churn` | Read-only Stripe churn and retention analysis | No |
| `/revisor:stripe-payments` | Read-only Stripe payment-health and collection analysis | No |
| `/revisor:stripe-weekly` | Save Stripe weekly snapshot plus briefing | Yes |

## First Real Flow

With QuickBooks connected in Claude Cowork:

1. Run `/revisor:qb-setup`.
2. Let Revisor create or refresh `.revisor/context.json`.
3. Confirm the first timestamped snapshot appears in `.revisor/snapshots/`.
4. Answer the targeted follow-up questions so the next runs can be more precise.
5. Run `/revisor:qb-health` for the first read-only diagnostic against the saved context.
6. Run `/revisor:qb-forecast` for the first scenario projection.
7. Run `/revisor:qb-snapshot` whenever you want a compact saved point-in-time record without a full weekly briefing.
8. Run `/revisor:qb-expenses` when a category spike needs a drill-down.
9. Run `/revisor:qb-weekly` to save a new weekly snapshot plus briefing.
10. Run `/revisor:qb-report` when you want internal and shareable report artifacts.
11. Run `/revisor:qb-whatif` when you want to compare a proposed decision against the current baseline.
12. If HubSpot is connected, run `/revisor:hub-setup`, `/revisor:hub-pipeline`, `/revisor:hub-forecast`, `/revisor:hub-velocity`, `/revisor:hub-sources`, and `/revisor:hub-weekly`.
13. If Stripe is connected, run `/revisor:stripe-setup`, `/revisor:stripe-mrr`, `/revisor:stripe-churn`, `/revisor:stripe-payments`, and `/revisor:stripe-weekly`.
14. Once the standalone connector loops look trustworthy, run `/revisor:biz-health`, `/revisor:biz-forecast`, and `/revisor:biz-report`.
15. Once the first cross-source pass looks trustworthy, run `/revisor:biz-customers` and `/revisor:biz-weekly`.

## Scheduling

For the recurring weekly loop:

1. make sure `/revisor:qb-setup` has already created `.revisor/context.json`
2. use [`scheduled/qb-weekly.md`](./scheduled/qb-weekly.md), [`scheduled/hub-weekly.md`](./scheduled/hub-weekly.md), [`scheduled/stripe-weekly.md`](./scheduled/stripe-weekly.md), or [`scheduled/biz-weekly.md`](./scheduled/biz-weekly.md) as the task prompt
3. follow [`scheduled/WEEKLY_RUNBOOK.md`](./scheduled/WEEKLY_RUNBOOK.md) for setup and acceptance expectations

Current scheduler expectations:

- writes must stay inside the mounted workspace tree
- same-day reruns must preserve timestamped history
- `Run on demand` should be treated as equivalent to an automatic scheduled run for safety

## Privacy Model

Revisor is local-first, not Revisor-hosted:

- durable state lives in local workspace files under `.revisor/`
- there is no separate Revisor backend in this repo
- internal report artifacts may contain sensitive dollar values
- shareable report artifacts are explicitly redacted for screenshots and sharing
- connector blind spots are named instead of being filled with guesses

QuickBooks data still comes through the active Cowork connector session, so the
honest privacy promise is:

- Revisor stores its own state locally
- Revisor does not require a separate hosted service to function
- shareable artifacts are intentionally less sensitive than internal ones

## Validation

Start here before a manual test pass:

1. run [`validation/run-local-checks.sh`](./validation/run-local-checks.sh)
2. follow [`validation/fresh-install-checklist.md`](./validation/fresh-install-checklist.md)
3. follow [`validation/qb-command-smoke-tests.md`](./validation/qb-command-smoke-tests.md)
4. follow [`validation/hubspot-stripe-smoke-tests.md`](./validation/hubspot-stripe-smoke-tests.md) when those connectors are enabled
5. follow [`validation/biz-command-smoke-tests.md`](./validation/biz-command-smoke-tests.md) once the standalone connector loops are stable

Recommended release-hardening validation round:

1. fresh install
2. scheduled `/revisor:biz-weekly` run
3. `/revisor:biz-customers`
4. `/revisor:biz-weekly`
5. `/revisor:biz-report`

The next release train after v0.1 is:

1. Salesforce parity (`/revisor:sf-*`)
2. connector-specific expansions that depend on currently unproven invoice, aging, or customer-detail surfaces

## Phase 0 Smoke Test

1. Build the package with `./build.sh`.
2. Install the plugin in Claude Cowork using the local package or local marketplace entry.
3. Invoke `/revisor:ping`.
4. Confirm the response matches the expected smoke-test output.

Optional CLI path:

- `claude --plugin-dir /Users/sergey/Projects/revisor-plugin -p "/revisor:ping"` can be used for a fast local smoke test when the local Claude CLI is authenticated.
- If the CLI returns an authentication error, run the smoke test in the Claude desktop/Cowork app instead.

Expected response:

```text
Revisor plugin smoke test OK.
Version: 0.1.0
Skill: ping
```

## License

MIT
