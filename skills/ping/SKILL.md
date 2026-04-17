---
name: ping
description: >
  This skill should be used when the user says "revisor ping",
  "test revisor", "is revisor installed", or "check revisor".
  Confirms the Revisor plugin is installed and responding.
metadata:
  version: "1.0.0"
---

# Revisor Ping

Reply in plain text with exactly this structure:

```text
Revisor plugin smoke test OK.
Version: 1.0.0
Skill: ping
```

If the user supplied additional context, add one extra line:

```text
Note: <user's context>
```

Keep the response short. Do not use tools.
