# Phase 1 Report Artifact Contract

This document settles artifact naming, HTML generation approach, and the
internal-versus-shareable redaction rules before `/revisor:qb-report` exists.

## Decision Summary

1. **Canonical outputs are timestamped and immutable.**
2. **Markdown and HTML variants are both first-class outputs.**
3. **HTML is written directly by Claude as a self-contained file with inline styles.**
4. **Internal and shareable outputs are distinct artifacts, not one file with optional redaction.**
5. **Local owner-directed delivery can include raw metrics; public shareable artifacts cannot.**

## Canonical File Names

All canonical artifacts use UTC timestamps plus a flow slug.

### Snapshots

- `.revisor/snapshots/YYYY-MM-DDTHH-MM-SSZ-qb-setup.json`
- `.revisor/snapshots/YYYY-MM-DDTHH-MM-SSZ-qb-snapshot.json`
- `.revisor/snapshots/YYYY-MM-DDTHH-MM-SSZ-qb-weekly.json`
- `.revisor/snapshots/YYYY-MM-DDTHH-MM-SSZ-hub-weekly.json`
- `.revisor/snapshots/YYYY-MM-DDTHH-MM-SSZ-stripe-weekly.json`
- `.revisor/snapshots/YYYY-MM-DDTHH-MM-SSZ-biz-weekly.json`

### Briefings

- `.revisor/reports/YYYY-MM-DDTHH-MM-SSZ-briefing.md`
- `.revisor/reports/YYYY-MM-DDTHH-MM-SSZ-hub-briefing.md`
- `.revisor/reports/YYYY-MM-DDTHH-MM-SSZ-stripe-briefing.md`
- `.revisor/reports/YYYY-MM-DDTHH-MM-SSZ-biz-briefing.md`

### Health Reports

- `.revisor/reports/YYYY-MM-DDTHH-MM-SSZ-health-report-internal.md`
- `.revisor/reports/YYYY-MM-DDTHH-MM-SSZ-health-report-internal.html`
- `.revisor/reports/YYYY-MM-DDTHH-MM-SSZ-health-report-shareable.md`
- `.revisor/reports/YYYY-MM-DDTHH-MM-SSZ-health-report-shareable.html`
- `.revisor/reports/YYYY-MM-DDTHH-MM-SSZ-biz-health-report-internal.md`
- `.revisor/reports/YYYY-MM-DDTHH-MM-SSZ-biz-health-report-internal.html`
- `.revisor/reports/YYYY-MM-DDTHH-MM-SSZ-biz-health-report-shareable.md`
- `.revisor/reports/YYYY-MM-DDTHH-MM-SSZ-biz-health-report-shareable.html`

### Convenience Aliases

These may be rewritten, but they are never the canonical record:

- `.revisor/snapshots/latest-qb-weekly.json`
- optional future convenience links like `latest-hub-weekly.json` or `latest-stripe-weekly.json`
- optional future convenience links such as `latest-health-report-internal.md`

## HTML Generation Decision

Revisor stays pure markdown and does not depend on a separate template engine.
For Phase 1 and Phase 3, Claude should write HTML directly using a fixed,
self-contained structure:

- single standalone HTML document
- inline CSS only
- no external fonts, scripts, or images
- no dependency on a build step
- no requirement for a shared partial/template runtime

The shared formatting skill should still define the structure and sections so the
generated HTML stays consistent. The point is to avoid introducing a second
runtime or packaging surface just to render reports.

## Internal Report Rules

Internal reports are owner-facing artifacts and may include:

- absolute dollar amounts
- exact runway values
- exact margins and percentages
- client names
- vendor names
- overdue balance details
- concrete recommendations tied to real account values

Internal markdown and internal HTML should match each other closely in content.

## Shareable Report Rules

Shareable reports are public-facing artifacts meant for screenshots, social
sharing, or lightweight peer comparison.

They may include:

- dimension names
- letter grades
- directional labels such as `improving`, `stable`, or `needs attention`
- qualitative explanations
- relative statements such as `above target`, `below target`, or `top client concentration is elevated`
- a short next-step recommendation
- a footer CTA that points to the future Cowork marketplace entry and the source repo

They must not include:

- absolute dollar amounts
- cash balances
- revenue totals
- profit totals
- invoice totals
- payroll figures
- exact customer or vendor names
- exact account identifiers
- raw connector payload excerpts

## Redaction Rubric

| Data class | Internal variant | Shareable variant |
|------------|------------------|-------------------|
| Letter grades | Show | Show |
| Trend direction | Show | Show |
| Absolute revenue, cash, profit | Show | Remove |
| Exact percentages | Show | Round into qualitative band if needed |
| Named customers or vendors | Show | Replace with generic labels like `top client` or `annual insurance` |
| Runway | Show exact months | Express as band, for example `healthy`, `watch`, `critical` |
| Risks and recommendations | Show | Show, but without confidential amounts or names |

## Minimum Report Sections

Both internal and shareable report variants should include:

1. Title and reporting date
2. Overall grade or summary state
3. Five dimension grades for the QuickBooks-only MVP
4. Top strengths
5. Top risks
6. One recommended next step
7. Footer

The difference between variants is not structure. It is the level of detail and
the presence or absence of sensitive metrics.

## Non-Public Delivery Exception

Slack, email, Google Docs, or other user-directed delivery channels may include
raw metrics if the user intentionally routes them to a destination they control.
That does **not** change the rules above for `*-shareable.*` artifacts. Public
shareability and owner-directed delivery are separate concerns.
