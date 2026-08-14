# claude-skills

<p align="center">
  <img src="https://cdn.simpleicons.org/claudecode/D97757" alt="Claude Code" width="200" />
</p>

A small collection of personal [Claude Code](https://claude.com/claude-code) customizations —
skills (reusable, version-controlled instructions that steer how Claude works on things
like PR hygiene and session logging) and hooks (commands Claude Code runs automatically
on lifecycle events). Clone it, install it, and these behaviors sync across every machine.

## Skills

| Skill | What it does |
|---|---|
| [`git-pr-workflow`](skills/git-pr-workflow/SKILL.md) | Keeps commits short and puts the real rationale, summary, and test plan in the PR description via `gh pr create`. |
| [`work-log`](skills/work-log/SKILL.md) | When a meaningful chunk of work wraps up, offers to write a dated session summary to `claude-work-logs/` — only writes it once you say yes. |

## Hooks

| Hook | What it does |
|---|---|
| Notification sound | Plays a short pop sound (`assets/sounds/pop-402322.mp3`) on `Notification`, `PermissionRequest`, and `Elicitation` — i.e. whenever Claude Code wants your attention, a permission decision, or an answer to a question. Cross-platform: `afplay`/`paplay`/`aplay`/`ffplay` on macOS/Linux, WPF `MediaPlayer` on Windows. |

Sound credit: ["Film Special Effects Pop"](https://pixabay.com/sound-effects/film-special-effects-pop-402322/)
by Dragon_Studio, via Pixabay ([license](https://pixabay.com/service/license-summary/)).

## Install

The install scripts below clone this repo, symlink each skill into Claude
Code's skills directory, and merge the notification-sound hook into
`settings.json`, so updates just need a `git pull` (or re-running the
one-liner) to take effect everywhere.

### macOS / Linux / WSL (bash)

```bash
git clone https://github.com/thapar25/claude-skills.git ~/.claude-skills 2>/dev/null || git -C ~/.claude-skills pull --ff-only
bash ~/.claude-skills/install.sh
```

Symlinks each skill under `skills/` into `~/.claude/skills/` and merges the notification
hook into `~/.claude/settings.json`.

### Windows (native PowerShell, not WSL)

```powershell
git clone https://github.com/thapar25/claude-skills.git "$env:USERPROFILE\.claude-skills" 2>$null; if (-not $?) { git -C "$env:USERPROFILE\.claude-skills" pull --ff-only }
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude-skills\install.ps1"
```

Links each skill under `skills/` into `%USERPROFILE%\.claude\skills\` as a directory
**junction** (works without admin rights or Developer Mode, unlike symlinks). If
junctions somehow fail too, it falls back to a plain copy and warns that you'll need
to re-run the script after each `git pull` to pick up changes. Also merges the
notification hook into `%USERPROFILE%\.claude\settings.json`.

Either form is idempotent — re-run it any time to pick up updates.

## Adding a new skill

1. Create `skills/<name>/SKILL.md` (and any supporting files) here.
2. Commit and push.
3. Re-run the install command above on every machine (including this one, if the
   skill wasn't authored directly inside `~/.claude-skills/skills/`).

## Adding a new hook

The install scripts currently manage one hook (notification sound) directly. To add
another, extend the "Notification sound hook" section of `install.sh`/`install.ps1`
(or add a similar block) — each merge is keyed by a `statusMessage` marker so re-running
install stays idempotent instead of appending duplicates.
