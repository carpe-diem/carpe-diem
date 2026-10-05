# Install prompt

Paste this into an AI coding agent (e.g. Claude Code) on a new machine to install this dotfiles config.

```
Install my dev environment config from https://github.com/carpe-diem/carpe-diem, step by step,
checking before each step whether it's already done (everything must be safe to re-run), and
asking for confirmation before any destructive step.

1. Install Herdr (https://herdr.dev) via Homebrew (`brew install herdr`) if not already installed.
   Verify with `herdr status` and `herdr session list`.
2. Install the Claude Code integration: `herdr integration install claude`.
3. Install `fd` via Homebrew (`brew install fd`) if not already installed — the Neovim file/symbol
   picker (Snacks) needs it.
4. Install `lazygit` via Homebrew (`brew install lazygit`) if not already installed — LazyVim
   auto-detects it and wires up `<leader>gg`/`<leader>gG` once the binary is on PATH, no config
   changes needed.
5. Back up any existing local config before overwriting it, then copy these files from the repo
   into place:
   - https://github.com/carpe-diem/carpe-diem/blob/main/configs/ghostty/config
     -> ~/.config/ghostty/config
   - https://github.com/carpe-diem/carpe-diem/blob/main/configs/herdr/config.toml
     -> ~/.config/herdr/config.toml
   - https://github.com/carpe-diem/carpe-diem/blob/main/configs/herdr/scripts/close-pane-safe.sh
     -> ~/.config/herdr/scripts/close-pane-safe.sh (make it executable with chmod +x)
   - everything under https://github.com/carpe-diem/carpe-diem/tree/main/configs/nvim
     -> ~/.config/nvim/ (copy the whole directory tree as-is, preserving the lua/ layout)
6. In the copied ~/.config/herdr/config.toml, replace the close-pane-safe.sh path with the
   absolute path for the current user's home directory (it's hardcoded per-machine).
7. Reload Herdr's config with `herdr server reload-config` and confirm `herdr status` shows no
   errors.
8. Make sure the Nerd Font used by Ghostty (`JetBrainsMono Nerd Font Mono`) is installed (e.g. via
   `brew install --cask font-jetbrains-mono-nerd-font`), otherwise Neovim's icons render as boxes.
9. Bootstrap Neovim's plugins without waiting for a slow first launch:
   `nvim --headless "+Lazy! sync" +qa`
10. Install the Python LSP tooling via Mason (pyright + ruff) so `gd`/`gr` work across files:
    `nvim --headless -c "lua require('mason-registry').refresh(function() for _,n in ipairs({'pyright','ruff'}) do local p=require('mason-registry').get_package(n) if not p:is_installed() then p:install() end end end)" -c "sleep 15" -c "qa"`
11. Open any Python file in a real project and run `:VenvSelect` (`<leader>cv`) once to point
    Pyright at that project's virtualenv (e.g. `.venv/bin/python3`) — it gets cached per project
    after that.
12. Report what was installed, what was skipped (already present), and how to verify it.
```
