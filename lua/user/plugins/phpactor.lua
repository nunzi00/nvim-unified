-- lua/user/plugins/phpactor.lua
return {
  "gbprod/phpactor.nvim",
  lazy = true,
  ft = { "php" },   -- carga al abrir PHP
  cmd = { "PhpActor" },  -- y si invocas :PhpActor ...
  keys = {
    -- Los comandos del wrapper son con :PhpActor <subcomando>
    { "<leader>mm", "<cmd>PhpActor context_menu<CR>",           desc = "Phpactor: Context menu",       mode = "n" },
    { "<leader>pi", "<cmd>PhpActor import_missing_classes<CR>", desc = "Phpactor: Import missing",     mode = "n" },
    { "<leader>pe", "<cmd>PhpActor expand_class<CR>",           desc = "Phpactor: Expand class",       mode = "n" },
    { "<leader>pn", "<cmd>PhpActor new_class<CR>",              desc = "Phpactor: New class",          mode = "n" },
    { "<leader>pr", "<cmd>PhpActor change_visibility<CR>",      desc = "Phpactor: Change visibility",  mode = "n" },
    { "<leader>pm", "<cmd>PhpActor move_class<CR>",             desc = "Phpactor: Move class/file",    mode = "n" },
    { "<leader>pc", "<cmd>PhpActor copy_class<CR>",             desc = "Phpactor: Copy class/file",    mode = "n" },
    { "<leader>pt", "<cmd>PhpActor transform<CR>",              desc = "Phpactor: Transform",          mode = "n" },
    { "<leader>ps", "<cmd>PhpActor status<CR>",                 desc = "Phpactor: Status",             mode = "n" },
    -- extras posibles del wrapper: generate_accessor, copy_class, navigate, etc.
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "neovim/nvim-lspconfig",
  },
  opts = (function()
    -- Resolver binario (Composer global -> Mason -> default del plugin)
    local function resolve_phpactor_bin()
      local lines = vim.fn.systemlist('composer global config home --absolute')
      local composer_home = (lines and #lines > 0) and vim.fn.trim(lines[#lines]) or nil
      if composer_home and composer_home ~= "" then
        local candidate = composer_home .. "/vendor/bin/phpactor"
        if vim.fn.executable(candidate) == 1 then return candidate end
      end
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/phpactor"
      if vim.fn.executable(mason_bin) == 1 then return mason_bin end
      -- si no, deja que use su default: stdpath("data") .. "/opt/phpactor/bin/phpactor"
      return nil
    end

    local bin = resolve_phpactor_bin()

    return {
      install = {
        -- evita checks pesados en arranque
        check_on_startup = "none",
        -- si encontramos binario, úsalo; si no, deja el default del plugin
        bin = bin or (vim.fn.stdpath("data") .. "/opt/phpactor/bin/phpactor"),
      },
      -- MUY IMPORTANTE: no dejes que este wrapper levante el LSP
      lspconfig = {
        enabled = false,
        options = {},
      },
    }
  end)(),
}

