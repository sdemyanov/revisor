# Probe F - Long-Run / Overlap Probe

Use this as the full Cowork task prompt.

Assume the working folder for this task is the `schedule-lab` directory.

On every run:

1. Create any missing folders needed under `./outputs/`.
2. Determine the current local timestamp and generate a unique `run_slug`.
3. Immediately create `./outputs/runs/<local-timestamp>--probe-f-start--<run_slug>.md` with:
   - `probe: F`
   - `phase: start`
   - `local_timestamp`
   - `run_slug`
4. Read `./fixtures/medium.txt`.
5. Perform a deliberately multi-step analysis of that file:
   - create a structured outline
   - extract recurring themes
   - classify each section into one category
   - produce a condensed summary
   - produce an alternate summary from a different angle
6. Save the analysis result to `./outputs/runs/<local-timestamp>--probe-f-analysis--<run_slug>.md`.
7. Create `./outputs/runs/<local-timestamp>--probe-f-end--<run_slug>.md` with:
   - `probe: F`
   - `phase: end`
   - `local_timestamp`
   - `run_slug`
8. Append one line to `./outputs/logs/long-run-log.md` noting that the run started and ended.
9. Never overwrite an existing file.

This probe exists to learn whether later intervals queue, overlap, or skip when one run is still busy. If Cowork's shortest available interval is too wide to make overlap practical, treat this probe as optional evidence rather than a blocker.
