#!/bin/bash
# Install the tv-setup skill for Claude Code and pi, pointing it at this checkout's tv/ folder.
# Safe to re-run: the skill is rewritten only when it changed.
set -euo pipefail

TV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
rendered="$(mktemp)"
trap 'rm -f "$rendered"' EXIT
sed "s#__TV_DIR__#$TV_DIR#g" "$TV_DIR/skill/SKILL.md" >"$rendered"

for dest in "$HOME/.claude/skills/tv-setup/SKILL.md" "$HOME/.pi/agent/skills/tv-setup/SKILL.md"; do
  if [ -f "$dest" ] && cmp -s "$rendered" "$dest"; then
    echo "up to date: $dest"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$rendered" "$dest"
    echo "installed:  $dest"
  fi
done
