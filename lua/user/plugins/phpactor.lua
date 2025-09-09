return {
  "phpactor/phpactor",
  branch = "master",
  ft = "php", -- lo carga solo en buffers PHP
  build = "composer install --no-dev -o", -- instala dependencias
  config = function()
    -- Opcional: mapeos cómodos
    vim.keymap.set("n", "<leader>pm", "<cmd>PhpactorContextMenu<CR>", { desc = "Phpactor context menu" })
    vim.keymap.set("n", "<leader>pi", "<cmd>PhpactorImportMissingClasses<CR>", { desc = "Phpactor import missing classes" })
    vim.keymap.set("n", "<leader>pn", "<cmd>PhpactorClassExpand<CR>", { desc = "Phpactor expand class" })
  end,
}

