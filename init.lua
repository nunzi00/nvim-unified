-- init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.mouse = 'a'
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Prepend Composer global vendor/bin to PATH (sin invocar composer)
local home = vim.fn.expand("~")
local bins = {
  home .. "/.config/composer/vendor/bin", -- composer moderno
  home .. "/.composer/vendor/bin",        -- ruta antigua
}
for _, p in ipairs(bins) do
  if vim.fn.isdirectory(p) == 1 then
    -- Evita duplicar
    if not vim.env.PATH:find(vim.pesc(p), 1, true) then
      vim.env.PATH = p .. ":" .. vim.env.PATH
    end
    break
  end
end


require "user.options"
require "user.keymaps"
require "user.lazy"
require "user.theme-monokai-pro"
require "user.cmp"
require "user.autocommands"
require "user.dap"
require "user.filetypes"
require "luasnip"

-- vim.cmd [[colorscheme onenord]]

-- fuerza ejecutable para los comandos :Phpactor*
if vim.fn.executable("phpactor") == 1 then
  vim.g["phpactor#path"] = vim.fn.exepath("phpactor")  -- usa el del PATH (Composer)
end

