#!/bin/bash
# Apply this repo's configs to the current machine. Safe to re-run: only files
# that differ are copied, and every overwritten file is backed up first to
# ~/.config/carpe-diem-backups/<timestamp>/.
#
#   ./update.sh            git pull, then apply
#   ./update.sh --no-pull  apply the working tree as-is (e.g. to test local edits)
set -euo pipefail
# Under pipefail `cmd | grep -q` can fail when grep exits early (SIGPIPE),
# so checks grep captured output (<<<"$(cmd)") instead of a pipe.

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO/configs"
BACKUP="$HOME/.config/carpe-diem-backups/$(date +%Y%m%d-%H%M%S)"
HERDR_DIR="$HOME/.config/herdr"
# Local Herdr plugins shipped in configs/herdr/plugins/<dir>, as "<dir>:<plugin id>"
LOCAL_PLUGINS=(workspace-layout:carpe-diem.workspace-layout agent-map:carpe-diem.agent-map)
changed=()

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

if [ "${1:-}" != "--no-pull" ]; then
  if [ -n "$(git -C "$REPO" status --porcelain --untracked-files=no)" ]; then
    say "Local changes in $REPO, skipping git pull"
  else
    say "Pulling latest config"
    git -C "$REPO" pull --ff-only
  fi
fi

# install_file <src> <dest>: copy if different, backing up the old dest
install_file() {
  local src="$1" dest="$2"
  if [ -f "$dest" ] && cmp -s "$src" "$dest"; then return; fi
  if [ -e "$dest" ]; then
    mkdir -p "$BACKUP/$(dirname "${dest#"$HOME"/}")"
    cp -p "$dest" "$BACKUP/${dest#"$HOME"/}"
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  changed+=("$dest")
}

# install_tree <src-dir> <dest-dir>: install_file for every file in the tree
install_tree() {
  local src="$1" dest="$2" f
  while IFS= read -r -d '' f; do
    install_file "$f" "$dest/${f#"$src"/}"
  done < <(find "$src" -type f ! -name .DS_Store -print0)
}

say "Copying configs"
install_file "$SRC/ghostty/config" "$HOME/.config/ghostty/config"

# config.toml hardcodes absolute script paths; rewrite them for this $HOME
rendered="$(mktemp)"
skill="$(mktemp)"
claude_settings="$(mktemp)"
trap 'rm -f "$rendered" "$skill" "$claude_settings"' EXIT
sed -E "s#/Users/[^/\"]+/\.config/herdr/#$HERDR_DIR/#g" "$SRC/herdr/config.toml" >"$rendered"
install_file "$rendered" "$HERDR_DIR/config.toml"
install_tree "$SRC/herdr/scripts" "$HERDR_DIR/scripts"
chmod +x "$HERDR_DIR"/scripts/*.sh
for p in "${LOCAL_PLUGINS[@]}"; do
  install_tree "$SRC/herdr/plugins/${p%%:*}" "$HERDR_DIR/local-plugins/${p%%:*}"
done
chmod +x "$HERDR_DIR"/local-plugins/*/*.sh "$HERDR_DIR"/local-plugins/*/*.py 2>/dev/null || true
install_file "$SRC/herdr/reviewr/config.toml" "$HERDR_DIR/plugins/config/persiyanov.reviewr/config.toml"

install_tree "$SRC/nvim" "$HOME/.config/nvim"
install_file "$SRC/git/delta.gitconfig" "$HOME/.config/git/delta.gitconfig"
grep -qx '~/.config/git/delta.gitconfig' <<<"$(git config --global --get-all include.path || true)" \
  || git config --global --add include.path '~/.config/git/delta.gitconfig'

# pi auto-loads every extension in ~/.pi/agent/extensions/ (status-footer.ts = its footer line)
install_tree "$SRC/pi/extensions" "$HOME/.pi/agent/extensions"

# pi packages (`pi install` records them in ~/.pi/agent/settings.json)
PI_PACKAGES=(
  https://github.com/earendil-works/pi-claude-code # Anthropic models through the Claude Code CLI login
  npm:pi-anthropic-oauth                            # Claude Pro/Max OAuth login inside pi
)
if pi --version >/dev/null 2>&1; then
  pi_installed="$(pi list 2>/dev/null || true)"
  for pkg in "${PI_PACKAGES[@]}"; do
    grep -qxF "  $pkg" <<<"$pi_installed" || { say "Installing pi package $pkg"; pi install "$pkg"; }
  done
elif command -v pi >/dev/null; then
  say "pi doesn't start (Node >= 22.19 needed), skipping its packages"
fi

if command -v lazygit >/dev/null; then
  install_file "$SRC/lazygit/config.yml" "$(lazygit --print-config-dir)/config.yml"
else
  say "lazygit not installed, skipping its config"
fi

if command -v herdr >/dev/null; then
  say "Herdr plugins"
  plugins="$(herdr plugin list 2>/dev/null || true)"
  grep -q 'persiyanov.reviewr' <<<"$plugins" || herdr plugin install persiyanov/herdr-reviewr --yes
  grep -q 'herdr-file-viewer' <<<"$plugins" || herdr plugin install smarzban/herdr-file-viewer --yes

  # Agent-state integration for pi (working/blocked/idle in Herdr's sidebar)
  integrations="$(herdr integration status 2>/dev/null || true)"
  if command -v pi >/dev/null && ! grep -q '^pi: current' <<<"$integrations"; then
    herdr integration install pi
  fi

  # (Re)link the local plugins from their installed copies
  for p in "${LOCAL_PLUGINS[@]}"; do
    dir="$HERDR_DIR/local-plugins/${p%%:*}" id="${p#*:}"
    if ! grep -q "$id" <<<"$plugins"; then
      herdr plugin link "$dir" >/dev/null
    elif ! grep -qF "$dir" <<<"$(grep -A2 "$id" <<<"$plugins")"; then
      herdr plugin unlink "$id" >/dev/null
      herdr plugin link "$dir" >/dev/null
    fi
  done

  # Herdr's agent skill (release-matched, from `herdr --skill`) so claude and pi can
  # inspect and drive other panes/agents: `herdr agent prompt backend "..." --wait`
  if herdr --skill >"$skill" 2>/dev/null && [ -s "$skill" ]; then
    install_file "$skill" "$HOME/.claude/skills/herdr/SKILL.md"
    install_file "$skill" "$HOME/.pi/agent/skills/herdr/SKILL.md"
  fi

  # Claude Code hooks that log `herdr agent prompt` calls for the agent map (prefix+m);
  # merged into ~/.claude/settings.json next to whatever hooks are already there
  if command -v claude >/dev/null && python3 - "$HOME/.claude/settings.json" "$claude_settings" <<'PY'
import json, os, sys
src, out = sys.argv[1], sys.argv[2]
settings = json.load(open(src)) if os.path.exists(src) else {}
cmd = 'python3 "$HOME/.config/herdr/local-plugins/agent-map/agent-bus.py" claude-hook'
hooks = settings.setdefault("hooks", {})
added = False
for event in ("PreToolUse", "PostToolUse", "PostToolUseFailure"):
    entries = hooks.setdefault(event, [])
    if not any(h.get("command") == cmd for e in entries for h in e.get("hooks", [])):
        entries.append({"matcher": "Bash", "hooks": [{"type": "command", "command": cmd}]})
        added = True
json.dump(settings, open(out, "w"), indent=2)
open(out, "a").write("\n")
sys.exit(0 if added else 1)
PY
  then
    install_file "$claude_settings" "$HOME/.claude/settings.json"
  fi

  herdr config check
  if grep -q 'status: running' <<<"$(herdr status 2>/dev/null || true)"; then
    herdr server reload-config >/dev/null && say "Reloaded running Herdr server"
  fi
fi

if command -v nvim >/dev/null && grep -q '/\.config/nvim/' <<<"$(printf '%s\n' "${changed[@]:-}")"; then
  say "Neovim config changed, restoring plugins to lazy-lock.json"
  nvim --headless "+Lazy! restore" +qa >/tmp/carpe-diem-lazy-restore.log 2>&1 \
    || say "Lazy restore failed, see /tmp/carpe-diem-lazy-restore.log"
fi

if [ ${#changed[@]} -eq 0 ]; then
  say "Already up to date"
else
  say "Updated ${#changed[@]} file(s):"
  printf '    %s\n' "${changed[@]}"
  [ -d "$BACKUP" ] && say "Previous versions backed up to $BACKUP"
  grep -q '/ghostty/' <<<"$(printf '%s\n' "${changed[@]}")" \
    && say "Ghostty: reload its config with cmd+shift+, (or restart it)"
fi
exit 0
