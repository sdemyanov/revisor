# Revisor Phase 1 — QuickBooks Scheduled-Session Proof

- **Run time (local):** 2026-04-15 15:20:11 -0700
- **Run time (UTC):** 2026-04-15 ~22:20Z
- **Task:** `revisor-phase-1-test` (automated scheduled run, no user present)
- **Source prompt:** `/sessions/clever-confident-feynman/mnt/uploads/SKILL.md`
- **Mode:** Read-only. Did NOT call `quickbooks-profile-info-update` or `quickbooks-transaction-import`.

> **Host-path note:** The task asked for writes at
> `/Users/sergey/Projects/revisor-plugin/phase1/quickbooks-scheduled-proof.md`
> and a timestamped copy under `/Users/sergey/Projects/revisor-plugin/phase1/probes/`.
> That macOS host path is **not mounted inside this sandbox** (only
> `/sessions/clever-confident-feynman/mnt/schedule-lab` and `.../uploads` are
> reachable). `mkdir` and `Write` against `/Users/...` both returned
> `EACCES: permission denied`. This file is therefore written inside the
> selected Cowork workspace folder (`schedule-lab/outputs/runs/`), which is
> the host bridge available to the scheduled session. The user can move/copy
> this file to the requested Revisor-plugin path on their Mac.

---

## 1. QuickBooks `mcp__*` tools visible in this scheduled session

All tools are under the prefix `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__`:

1. `about-quickbooks`
2. `benchmarking-against-industry`
3. `benchmarking-quickbooks-account`
4. `cash-flow-generator`
5. `cash-flow-quickbooks-account`
6. `company-info`
7. `industry-recommendation`
8. `profit-loss-generator`
9. `profit-loss-quickbooks-account`
10. `quickbooks-profile-info-update` *(not called — blocked by task rules)*
11. `quickbooks-transaction-import` *(not called — blocked by task rules)*

Note: these tools were not statically present at session start — they were surfaced as deferred tools and pulled in via `ToolSearch` before invocation. Once surfaced, they called successfully without any additional auth prompt.

---

## 2. `company-info`

- **Call succeeded:** yes
- **Output (plain text):**
  - Company Name: `Lumos Land Inc.`
  - Industry: `518210`
- **Note:** Auth was already live in the scheduled session. No OAuth prompt needed.

---

## 3. `profit-loss-quickbooks-account` — 2025-04-01 → 2026-03-31

- **Call succeeded:** yes (`status: "success"`)
- **Top-level fields returned:**
  `status`, `instanceId`, `periodStart`, `periodEnd`, `reportTitle`, `companyName`,
  `reportPeriod`, `datePrepared`, `timePrepared`, `totalIncome`, `totalExpenses`,
  `netIncome`, `grossProfit`, `summaryBreakdown`, `reportData`, `trends`,
  `trendComparison`, `trendExplanation`, `showSignInNudge`, `userHasLoggedIn`,
  `monthlyBreakdown`, `monthlyColumns`, `quickbooksSignInUrl`,
  `quickbooksSignUpUrl`, `quickbooksBankAccountsUrl`, `3p_anonymousId`,
  `3p_provider`.
- **`monthlyBreakdown` present:** yes (12 month buckets, Apr 2025 through Mar 2026).
- **Headline numbers:**
  - `totalIncome`: **$0.00**
  - `totalExpenses`: **$3,375.64**
  - `grossProfit`: **$0.00**
  - `netIncome`: **-$3,375.64**
- **Expense detail (from `reportData.rows`):**
  - Bank Charges & Fees: $140.00
  - Legal & Professional Services: $2,160.00
  - Office Supplies & Software: $218.64
  - Taxes & Licenses: $857.00
  - Total for Expenses: $3,375.64
- **Caveats / oddities:**
  - `reportPeriod`, `datePrepared`, `timePrepared` came back as empty strings on this call (the cash-flow call populated them). Minor cosmetic inconsistency, not a data problem.
  - `monthlyBreakdown` contains an `expenseAccountsAggregated` block whose values are **double** the `expenseAccounts` values for the same month (e.g. Apr 2025 `Total for Expenses` = 2042.21 in `expenseAccounts` but 4084.42 in `expenseAccountsAggregated`). Consumers should prefer `expenseAccounts` / top-level `totalExpenses` for truth; `*Aggregated` appears to double-count and should not be summed independently.
  - Jan / Feb / Mar 2026 are all zero — likely no posted activity yet or not synced. Not a tool bug, but worth flagging before presenting numbers.
  - `trends.totalExpenses: "negative"` / `netIncome: "positive"` are directional labels against the prior year (expenses trending down = "negative" trend on expenses = good), not signs of the values.

---

## 4. `cash-flow-quickbooks-account` — 2025-04-01 → 2026-03-31

- **Call succeeded:** yes (`status: "success"`)
- **Top-level fields returned:**
  `status`, `instanceId`, `periodStart`, `periodEnd`, `reportTitle`, `companyName`,
  `reportPeriod`, `datePrepared`, `timePrepared`, `reportRows`,
  `operatingActivities`, `investingActivities`, `financingActivities`,
  `netCashIncrease`, `cashAtBeginning`, `cashAtEnd`, `trends`, `trendComparison`,
  `trendExplanation`, `showSignInNudge`, `userHasLoggedIn`, `quickbooksSignInUrl`,
  `quickbooksSignUpUrl`, `quickbooksBankAccountsUrl`, `3p_anonymousId`,
  `3p_provider`.
- **`cashAtEnd` present:** yes.
- **Headline numbers:**
  - `operatingActivities`: **-$3,375.64**
  - `investingActivities`: $0.00
  - `financingActivities`: $3,395.00 (Owner's Investment)
  - `netCashIncrease`: **$19.36**
  - `cashAtBeginning`: $37.96
  - `cashAtEnd`: **$57.32**
- **Is `cashAtEnd` a true live bank balance?** **No.** It is period-end cash as of `periodEnd` (2026-03-31), computed as `cashAtBeginning + netCashIncrease` from posted transactions inside the reporting window. It is **not** a live "what is in my bank right now" figure. If the weekly flow needs current cash-on-hand, that needs a different source — a balance-sheet-as-of pull or a bank-account query — neither of which is exposed through these two endpoints.
- **Caveats / oddities:**
  - `netCashIncrease` returns as `19.360000000000127` and `cashAtEnd` as `57.32000000000013` — float artifacts. Round/format to two decimals for user-facing output.
  - `reportPeriod` = "April 1, 2025-March 31, 2026"; `datePrepared` = "Wednesday, April 15, 2026"; `timePrepared` = "10:18 PM GMTZ" — confirms the cash-flow call populates timing fields that P&L left blank.
  - `trends.financingActivities: "negative"` despite actual positive $3,395 — again a prior-year directional label, not the sign of the current period.

---

## 5. Scheduled-session capability summary

| Capability | Works in scheduled session? | Evidence |
|---|---|---|
| `company-info` | yes | Returned `Lumos Land Inc.` + industry `518210` |
| `profit-loss-quickbooks-account` (1-year window) | yes | `status: "success"`, full P&L + `monthlyBreakdown` |
| `cash-flow-quickbooks-account` (1-year window) | yes | `status: "success"`, operating / financing / `netCashIncrease` / `cashAtEnd` all returned |
| Read-only rule observed | yes | `quickbooks-profile-info-update` and `quickbooks-transaction-import` were NOT called |
| Writes to `/Users/sergey/...` host path | no | Sandbox does not mount that path; `EACCES` on `mkdir` and `Write`. Files written inside Cowork workspace instead. |

---

## 6. Verdict

- **scheduled P&L:** yes
- **scheduled cash flow:** yes
- **scheduled weekly flow blocked:** no

Both read-only QuickBooks endpoints returned real data end-to-end inside the scheduled session with no user present and no OAuth prompt. The scheduled weekly flow is **not blocked at the tool-access layer**. The only meaningful gap is that `cashAtEnd` is period-end, not a live bank balance — if the weekly flow requires "cash on hand right now," that requires a different data source not covered by this proof. A second, unrelated limitation in this particular run is that writes to the Revisor-plugin host path (`/Users/sergey/Projects/revisor-plugin/phase1/`) are not reachable from the scheduled-session sandbox; output therefore landed inside the Cowork workspace folder.
