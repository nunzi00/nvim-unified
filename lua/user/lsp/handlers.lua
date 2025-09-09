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

local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true }
  local keymap = vim.api.nvim_buf_set_keymap
  keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  keymap(bufnr, "n", "<leader>k", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  keymap(bufnr, "n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  keymap(bufnr, "n", "<leader>lf", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
  keymap(bufnr, "n", "<leader>li", "<cmd>LspInfo<CR>", opts)
  keymap(bufnr, "n", "<leader>lj", "<cmd>lua vim.diagnostic.goto_next({ buffer = 0 })<CR>", opts)
  keymap(bufnr, "n", "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev({ buffer = 0 })<CR>", opts)
  keymap(bufnr, "n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  keymap(bufnr, "n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  keymap(bufnr, "n", "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
end

M.on_attach = function(client, bufnr)
  -- Desactivar formateo donde no lo quieres
  if client.name == "tsserver" or client.name == "ts_ls" then
    client.server_capabilities.documentFormattingProvider = false
  end
  if client.name == "lua_ls" then
    client.server_capabilities.documentFormattingProvider = false
  end

  -- Mapear code_action solo si el servidor lo soporta
  if client.server_capabilities.codeActionProvider then
    local opts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  end

  lsp_keymaps(bufnr)

  -- Illuminate (opcional)
  local ok_illum, illuminate = pcall(require, "illuminate")
  if ok_illum then
    illuminate.on_attach(client)
  end
end

return M