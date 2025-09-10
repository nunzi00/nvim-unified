-- lua/user/lsp/handlers.lua
local M = {}

-- Forzar la carga de las capacidades de nvim-cmp.
-- Si esto falla, es una dependencia que falta y debe ser instalada.
local cmp_nvim_lsp = require("cmp_nvim_lsp")

-- Capacidades LSP + nvim-cmp
M.capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Colores para los diagnósticos
vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#FF0000", bg = "#232129" })
vim.api.nvim_set_hl(0, "DiagnosticSignWarn",  { fg = "#FFA500", bg = "#232129" })
vim.api.nvim_set_hl(0, "DiagnosticSignInfo",  { fg = "#00FFFF", bg = "#232129" })
vim.api.nvim_set_hl(0, "DiagnosticSignHint",  { fg = "#808080", bg = "#232129" })

-- Config global de diagnósticos y handlers
local function setup_diagnostics()
  vim.diagnostic.config({
    virtual_text = false,
    underline = true,
    update_in_insert = true,
    severity_sort = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN]  = "",
        [vim.diagnostic.severity.HINT]  = "󰉀",
        [vim.diagnostic.severity.INFO]  = "",
      },
    },
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  })

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover,
    { border = "rounded" }
  )

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    { border = "rounded" }
  )
end
setup_diagnostics() -- Ejecutar la configuración

M.on_attach = function(client, bufnr)
  -- vim.notify("on_attach called for: " .. client.name) -- DEBUG
  -- Desactivar formateo donde no lo quieres
  if client.name == "tsserver" or client.name == "ts_ls" then
    client.server_capabilities.documentFormattingProvider = false
  end
  if client.name == "lua_ls" then
    client.server_capabilities.documentFormattingProvider = false
  end

  -- Illuminate (opcional)
  local ok_illum, illuminate = pcall(require, "illuminate")
  if ok_illum then
    illuminate.on_attach(client)
  end
end

return M