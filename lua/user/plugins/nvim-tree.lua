return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy= false,
  dependencies = {"nvim-tree/nvim-web-devicons"},
  config = function ()
    require("nvim-tree").setup {
      update_focused_file = {
        enable = true,
        update_cwd = true,
      },
      renderer = {
        root_folder_modifier = ":t",
      },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
        icons = {
          hint = "󰉀",
          info = "",
          warning = "",
          error = "",
        },
      },
      view = {
        width = 40,
        side = "left",
      }
    }
  end
}
