# Probe C - Connector and Plugin Parity Probe

Use this as the full Cowork task prompt.

Before saving the task, replace these placeholders:

- `<TARGET_PLUGIN_OR_SKILL>` with the plugin or skill you want to check
- `<TARGET_CONNECTOR>` with the connector you want to check

Assume the working folder for this task is the `schedule-lab` directory.

On every run:

1. Create any missing folders needed under `./outputs/`.
2. Determine the current local timestamp and generate a unique `run_slug`.
3. Create a new file in `./outputs/runs/` named `<local-timestamp>--probe-c-capability-check--<run_slug>.md`.
4. In that file, record:
   - `probe: C`
   - `local_timestamp`
   - `run_slug`
   - `target_plugin_or_skill: <TARGET_PLUGIN_OR_SKILL>`
   - `target_connector: <TARGET_CONNECTOR>`
5. Check whether `<TARGET_PLUGIN_OR_SKILL>` is visible and usable in this scheduled session. Perform the smallest safe verification available and record the result.
6. Check whether `<TARGET_CONNECTOR>` is visible and usable in this scheduled session. Perform the smallest safe read-only verification available and record the result.
7. Append one new line to `./outputs/logs/capability-probe.md` summarizing both checks.
8. If either check fails, append a failure note to `./outputs/failures/capability-probe-failures.md`.
9. Never overwrite an existing file.

Do not run real business workflows. This probe exists only to compare capability access between manual and scheduled contexts.
