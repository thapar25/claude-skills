# claude-skills

Personal Claude Code skills, synced across dev machines.

## Install / update on a machine

```
curl -fsSL https://raw.githubusercontent.com/thapar25/claude-skills/main/install.sh | bash
```

This clones (or pulls, if already cloned) the repo to `~/.claude-skills` and symlinks
each skill under `skills/` into `~/.claude/skills/`. Re-run it any time to pick up updates.

## Adding a new skill

1. Create `skills/<name>/SKILL.md` (and any supporting files) here.
2. Commit and push.
3. Re-run the install command above on every machine (including this one, if the
   skill wasn't authored directly inside `~/.claude-skills/skills/`).
