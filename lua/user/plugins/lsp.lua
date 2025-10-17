-- lua/user/plugins/lsp.lua
return {
  "williamboman/mason-lspconfig.nvim",
  lazy = false,
  dependencies = {
    {
      "williamboman/mason.nvim",
      config = function()
        require("mason").setup({
          PATH = "append",
        })
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
      "tsserver",
      "vimls",
      "yamlls",
      "intelephense",
      -- Phpactor se configura aparte
    }

    local mlsp = require("mason-lspconfig")
    mlsp.setup({
      ensure_installed = servers,
      automatic_installation = true,
    })

    local handlers = require("user.lsp.handlers")

    -- === Intelephense ===
    local intelephense_js = vim.fn.stdpath("data")
      .. "/mason/packages/intelephense/node_modules/intelephense/lib/intelephense.js"
    local node_bin = vim.fn.exepath("node")

    local function setup_default(server_name)
      if server_name == "intelephense" then return end
      vim.lsp.config[server_name] = {
        on_attach = handlers.on_attach,
        capabilities = handlers.capabilities,
        single_file_support = true,
      }
      vim.lsp.enable(server_name)
    end

    local function setup_php_like(opts)
      vim.lsp.config["intelephense"] = vim.tbl_deep_extend("force", {
        on_attach = handlers.on_attach,
        capabilities = handlers.capabilities,
        root_dir = function(_) return vim.loop.cwd() end,
        single_file_support = true,
        cmd = (node_bin ~= "" and { node_bin, intelephense_js, "--stdio" }) or { "intelephense", "--stdio" },
        settings = {
          intelephense = {
            environment = { phpVersion = "8.3" },
            format = { enable = true },
            files = {
              maxSize = 4 * 1024 * 1024,
              exclude = {
                "**/.git/**",
                "**/node_modules/**",
                "**/var/**",
              },
            },
          },
        },
      }, opts or {})
      vim.lsp.enable("intelephense")
    end

    -- === Fallback manual si no hay setup_handlers ===
    local installed = mlsp.get_installed_servers and mlsp.get_installed_servers() or servers
    for _, server_name in ipairs(installed) do
      setup_default(server_name)
    end
    setup_php_like()

    -- === Autocmd para asegurar attach en buffers PHP ===
    local grp = vim.api.nvim_create_augroup("php_lsp_try_add_all", { clear = true })
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter", "BufWinEnter" }, {
      group = grp,
      pattern = "*.php",
      callback = function()
        for _, client in ipairs(vim.lsp.get_clients({ name = "intelephense" })) do
          if client and client.attached_buffers then
            return
          end
        end
        vim.lsp.enable("intelephense")
      end,
    })

    -- === Anti-duplicados (intelephense) ===
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
      for _, c in ipairs(vim.lsp.get_clients({ name = "intelephense" })) do
        local r = client_root(c)
        if r ~= cwd then
          vim.schedule(function() c:stop() end)
        end
      end
      local same = {}
      for _, c in ipairs(vim.lsp.get_clients({ name = "intelephense" })) do
        if client_root(c) == cwd then table.insert(same, c) end
      end
      for i = 2, #same do
        local c = same[i]
        vim.schedule(function() c:stop() end)
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
        if client and client.name == "intelephense" then
          kill_non_cwd_php_clients()
        end
      end,
    })

    -- === Phpactor como LSP (solo code actions) ===
    vim.lsp.config["phpactor"] = {
      on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        if handlers and handlers.on_attach then
          handlers.on_attach(client, bufnr)
        end
      end,
      capabilities = handlers and handlers.capabilities or nil,
      root_dir = function() return vim.loop.cwd() end,
      single_file_support = true,
      init_options = {
        ["language_server_worse_reflection.inlay_hints.enable"] = false,
      },
    }
    vim.lsp.enable("phpactor")

    local grp2 = vim.api.nvim_create_augroup("phpactor_lsp_try_add", { clear = true })
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter", "BufWinEnter" }, {
      group = grp2,
      pattern = "*.php",
      callback = function()
        vim.lsp.enable("phpactor")
      end,
    })
  end,
}

