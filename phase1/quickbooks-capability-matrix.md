# Phase 1 QuickBooks Capability Matrix

This matrix is the Phase 1 truth source for what the current QuickBooks connector
has actually proven versus what Revisor still needs to verify manually before a
Phase 3 entrypoint skill depends on it.

## Status Legend

- `VERIFIED`: exercised successfully with live connector access
- `PARTIAL`: supported, but only with important caveats about granularity or interpretation
- `ABSENT`: no safe read path exists in the current connector surface
- `TOOL VISIBLE`: a relevant tool exists, but the specific data contract is not yet proven
- `UNVERIFIED`: no successful proof in this repo yet
- `OUT OF SCOPE`: useful, but not required for the QuickBooks-only MVP

## Current Evidence Already In Repo

- Manual session: QuickBooks MCP server connected and authenticated; `company-info` succeeded
  - evidence: `schedule-lab/outputs/logs/capability-baseline.md`
- Scheduled session: QuickBooks connector visible in scheduled runtime; `company-info` succeeded
  - evidence: `schedule-lab/outputs/logs/capability-probe.md`
  - summary: `schedule-lab/RESULTS.md` T10
- Scheduled QuickBooks proof: `profit-loss-quickbooks-account` and `cash-flow-quickbooks-account` both succeeded inside a scheduled task, with `monthlyBreakdown` and `cashAtEnd` present
  - evidence: `schedule-lab/outputs/quickbooks-scheduled-proof.md`
- Live connector probe: `profit-loss-quickbooks-account` and `cash-flow-quickbooks-account` succeeded with trailing-12-month windows and documented payloads
  - evidence: `phase1/quickbooks-live-probe.md`

## Connector Surface Observed So Far

Visible QuickBooks tools at time of writing:

- `about-quickbooks`
- `benchmarking-against-industry`
- `benchmarking-quickbooks-account`
- `cash-flow-generator`
- `cash-flow-quickbooks-account`
- `company-info`
- `industry-recommendation`
- `profit-loss-generator`
- `profit-loss-quickbooks-account`
- `quickbooks-profile-info-update`
- `quickbooks-transaction-import`

## MVP Capability Matrix

| Requirement | Candidate tool(s) | Status | Evidence / note | Phase 3 rule |
|-------------|-------------------|--------|------------------|---------------|
| Connector can be installed and authenticated | `company-info` | VERIFIED | Manual baseline and scheduled T10 both succeeded | Safe dependency |
| Scheduled QuickBooks access works in desktop Cowork | `company-info`, `profit-loss-quickbooks-account`, `cash-flow-quickbooks-account` | VERIFIED | T10 plus the scheduled proof both succeeded, including live P&L and cash-flow reads | Safe dependency |
| Company identity / industry metadata | `company-info` | VERIFIED | Returns company name + industry code | Safe dependency |
| Profit and loss over a period | `profit-loss-quickbooks-account`, `profit-loss-generator` | VERIFIED | Live probe succeeded; payload includes totals, account-level row tree, `monthlyBreakdown`, and year-over-year comparison fields | Safe dependency |
| Cash flow analysis | `cash-flow-quickbooks-account`, `cash-flow-generator` | VERIFIED | Live probe succeeded; payload includes operating/investing/financing totals plus `cashAtBeginning` and `cashAtEnd` | Safe dependency for period-bounded cash-flow analysis |
| Balance sheet | none proven yet | ABSENT | No balance-sheet-specific read endpoint is exposed in the connector | Keep out of the QuickBooks-only MVP |
| Current cash or bank balances | `cash-flow-quickbooks-account` | PARTIAL | The connector exposes period-end consolidated cash via `cashAtEnd`, but no separate live current-balance or per-bank-account endpoint | Only use when explicitly labeled as period-end cash for the requested window |
| Invoices and status | none proven yet | ABSENT | No invoice read endpoint in the connector | Keep out of the QuickBooks-only MVP |
| Receivables aging | none proven yet | ABSENT | No AR aging endpoint is exposed | Keep out of the QuickBooks-only MVP |
| Payables aging | none proven yet | ABSENT | No AP aging endpoint is exposed | Keep out of the QuickBooks-only MVP |
| Expenses by category | `profit-loss-quickbooks-account` | VERIFIED | P&L payload exposes account-level expense categories in both total and monthly views | Safe dependency if labeled as chart-of-accounts categories, not vendors |
| Expenses by vendor | none proven yet | ABSENT | No vendor-level field or vendor endpoint is exposed | Keep out of the QuickBooks-only MVP |
| Customer revenue breakdown | none proven yet | ABSENT | No customer-level field or customers endpoint is exposed | Keep out of the QuickBooks-only MVP |
| Product or service categories / classes | none proven yet | ABSENT | No class / item / product-category read path is exposed | Keep out of the QuickBooks-only MVP |
| Enough transaction history to infer periodic expenses confidently | `profit-loss-quickbooks-account` monthly categories only | PARTIAL | Monthly category totals exist, but there is no vendor- or transaction-level read path for reliable automatic recurring-expense detection | Auto-add only category-level heuristics as `assumed`, include them by default, and let users exclude false positives |
| Trailing 12-month date range handling | `profit-loss-quickbooks-account`, `cash-flow-quickbooks-account` | VERIFIED | Live probe confirmed explicit trailing-12-month windows on both tools | Safe dependency |
| Monthly comparisons | `profit-loss-quickbooks-account` | VERIFIED | Live probe confirmed built-in monthly breakout across the trailing-12-month window | Safe dependency for month-over-month analysis |
| Industry benchmarking | `benchmarking-against-industry`, `benchmarking-quickbooks-account` | TOOL VISIBLE | Useful for future grading context, but not required for QuickBooks MVP | OUT OF SCOPE for Phase 3 blocker logic |

## Immediate Manual Checks Still Needed Before Phase 3 Depends On Them

1. Tune the threshold for auto-adding `assumed` recurring expenses so the default forecast stays conservative without becoming noisy.
2. Remove or defer any Phase 3 behavior that assumes invoices, AR/AP aging, vendor detail, customer detail, or class tracking unless a new data source is introduced.
3. Keep scheduled writes inside the mounted workspace root selected for the task; this proof again confirmed that arbitrary `/Users/...` host paths can fail with `EACCES` even when the underlying repo exists locally.

## Implementation Constraint

No Phase 3 skill may rely on a row marked `UNVERIFIED` or `ABSENT`. A row marked
`TOOL VISIBLE` can be referenced only behind graceful-degradation language until
the exact payload and date-range behavior are confirmed in a live session. A row
marked `PARTIAL` must be labeled honestly in product copy and report output.
