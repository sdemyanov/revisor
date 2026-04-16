---
name: 12-health-scoring
description: >
  Shared Revisor skill for QuickBooks-only Business Health Report grading and
  trend arrows.
metadata:
  version: "0.1.0"
  scope: "shared"
---

# Revisor Health Scoring

Use this skill for `/revisor:qb-report` and any weekly flow that needs a stable
scorecard vocabulary.

## QuickBooks-Only Dimension Set

Because the current QuickBooks connector does not expose AR/AP aging, invoice
status, customer concentration, or vendor-level detail, the QuickBooks-only
report should score these 5 dimensions:

1. `Cash Runway`
2. `Revenue Activity`
3. `Margins`
4. `Expense Stability`
5. `Obligation Readiness`

Do not fabricate collections or concentration grades until a later source proves
them.

## Grade Output

Allowed dimension states:

- `A`
- `B`
- `C`
- `D`
- `F`
- `N/A`

Use `N/A` when the dimension is structurally not meaningful, for example:

- revenue-based grades when trailing revenue is zero for a dormant entity
- margin grades when revenue is zero

Exclude `N/A` dimensions from the overall grade math.

## Dimension Rules

### 1. Cash Runway

For active businesses:

- `A`: base runway > 12 months
- `B`: base runway 6 to 12 months
- `C`: base runway 3 to 6 months
- `D`: base runway 1 to 3 months
- `F`: base runway < 1 month

Downgrade one band if worst case is more than 6 months shorter than base.

For businesses marked dormant, winding down, or in dissolution:

- use the cash-floor and near-term obligation risk as the primary frame
- `A`: no visible floor breach in the modeled horizon
- `B`: horizon remains above floor but one low-confidence obligation could tighten cash
- `C`: assumed floor breach in 31 to 60 days
- `D`: assumed floor breach within 30 days or confirmed breach in 31 to 60 days
- `F`: current cash below floor or confirmed breach within 30 days

### 2. Revenue Activity

If the business is dormant or in dissolution and trailing revenue is zero, use `N/A`.

Otherwise:

- `A`: strong positive revenue trend or >30% growth
- `B`: modest positive growth
- `C`: roughly flat
- `D`: mild decline or stalled active business
- `F`: sharp decline or active business with effectively no revenue

### 3. Margins

If trailing revenue is zero, use `N/A`.

Otherwise:

- use gross margin against the business-type benchmark
- for dominant-line businesses (>70% one line), use that benchmark
- for hybrids, use a revenue-weighted blend across product lines when available

Quick benchmark bands:

- SaaS: `A > 75`, `B 60-75`, `C 45-60`, `D 30-45`, `F < 30`
- Services: `A > 50`, `B 35-50`, `C 20-35`, `D 10-20`, `F < 10`
- Ecommerce: `A > 55`, `B 40-55`, `C 25-40`, `D 10-25`, `F < 10`

### 4. Expense Stability

Score the shape of category spending, not total spend alone.

- `A`: no unresolved material category spikes; expense pattern stable or improving
- `B`: one explained or low-risk lump, but no current unresolved instability
- `C`: one unresolved material category change versus the recent baseline
- `D`: multiple unresolved spikes or a major >30% swing in a key category
- `F`: repeated severe unexplained volatility that undermines planning confidence

When the business is winding down and prior recurring costs have been explicitly excluded, treat that as a positive stabilization signal rather than a missing-data problem.

### 5. Obligation Readiness

Compare current period-end cash to upcoming `confirmed` and `assumed` obligations in the next 60 days.

- `A`: no upcoming obligations, or cash covers them comfortably (>3x)
- `B`: cash covers upcoming obligations 2x to 3x
- `C`: cash covers upcoming obligations 1x to 2x, or all near-term obligations are still low-confidence assumptions
- `D`: cash is below upcoming obligations, or floor breach risk exists in 31 to 60 days
- `F`: cash cannot cover the next major obligation, or floor breach risk exists within 30 days

## Direction Arrows

Use recent snapshots when available.

Comparable history may come from `qb-setup`, `qb-snapshot`, or `qb-weekly`
snapshots as long as the metric shape is materially the same for the dimension
being scored. Same-day snapshots still count as comparable history when they
reflect the same metric contract.

- `↑`: dimension improved over the last 2 or more comparable observations
- `→`: roughly stable or insufficient movement to matter
- `↓`: dimension worsened over the last 2 or more comparable observations
- `?`: insufficient comparable history

If at least one prior comparable snapshot exists and the current state is
materially unchanged, use `→`, not `?`.

Example:

- latest prior comparable snapshot exists
- same grade still applies
- no material movement in the underlying metric

Then the arrow should be `→` even if all snapshots are from the same day.

Use `?` only when no prior comparable snapshot exists or the available history
is too structurally different to compare honestly.

## Overall Grade

- Compute from scored dimensions only; exclude `N/A`
- Weight `Cash Runway` 2x
- Weight `Revenue Activity` 2x when it is scored
- Weight all other scored dimensions 1x

Map numeric average to:

- `A`: >= 4.5
- `B`: >= 3.5 and < 4.5
- `C`: >= 2.5 and < 3.5
- `D`: >= 1.5 and < 2.5
- `F`: < 1.5

Use `Overall: N/A` only if fewer than 2 dimensions can honestly be scored.

## Tone Rules

- Grades should be defensible, not dramatic.
- When a weak grade is driven by an assumed item, say so.
- When a dimension is `N/A`, explain why in one short sentence.
