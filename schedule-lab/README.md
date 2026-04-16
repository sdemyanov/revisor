# Schedule Lab Runbook

## Purpose

This folder is a runnable harness for the scheduled-task behavior work described in `REVISOR_SCHEDULED_TASK_BEHAVIOR_TEST_PLAN.md`.

Use it to answer platform questions before Revisor depends on Cowork scheduling for weekly briefings, file writes, and optional outbound notifications.

## Use This Folder as the Working Directory

For every Cowork task in this lab, set the working folder to:

`/Users/sergey/Projects/revisor-plugin/schedule-lab`

All prompt files in `prompts/` assume that folder is selected. They write only to relative paths inside this lab.

## Folder Layout

- `prompts/` contains the probe prompts you paste into Cowork.
- `fixtures/` contains local files used by the probes.
- `outputs/` is where Cowork should write run markers, logs, and failure evidence.
- `RESULTS.md` is the ledger for recording what you observed.

## Prompt Map

- `prompts/probe-a-run-marker.md`: T1, T2, T3, T4, T5, T6, T14, T15
- `prompts/probe-b-relative-path.md`: T7, T8
- `prompts/probe-c-capability-parity.md`: T9, T10
- `prompts/probe-d-side-effect.md`: T13
- `prompts/probe-e-failure.md`: T11, T12
- `prompts/probe-f-long-run.md`: T16

## Before You Start

1. Keep `RESULTS.md` open and fill in one section immediately after each test.
2. Use private destinations only for Slack or email delivery.
3. If you want clean counts for each pass, archive old files from `outputs/` before starting the next pass.
4. For T9 and T10, decide which plugin/skill and connector you want to test before creating the task.
5. For T11, decide whether you want the failure to come from a missing local file or from a disconnected connector.

## How to Create a Task

You can create tasks either from the Scheduled page or with `/schedule`. The test matrix includes both because parity itself is something we want to learn.

For each task:

1. Open Cowork.
2. Create a new task from the Scheduled page or use `/schedule`, depending on the test case.
3. Give the task a name that includes the test ID.
4. Set the working folder to `/Users/sergey/Projects/revisor-plugin/schedule-lab`.
5. Open the matching file in `prompts/` and paste its contents into the task prompt.
6. Replace any placeholders before saving. Probe C, Probe D, and Probe E include placeholders.
7. Pick the cadence required by the test case.
8. Save the task.
9. Use "Run on demand" when the test case calls for a manual comparison.

Suggested task-name pattern:

`lab-T3-run-marker-hourly`

## Recommended Execution Order

### Pass 1 - Baseline

Run these first:

- T1 basic scheduled run
- T2 `/schedule` vs Scheduled page parity
- T6 on-demand plus recurring

How to run them:

- Use `prompts/probe-a-run-marker.md`.
- For T1, create one recurring task, run it manually once, then wait for the next scheduled run.
- For T2, create two equivalent Probe A tasks: one from the Scheduled page and one with `/schedule`. Compare the resulting history and output files.
- For T6, use one recurring Probe A task and click "Run on demand" between scheduled runs. Check whether history clearly labels the run types.

### Pass 2 - Catch-Up and History

Run next:

- T3 single missed run catch-up
- T4 multiple missed intervals
- T5 pause/resume

How to run them:

- Use `prompts/probe-a-run-marker.md`.
- For T3, miss one interval by closing the app or sleeping the machine, then reopen and compare history rows with new output files.
- For T4, miss three or more intervals, reopen later, then count how many run files were created and how many history entries appeared.
- For T5, pause the recurring task before the next scheduled run, resume later, and check whether paused intervals are replayed or permanently skipped.

### Pass 3 - File and Folder Safety

Run next:

- T7 relative path resolution
- T8 folder moved or renamed
- T12 partial-write failure behavior

How to run them:

- Use `prompts/probe-b-relative-path.md` for T7 and T8.
- For T7, run it once manually and once as scheduled, then inspect where the files landed.
- For T8, rename or move the `schedule-lab` folder before the next scheduled run, then observe the result and restore the folder afterward.
- Use `prompts/probe-e-failure.md` for T12 and keep the default missing-file failure mode. Confirm that the initial marker is written before the failure occurs.

### Pass 4 - Capability Parity

Run next:

- T9 plugin and skill parity
- T10 connector parity
- T11 connector auth expiry

How to run them:

- Use `prompts/probe-c-capability-parity.md` for T9 and T10.
- Replace the placeholders with the specific plugin/skill and connector you want to probe.
- Run once manually and once on schedule, then compare logs.
- For T11, use `prompts/probe-e-failure.md`, switch the failure mode to a disconnected connector, then disconnect or expire the target connector before the scheduled run.

### Pass 5 - Operational Edge Cases

Run last:

- T13 duplicate external side effects
- T14 time zone basis
- T15 DST or time-zone change behavior
- T16 overlapping-run behavior

How to run them:

- Use `prompts/probe-d-side-effect.md` for T13 and replace the delivery placeholder with a private destination.
- Use `prompts/probe-a-run-marker.md` for T14 and T15. Compare task history timestamps with the timestamps written into the output files.
- Use `prompts/probe-f-long-run.md` for T16. Choose the shortest practical interval and inspect whether later runs queue, overlap, or skip while the previous run is still busy.

## How to Inspect Results

After each run:

1. Open `outputs/runs/`, `outputs/logs/`, `outputs/notifications/`, `outputs/failures/`, and `outputs/path-probe/`.
2. Compare the file count and timestamps with the Scheduled-task history in Cowork.
3. Record what happened in `RESULTS.md`.
4. Save screenshots for history rows, skipped-run notices, or outbound messages.

## Minimum Useful First Session

If you only want the fastest path to useful signal, do this:

1. Run T1.
2. Run T3.
3. Run T4.
4. Run T7.
5. Run T10.
6. Run T12.

That subset answers the most important MVP questions: basic parity, catch-up semantics, file safety, connector parity, and partial-write failure behavior.

## Notes

- Probe prompts are intentionally append-only so duplicate behavior is obvious.
- Do not use real customer data in this lab.
- For T13, keep the test destination private and ephemeral.
- T16 is the least certain test because Cowork intervals may be too wide to make overlap easy to observe. Treat it as optional if the platform does not make it practical.
