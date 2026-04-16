# Probe E - Failure Probe

Use this as the full Cowork task prompt.

Before saving the task, choose one failure mode:

- Keep the default `missing_fixture` mode for local-file failure testing.
- Replace `missing_fixture` with `disconnected_connector` when you want to test expired or missing connector access.
- If you choose connector failure, also replace `<TARGET_CONNECTOR>` with the connector name you plan to disconnect before the run.

Assume the working folder for this task is the `schedule-lab` directory.

On every run:

1. Create any missing folders needed under `./outputs/`.
2. Determine the current local timestamp and generate a unique `run_slug`.
3. Create a file in `./outputs/failures/` named `<local-timestamp>--probe-e-started--<run_slug>.md`.
4. In that file, record:
   - `probe: E`
   - `local_timestamp`
   - `run_slug`
   - `failure_mode: missing_fixture`
   - `target_connector: <TARGET_CONNECTOR>` only if that mode is being used
5. Append one new line to `./outputs/logs/failure-probe-log.md` saying the run started.
6. Trigger the selected failure mode:
   - If `failure_mode` is `missing_fixture`, try to read `./fixtures/does-not-exist.txt`.
   - If `failure_mode` is `disconnected_connector`, attempt the smallest safe read-only action against `<TARGET_CONNECTOR>`.
7. After the failure attempt, write what happened to `./outputs/failures/<local-timestamp>--probe-e-result--<run_slug>.md` if the task is still able to continue.
8. Append a final summary line to `./outputs/logs/failure-probe-log.md` if the task is still able to continue.
9. Never overwrite an existing file.

This probe should fail in a controlled way after a small local write so partial-write behavior is easy to inspect.
