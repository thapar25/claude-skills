# claude-skills

Personal Claude Code skills, synced across dev machines.

## Install / update on a machine

This repo is **private**, so a plain `curl` to raw.githubusercontent.com won't work
(404, unauthenticated). Clone over git instead — this reuses whatever GitHub auth
you already have set up (`gh auth login`, or SSH keys) — then run the installer:

```
git clone https://github.com/thapar25/claude-skills.git ~/.claude-skills 2>/dev/null || git -C ~/.claude-skills pull --ff-only
bash ~/.claude-skills/install.sh
```

The installer itself also does a clone-or-pull of `~/.claude-skills`, so the first
line is mostly there to bootstrap the very first run before `install.sh` exists locally.
It then symlinks each skill under `skills/` into `~/.claude/skills/`. Re-run either
form any time to pick up updates.

## Adding a new skill

1. Create `skills/<name>/SKILL.md` (and any supporting files) here.
2. Commit and push.
3. Re-run the install command above on every machine (including this one, if the
   skill wasn't authored directly inside `~/.claude-skills/skills/`).
