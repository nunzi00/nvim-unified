-- lua/user/plugins/lsp.lua
return {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    -- Handlers seguros
    local ok_handlers, handlers = pcall(require, "user.lsp.handlers")
    if not ok_handlers then
      handlers = {
        on_attach = function() end,
        capabilities = vim.lsp.protocol.make_client_capabilities(),
      }
      vim.schedule(function()
        vim.notify("[LSP] No se pudo cargar user.lsp.handlers", vim.log.levels.WARN)
      end)
    end

    local lspconfig = require("lspconfig")
    local util      = require("lspconfig.util")

    -- Servidores a instalar
    local servers = {
      "bashls","dockerls","eslint","html","jsonls","lua_ls",
      "sqlls","ts_ls","vimls","yamlls", "phpactor", "intelephense",
    }

    -- Configuración centralizada con mason-lspconfig
    require("mason-lspconfig").setup({
      ensure_installed = servers,
      automatic_installation = true,
      handlers = {
        -- Handler por defecto para todos los servidores
        function(server_name)
          lspconfig[server_name].setup({
            on_attach = handlers.on_attach,
            capabilities = handlers.capabilities,
            single_file_support = true,
          })
        end,

        -- Configuración específica para Intelephense (principalmente para autocompletado)
        -- ["intelephense"] = function()
        --   local php_root = util.root_pattern("composer.json", ".git")
        --   lspconfig.intelephense.setup({
        --     on_attach = handlers.on_attach,
        --     capabilities = handlers.capabilities,
        --     single_file_support = true,
        --     root_dir = function(fname) return php_root(fname) or util.path.dirname(fname) end,
        --   })
        -- end,

        -- Configuración específica para Phpactor (principalmente para code_action)
        ["phpactor"] = function()
          lspconfig.phpactor.setup({
            on_attach = handlers.on_attach,
            capabilities = handlers.capabilities,
            root_dir = util.root_pattern("composer.json"),
          })
        end,
      }
    })

    -- Utilidades
    vim.api.nvim_create_user_command("OpenMason", function() require("mason.ui").open() end, {})
  end,
}
