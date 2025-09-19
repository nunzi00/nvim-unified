-- lua/user/plugins/lsp.lua

return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    {
      "williamboman/mason.nvim",
      config = function()
        require("mason").setup({
          PATH = "append", -- clave: que Mason no pise tu PATH
        })
      end,
    },
    "neovim/nvim-lspconfig",
  },
  config = function()
    -- Importante: NO incluimos "phpactor" aquí para que Mason no lo gestione como LSP
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
      "intelephense", -- único LSP para PHP
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
      if server_name == "intelephense" then return end
      if not lspconfig[server_name] then return end
      if lspconfig[server_name].manager ~= nil then return end
      lspconfig[server_name].setup({
        on_attach = handlers.on_attach,
        capabilities = handlers.capabilities,
        single_file_support = true,
      })
    end

    local function setup_php_like(server_name, opts)
      if not lspconfig[server_name] then return end
      if lspconfig[server_name].manager ~= nil then return end
      lspconfig[server_name].setup(vim.tbl_deep_extend("force", {
        on_attach = handlers.on_attach,
        capabilities = handlers.capabilities,
        -- Forzamos root_dir al CWD para evitar raíces del monorepo que no te interesen
        root_dir = function(_) return vim.loop.cwd() end,
        single_file_support = true,
      }, opts or {}))
    end

    -- API nueva (setup_handlers) o fallback
    if type(mlsp.setup_handlers) == "function" then
      mlsp.setup_handlers({
        -- Handler por defecto para todos los servidores salvo intelephense
        function(server_name)
          setup_default(server_name)
        end,

        -- Phpactor NO se configura aquí para evitar levantar su LSP
        -- ["phpactor"] = function() end,

        ["intelephense"] = function()
          setup_php_like("intelephense", {
            settings = {
              intelephense = {
                files = {
                  exclude = {
                    "**/.git/**",
                    "**/node_modules/**",
                    "**/vendor/**",
                    "**/var/**",
                  },
                },
              },
            },
          })
        end,
      })
    else
      -- Fallback en caso de versiones antiguas de mason-lspconfig
      local installed = mlsp.get_installed_servers and mlsp.get_installed_servers() or servers
      for _, server_name in ipairs(installed) do
        setup_default(server_name)
      end

      -- NO configuramos phpactor aquí (se elimina el bloque que lo levantaba)
      setup_php_like("intelephense", {
        settings = {
          intelephense = {
            files = {
              exclude = {
                "**/.git/**",
                "**/node_modules/**",
                "**/vendor/**",
                "**/var/**",
              },
            },
          },
        },
      })
    end

    -- === Anti-duplicados (acotado a intelephense) ===
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
      for _, name in ipairs({ "intelephense" }) do
        local same = {}
        for _, c in ipairs(vim.lsp.get_active_clients({ name = name })) do
          local r = client_root(c)
          if r ~= cwd then
            vim.schedule(function() c.stop() end)
          else
            table.insert(same, c)
          end
        end
        -- Si por lo que sea se levantaran múltiples en el mismo root, dejamos solo uno
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
        if client.name == "intelephense" then
          kill_non_cwd_php_clients()
        end
      end,
    })
  end,
}

