return {
  "phpactor/phpactor",
  branch = "master",
  ft = "php",                             -- lo carga solo en buffers PHP
  build = "composer install --no-dev -o", -- instala dependencias
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  config = function()
    -- Opcional: mapeos cómodos
    vim.keymap.set("n", "<leader>mm", "<cmd>PhpactorContextMenu<CR>", { desc = "Phpactor context menu" })
    vim.keymap.set("n", "<leader>pi", "<cmd>PhpactorImportMissingClasses<CR>", { desc = "Phpactor import missing classes" })
    vim.keymap.set("n", "<leader>pc", "<cmd>PhpactorClassExpand<CR>", { desc = "Phpactor expand class" })
    vim.keymap.set("n", "<leader>pn", "<cmd>PhpactorClassNew<CR>", { desc = "Phpactor new class" })
    vim.keymap.set("n", "<leader>pr", "<cmd>PhpactorRenameVariable<CR>", { desc = "Phpactor rename variable" })
    vim.keymap.set("n", "<leader>pm", "<cmd>PhpactorMoveFile<CR>",  { desc = "Phpactor move file" })
  end,
}
