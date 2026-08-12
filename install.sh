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
