return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Ruff's default rule set is broader than most projects actually enforce
      -- (pyupgrade, tryceratops, etc.), so without an explicit [tool.ruff.lint]
      -- it floods old/untouched code with warnings nobody asked for. Scope the
      -- editor down to flake8's bread and butter (pyflakes + pycodestyle) —
      -- override per-project with a .ruff.toml if a project wants Ruff's full set.
      ruff = {
        init_options = {
          settings = {
            lint = { select = { "E", "F", "W" } },
          },
        },
      },
    },
  },
}
