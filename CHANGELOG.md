# Changelog

## 1.0.0 - 2026-04-16

First public 1.0 release for the local-first Revisor Cowork plugin.

### Added

- QuickBooks financial intelligence flows:
  - `/revisor:qb-setup`
  - `/revisor:qb-health`
  - `/revisor:qb-forecast`
  - `/revisor:qb-snapshot`
  - `/revisor:qb-weekly`
  - `/revisor:qb-report`
  - `/revisor:qb-expenses`
  - `/revisor:qb-whatif`
- HubSpot CRM and pipeline flows:
  - `/revisor:hub-setup`
  - `/revisor:hub-pipeline`
  - `/revisor:hub-forecast`
  - `/revisor:hub-velocity`
  - `/revisor:hub-sources`
  - `/revisor:hub-weekly`
- Stripe subscription and payments flows:
  - `/revisor:stripe-setup`
  - `/revisor:stripe-mrr`
  - `/revisor:stripe-churn`
  - `/revisor:stripe-payments`
  - `/revisor:stripe-weekly`
- Cross-source business flows:
  - `/revisor:biz-health`
  - `/revisor:biz-forecast`
  - `/revisor:biz-report`
  - `/revisor:biz-customers`
  - `/revisor:biz-weekly`
- Shared skills for formatting, proactive analysis, scoring, cross-source synthesis, and deterministic entity matching
- Local-first runtime state under `.revisor/`
- Timestamped snapshot and report artifacts, including shareable redacted health reports
- Scheduled prompts for QuickBooks, HubSpot, Stripe, and unified business weekly briefings
- Validation scaffolding for fresh install, command smoke tests, scheduled runs, and local schema/build checks

### Shipped Scope

`v1.0` includes the proven QuickBooks, HubSpot, Stripe, and `biz-*` layers in one package.

### Deferred To The Next Release Train

- Salesforce parity (`/revisor:sf-*`)
- Slack or email push delivery
- Connector-specific analyses that depend on invoice, aging, vendor-detail, or customer-detail surfaces not yet proven in the current connectors
- Automatic learning from every casual conversation
