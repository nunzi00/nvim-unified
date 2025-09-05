return {
  "windwp/nvim-autopairs", -- Autopairs, integrates with both cmp and treesitter
  event = "InsertEnter",
  config = function()
    require("nvim-autopairs").setup()
  end,
}
