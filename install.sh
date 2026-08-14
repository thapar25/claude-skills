#!/usr/bin/env bash
# Installs/updates personal Claude Code skills from this repo onto the current machine.
# Usage: curl -fsSL https://raw.githubusercontent.com/thapar25/claude-skills/main/install.sh | bash
set -euo pipefail

REPO_URL="https://github.com/thapar25/claude-skills.git"
CLONE_DIR="$HOME/.claude-skills"
TARGET_DIR="$HOME/.claude/skills"

if [ -d "$CLONE_DIR/.git" ]; then
  git -C "$CLONE_DIR" pull --ff-only
else
  git clone "$REPO_URL" "$CLONE_DIR"
fi

mkdir -p "$TARGET_DIR"

for skill_path in "$CLONE_DIR"/skills/*/; do
  skill_path="${skill_path%/}"
  name="$(basename "$skill_path")"
  link="$TARGET_DIR/$name"

  if [ -L "$link" ]; then
    rm "$link"
  elif [ -e "$link" ]; then
    backup="${link}.bak.$(date +%s)"
    echo "Existing non-symlink at $link, backing up to $backup"
    mv "$link" "$backup"
  fi

  ln -s "$skill_path" "$link"
  echo "Linked $name"
done

echo "Done. Skills installed from $CLONE_DIR into $TARGET_DIR"

# --- "Claude needs you" sound hook ----------------------------------------
# Plays a short sound whenever Claude Code wants your attention: a permission
# prompt (PermissionRequest), a multiple-choice question (Elicitation), or the
# general attention notification (Notification, e.g. idle/away nudges).
SOUND_FILE="$CLONE_DIR/assets/sounds/pop-402322.mp3"
SETTINGS_PATH="$HOME/.claude/settings.json"
HOOK_MARKER="claude-skills:notification-sound"

case "$(uname -s)" in
  Darwin)
    PLAY_CMD="afplay \"$SOUND_FILE\""
    ;;
  *)
    if command -v paplay >/dev/null 2>&1; then
      PLAY_CMD="paplay \"$SOUND_FILE\""
    elif command -v aplay >/dev/null 2>&1; then
      PLAY_CMD="aplay \"$SOUND_FILE\""
    elif command -v ffplay >/dev/null 2>&1; then
      PLAY_CMD="ffplay -nodisp -autoexit -loglevel quiet \"$SOUND_FILE\""
    else
      PLAY_CMD=""
    fi
    ;;
esac

if [ -z "$PLAY_CMD" ]; then
  echo "Warning: no audio player found (afplay/paplay/aplay/ffplay); skipping notification sound hook."
elif ! command -v python3 >/dev/null 2>&1; then
  echo "Warning: python3 not found; skipping notification sound hook."
else
  python3 - "$SETTINGS_PATH" "$PLAY_CMD" "$HOOK_MARKER" <<'PYEOF'
import json, os, sys

settings_path, command, marker = sys.argv[1], sys.argv[2], sys.argv[3]
hook_events = ["Notification", "PermissionRequest", "Elicitation"]

if os.path.exists(settings_path):
    with open(settings_path) as f:
        data = json.load(f)
else:
    os.makedirs(os.path.dirname(settings_path), exist_ok=True)
    data = {}

hooks = data.setdefault("hooks", {})

def is_ours(entry):
    return any(
        h.get("statusMessage") == marker or "pop-402322.mp3" in (h.get("command") or "")
        for h in entry.get("hooks", [])
    )

for event in hook_events:
    entries = hooks.setdefault(event, [])
    entries[:] = [e for e in entries if not is_ours(e)]
    entries.append({
        "matcher": "",
        "hooks": [{"type": "command", "command": command, "statusMessage": marker}],
    })

with open(settings_path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")

print(f"Notification sound hook installed in {settings_path} for: {', '.join(hook_events)}")
PYEOF
fi
