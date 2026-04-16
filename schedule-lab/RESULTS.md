# Schedule Lab Results

Use this ledger to record what happened in each scheduled-task behavior experiment.

## Status Summary

| Test | Status | Short conclusion |
|------|--------|------------------|
| T1 | DONE | Scheduled task fires reliably; ~88% of minute-cron ticks executed (15/17); per-fire delay 5-50s past tick |
| T2 | DONE (with insight) | Programmatic and UI tasks behave identically once running; the only observable difference is creation/management surface; UI-created `lab-t2-run-marker-ui` was set up as "Manual only" while programmatic was recurring (Sergey's choice on UI form) |
| T3 | Awaiting Sergey | Close Cowork for ~3 minutes during a recurring window then reopen — playbook below. Use existing tasks (re-enable T1 or T6 first). |
| T4 | Awaiting Sergey | Same protocol as T3 but ≥3 missed intervals — playbook below |
| T5 | Pause window started | Task paused at 2026-04-15 ~12:58 PT after 3 observed fires; the third fire at 12:58:08 may have raced with the pause action. Sergey to re-enable after ≥5 minutes; observe whether paused intervals replay |
| T6 | DONE (negative finding) | From inside the running session, manual ("Run on demand") and scheduled fires are INDISTINGUISHABLE — both carry `CLAUDE_CODE_TAGS=lam_session_type:scheduled` and the same `<scheduled-task>` prompt wrapper. Distinguishability, if any, lives only in the Scheduled-page UI history (Sergey to confirm via screenshot) |
| T7 | DONE | Relative paths resolve to the EPHEMERAL sandbox root (`/sessions/<sandbox>/outputs/...`), NOT the workspace folder — files vanish with the sandbox. Use absolute host paths for persistent output |
| T8 | Awaiting Sergey | Rename `schedule-lab/` to `schedule-lab-renamed/` for one minute, then restore — playbook below |
| T9 | DONE | Skill tool is available in scheduled sessions; scheduled-session filesystem enumeration matched the in-session system reminder, and `pdf` loaded successfully via the Skill tool |
| T10 | DONE | Scheduled sessions can see and use an authenticated QuickBooks connector. Final parity run saw 43 tools across 8 servers, including QuickBooks (11 tools), and a scheduled `company-info` probe succeeded |
| T11 | Awaiting Sergey | Disconnect a connector before next scheduled fire — playbook below |
| T12 | In flight | First fire imminent; will inspect failure-probe-log.md |
| T13 | Awaiting destination | Needs Sergey to provide a private Slack channel or email inbox; tasks not created until destination is confirmed |
| T14 | PARTIAL (metadata only) | Cron interpreted in user's local TZ (PDT). Confirmed: cron `0 12 * * *` → nextRunAt `2026-04-16T19:00:54Z` (12:00 PDT == 19:00 UTC). Dispatch jitter: 54 seconds. Daily fire still pending for full end-to-end confirmation |
| T15 | Awaiting Sergey | Requires changing macOS system TZ; playbook below — optional, not on MVP critical path |
| T16 | In flight | First fire imminent; long-running task (90s sleep) on every-minute schedule — will produce overlap/queue/skip evidence |

## Pass 1 Headline Findings (apply across multiple tests)

These cross-cutting observations come from T1+T2+T6+T7+T9+T14 evidence and should drive Revisor product decisions immediately.

1. **Each scheduled run starts in a fresh ephemeral sandbox** (`/sessions/<adjective-adjective-name>/`). 50+ distinct sandbox names observed in 17 minutes. State does NOT persist between runs.
2. **Workspace mount**: `/Users/sergey/Projects/revisor-plugin` (host) → `/sessions/<sandbox>/mnt/revisor-plugin` (in-sandbox). The host path is exposed to the running session via env var `CLAUDE_CODE_WORKSPACE_HOST_PATHS`.
3. **Absolute host paths in the prompt are auto-translated to the sandbox mount** when the task uses standard file operations — both forms end up at the same host file. This is robust enough to recommend as the default Revisor pattern.
4. **Relative paths are NOT safe** — they resolve to `/sessions/<sandbox>/<...>`, an ephemeral scratchpad the user cannot see. The CWD is not the workspace folder by default; even within the same task, CWD varied (one T1 run had `cwd=.../schedule-lab`, all others had bare sandbox root).
5. **`invocation_type` is opaque to the running session** — `lam_session_type:scheduled` tag fires for both scheduled and manual-from-UI runs. Plan for idempotent prompts; do not branch on invocation type from inside.
6. **Cron is evaluated in the user's local time zone**, with a deterministic dispatch jitter (observed 5-54 seconds) added per task. Document this for users so they don't expect second-precision firing.
7. **Cadence is best-effort**: at every-minute cron, ~80-88% of ticks produced runs in our sample. At weekly cadences this is irrelevant; at sub-hourly cadences Revisor cannot count on every tick.
8. **Skills are available** in scheduled sessions (T9). The Skill tool works, and scheduled-session filesystem enumeration matches the scheduled session's `<available_skills>` system reminder.
9. **One T1 fire reported `timezone=Etc/UTC`** despite `$TZ=America/Los_Angeles` in the diagnostic — environment can occasionally drift. Don't read TZ from a single source; cross-check.
10. **Two T6 fires landed at the exact same second (12:23:06)** in different sandboxes — a manual on-demand click coincided with a scheduled fire. Both produced full output. Revisor must dedupe by run_slug at the file/destination layer if duplicate side effects matter.
11. **Scheduled sessions can access authenticated third-party connectors** when those connectors are actually installed and authorized. Early T10 fires showed only framework MCPs because no third-party connector had been connected yet; the final T10 parity run exposed QuickBooks (11 tools) in the scheduled session and successfully executed the read-only `company-info` probe without re-auth prompts. For Revisor MVP, that means a desktop scheduled weekly QuickBooks briefing can pull fresh QuickBooks data directly, while still treating each additional connector as a separate parity check until proven.

## Template

Copy this block for any rerun or unexpected variant:

```markdown
### T#

- Date run:
- Tester:
- Task name:
- Creation path:
- Prompt file:
- Schedule:
- Working folder:
- Preconditions:
- Observed behavior:
- Evidence saved:
- Revisor decision:
- Follow-up:
```

## T1

- Date run: 2026-04-15 (task created; awaiting first scheduled run at 19:15 UTC)
- Tester: Sergey + Claude (Cowork session)
- Task name: lab-t1-run-marker
- Creation path: programmatic via mcp__scheduled-tasks__create_scheduled_task (the /schedule equivalent)
- Prompt file: inline in task SKILL.md at /Users/sergey/Documents/Claude/Scheduled/lab-t1-run-marker/SKILL.md (derived from prompts/probe-a-run-marker.md, with absolute paths to insulate Pass 1 from path-resolution risk that T7 will probe later)
- Schedule: cron `* * * * *` (every minute) — smallest practical interval; tool note warns of "small deterministic delay of several minutes" at dispatch
- Working folder: not configurable on create_scheduled_task; absolute paths used in prompt — base /Users/sergey/Projects/revisor-plugin/schedule-lab
- Preconditions: notifyOnCompletion=true; outputs/runs, outputs/logs, outputs/diagnostics, outputs/failures will be created on first run if missing
- Observed behavior:
  - 15 successful fires between 12:15:05 and 12:31:12 PT (17 minutes wall clock) — ~88% of cron ticks.
  - First fire at 12:15:05 PT vs nextRunAt 19:15:00 UTC (12:15:00 PT) → 5-second dispatch delay; subsequent fires showed 0-50s jitter past their cron tick.
  - `invocation_type` self-reported as "scheduled" via env var `CLAUDE_CODE_TAGS=lam_session_type:scheduled` and `<scheduled-task>` prompt-wrapper block.
  - Each fire ran in a fresh sandbox (`sharp-loving-noether`, `relaxed-charming-mendel`, `wizardly-serene-cerf`, …, 15 distinct names).
  - One fire (12:30:24) reported `timezone=Etc/UTC` despite `$TZ=America/Los_Angeles` — environment occasionally drifts.
  - Absolute host paths in prompt resolved correctly to host files via mount; first fire also had `cwd=.../schedule-lab` (matched workspace) but subsequent fires had bare sandbox-root cwd → relative paths would have landed elsewhere.
- Evidence saved: outputs/runs/2026-04-15T12-15-05--lab-t1-run-marker--*.md (×15), outputs/diagnostics/t1-*.md (×15), outputs/logs/run-log.md
- Revisor decision: scheduling itself is reliable enough for weekly briefings; don't promise sub-minute precision; always use absolute host paths.
- Follow-up: re-enable T1 (currently disabled by Sergey post-Pass-1) before running T3/T4 catch-up tests.

## T2

- Date run: 2026-04-15 (programmatic arm in flight; UI arm pending)
- Tester: Sergey + Claude
- Task name: lab-t2-run-marker-programmatic (programmatic arm) + lab-t2-run-marker-ui (Sergey to create from Scheduled page)
- Creation path: programmatic arm via scheduled-tasks MCP; UI arm via Scheduled page in Cowork sidebar
- Prompt file: prompts/probe-a-run-marker.md (UI arm should paste its contents); programmatic arm uses an absolute-path-hardened variant inline in the task SKILL.md
- Schedule: cron `* * * * *` for both arms; UI arm should match cadence and prompt as closely as possible
- Working folder: programmatic arm — not settable on creation; UI arm — Sergey should set to /Users/sergey/Projects/revisor-plugin/schedule-lab
- Preconditions: both arms must coexist and write to the same outputs/runs/ folder; differentiating by task_name and run_slug prefix (t2p- for programmatic, set t2u- for UI arm if you customize the prompt)
- Observed behavior:
  - Programmatic arm (`lab-t2-run-marker-programmatic`): 14 fires at every-minute cron between 12:15:05 and 12:31:10 PT.
  - UI arm (`lab-t2-run-marker-ui`): created by Sergey; configured "Manual only" (no recurring schedule). Single fire at 12:21:36 PT after Sergey clicked Run.
  - Once executing, both arms ran in identical environments (same sandbox naming pattern, same env vars, same `<scheduled-task>` wrapper, same TZ).
  - The UI form clearly supports manual-only AND recurring (Sergey opted for manual-only); the programmatic API can do both via cronExpression vs fireAt.
  - No detectable runtime difference attributable to creation surface.
- Evidence saved: outputs/runs/*--lab-t2-run-marker-programmatic--*.md (×14), outputs/runs/2026-04-15T12:21:36-0700--probe-a-run-marker--t2ui-*.md (×1), diagnostics
- Revisor decision: doc/onboarding can recommend either creation surface; runtime parity is fine. Note that the UI exposes a "Manual only" option that isn't obvious from the create_scheduled_task signature.
- Follow-up: optionally re-run with both arms recurring at the same cadence to confirm cron parity in both surfaces.

## T3

- Date run:
- Tester:
- Task name:
- Creation path:
- Prompt file:
- Schedule:
- Working folder:
- Preconditions:
- Observed behavior:
- Evidence saved:
- Revisor decision:
- Follow-up:

## T4

- Date run:
- Tester:
- Task name:
- Creation path:
- Prompt file:
- Schedule:
- Working folder:
- Preconditions:
- Observed behavior:
- Evidence saved:
- Revisor decision:
- Follow-up:

## T5

- Date run: 2026-04-15 (pause window opened ~12:58 PT after 3 observed fires, with the third likely racing the pause action)
- Tester: Sergey + Claude
- Task name: lab-t5-pause-resume
- Creation path: programmatic via scheduled-tasks MCP
- Prompt file: inline absolute-path Probe A variant (in task SKILL.md)
- Schedule: cron `* * * * *`; currently `enabled: false` (paused via update_scheduled_task)
- Working folder: absolute paths under /Users/sergey/Projects/revisor-plugin/schedule-lab
- Preconditions: 3 fires observed at 12:56:12, 12:57:04, and 12:58:08 PT (run_slugs t5-...-331a6f, t5-...-9856ec, and t5-...-941dcd) before or during the pause boundary. The 12:58:08 fire likely raced the pause action and should be treated as boundary evidence when interpreting resume behavior.
- Observed behavior: pre-pause working as expected. Post-resume behavior pending — see playbook for the resume step. Resume analysis should treat the 12:58:08 fire as the boundary case.
- Evidence saved (pre-pause): outputs/runs/*--lab-t5-pause-resume--* (×3), diagnostics
- Revisor decision: pending resume observation
- Follow-up: Sergey playbook
  1. Confirm T5 is currently paused (it is — `enabled: false` per list_scheduled_tasks at the time of pause).
  2. Wait at least 5 wall-clock minutes (so ≥5 minute-cron ticks fall inside the paused window).
  3. Re-enable: ask Claude to call `mcp__scheduled-tasks__update_scheduled_task taskId=lab-t5-pause-resume enabled=true`, OR toggle from the Scheduled-page UI.
  4. Note the resume timestamp and observe the next 2-3 fires.
  5. Compare run count to the size of the paused window — if N fires happen immediately on resume that approximately equals the paused minutes, intervals are being replayed; if only the next regular tick fires, paused intervals are silently skipped.

## T6

- Date run: 2026-04-15 (task created; awaiting first scheduled and manual fires)
- Tester: Sergey + Claude
- Task name: lab-t6-run-marker
- Creation path: programmatic via scheduled-tasks MCP
- Prompt file: inline absolute-path variant of prompts/probe-a-run-marker.md, augmented to record `invocation_type` AND `invocation_evidence` (every signal the running session used to decide scheduled vs manual)
- Schedule: cron `* * * * *`; Sergey will additionally hit "Run on demand" several times between scheduled fires
- Working folder: absolute paths under /Users/sergey/Projects/revisor-plugin/schedule-lab
- Preconditions: T1 must fire successfully first (proves harness); then trigger 3+ manual runs interleaved with scheduled fires
- Observed behavior:
  - 12 fires between 12:15:12 and 12:31:11 PT.
  - **Negative finding (1)**: invocation_type is NOT distinguishable from inside the session. Every fire — including the ones we strongly suspect were manual on-demand — reported `invocation_type=scheduled` because every dispatch (manual or cron) carries the `lam_session_type:scheduled` env tag and `<scheduled-task>` prompt wrapper.
  - **Striking observation (2)**: At 12:23:06 two T6 fires landed in the SAME second in two different sandboxes (`exciting-trusting-einstein` and `confident-sharp-allen`) — strongly suggests Sergey's manual click coincided with a scheduled fire and BOTH executed in parallel. The platform did not deduplicate or queue.
  - Both fires produced full marker files and diagnostic snapshots; no error or warning visible in the in-session evidence.
- Evidence saved: outputs/runs/*--lab-t6-run-marker--*.md (×12 including the 12:23:06 duplicate pair), diagnostics
- Revisor decision:
  - Revisor MUST treat every scheduled prompt as idempotent — cannot branch on invocation type from inside.
  - If Revisor adds a manual-trigger affordance later, it cannot rely on the in-session signal to dedupe; dedupe must happen at the file/destination layer using a run_slug or content-hash registry.
- Follow-up: capture Scheduled-page screenshot showing the history columns for one manual + one scheduled fire — that is the only place distinguishability can plausibly live.

## T7

- Date run: 2026-04-15 (first fire 12:56:00 PT)
- Tester: Claude (autonomous)
- Task name: lab-t7-relative-paths
- Creation path: programmatic
- Prompt file: inline Probe B variant — relative writes only, with diagnostics to absolute path so we can always find evidence
- Schedule: cron `* * * * *`
- Working folder: relative paths used deliberately
- Preconditions: none
- Observed behavior:
  - cwd at fire time: `/sessions/relaxed-great-goodall` (sandbox root, NOT the workspace mount)
  - Relative writes succeeded (exit 0 for all). Files were created at `/sessions/relaxed-great-goodall/outputs/path-probe/current-location.txt` and `/sessions/relaxed-great-goodall/outputs/path-probe/nested/check.txt`.
  - These files live in the EPHEMERAL session scratchpad — they vanish with the sandbox and the user cannot see them on the host.
  - The diagnostic file (written via the absolute mount path `/sessions/<sandbox>/mnt/revisor-plugin/schedule-lab/outputs/diagnostics/...`) DID land on the host.
- Evidence saved: outputs/diagnostics/t7-t7-20260415-125600-b47f77.md (host-visible); the relative writes themselves are NOT host-visible (proving the failure mode).
- Revisor decision (CRITICAL): Revisor scheduled prompts MUST use absolute host paths. Never instruct a scheduled task to write via relative paths or `~/...` — those land in the sandbox scratchpad and are lost. Document this in REVISOR_IMPLEMENTATION_PLAN.md as a hard rule.
- Follow-up: optionally extend the prompt to test `cd <workspace>` first, to confirm whether explicit cd makes relative paths safe.

## T8

- Date run:
- Tester:
- Task name:
- Creation path:
- Prompt file:
- Schedule:
- Working folder:
- Preconditions:
- Observed behavior:
- Evidence saved:
- Revisor decision:
- Follow-up:

## T9

- Date run: 2026-04-15 (first fire 12:56:12 PT)
- Tester: Claude (autonomous)
- Task name: lab-t9-skill-parity
- Creation path: programmatic
- Prompt file: inline Probe C variant — enumerate skills via filesystem AND system-reminder, attempt one no-op invocation
- Schedule: cron `* * * * *`
- Working folder: absolute host paths
- Preconditions: none
- Observed behavior:
  - 28 skills enumerated via filesystem walk of `.claude/skills/` AND via the in-prompt `<available_skills>` block — lists matched.
  - Skill tool was available; `pdf` skill loaded successfully and returned the PDF Processing Guide content with no follow-up questions.
  - Skills observed: schedule, setup-cowork, xlsx, pdf, skill-creator, pptx, docx, cowork-plugin-management:cowork-plugin-customizer, cowork-plugin-management:create-cowork-plugin, all `data:*` skills (×9), all `retriever:*` skills (×9).
- Evidence saved: outputs/logs/capability-probe.md (T9 section), outputs/diagnostics/t9-*.md
- Revisor decision: skills can be invoked from inside scheduled prompts. That is enough to author Revisor scheduled flows around local skills, but manual-session parity has not yet been explicitly diffed.
- Follow-up: optional manual baseline diff if we want to confirm that the visible skill set is identical outside the scheduled-session context.

## T10

- Date run: 2026-04-15 (initial framework-only fires at 12:59:05, 13:00:06, 13:01:05 PT; final QuickBooks parity run at 13:39:14 PT after connector install/auth)
- Tester: Claude (autonomous)
- Task name: lab-t10-connector-parity
- Creation path: programmatic
- Prompt file: inline Probe C variant — enumerate all `mcp__*` tools and perform the smallest safe read-only probe available on the target connector
- Schedule: cron `* * * * *`
- Working folder: absolute paths
- Preconditions: QuickBooks initially absent, then manually installed and authenticated in a normal Cowork session before the final rerun
- Observed behavior:
  - Initial scheduled fires before connector setup showed only framework infrastructure: 32 tools across 7 servers with **no third-party connectors visible**.
  - Manual baseline after connector setup exposed QuickBooks in a normal Cowork session, proving the connector was installed and authenticated.
  - Final scheduled rerun at 13:39:14 PT exposed **43 tools across 8 servers**, including QuickBooks (`aea89b51-0a76-4f66-ae82-a3b496c4dadc`) with 11 tools.
  - The scheduled read-only probe `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__company-info` **succeeded** and returned `Company Name: Lumos Land Inc.` and `Industry: 518210`.
  - No re-auth prompt occurred inside the scheduled session, and no mutating QuickBooks tools were called.
- Evidence saved: outputs/logs/capability-probe.md (T10 sections), outputs/diagnostics/t10-*.md
- Revisor decision:
  - Desktop scheduled sessions **can** see and use an authenticated QuickBooks connector.
  - Revisor MVP may pull fresh QuickBooks data directly from a scheduled weekly briefing; a manual-only local cache is **not** required as a workaround for QuickBooks.
  - Treat this as proven for QuickBooks specifically. Other third-party connectors should still get their own parity check before we promise them in scheduled flows.
- Follow-up:
  - Optional: rerun the same scheduled parity test for Slack/email/Docs before promising outbound delivery through those connectors.
  - Keep the QuickBooks read-only probe (`company-info`) as the fastest smoke test for future scheduled-session regressions.

## T11

- Date run:
- Tester:
- Task name:
- Creation path:
- Prompt file:
- Schedule:
- Working folder:
- Preconditions:
- Observed behavior:
- Evidence saved:
- Revisor decision:
- Follow-up:

## T12

- Date run:
- Tester:
- Task name:
- Creation path:
- Prompt file:
- Schedule:
- Working folder:
- Preconditions:
- Observed behavior:
- Evidence saved:
- Revisor decision:
- Follow-up:

## T13

- Date run:
- Tester:
- Task name:
- Creation path:
- Prompt file:
- Schedule:
- Working folder:
- Preconditions:
- Observed behavior:
- Evidence saved:
- Revisor decision:
- Follow-up:

## T14

- Date run: 2026-04-15 (created; daily-noon-local task next firing 2026-04-16 19:00:54 UTC)
- Tester: Claude (autonomous; metadata-level confirmation already in hand)
- Task name: lab-t14-tz-noon-local
- Creation path: programmatic
- Prompt file: inline Probe A variant with TZ-verdict logic
- Schedule: cron `0 12 * * *`
- Working folder: absolute paths
- Preconditions: none
- Observed behavior (metadata only — actual fire is tomorrow):
  - `nextRunAt` from list_scheduled_tasks: `2026-04-16T19:00:54.000Z`.
  - Sergey is in PDT (UTC-7). Local 12:00 PDT == 19:00 UTC. ✓ Cron is interpreted in local TZ.
  - `jitterSeconds: 54` reported by the platform — the deterministic dispatch jitter is exposed in the API.
  - Per-fire TZ env data from prior tasks: `$TZ=America/Los_Angeles` consistently, with one outlier reporting `Etc/UTC` (one fire out of ~50 across all tasks).
- Evidence saved: list_scheduled_tasks output (this RESULTS.md row), forthcoming first-fire markers
- Revisor decision: it is safe to express weekly briefing schedules in user-local time directly (e.g., "Friday 9am"). Document that the actual fire may land up to ~1 minute past the scheduled minute due to jitter.
- Follow-up: after the 12:00 PT fire on 2026-04-16, append the actual `verdict_local_or_utc` and `delay_from_scheduled_minute_seconds` from the run marker.

## T15

- Date run:
- Tester:
- Task name:
- Creation path:
- Prompt file:
- Schedule:
- Working folder:
- Preconditions:
- Observed behavior:
- Evidence saved:
- Revisor decision:
- Follow-up:

## T16

- Date run: 2026-04-15 (task registered; first ~90s fire imminent)
- Tester: Claude (autonomous)
- Task name: lab-t16-long-run
- Creation path: programmatic
- Prompt file: inline Probe F variant — write start marker, sleep 90s, write end marker
- Schedule: cron `* * * * *`
- Working folder: absolute paths
- Preconditions: none
- Observed behavior: TBD — once 2-3 fires complete, look for whether end-marker timestamps overlap with subsequent start-marker timestamps. Three possibilities to look for: (a) overlap (parallel sandboxes during the 90s window), (b) queueing (next fire delayed until prior ends), (c) skipping (next minute's tick suppressed).
- Evidence saved: pending — outputs/runs/*--lab-t16-long-run--*--start.md and *--end.md pairs
- Revisor decision: pending. If Cowork allows true overlap, weekly cadence is fine; if it queues, weekly is fine but tighter cadences could pile up; if it skips, the platform self-protects against runaway schedules.
- Follow-up: after 5+ minutes, run `ls outputs/runs/ | grep t16` and pair start/end markers; record duration, gap between consecutive start markers, and any sandbox overlap.

---

# Sergey Playbooks for Remaining Manual-Step Tests

These tests cannot complete without you doing something the scheduled-tasks API can't drive. Each playbook is the smallest action that produces useful evidence.

## T3 — Single missed run catch-up

Goal: learn whether ONE missed cron tick is replayed when Cowork comes back.

1. Re-enable `lab-t1-run-marker` (currently disabled). Tell Claude "re-enable lab-t1-run-marker" or toggle from the Scheduled page.
2. Confirm next-run timestamp from list_scheduled_tasks.
3. Quit the Cowork desktop app (full quit, not just close window) for ~3 minutes, spanning at least one cron tick.
4. Reopen Cowork.
5. Within 2 minutes of reopen, ask Claude to: list outputs/runs/ files for `lab-t1-run-marker` newer than the quit moment; list scheduled-task history rows for that task in the same window.
6. Compare counts. If a run marker exists for a minute that fell entirely inside the quit window → catch-up replay confirmed. If not → missed minutes are dropped.

## T4 — Multiple missed intervals

Same as T3 but quit Cowork for at least 5 minutes spanning 5+ ticks. Then count how many catch-up runs appear vs how many ticks were missed. Three possible outcomes: replay-all, collapse-to-one, drop-all.

## T8 — Folder moved or renamed

Goal: see whether scheduled tasks keep finding the workspace folder if you rename or move it between fires.

1. Re-enable `lab-t1-run-marker`.
2. Wait for one fire to confirm baseline.
3. In Finder/terminal, rename `/Users/sergey/Projects/revisor-plugin/schedule-lab` → `schedule-lab-renamed`.
4. Wait for one cron tick (so a fire happens against the renamed-out state).
5. Inspect the most recent fire's output and history row — look for: did the task fail, did it write to a stale path, did it create a new folder named `schedule-lab` somewhere, or did it gracefully error?
6. Rename back to `schedule-lab`.
7. Wait for one more fire to confirm recovery.

If you'd rather test a workspace SELECTION change rather than a rename, the equivalent is to change the working folder from the Cowork sidebar between fires.

## T11 — Connector auth expiry

Goal: see how a scheduled task behaves when a connector it is told to use is disconnected.

1. Pick one connected MCP/connector that you can disconnect without disrupting other work — Slack or a personal Gmail are typical.
2. Ask Claude to create a small "lab-t11-connector-failure" task whose prompt instructs it to call ONE read-only operation on that connector (e.g., list 1 channel, list 1 inbox label) and write the outcome to `outputs/failures/lab-t11-connector.md`. Pre-approve permissions by clicking Run-now once.
3. Disconnect the connector from the Cowork settings.
4. Wait for the next scheduled fire.
5. Inspect the failure log AND the Scheduled-page history — does the run get marked failed, paused, or silently no-op? does the failure row include the auth error?
6. Reconnect and confirm the next fire recovers.

## T13 — Duplicate external side effects

Pre-req: a private Slack channel OR a private email inbox you don't mind getting test pings.

1. Tell Claude which destination + connector + channel/address you'll use. Claude will create `lab-t13-side-effect` with cron `* * * * *`, a unique-slug-per-run prompt, and a "send the slug to <destination>" step.
2. Quit Cowork for ~5 minutes (forces missed runs — this combines T13 with T3/T4 catch-up).
3. Reopen Cowork.
4. Compare: count of `outputs/notifications/local-proof.md` lines vs count of slug-bearing messages in the destination. Dupes in the destination ≥ dupes in the local proof → outbound delivery is duplicating; equal → it isn't.

## T15 — DST / time-zone change

Goal: confirm how scheduled tasks behave when the host TZ changes mid-life.

This test is OPTIONAL and not on Revisor's MVP critical path — if Cowork uses local TZ (already confirmed via T14 metadata), the only remaining risk is the spring-forward / fall-back transitions.

1. Note the current `nextRunAt` for `lab-t14-tz-noon-local`.
2. In macOS System Settings → General → Date & Time, switch from PDT to UTC.
3. Quit and reopen Cowork.
4. Re-list scheduled tasks. Did `nextRunAt` for the noon-local task shift, or stay anchored to the original UTC instant?
5. Switch the system TZ back. Confirm `nextRunAt` re-shifts.

Skip unless we see customer signal about cross-timezone teams.

---

# Suggested next session — Pass-2/3/4/5 wrap-up

Easiest order:

1. Resume T5 (you can do this anytime ≥5 minutes after pause).
2. Run T3 (3-minute Cowork quit). Inspect.
3. Run T4 (5+ minute Cowork quit). Inspect.
4. Run T8 (rename for one tick, restore).
5. Pick a connector and run T11.
6. (Optional) Provide a Slack/email destination so Claude can stand up T13.
7. Wait for T14's noon-PDT fire on 2026-04-16 (auto).
8. Skip T15 unless cross-TZ users become a near-term concern.

Once T3, T4, T5, T8, T11, T12, T16 land, the exit-criteria checklist in REVISOR_SCHEDULED_TASK_BEHAVIOR_TEST_PLAN.md is satisfied and Revisor can fold the headline findings into REVISOR_IMPLEMENTATION_PLAN.md.
