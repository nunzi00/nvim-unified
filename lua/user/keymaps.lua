local opts = { noremap = true, silent = true }

-- local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.keymap.set

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<S-h>", "<C-w>h", opts)
keymap("n", "<S-j>", "<C-w>j", opts)
keymap("n", "<S-k>", "<C-w>k", opts)
keymap("n", "<S-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<C-h>", "gT", opts)
keymap("n", "<C-l>", "gt", opts)

-- Move text up and down
keymap("n", "<A-j>", "<Esc>:m .+1<CR>==gi", opts)
keymap("n", "<A-k>", "<Esc>:m .-2<CR>==gi", opts)

-- Reload nvim config
keymap("n", "<Leader>sv", ":source $MYVIMRC<CR>", opts)

-- Edit snippets
keymap("n", "<Leader>se", ":lua require('luasnip.loaders').edit_snippet_files()<CR>", opts)

-- Insert --
-- Press jk fast to exit insert mode
keymap("i", "jj", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
-- keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Terminal --
-- Better terminal navigation
-- keymap("t", "<C-h>", "<C-\><C-N><C-w>h", term_opts)
-- keymap("t", "<C-j>", "<C-\><C-N><C-w>j", term_opts)
-- keymap("t", "<C-k>", "<C-\><C-N><C-w>k", term_opts)
-- keymap("t", "<C-l>", "<C-\><C-N><C-w>l", term_opts)

-- Command
-- Expand current folder
keymap("c", "%%", [[getcmdtype() == ':' ? expand('%:h').'/' : '%%']], { noremap = true, silent = false, expr = true })

-- Telescope
-- keymap("n", "<leader>f", "<cmd>Telescope find_files<CR>", opts)
-- -- keymap("n", "<leader>f", "<cmd>lua require'telescope.builtin'.find_files(require('telescope.themes').get_dropdown({ previewer = false }))<CR>", opts)
-- keymap("n", "<C-t>", "<cmd>Telescope live_grep<CR>", opts)

-- NvimTree
keymap("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", opts)

-- Neotest
keymap("n", "<leader>tr", "<cmd>TextCaseOpenTelescope<cr>", opts)
keymap("n", "<leader>to", "<esc><cmd>lua require('neotest').output_panel.open()<cr>", opts)
keymap("n", "<leader>tc", "<esc><cmd>lua require('neotest').output_panel.close()<cr>", opts)
keymap("n", "<leader>te", "<esc><cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", opts)
keymap("n", "<leader>tm", "<esc><cmd>lua require('neotest').run.run()<cr>", opts)
-- To test a directory run lua require("neotest").run.run("path/to/directory")
-- To test the full test suite run lua require("neotest").run.run({ suite = true })

-- -------------------------------------------------------------------------------
-- nmap <S-F4> :execute "silent grep! -R " . expand("<cword>") . " ./**" <Bar> cw<CR>
-- inoremap <Leader>rt :RemoveTrail<CR>
-- cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

-- " Shortcut for :Files command
-- nmap <Leader>f :Files<CR>
-- "nmap <Leader>fv :vnew<CR>:Files<CR>
-- "nmap <Leader>fh :new<CR>:Files<CR>
-- "nmap <Leader>ft :tabnew<CR>:Files<CR>
--
-- Rest Nvim
-- keymap("n", "<leader>rr", "<cmd>lua require('rest-nvim').run()<cr>", opts)
-- keymap("n", "<leader>rl", "<cmd>lua require('rest-nvim').last()<cr>", opts)
-- keymap("n", "<leader>rt", "<cmd>lua require('rest-nvim').run(true)<cr>", opts)

-- General
keymap("n", "<leader>pv", vim.cmd.Ex)
keymap("n", "<C-k>", "<cmd>cnext<CR>zz")
keymap("n", "<C-j>", "<cmd>cprev<CR>zz")
keymap("n", "<leader>k", "<cmd>lnext<CR>zz")
keymap("n", "<leader>j", "<cmd>lprev<CR>zz")
keymap('n', 'ne', "<esc><cmd>enew<cr>")
keymap("n", "|", "<cmd>vs<cr>")
keymap("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
keymap("n", "<leader>ta", function()
  vim.cmd "!docker exec gf_back sh -c 'APP_ENV=test php vendor/bin/phpunit'"
end)
keymap("n", "<C-q>", "<cmd>qa!<CR>", opts)
keymap("n", "<leader>q", "<cmd>bdelete<CR>")
keymap("n", "<C-s>", "<cmd>w!<cr>", opts)
keymap("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], opts)




