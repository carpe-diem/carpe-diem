[INSTALL_PROMPT.md](https://github.com/user-attachments/files/33213958/INSTALL_PROMPT.md)
# Install prompt

Paste this into an AI coding agent (e.g. Claude Code) on a new machine to install this dotfiles config.

```
Install my dev environment config from https://github.com/carpe-diem/carpe-diem, step by step,
checking before each step whether it's already done (everything must be safe to re-run), and
asking for confirmation before any destructive step.

1. Install Herdr (https://herdr.dev) via Homebrew (`brew install herdr`) if not already installed.
   Verify with `herdr status` and `herdr session list` (the server shows "not running" until
   Herdr is first launched — that's expected).
2. Install the Claude Code integration if `herdr integration status` doesn't already show
   `claude: current`: `herdr integration install claude`.
3. Install Ghostty via Homebrew (`brew install --cask ghostty`) if not already installed — it's
   the dedicated Herdr host (its config launches `/opt/homebrew/bin/herdr` directly).
4. Install Neovim via Homebrew (`brew install neovim`) if not already installed — steps 12–13
   need it.
5. Install `fd` via Homebrew (`brew install fd`) if not already installed — the Neovim file/symbol
   picker (Snacks) needs it.
6. Install `lazygit` via Homebrew (`brew install lazygit`) if not already installed — LazyVim
   auto-detects it and wires up `<leader>gg`/`<leader>gG` once the binary is on PATH, no config
   changes needed.
7. Make sure `jq` is available at `/usr/bin/jq` — close-pane-safe.sh calls it by absolute path.
   It ships with macOS 15+; on older macOS run `brew install jq` and update the `JQ=` line in the
   copied script to `$(brew --prefix)/bin/jq`.
8. Install the Herdr plugins the config binds keys to, skipping any already listed by
   `herdr plugin list`:
   - `herdr plugin install persiyanov/herdr-reviewr` (cmd+r -> `persiyanov.reviewr.toggle`)
   - `herdr plugin install smarzban/herdr-file-viewer` (cmd+e ->
     `herdr-file-viewer.open-file-viewer`), plus its renderers so markdown/diffs/code are styled:
     `brew install glow git-delta bat`
9. Back up any existing local config before overwriting it, then copy these files from the repo
   into place:
   - https://github.com/carpe-diem/carpe-diem/blob/main/configs/ghostty/config
     -> ~/.config/ghostty/config
   - https://github.com/carpe-diem/carpe-diem/blob/main/configs/herdr/config.toml
     -> ~/.config/herdr/config.toml
   - https://github.com/carpe-diem/carpe-diem/blob/main/configs/herdr/scripts/close-pane-safe.sh
     -> ~/.config/herdr/scripts/close-pane-safe.sh (make it executable with chmod +x)
   - everything under https://github.com/carpe-diem/carpe-diem/tree/main/configs/nvim
     -> ~/.config/nvim/ (copy the whole directory tree as-is, preserving the lua/ layout)
10. In the copied ~/.config/herdr/config.toml, replace the close-pane-safe.sh path with the
    absolute path for the current user's home directory (it's hardcoded per-machine).
11. Validate Herdr's config with `herdr config check` (should print `Config: ok`). If the Herdr
    server is running (`herdr status`), also reload it with `herdr server reload-config`;
    otherwise skip the reload — the config is read when Herdr first starts.
12. Make sure the Nerd Font used by Ghostty (`JetBrainsMono Nerd Font Mono`) is installed (e.g. via
    `brew install --cask font-jetbrains-mono-nerd-font`), otherwise Neovim's icons render as boxes.
13. Bootstrap Neovim's plugins without waiting for a slow first launch:
    `nvim --headless "+Lazy! sync" +qa`
    This clones ~35 plugins and can take 10+ minutes on a slow connection (snacks.nvim and
    nvim-treesitter are the big ones) — run it with a generous timeout / in the background, and
    don't treat a long run as a hang while git clones are still active.
    Exit code 0 is NOT proof of success — Lazy can exit cleanly after an interrupted clone. Verify
    afterwards: no `*.cloning` files may remain in `~/.local/share/nvim/lazy`, and every plugin dir
    there (notably `snacks.nvim` and `nvim-treesitter`) must contain more than just `.git`. If any
    check fails, delete that plugin's dir and its `.cloning` marker, then re-run the sync.
14. Install the Python LSP tooling via Mason (pyright + ruff) so `gd`/`gr` work across files:
    `nvim --headless -c "lua require('mason-registry').refresh(function() for _,n in ipairs({'pyright','ruff'}) do local p=require('mason-registry').get_package(n) if not p:is_installed() then p:install() end end end)" -c "sleep 15" -c "qa"`
15. Open any Python file in a real project and run `:VenvSelect` (`<leader>cv`) once to point
    Pyright at that project's virtualenv (e.g. `.venv/bin/python3`) — it gets cached per project
    after that.
16. Report what was installed, what was skipped (already present), and how to verify it.
```
