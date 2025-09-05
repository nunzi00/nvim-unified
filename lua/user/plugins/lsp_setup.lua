return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    {
      "williamboman/mason.nvim",
      config = function()
        require("mason").setup()
      end,
    },
    "neovim/nvim-lspconfig",
  },
  config = function()
    local servers = {
      "bashls",
      "dockerls",
      "eslint",
      "html",
      "jsonls",
      "lua_ls",
      "sqlls",
      "ts_ls",       -- o "tsserver" según tu setup
      "vimls",
      "yamlls",
      "phpactor",
      "intelephense",
    }

    local mlsp = require("mason-lspconfig")
    mlsp.setup({
      ensure_installed = servers,
      automatic_installation = true,
    })

    local lspconfig = require("lspconfig")
    local handlers = require("user.lsp.handlers")

    -- Helpers de setup
    local function setup_default(server_name)
      if server_name == "phpactor" or server_name == "intelephense" then return end
      if not lspconfig[server_name] then return end
      -- Evitar doble setup si algún otro módulo ya lo hizo
      if lspconfig[server_name].manager ~= nil then return end
      lspconfig[server_name].setup({
        on_attach = handlers.on_attach,
        capabilities = handlers.capabilities,
        single_file_support = true,
      })
    end

    local function setup_php_like(server_name)
      if not lspconfig[server_name] then return end
      if lspconfig[server_name].manager ~= nil then return end
      lspconfig[server_name].setup({
        on_attach = handlers.on_attach,
        capabilities = handlers.capabilities,
        root_dir = function(_) return vim.loop.cwd() end,
        single_file_support = true,
      })
    end

    -- API nueva (setup_handlers) o fallback
    if type(mlsp.setup_handlers) == "function" then
      mlsp.setup_handlers({
        function(server_name)
          setup_default(server_name)
        end,
        ["phpactor"] = function()
          setup_php_like("phpactor")
        end,
        ["intelephense"] = function()
          setup_php_like("intelephense")
        end,
      })
    else
      local installed = mlsp.get_installed_servers and mlsp.get_installed_servers() or servers
      for _, server_name in ipairs(installed) do
        setup_default(server_name)
      end
      setup_php_like("phpactor")
      setup_php_like("intelephense")
    end

    -- === Anti-duplicados robusto (phpactor/intelephense) ===
    local function client_root(client)
      if client.root_dir and type(client.root_dir) == "string" then
        return client.root_dir
      end
      if client.workspace_folders and client.workspace_folders[1] and client.workspace_folders[1].name then
        return client.workspace_folders[1].name
      end
      if client.config and type(client.config.root_dir) == "string" then
        return client.config.root_dir
      end
      return ""
    end

    local function kill_non_cwd_php_clients()
      local cwd = vim.loop.cwd()
      for _, name in ipairs({ "phpactor", "intelephense" }) do
        local same = {}
        for _, c in ipairs(vim.lsp.get_active_clients({ name = name })) do
          local r = client_root(c)
          if r ~= cwd then
            vim.schedule(function() c.stop() end)
          else
            table.insert(same, c)
          end
        end
        -- si hay más de uno con el mismo cwd, deja solo uno
        for i = 2, #same do
          local c = same[i]
          vim.schedule(function() c.stop() end)
        end
      end
    end

    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("php_lsp_dedupe_boot", { clear = true }),
      callback = function() kill_non_cwd_php_clients() end,
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("php_lsp_dedupe_attach", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end
        if client.name == "phpactor" or client.name == "intelephense" then
          kill_non_cwd_php_clients()
        end
      end,
    })
  end,
}

