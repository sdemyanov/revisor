# Probe A - Run Marker

Use this as the full Cowork task prompt.

Assume the working folder for this task is the `schedule-lab` directory that contains `outputs/`, `fixtures/`, and `RESULTS.md`.

On every run:

1. Create any missing folders needed under `./outputs/`.
2. Determine the current local date, local time, and local time zone as best you can from the environment available to you.
3. Generate a unique `run_slug` that will not collide with prior runs.
4. Create a new file in `./outputs/runs/` named `<local-timestamp>--probe-a-run-marker--<run_slug>.md`.
5. Write the following fields into that file:
   - `probe: A`
   - `local_timestamp`
   - `timezone`
   - `run_slug`
   - `task_name` if visible
   - `invocation_type` if visible, otherwise `unknown`
   - `notes` with any clue about whether this run appears scheduled, manual, catch-up, paused/resumed, or unknown
6. Append one new line to `./outputs/logs/run-log.md` in this format:
   `<local_timestamp> | probe=A | run_slug=<run_slug> | task_name=<task_name_or_unknown> | invocation_type=<visible_or_unknown> | timezone=<timezone>`
7. Never overwrite an existing file.
8. If any part of the run fails, append a short failure note to `./outputs/failures/probe-a-failures.md`.

Do not do business analysis. This probe exists only to mark execution behavior.
