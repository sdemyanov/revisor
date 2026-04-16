# Revisor Phase 1 — QuickBooks Connector Live Probe

- Run date: 2026-04-15
- Company (from `company-info`): Lumos Land Inc.
- Industry NAICS (from `company-info`): 518210
- User auth state: signed in (`userHasLoggedIn: true` on every read-only call)
- Mutating tools skipped per protocol: `quickbooks-profile-info-update`, `quickbooks-transaction-import`

## 1. Available QuickBooks MCP tools in this session

All tools are namespaced `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__*`. Bare names below for readability.

| Tool                              | Touches live QB data?            | Mutating? | Used in this probe   |
| --------------------------------- | -------------------------------- | --------- | -------------------- |
| `about-quickbooks`                | No (discovery carousel)          | No        | No (not needed)      |
| `benchmarking-against-industry`   | No (uses caller-supplied number) | No        | No (scope: QB reads) |
| `benchmarking-quickbooks-account` | Yes (read)                       | No        | No (scope: P&L/CF)   |
| `cash-flow-generator`             | No (uses caller-supplied txns)   | No        | No                   |
| `cash-flow-quickbooks-account`    | Yes (read)                       | No        | Yes                  |
| `company-info`                    | Yes (read)                       | No        | Yes (prereq)         |
| `industry-recommendation`         | No (search)                      | No        | No                   |
| `profit-loss-generator`           | No (uses caller-supplied txns)   | No        | No                   |
| `profit-loss-quickbooks-account`  | Yes (read)                       | No        | Yes                  |
| `quickbooks-profile-info-update`  | Yes                              | **YES**   | **Excluded**         |
| `quickbooks-transaction-import`   | Yes                              | **YES**   | **Excluded**         |

Relevant live read-only tools against the QB account include `company-info`, `profit-loss-quickbooks-account`, `cash-flow-quickbooks-account`, and `benchmarking-quickbooks-account`. This probe exercised the first three; the benchmarking path was left out because it is not a Phase 1 blocker for Revisor.

## 2. `profit-loss-quickbooks-account` — trailing 12 months

- Window: 2025-04-01 → 2026-03-31
- Required parameters: **none**. Both `periodStart` and `periodEnd` are optional (default null).
- Implicit prerequisite: `company-info` must have been called once in the session to establish the OAuth connection. Confirmed in this session.
- Call status: **success**.

### Top-level fields returned

```
status, instanceId, periodStart, periodEnd,
reportTitle, companyName, reportPeriod, datePrepared, timePrepared,
totalIncome, totalExpenses, netIncome, grossProfit,
summaryBreakdown { income, otherIncome, expenses, otherExpenses, netOperatingIncome },
reportData.data.rows[]  -- full hierarchical P&L row tree (ACCOUNT_NAME, totals, subgroups)
trends { totalRevenue, totalExpenses, netIncome },
trendComparison { priorPeriodStart, priorPeriodEnd, description, isYearOverYear, hasPriorData },
trendExplanation,
showSignInNudge, userHasLoggedIn,
monthlyBreakdown { "<YYYY-MM-01> - <YYYY-MM-DD>": { totalIncome, totalCogs, grossProfit,
                    totalExpenses, netIncome, incomeAccounts{…}, cogsAccounts{…},
                    expenseAccounts{…}, *Aggregated variants } },
monthlyColumns[],
quickbooksSignInUrl, quickbooksSignUpUrl, quickbooksBankAccountsUrl,
3p_anonymousId, 3p_provider
```

### TTM totals (2025-04-01 → 2026-03-31)

| Metric             | Value       |
| ------------------ | ----------- |
| Total Income       | $0.00       |
| COGS               | $0.00       |
| Gross Profit       | $0.00       |
| Total Expenses     | $3,375.64   |
| Net Operating Inc. | -$3,375.64  |
| Other Income / Exp | $0.00 / $0.00 |
| Net Income         | -$3,375.64  |

Expense categories surfaced (account level): Bank Charges & Fees ($140), Legal & Professional Services ($2,160), Office Supplies & Software ($218.64), Taxes & Licenses ($857). No revenue activity in the window.

### Sufficiency for TTM analysis

**Yes, sufficient for TTM analysis.** The tool returns:

- Period totals for income, COGS, gross profit, expenses, other income/expense, net income.
- Account-level breakdown via `reportData.data.rows` (hierarchical, with subgroup totals).
- Full per-month breakout via `monthlyBreakdown`, keyed by `"YYYY-MM-01 - YYYY-MM-DD"`, each containing the same metric set plus account-level income/COGS/expense dicts.
- A `monthlyColumns` array giving the human-readable month sequence (`"Apr 2025" … "Mar 2026"`).
- Year-over-year trend comparison against the prior 365-day window (`trendComparison.hasPriorData: true`).

The aggregation granularity is month, not day. Account resolution is chart-of-accounts level (Bank Charges & Fees, Office Supplies & Software, etc.), not vendor or class level.

Caveat observed in the payload: the `expenseAccountsAggregated` numbers in each month's block appear double-counted versus `expenseAccounts` (e.g., April `Expenses: 4084.42` under aggregated vs. `2042.21` under non-aggregated). Prefer `expenseAccounts` + `totalExpenses` for monthly math; treat `*Aggregated` with suspicion.

## 3. Monthly comparison handling

**The tool supports monthly breakout directly.** The TTM call above returned `monthlyBreakdown` keyed by each of the 12 months in the window, so I did **not** run two adjacent monthly windows. If a consumer still wants to verify the per-month endpoint behavior, the `periodStart`/`periodEnd` parameters accept arbitrary windows including sub-month ranges — but it is redundant for this use case.

Recorded monthly figures pulled straight from `monthlyBreakdown`:

| Month    | Income | Expenses | Net Income |
| -------- | ------ | -------- | ---------- |
| Apr 2025 | $0.00  | $2,042.21 | -$2,042.21 |
| May 2025 | $0.00  | $38.26    | -$38.26    |
| Jun 2025 | $0.00  | $1,051.15 | -$1,051.15 |
| Jul 2025 | $0.00  | $42.71    | -$42.71    |
| Aug 2025 | $0.00  | $42.14    | -$42.14    |
| Sep 2025 | $0.00  | $42.82    | -$42.82    |
| Oct 2025 | $0.00  | $42.82    | -$42.82    |
| Nov 2025 | $0.00  | $37.45    | -$37.45    |
| Dec 2025 | $0.00  | $36.08    | -$36.08    |
| Jan 2026 | $0.00  | $0.00     | $0.00      |
| Feb 2026 | $0.00  | $0.00     | $0.00      |
| Mar 2026 | $0.00  | $0.00     | $0.00      |

Feb 2026 and Mar 2026 both zero-activity in this account, which matches the specifically requested adjacent-window test — comparison handling works and returns zeros without erroring.

## 4. `cash-flow-quickbooks-account` — trailing 12 months

- Window: 2025-04-01 → 2026-03-31
- Required parameters: **none**. Both dates optional.
- Implicit prerequisite: same as P&L — `company-info` first.
- Call status: **success**.

### Top-level fields returned

```
status, instanceId, periodStart, periodEnd,
reportTitle, companyName, reportPeriod, datePrepared, timePrepared,
reportRows[]   -- hierarchical rows for Operating / Investing / Financing,
                   Net Cash Increase, Cash at beginning, Cash at end
operatingActivities, investingActivities, financingActivities,
netCashIncrease, cashAtBeginning, cashAtEnd,
trends { operatingActivities, investingActivities, financingActivities },
trendComparison { priorPeriodStart, priorPeriodEnd, description, isYearOverYear, hasPriorData },
trendExplanation,
showSignInNudge, userHasLoggedIn,
quickbooksSignInUrl, quickbooksSignUpUrl, quickbooksBankAccountsUrl,
3p_anonymousId, 3p_provider
```

### TTM totals (2025-04-01 → 2026-03-31)

| Metric                  | Value     |
| ----------------------- | --------- |
| Operating activities    | -$3,375.64 |
| Investing activities    | $0.00     |
| Financing activities    | $3,395.00 (Owner's Investment) |
| Net cash increase       | $19.36    |
| Cash at beginning       | $37.96    |
| Cash at end             | $57.32    |

### Does the result include current cash / bank balances?

**Partially.** The payload exposes `cashAtBeginning` and `cashAtEnd` as scalar fields plus the corresponding FORMULA rows in `reportRows`. These are period-bounded: `cashAtEnd` is the cash balance at `periodEnd`, not a live "current" balance.

- For the probed window (period ending 2026-03-31), `cashAtEnd = $57.32`.
- Today is 2026-04-15, so to get a point-in-time current balance the caller would need to re-probe with `periodEnd` set to today (or the most recent close). There is **no separate balance-sheet / bank-balance endpoint** in this connector, and no per-account bank-balance field is returned.
- Cash is returned as a single consolidated number. No breakdown by bank account or by GL cash account.
- There is no monthly breakdown on the cash-flow tool (unlike P&L).

## 5. Capability matrix for other Phase 1 needs

No list-transactions / query endpoint exists in this connector — only P&L, cash flow, benchmarking, and company-info reads. Everything below was evaluated by scanning the full tool inventory; I did not attempt unsafe probes.

| Capability                             | Status  | Notes |
| -------------------------------------- | ------- | ----- |
| Invoices and status                    | absent  | No invoice read endpoint in the connector. |
| Receivables aging (AR aging)           | absent  | No AR endpoint; P&L does not expose balance-sheet items. |
| Payables aging (AP aging)              | absent  | No AP endpoint. |
| Expenses by category                   | **present** | Via `profit-loss-quickbooks-account` → `reportData.data.rows` + `monthlyBreakdown[*].expenseAccounts`. Granularity is chart-of-accounts (e.g., Legal & Professional Services, Taxes & Licenses), both total and per-month. |
| Expenses by vendor                     | absent  | No vendor-level field in P&L output. No vendors endpoint. |
| Customer revenue breakdown             | absent  | P&L only exposes account-level income, not customer-level. No customers endpoint. |
| Product / service categories or classes | absent | No class / item tracking surfaced. |

## 6. Implications for Revisor Phase 1

- TTM P&L with monthly granularity: **fully covered** by one `profit-loss-quickbooks-account` call. No stitching needed.
- TTM cash flow and period-end cash: **covered**, but only for the window endpoint. A "current cash" reading requires a probe with `periodEnd = today`. No bank-account-level detail.
- Anything invoice-, vendor-, customer-, AR/AP-, or class-level: **not available** through this connector. Revisor will need either a different data source or to accept user-supplied CSV input via the `*-generator` tools (non-mutating) for those slices.
- Any write-back to QuickBooks (profile updates, transaction import) is out of scope for Phase 1 and out of scope for this probe by rule.
