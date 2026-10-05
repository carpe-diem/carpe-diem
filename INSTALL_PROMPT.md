# Install prompt

Paste this into an AI coding agent (e.g. Claude Code) on a new machine to install this dotfiles config.

```
Install my terminal config from https://github.com/carpe-diem/carpe-diem, step by step, checking
before each step whether it's already done (everything must be safe to re-run), and asking for
confirmation before any destructive step.

1. Install Herdr (https://herdr.dev) via Homebrew (`brew install herdr`) if not already installed.
   Verify with `herdr status` and `herdr session list`.
2. Install the Claude Code integration: `herdr integration install claude`.
3. Back up any existing local config before overwriting it, then copy these files from the repo
   into place:
   - https://github.com/carpe-diem/carpe-diem/blob/main/configs/ghostty/config
     -> ~/.config/ghostty/config
   - https://github.com/carpe-diem/carpe-diem/blob/main/configs/herdr/config.toml
     -> ~/.config/herdr/config.toml
   - https://github.com/carpe-diem/carpe-diem/blob/main/configs/herdr/scripts/close-pane-safe.sh
     -> ~/.config/herdr/scripts/close-pane-safe.sh (make it executable with chmod +x)
4. In the copied ~/.config/herdr/config.toml, replace the close-pane-safe.sh path with the
   absolute path for the current user's home directory (it's hardcoded per-machine).
5. Reload Herdr's config with `herdr server reload-config` and confirm `herdr status` shows no
   errors.
6. Report what was installed, what was skipped (already present), and how to verify it.
```
