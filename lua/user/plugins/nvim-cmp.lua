-- lua/user/plugins/nvim-cmp.lua
return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    -- Fuentes de autocompletado
    "hrsh7th/cmp-nvim-lsp", -- Para sugerencias del LSP
    "hrsh7th/cmp-buffer",   -- Para sugerencias del buffer actual
    "hrsh7th/cmp-path",     -- Para sugerencias de rutas de archivos
    "saadparwaiz1/cmp_luasnip", -- Para sugerencias de snippets

    -- Motor de Snippets
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
  },
  config = function()
    -- La configuración de cmp ya está en lua/user/cmp.lua
    -- y se carga automáticamente. No se necesita nada aquí.
  end,
}