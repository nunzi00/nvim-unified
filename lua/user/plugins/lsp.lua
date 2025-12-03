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
      "ts_ls",
      "vimls",
      "yamlls",
      "intelephense",
    }

    local mlsp = require("mason-lspconfig")
    mlsp.setup({
      ensure_installed = servers,
      automatic_installation = true,
    })

    local lspconfig = require("lspconfig")
    local handlers = require("user.lsp.handlers")

    -- Configuración por defecto para la mayoría de servidores
    local default_config = {
      on_attach = handlers.on_attach,
      capabilities = handlers.capabilities,
    }

    -- === Configurar todos los servidores excepto intelephense ===
    for _, server_name in ipairs(servers) do
      if server_name ~= "intelephense" then
        lspconfig[server_name].setup(default_config)
      end
    end

    -- === Intelephense (PHP) ===
    lspconfig.intelephense.setup({
      on_attach = handlers.on_attach,
      capabilities = handlers.capabilities,
      root_dir = function() return vim.loop.cwd() end,
      single_file_support = true,
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
    })

    -- === Phpactor (PHP - solo code actions) ===
    lspconfig.phpactor.setup({
      on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        if handlers and handlers.on_attach then
          handlers.on_attach(client, bufnr)
        end
      end,
      capabilities = handlers.capabilities,
      root_dir = function() return vim.loop.cwd() end,
      single_file_support = true,
      init_options = {
        ["language_server_worse_reflection.inlay_hints.enable"] = false,
      },
    })
  end,
}
