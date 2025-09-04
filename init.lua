local function loadrequire(module)
    local function requiref(module)
        require(module)
    end
    pcall(requiref,module)
end

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.mouse = 'a'
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require "user.options"
require "user.keymaps"
require "user.lazy"
require "user.theme-monokai-pro"
require "user.cmp"
require "user.lsp"
require "user.toggleterm"
require "user.autocommands"
require "user.dap"
require "user.filetypes"

onenord_load = function()
  vim.cmd [[colorscheme onenord]]
end

return onenord_load()
