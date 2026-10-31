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
4. Install Neovim via Homebrew (`brew install neovim`) if not already installed — steps 14–15
   need it.
5. Install `fd` via Homebrew (`brew install fd`) if not already installed — the Neovim file/symbol
   picker (Snacks) needs it.
6. Install `lazygit` via Homebrew (`brew install lazygit`) if not already installed — LazyVim
   auto-detects it and wires up `<leader>gg`/`<leader>gG` once the binary is on PATH (its own
   config, which renders diffs with delta, is copied in step 11). Also install `git-delta` (`brew install git-delta`, binary is `delta`) if
   not already installed — it's git's pager (configured in step 11) and a file-viewer renderer.
7. Make sure `jq` is available at `/usr/bin/jq` — close-pane-safe.sh and the layout plugin call it
   by absolute path.
   It ships with macOS 15+; on older macOS run `brew install jq` and update the `JQ=` line in the
   copied script to `$(brew --prefix)/bin/jq`.
8. Install `claude` (Claude Code) if not already on PATH — new Herdr workspaces start it in their
   `IA` tab (see step 11).
9. Install pi (https://pi.dev), the second coding agent used inside Herdr, if `pi` isn't on PATH:
   `curl -fsSL https://pi.dev/install.sh | sh` (installs to `~/.pi/agent/` and links
   `~/.local/bin/pi`). It needs Node.js >= 22.19 as the `node` on PATH; with nvm make sure
   `nvm alias default` points to 22+ (an older node makes pi crash with
   `does not provide an export named 'enableCompileCache'`). Verify with `pi --version`.
   Logging in (`pi`, then `/login`, or a provider API key) is interactive — leave it to me.
   Step 11 installs pi's Herdr integration and its footer extension.
10. Clone the repo to `~/code/carpe-diem` if it isn't there yet
   (`git clone https://github.com/carpe-diem/carpe-diem ~/code/carpe-diem`); if it already exists,
   leave it alone (step 11 pulls it).
11. Run `~/code/carpe-diem/update.sh`. It is idempotent and only copies files that differ,
    backing up anything it overwrites to `~/.config/carpe-diem-backups/<timestamp>/`. It:
    - pulls the repo (`git pull --ff-only`, skipped if the clone has local changes)
    - copies `configs/ghostty/config` -> ~/.config/ghostty/config
    - copies `configs/herdr/config.toml` -> ~/.config/herdr/config.toml, rewriting the hardcoded
      `/Users/<user>/.config/herdr/` script paths to the current `$HOME`
    - copies `configs/herdr/scripts/` -> ~/.config/herdr/scripts/ (chmod +x). The cmd+w guard,
      close-pane-safe.sh, calls jq at `/usr/bin/jq` (see step 7)
    - copies `configs/herdr/plugins/workspace-layout/` -> ~/.config/herdr/local-plugins/workspace-layout/
      and `herdr plugin link`s it. On `workspace.created` it builds the tabs
      IA (claude + reviewr split on the right) | Services (2x2 shells) | Git (lazygit) | Code (nvim) | Console, all in the
      workspace's directory (git worktree workspaces get only IA and Console). It only touches single-pane workspaces; `prefix+shift+l` applies it
      to an existing one
    - copies `configs/herdr/reviewr/config.toml` -> ~/.config/herdr/plugins/config/persiyanov.reviewr/config.toml
      (`auto_open = false`: the layout already opens reviewr, so worktree workspaces would get two)
    - installs the Herdr plugins the config binds keys to, if missing:
      `persiyanov/herdr-reviewr` (cmd+r) and `smarzban/herdr-file-viewer` (cmd+e; its renderers
      come from `brew install glow git-delta bat`, which you should run if they're missing)
    - runs `herdr integration install pi` if pi is installed and `herdr integration status`
      doesn't show `pi: current`
    - copies `configs/pi/extensions/` -> ~/.pi/agent/extensions/ (pi auto-loads them).
      `status-footer.ts` replaces pi's footer with one line:
      `~/path/dir · git:branch · provider/model (thinking)   [▪▪........] 18% (256k)`
    - copies `configs/nvim/` -> ~/.config/nvim/ (the whole tree, including gitsigns.nvim and
      diffview.nvim: `<leader>gvo` open, `<leader>gvc` close, `<leader>gvf` file history,
      `<leader>gvh` repo history, all under `<leader>gv` because LazyVim already owns
      `<leader>gd`/`gD`/`gh`)
    - copies `configs/git/delta.gitconfig` -> ~/.config/git/delta.gitconfig and adds it to
      `include.path` in ~/.gitconfig if it isn't there already (it never overwrites ~/.gitconfig)
    - copies `configs/lazygit/config.yml` -> `"$(lazygit --print-config-dir)/config.yml"` (on macOS
      that's ~/Library/Application Support/lazygit/, not ~/.config/lazygit). It uses the
      `git.diffRenderers` key (lazygit >= 0.65). Don't "fix" it back to `git.paging`
    - runs `herdr config check` (must print `Config: ok`) and `herdr server reload-config` if the
      server is running
    - runs `nvim --headless "+Lazy! restore" +qa` when the Neovim config changed. On a fresh
      machine that clones every plugin and can take 10+ minutes, so run it with a generous timeout.
      Step 14 still verifies the result
    Show its output. Verify with `git config core.pager` (should print `delta`) and
    `herdr plugin list` (should list `carpe-diem.workspace-layout`, `persiyanov.reviewr` and
    `herdr-file-viewer`).
12. Sanity-check the layout: `herdr workspace create --cwd ~/code/carpe-diem --label layout-test --no-focus`,
    then `herdr tab list --workspace <id>` should show IA (2 panes), Services (4 panes), Git, Code and Console.
    Close it with `herdr workspace close <id>`. Skip this step if the Herdr server isn't running.
13. Make sure the Nerd Font used by Ghostty (`JetBrainsMono Nerd Font Mono`) is installed (e.g. via
    `brew install --cask font-jetbrains-mono-nerd-font`), otherwise Neovim's icons render as boxes.
14. Bootstrap Neovim's plugins without waiting for a slow first launch:
    `nvim --headless "+Lazy! sync" +qa`
    This clones ~35 plugins and can take 10+ minutes on a slow connection (snacks.nvim and
    nvim-treesitter are the big ones) — run it with a generous timeout / in the background, and
    don't treat a long run as a hang while git clones are still active.
    Exit code 0 is NOT proof of success — Lazy can exit cleanly after an interrupted clone. Verify
    afterwards: no `*.cloning` files may remain in `~/.local/share/nvim/lazy`, and every plugin dir
    there (notably `snacks.nvim` and `nvim-treesitter`) must contain more than just `.git`. If any
    check fails, delete that plugin's dir and its `.cloning` marker, then re-run the sync.
15. Install the Python LSP tooling via Mason (pyright + ruff) so `gd`/`gr` work across files:
    `nvim --headless -c "lua require('mason-registry').refresh(function() for _,n in ipairs({'pyright','ruff'}) do local p=require('mason-registry').get_package(n) if not p:is_installed() then p:install() end end end)" -c "sleep 15" -c "qa"`
16. Open any Python file in a real project and run `:VenvSelect` (`<leader>cv`) once to point
    Pyright at that project's virtualenv (e.g. `.venv/bin/python3`) — it gets cached per project
    after that.
17. Ask me whether this machine should also run the shared dev infrastructure in
    `~/code/carpe-diem/infra` (Postgres, S3/SeaweedFS, Logto, Mailpit, optional Valkey, Caddy on
    `*.localhost`; see `infra/README.md`). Skip this step if I say no. If yes:
    - Use Podman (not Docker). Install it if missing:
      `brew install podman podman-compose` and `brew install --cask podman-desktop`.
    - Create the VM if `podman machine list` shows none:
      `podman machine init --cpus 4 --memory 4096 --disk-size 50`. Start it with
      `podman machine start` if it isn't running.
    - Run `~/code/carpe-diem/infra/infra up`. On the first run it lowers
      `net.ipv4.ip_unprivileged_port_start` to 80 inside the Podman VM (persisted in
      `/etc/sysctl.d/`) so Caddy can serve `*.localhost` on ports 80/443; that's expected.
    - Run `~/code/carpe-diem/infra/infra trust` so the browser accepts `https://*.localhost`
      (adds Caddy's local CA to the login keychain; macOS asks for my password).
    - Verify with `infra/infra status` (all services up) and
      `curl -s -o /dev/null -w '%{http_code}' https://logto.localhost/oidc/.well-known/openid-configuration`
      (should print 200). Remind me that the first visit to https://logto-admin.localhost creates
      the Logto admin account.
    - Don't create any project databases; each project's own setup does that via
      `infra/infra project create <name>`.
18. Report what was installed, what was skipped (already present), and how to verify it.
```

## Updating

After changing a config in the repo (and pushing it), run this on every other machine:

```
~/code/carpe-diem/update.sh
```

It pulls, copies only what changed (with backups), reloads Herdr and, if the Neovim config
changed, runs `Lazy! restore` to match `lazy-lock.json`. Use `./update.sh --no-pull` to apply
uncommitted local edits on the machine you're working on. Ghostty needs `cmd+shift+,` to pick up
its config.
