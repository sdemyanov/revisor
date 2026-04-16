# Revisor Plugin Install Smoke Test

This repo contains the minimal Revisor plugin needed to complete Phase 0:
package validation, local loading, marketplace install testing, and one working
smoke-test skill.

For the broader QuickBooks validation flow after install, use:

- [validation/README.md](/Users/sergey/Projects/revisor-plugin/validation/README.md)
- [validation/fresh-install-checklist.md](/Users/sergey/Projects/revisor-plugin/validation/fresh-install-checklist.md)
- [validation/qb-command-smoke-tests.md](/Users/sergey/Projects/revisor-plugin/validation/qb-command-smoke-tests.md)

## Included

- plugin manifest: [.claude-plugin/plugin.json](/Users/sergey/Projects/revisor-plugin/.claude-plugin/plugin.json)
- smoke-test skill: [skills/ping/SKILL.md](/Users/sergey/Projects/revisor-plugin/skills/ping/SKILL.md)
- local test marketplace: [test-marketplace/.claude-plugin/marketplace.json](/Users/sergey/Projects/revisor-plugin/test-marketplace/.claude-plugin/marketplace.json)
- local marketplace plugin link: `test-marketplace/plugins/revisor`
- package builder: [build.sh](/Users/sergey/Projects/revisor-plugin/build.sh)

## Validation

Validate the plugin manifest:

```bash
claude plugin validate /Users/sergey/Projects/revisor-plugin
```

Validate the local test marketplace:

```bash
claude plugin validate /Users/sergey/Projects/revisor-plugin/test-marketplace
```

Build the package:

```bash
cd /Users/sergey/Projects/revisor-plugin
./build.sh
```

## Fastest Local Load

This loads the plugin for one Claude session without installing it globally:

```bash
claude --plugin-dir /Users/sergey/Projects/revisor-plugin
```

Then invoke:

```text
/revisor:ping
```

If your environment prefers natural language:

```text
revisor ping
```

If the local `claude` CLI is not authenticated, this path may fail before skill
execution. On this machine, `claude --plugin-dir ... -p "/revisor:ping"` reached
the session startup path but returned a 401 authentication error. In that case,
use the Claude desktop/Cowork app for the Phase 0 smoke test instead.

Expected response:

```text
Revisor plugin smoke test OK.
Version: 0.1.0
Skill: ping
```

## Local Marketplace Install Flow

1. Start `claude` from any directory.
2. Add the marketplace:

```text
/plugin marketplace add /Users/sergey/Projects/revisor-plugin/test-marketplace
```

3. Install the plugin:

```text
/plugin install revisor@revisor-local-test-marketplace
```

4. Restart Claude if prompted.
5. Invoke `/revisor:ping`.

## Manual Acceptance For Phase 0

Phase 0 is complete when all of these are true:

- `claude plugin validate` passes for the plugin root
- `claude plugin validate` passes for `test-marketplace`
- `./build.sh` creates `revisor.plugin`
- `/revisor:ping` works in a real Claude session
- the marketplace install path succeeds

## After Phase 0

Once the ping smoke test passes, the next validation pass should move to:

1. `/revisor:qb-setup`
2. `/revisor:qb-health`
3. `/revisor:qb-forecast`
4. `/revisor:qb-weekly`
5. `/revisor:qb-report`
6. `/revisor:qb-whatif`
7. if HubSpot is connected: `/revisor:hub-setup`, `/revisor:hub-pipeline`, `/revisor:hub-forecast`
8. if HubSpot is connected and the first pass looks good: `/revisor:hub-velocity`, `/revisor:hub-sources`, `/revisor:hub-weekly`
9. if Stripe is connected: `/revisor:stripe-setup`, `/revisor:stripe-mrr`, `/revisor:stripe-churn`
10. if Stripe is connected and the first pass looks good: `/revisor:stripe-payments`, `/revisor:stripe-weekly`
11. once the standalone loops are stable: `/revisor:biz-health`, `/revisor:biz-forecast`, `/revisor:biz-report`
12. once the first cross-source pass looks good: `/revisor:biz-customers`, `/revisor:biz-weekly`

Use the files under `validation/` so those checks stay repeatable.
