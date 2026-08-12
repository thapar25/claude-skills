---
name: work-log
description: "Use when a meaningful chunk of work (config edits, deployments, upgrades, debugging, real code changes) is wrapping up or a goal has been reached: proactively offer to write a session summary to claude-work-logs/. Also use if the user explicitly asks to log, write up, or summarize the session. Skip for trivial one-off Q&A."
---

# Work log

When a session's goal is achieved, or work is close to done on something meaningful, proactively
offer in one line — e.g. "Want me to log this session to claude-work-logs/?" — do not just do it.

**Do not draft or write the file until the user explicitly agrees.** If they decline, drop it.

What counts as "meaningful": config edits, deployments, upgrades, debugging, code changes. Skip the
offer for trivial one-off Q&A or read-only exploration.

Once the user agrees:

1. Get the real date/time via `date` (never guess it from context).
2. Create `claude-work-logs/` in the current project/working directory if it doesn't already exist.
3. Write `claude-work-logs/YYYY-MM-DD_HHMM_short-slug.md` containing:
   - What was done
   - Why
   - End state / anything left pending
