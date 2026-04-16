# Probe D - Side-Effect Probe

Use this as the full Cowork task prompt.

Before saving the task, replace `<PRIVATE_DELIVERY_TARGET>` with the private Slack channel, email destination, or other user-controlled endpoint you want to test.

Assume the working folder for this task is the `schedule-lab` directory.

On every run:

1. Create any missing folders needed under `./outputs/`.
2. Determine the current local timestamp and generate a unique `run_slug`.
3. Create a new file in `./outputs/notifications/` named `<local-timestamp>--probe-d-side-effect--<run_slug>.md`.
4. Write the following into that file:
   - `probe: D`
   - `local_timestamp`
   - `run_slug`
   - `delivery_target: <PRIVATE_DELIVERY_TARGET>`
5. Append one new line to `./outputs/logs/notification-log.md` with the same information.
6. Send exactly one outbound message to `<PRIVATE_DELIVERY_TARGET>` containing the `run_slug` and the local timestamp.
7. If outbound delivery is unavailable, record that failure in `./outputs/failures/side-effect-failures.md`.
8. Never overwrite an existing file.
9. Never re-use a prior `run_slug`.

Do not post publicly. This probe exists only to detect duplicate or replayed side effects.
