-- lua/user/plugins/lsp.lua
return {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = {
    {
      "williamboman/mason.nvim",
      lazy = false,
      config = function() require("mason").setup() end,
    },
    { "williamboman/mason-lspconfig.nvim", lazy = false },
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

    -- Resolver binarios: Mason (settings) -> PATH
    local function exepath_safe(name)
      local p = vim.fn.exepath(name)
      if p and p ~= "" then return p end
      return nil
    end

    local function phpactor_bin()
      local ok, settings = pcall(require, "mason.settings")
      if ok and settings and settings.current and settings.current.install_root_dir then
        local bin = settings.current.install_root_dir .. "/bin/phpactor"
        if vim.loop.fs_stat(bin) then
          return bin
        end
      end
      -- fallback a PATH (si Mason no está o no lo tiene instalado)
      return exepath_safe("phpactor")
    end

    -- Servidores a instalar (Mason solo instala)
    local servers = {
      "bashls","dockerls","eslint","html","jsonls","lua_ls",
      "sqlls","ts_ls","vimls","yamlls","phpactor","intelephense",
    }
    require("mason-lspconfig").setup({
      ensure_installed = servers,
      automatic_installation = true,
    })

    -- Helper genérico
    local function setup(server, opts)
      lspconfig[server].setup(vim.tbl_deep_extend("force", {
        on_attach = handlers.on_attach,
        capabilities = handlers.capabilities,
        single_file_support = true,
      }, opts or {}))
    end

    -- Servidores no-PHP (evita duplicar yamlls si ya hay manager)
    for _, s in ipairs(servers) do
      if s ~= "phpactor" and s ~= "intelephense" then
        if lspconfig[s] and not lspconfig[s].manager then
          if s ~= "yamlls" or (s == "yamlls" and not lspconfig.yamlls.manager) then
            setup(s)
          end
        end
      end
    end

    -- === PHP ===
    local php_root = util.root_pattern("composer.json", ".git")
    local php_excludes = {
      "**/.git/**","**/node_modules/**","**/vendor/**",
      "**/var/**","**/cache/**","**/var/cache/**",
    }

    -- Phpactor (forzado con bin resuelto por Mason settings o PATH)
    do
      local bin = phpactor_bin()
      if not bin then
        vim.schedule(function()
          vim.notify("[phpactor] Binario no encontrado (instala con :Mason o composer)", vim.log.levels.ERROR)
        end)
      else
        setup("phpactor", {
          cmd = { bin, "language-server" },
          filetypes = { "php" },
          root_dir = function(fname) return php_root(fname) or util.path.dirname(fname) end,
          single_file_support = true,
          -- Si usas phpstan/psalm/psr-12 vía phpactor.json, no hace falta tocar aquí:
          init_options = {
            ["language_server_phpstan.enabled"] = false, -- lo controlas en phpactor.json si usas extension
            ["language_server.diagnostics_on_update"] = false,
          },
          settings = { phpactor = { files = { exclude = php_excludes } } },
          on_init = function(client)
            vim.schedule(function()
              vim.notify("[phpactor] attached → " .. (client.config.root_dir or "?"))
            end)
          end,
        })
      end
    end

    -- Intelephense (comenta este bloque si quieres probar solo phpactor)
    setup("intelephense", {
      root_dir = function(fname) return php_root(fname) or util.path.dirname(fname) end,
      settings = { intelephense = { files = { exclude = php_excludes } } },
    })

    -- Deduplicación (API nueva)
    local function kill_non_project_php_clients()
      local cwd = vim.loop.cwd()
      for _, name in ipairs({ "phpactor", "intelephense" }) do
        for _, c in ipairs(vim.lsp.get_clients({ name = name })) do
          local root = (c.config and c.config.root_dir) or ""
          if root ~= "" and root ~= cwd and not root:find(vim.pesc(cwd), 1, true) then
            vim.schedule(function() c.stop() end)
          end
        end
      end
    end
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("php_lsp_dedupe_fix", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and (client.name == "phpactor" or client.name == "intelephense") then
          kill_non_project_php_clients()
        end
      end,
    })

    -- Utilidades
    vim.api.nvim_create_user_command("OpenMason", function() require("mason.ui").open() end, {})
    vim.api.nvim_create_user_command("PhpactorDebug", function()
      local rd = (function()
        local buf = vim.api.nvim_get_current_buf()
        local fname = vim.api.nvim_buf_get_name(buf)
        return (php_root(fname) or util.path.dirname(fname)) or "?"
      end)()
      vim.print({
        phpactor_cmd = (function()
          local b = phpactor_bin()
          return b and { b, "language-server" } or "NOT FOUND"
        end)(),
        root_dir = rd,
        clients = vim.tbl_map(function(c)
          return { id=c.id, name=c.name, root=(c.config and c.config.root_dir) or "" }
        end, vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })),
      })
    end, {})
  end,
}

