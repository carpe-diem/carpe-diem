return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      virtual_text = {
        current_line = true,
        spacing = 4,
        source = "if_many",
        prefix = "●",
      },
    },
  },
}
