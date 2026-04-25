# Revisor

## What it is

Revisor is a local-first Claude Cowork plugin for business diagnostics, forecasts, reports, and weekly briefings across QuickBooks, HubSpot, and Stripe.

## Who is this for

Revisor is for the person who runs the business but doesn't have a CFO, an analyst, or a spare afternoon. You already have your books in QuickBooks, your pipeline in HubSpot, and your subscriptions in Stripe — Revisor reads what's already there and tells you, in plain English, how the business is actually doing.

It's aimed at founders, owner-operators, and finance-of-one teams who want to walk into Monday knowing the cash runway, what changed last week, which deals are stuck, and what's quietly drifting — without having to build spreadsheets or learn a new dashboard. You stay in Claude, ask normal questions, and get back diagnostics, forecasts, and weekly briefings you can act on or share. Nothing leaves your workspace except the API calls Cowork already makes to your connected accounts.

## Release

`v1.0.0` is the current release in this workspace. See [`CHANGELOG.md`](./CHANGELOG.md) for the full set of shipped flows and what is intentionally deferred.

## What Revisor Does

- **QuickBooks**: setup, health checks, forecasts, snapshots, expense drill-downs, weekly briefings, reports, and what-if scenarios
- **HubSpot**: setup, pipeline analysis, forecasts, velocity analysis, source analysis, and weekly briefings
- **Stripe**: setup, MRR analysis, churn analysis, payment-health checks, and weekly briefings
- **Cross-source**: unified business health, forecasts, reports, customer/account views, and weekly briefings when multiple sources are connected

## Prerequisites

Revisor is built for Claude Cowork and uses Cowork's connector and scheduled-task surfaces. Before running anything beyond `/revisor:ping`, make sure:

- You are using Claude Cowork (the plugin assumes Cowork mode and the mounted workspace).
- The MCP connectors for the sources you intend to use are installed and authenticated in Cowork: QuickBooks for the `qb-*` flows, HubSpot for the `hub-*` flows, Stripe for the `stripe-*` flows.
- You have selected a workspace folder. Revisor's setup commands write durable state into `.revisor/` inside that folder.

The `biz-*` cross-source flows activate automatically once two or more of the above sources are connected.

## Get Started

1. Install the plugin: download `revisor.plugin` from the latest release, then in Claude Desktop go to Cowork → Customize → Add plugin → Personal → Upload and select the file. For local development from this repo (bundled marketplace under [`test-marketplace/`](./test-marketplace/) or `claude --plugin-dir`) see [`SMOKE_TEST.md`](./SMOKE_TEST.md).
2. Connect the sources you actually use.
3. Confirm the plugin is loaded with `/revisor:ping`.
4. Run the matching setup command for each connected source.

| Source | Start here | Then use |
|---|---|---|
| Any | `/revisor:ping` | (sanity check that the plugin is installed and loaded) |
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

- `.revisor/context.json` — canonical business context built by the setup commands
- `.revisor/snapshots/` — timestamped, immutable point-in-time captures
- `.revisor/reports/` — internal and shareable report artifacts

These files are meant to be inspectable, editable, and portable with the project. The JSON shape is pinned by the schemas in [`contracts/`](./contracts/) and illustrated by the fixtures in [`examples/`](./examples/):

- [`contracts/context.schema.v1.json`](./contracts/context.schema.v1.json)
- [`contracts/snapshot.schema.v1.json`](./contracts/snapshot.schema.v1.json)
- [`contracts/connector.snapshot.schema.v1.json`](./contracts/connector.snapshot.schema.v1.json)

A rendered sample of an internal Business Health Report lives in [`demo-reports/`](./demo-reports/) so you can see what the cross-source output looks like before connecting anything.

## Weekly Briefings

For scheduled runs, use the matching prompt under [`scheduled/`](./scheduled/README.md):

- [`scheduled/qb-weekly.md`](./scheduled/qb-weekly.md)
- [`scheduled/hub-weekly.md`](./scheduled/hub-weekly.md)
- [`scheduled/stripe-weekly.md`](./scheduled/stripe-weekly.md)
- [`scheduled/biz-weekly.md`](./scheduled/biz-weekly.md) when multiple sources are connected

The end-to-end task setup, acceptance checks, and known scheduler behaviors are captured in [`scheduled/WEEKLY_RUNBOOK.md`](./scheduled/WEEKLY_RUNBOOK.md).

## Privacy

Revisor is local-first:

- durable Revisor state lives in local workspace files
- there is no separate Revisor backend in this repo (the connectors themselves still call out to QuickBooks, HubSpot, and Stripe through Cowork)
- internal report artifacts may contain sensitive values
- shareable report artifacts are intentionally redacted
- connector blind spots are named instead of filled with guesses

To clear all local Revisor state, delete `.revisor/` and `reports/` from your workspace.

## Repository Layout

- `.claude-plugin/` — plugin manifest (`plugin.json`)
- `skills/` — per-command skills plus shared skills (`01-business-context`, `10-formatting`, scoring, etc.)
- `scheduled/` — scheduled-task prompts and the weekly runbook
- `contracts/` — pinned JSON schemas for context and snapshots
- `examples/` — example context and weekly-snapshot JSON for each source
- `demo-reports/` — rendered sample reports
- `validation/` — fresh-install checklist and command smoke tests
- `test-marketplace/` — local marketplace scaffold for install testing
- `build.sh` — packages the plugin into `revisor.plugin`

## Create Your Own Skill

Revisor is intentionally extensible — every command in the tables above is just a skill folder under `skills/`. To add your own:

1. Create a new folder, e.g. `skills/qb-my-analysis/`.
2. Add a `SKILL.md` with YAML frontmatter (`name`, `description`, optional `metadata.version`) followed by the prompt body. The `description` is what tells Claude when to invoke the skill, so be specific about the trigger phrases and the slash command (for example, `/revisor:qb-my-analysis`).
3. If your skill needs reusable logic, factor it into a numbered shared skill (see `skills/01-business-context/`, `skills/10-formatting/`, etc.) and reference it from your skill.
4. Put one or more example prompts under an `evals/` subfolder if you want to keep regression cases alongside the skill — `skills/qb-top-expense/evals/` is a working example.
5. Re-run `./build.sh` and reload the plugin to pick up the new skill.

A minimal `SKILL.md` looks like this:

```markdown
---
name: qb-my-analysis
description: >
  Use when the user says "/revisor:qb-my-analysis" or asks for
  <your specific analysis>. Reads `.revisor/context.json` and the
  latest QuickBooks snapshot, and produces <output shape>.
metadata:
  version: "0.1.0"
---

# QuickBooks: My Analysis

<prompt body — what data to load, how to reason, what to write>
```

Conventions worth following: read existing context from `.revisor/context.json` rather than re-asking the user, write durable artifacts under `.revisor/snapshots/` or `.revisor/reports/` with a timestamped filename, and lean on the shared skills (`07-cross-source-synthesis`, `10-formatting`, `11-proactive-analysis`, `12-health-scoring` / `13-biz-scoring`) so your output stays consistent with the rest of Revisor.

## Troubleshooting

- `/revisor:ping` does not respond: the plugin is not loaded — re-run the install steps in [`SMOKE_TEST.md`](./SMOKE_TEST.md).
- A `qb-*`, `hub-*`, or `stripe-*` command reports missing data: confirm the matching MCP connector is installed and authenticated in Cowork, then re-run the corresponding `*-setup` command.
- A `biz-*` command says it cannot run: at least two sources must be connected and set up before cross-source flows activate.

## License

MIT (see [`LICENSE`](./LICENSE)).
