# Probe B - Relative Path and Folder Probe

Use this as the full Cowork task prompt.

Assume the working folder for this task is the `schedule-lab` directory unless the test intentionally changes or breaks it.

On every run:

1. Create any missing folders needed under `./outputs/`.
2. Determine the current local date, local time, and local time zone as best you can from the environment available to you.
3. Generate a unique `run_slug`.
4. Attempt to read `./fixtures/small.txt`.
5. Create a new file in `./outputs/path-probe/` named `<local-timestamp>--probe-b-path-check--<run_slug>.md`.
6. In that file, record:
   - `probe: B`
   - `local_timestamp`
   - `timezone`
   - `run_slug`
   - whether `./fixtures/small.txt` was readable
   - whether writes to `./outputs/path-probe/` succeeded
   - whether writes to `./outputs/path-probe/nested/` succeeded
   - any clue about the current working folder if visible
7. Create `./outputs/path-probe/nested/<local-timestamp>--nested-check--<run_slug>.txt` with a short confirmation line.
8. Append one new line to `./outputs/logs/path-probe-log.md` summarizing the read/write results.
9. If any path operation fails, append a short failure note to `./outputs/failures/path-probe.md`.
10. Never overwrite an existing file.

Do not recover by switching to unrelated folders. The point is to learn what the selected working folder allows and what breaks when it changes.
