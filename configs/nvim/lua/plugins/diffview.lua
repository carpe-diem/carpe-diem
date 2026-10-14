-- Side-by-side diffs / file history. Keymaps live under <leader>gv because
-- LazyVim already uses <leader>gd/gD (snacks git_diff) and <leader>gh (hunks).
return {
  { "folke/which-key.nvim", opts = { spec = { { "<leader>gv", group = "diffview" } } } },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gvo", "<cmd>DiffviewOpen<cr>", desc = "Open (working tree)" },
      { "<leader>gvc", "<cmd>DiffviewClose<cr>", desc = "Close" },
      { "<leader>gvf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gvh", "<cmd>DiffviewFileHistory<cr>", desc = "Repo history" },
    },
    opts = {},
  },
}
