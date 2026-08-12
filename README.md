# claude-skills

Personal Claude Code skills, synced across dev machines.

## Install / update on a machine

This repo is **private**, so a plain `curl` to raw.githubusercontent.com won't work
(404, unauthenticated). Clone over git instead, reusing whatever GitHub auth is
already set up on the machine (`gh auth login`, SSH keys, or on Windows the Git
Credential Manager that ships with Git for Windows).

### macOS / Linux / WSL (bash)

```
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
