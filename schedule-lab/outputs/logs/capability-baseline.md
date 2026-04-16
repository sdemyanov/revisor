# Capability Baseline

**Captured:** 2026-04-15
**Session:** wizardly-gracious-fermi
**Scope:** Enumerate every `mcp__*` tool exposed to this session, grouped by server. No side-effecting actions performed beyond a single read-only QuickBooks probe noted below.

## MCP tools by server

### `mcp__Claude_in_Chrome__*` — Chrome browser automation (first-party)
- `mcp__Claude_in_Chrome__computer`
- `mcp__Claude_in_Chrome__file_upload`
- `mcp__Claude_in_Chrome__find`
- `mcp__Claude_in_Chrome__form_input`
- `mcp__Claude_in_Chrome__get_page_text`
- `mcp__Claude_in_Chrome__gif_creator`
- `mcp__Claude_in_Chrome__javascript_tool`
- `mcp__Claude_in_Chrome__navigate`
- `mcp__Claude_in_Chrome__read_console_messages`
- `mcp__Claude_in_Chrome__read_network_requests`
- `mcp__Claude_in_Chrome__read_page`
- `mcp__Claude_in_Chrome__resize_window`
- `mcp__Claude_in_Chrome__shortcuts_execute`
- `mcp__Claude_in_Chrome__shortcuts_list`
- `mcp__Claude_in_Chrome__switch_browser`
- `mcp__Claude_in_Chrome__tabs_close_mcp`
- `mcp__Claude_in_Chrome__tabs_context_mcp`
- `mcp__Claude_in_Chrome__tabs_create_mcp`
- `mcp__Claude_in_Chrome__upload_image`

### `mcp__cowork__*` — Cowork filesystem helpers (first-party)
- `mcp__cowork__allow_cowork_file_delete`
- `mcp__cowork__present_files`
- `mcp__cowork__request_cowork_directory`

### `mcp__cowork-onboarding__*` — Cowork onboarding UI (first-party)
- `mcp__cowork-onboarding__show_onboarding_role_picker`

### `mcp__mcp-registry__*` — Connector discovery (first-party)
- `mcp__mcp-registry__search_mcp_registry`
- `mcp__mcp-registry__suggest_connectors`

### `mcp__plugins__*` — Plugin marketplace (first-party)
- `mcp__plugins__search_plugins`
- `mcp__plugins__suggest_plugin_install`

### `mcp__scheduled-tasks__*` — Scheduled task management (first-party)
- `mcp__scheduled-tasks__create_scheduled_task`
- `mcp__scheduled-tasks__list_scheduled_tasks`
- `mcp__scheduled-tasks__update_scheduled_task`

### `mcp__session_info__*` — Session transcript inspection (first-party)
- `mcp__session_info__list_sessions`
- `mcp__session_info__read_transcript`

### `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__*` — QuickBooks connector (third-party, Intuit)

Read / analysis tools:
- `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__about-quickbooks` *(informational; no auth required)*
- `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__benchmarking-against-industry`
- `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__benchmarking-quickbooks-account`
- `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__cash-flow-generator`
- `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__cash-flow-quickbooks-account`
- `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__company-info`
- `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__industry-recommendation`
- `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__profit-loss-generator`
- `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__profit-loss-quickbooks-account`

Write / mutating tools (not exercised — out of scope for a read-only baseline):
- `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__quickbooks-profile-info-update`
- `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__quickbooks-transaction-import`

### Previously advertised, now unavailable
- `RemoteTrigger` — its MCP server disconnected during this session.

## Third-party connector audit

**QuickBooks — PRESENT and AUTHENTICATED** as a registered MCP server (opaque server id `aea89b51-0a76-4f66-ae82-a3b496c4dadc`). OAuth completed between the first and second probe attempts; the read probe now succeeds (see below).

Still **not present**:

- Slack — absent
- Gmail — absent
- Google Drive — absent
- GitHub — absent
- Notion — absent
- Asana — absent
- Other SaaS connectors (Jira, Linear, Salesforce, HubSpot, Box, Dropbox, OneDrive, Outlook, Teams, Zoom, PagerDuty, etc.) — absent

Additional connectors can be discovered via `mcp__mcp-registry__search_mcp_registry` and proposed to the user with `mcp__mcp-registry__suggest_connectors`.

## QuickBooks read-only probe

**Tool probed:** `mcp__aea89b51-0a76-4f66-ae82-a3b496c4dadc__company-info`
**Why this one:** Smallest genuine read against the QuickBooks API — no parameters, no side effects, returns only `Company Name` and `Industry` as plain text. (`about-quickbooks` is purely informational and would not exercise the connector. `quickbooks-profile-info-update` and `quickbooks-transaction-import` are mutating and were deliberately skipped.)

**Result history in this session:**

1. First attempt — **FAILED (auth required).** Server response: `This connector requires authentication. The user needs to connect it before this tool can be used.`
2. Second attempt (after the user authorized the connector) — **SUCCEEDED.** Server response:
   ```
   Company Name: Lumos Land Inc.
   Industry: 518210
   ```

**Interpretation:** The QuickBooks connector is now fully reachable and authenticated for this session. NAICS code `518210` corresponds to "Data Processing, Hosting, and Related Services", so the linked company appears to be a tech/hosting business. No state was changed; only the read-only `company-info` endpoint was called.
