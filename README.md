# claude-skills

<p align="center">
  <img src="https://cdn.simpleicons.org/claudecode/D97757" alt="Claude Code" width="200" />
</p>

A small collection of [Claude Code](https://claude.com/claude-code) skills — reusable,
version-controlled instructions that steer how Claude works on things like PR hygiene
and session logging. Clone it, install it, and Claude picks up these behaviors
automatically whenever they're relevant.

## What's here

| Skill | What it does |
|---|---|
| [`git-pr-workflow`](skills/git-pr-workflow/SKILL.md) | Keeps commits short and puts the real rationale, summary, and test plan in the PR description via `gh pr create`. |
| [`work-log`](skills/work-log/SKILL.md) | When a meaningful chunk of work wraps up, offers to write a dated session summary to `claude-work-logs/` — only writes it once you say yes. |

## Install

The install scripts below clone this repo and symlink each skill into Claude
Code's skills directory, so updates just need a `git pull` (or re-running the
one-liner) to take effect everywhere.

### macOS / Linux / WSL (bash)

```bash
git clone https://github.com/thapar25/claude-skills.git ~/.claude-skills 2>/dev/null || git -C ~/.claude-skills pull --ff-only
bash ~/.claude-skills/install.sh
```

Symlinks each skill under `skills/` into `~/.claude/skills/`.

### Windows (native PowerShell, not WSL)

```powershell
git clone https://github.com/thapar25/claude-skills.git "$env:USERPROFILE\.claude-skills" 2>$null; if (-not $?) { git -C "$env:USERPROFILE\.claude-skills" pull --ff-only }
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude-skills\install.ps1"
```

Links each skill under `skills/` into `%USERPROFILE%\.claude\skills\` as a directory
**junction** (works without admin rights or Developer Mode, unlike symlinks). If
junctions somehow fail too, it falls back to a plain copy and warns that you'll need
to re-run the script after each `git pull` to pick up changes.

Either form is idempotent — re-run it any time to pick up updates.

## Adding a new skill

1. Create `skills/<name>/SKILL.md` (and any supporting files) here.
2. Commit and push.
3. Re-run the install command above on every machine (including this one, if the
   skill wasn't authored directly inside `~/.claude-skills/skills/`).
