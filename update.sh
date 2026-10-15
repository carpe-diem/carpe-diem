#!/bin/bash
# Apply this repo's configs to the current machine. Safe to re-run: only files
# that differ are copied, and every overwritten file is backed up first to
# ~/.config/carpe-diem-backups/<timestamp>/.
#
#   ./update.sh            git pull, then apply
#   ./update.sh --no-pull  apply the working tree as-is (e.g. to test local edits)
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO/configs"
BACKUP="$HOME/.config/carpe-diem-backups/$(date +%Y%m%d-%H%M%S)"
HERDR_DIR="$HOME/.config/herdr"
LAYOUT_PLUGIN_ID="carpe-diem.workspace-layout"
LAYOUT_PLUGIN_DIR="$HERDR_DIR/local-plugins/workspace-layout"
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
trap 'rm -f "$rendered"' EXIT
sed -E "s#/Users/[^/\"]+/\.config/herdr/#$HERDR_DIR/#g" "$SRC/herdr/config.toml" >"$rendered"
install_file "$rendered" "$HERDR_DIR/config.toml"
install_tree "$SRC/herdr/scripts" "$HERDR_DIR/scripts"
chmod +x "$HERDR_DIR"/scripts/*.sh
install_tree "$SRC/herdr/plugins/workspace-layout" "$LAYOUT_PLUGIN_DIR"

install_tree "$SRC/nvim" "$HOME/.config/nvim"
install_file "$SRC/git/delta.gitconfig" "$HOME/.config/git/delta.gitconfig"
git config --global --get-all include.path | grep -qx '~/.config/git/delta.gitconfig' \
  || git config --global --add include.path '~/.config/git/delta.gitconfig'

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

  # (Re)link the local layout plugin from its installed copy
  if ! grep -q "$LAYOUT_PLUGIN_ID" <<<"$plugins"; then
    herdr plugin link "$LAYOUT_PLUGIN_DIR" >/dev/null
  elif ! herdr plugin list | grep -A2 "$LAYOUT_PLUGIN_ID" | grep -q "$LAYOUT_PLUGIN_DIR"; then
    herdr plugin unlink "$LAYOUT_PLUGIN_ID" >/dev/null
    herdr plugin link "$LAYOUT_PLUGIN_DIR" >/dev/null
  fi

  herdr config check
  if herdr status 2>/dev/null | grep -q 'status: running'; then
    herdr server reload-config >/dev/null && say "Reloaded running Herdr server"
  fi
fi

if command -v nvim >/dev/null && printf '%s\n' "${changed[@]:-}" | grep -q '/\.config/nvim/'; then
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
  printf '%s\n' "${changed[@]}" | grep -q '/ghostty/' \
    && say "Ghostty: reload its config with cmd+shift+, (or restart it)"
fi
exit 0
