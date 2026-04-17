# Revisor

Revisor is a local-first Claude Cowork plugin for business diagnostics, forecasts, reports, and weekly briefings across QuickBooks, HubSpot, and Stripe.

## Release

`v1.0` is the current release in this workspace.

## What Revisor Does

- **QuickBooks**: setup, health checks, forecasts, snapshots, expense drill-downs, weekly briefings, reports, and what-if scenarios
- **HubSpot**: setup, pipeline analysis, forecasts, velocity analysis, source analysis, and weekly briefings
- **Stripe**: setup, MRR analysis, churn analysis, payment-health checks, and weekly briefings
- **Cross-source**: unified business health, forecasts, reports, customer/account views, and weekly briefings when multiple sources are connected

## Get Started

1. Install the plugin in Claude Cowork.
2. Connect the sources you actually use.
3. Run the matching setup command for each connected source.

| Source | Start here | Then use |
|---|---|---|
| QuickBooks | `/revisor:qb-setup` | `/revisor:qb-health`, `/revisor:qb-forecast`, `/revisor:qb-snapshot`, `/revisor:qb-expenses`, `/revisor:qb-weekly`, `/revisor:qb-report`, `/revisor:qb-whatif` |
| HubSpot | `/revisor:hub-setup` | `/revisor:hub-pipeline`, `/revisor:hub-forecast`, `/revisor:hub-velocity`, `/revisor:hub-sources`, `/revisor:hub-weekly` |
| Stripe | `/revisor:stripe-setup` | `/revisor:stripe-mrr`, `/revisor:stripe-churn`, `/revisor:stripe-payments`, `/revisor:stripe-weekly` |

If two or more sources are connected, use the business layer:

- `/revisor:biz-health`
- `/revisor:biz-forecast`
- `/revisor:biz-report`
- `/revisor:biz-customers`
- `/revisor:biz-weekly`

## Local Files

Revisor stores its own state in the workspace:

- `.revisor/context.json`
- `.revisor/snapshots/`
- `.revisor/reports/`

These files are meant to be inspectable, editable, and portable with the project.

## Weekly Briefings

For scheduled runs, use the matching prompt under [`scheduled/`](./scheduled/README.md):

- [`scheduled/qb-weekly.md`](./scheduled/qb-weekly.md)
- [`scheduled/hub-weekly.md`](./scheduled/hub-weekly.md)
- [`scheduled/stripe-weekly.md`](./scheduled/stripe-weekly.md)
- [`scheduled/biz-weekly.md`](./scheduled/biz-weekly.md) when multiple sources are connected

## Privacy

Revisor is local-first:

- durable Revisor state lives in local workspace files
- there is no separate Revisor backend in this repo
- internal report artifacts may contain sensitive values
- shareable report artifacts are intentionally redacted
- connector blind spots are named instead of filled with guesses

## Local Development

Build the package:

```bash
./build.sh
```

Run local checks:

```bash
bash validation/run-local-checks.sh
```

For install and smoke-test steps, see [`SMOKE_TEST.md`](./SMOKE_TEST.md). For release notes, see [`CHANGELOG.md`](./CHANGELOG.md). For deeper manual validation, see [`validation/README.md`](./validation/README.md).

## License

MIT
