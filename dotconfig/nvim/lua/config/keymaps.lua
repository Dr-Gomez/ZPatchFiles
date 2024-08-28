-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local opts = { noremap = true, silent = true }
local keymap = vim.keymap

-- Sets navigation keymaps
-- j/k = down/up, h/l = left/right

keymap.set("n", "<leader><Left>", "<C-w>h", opts)
keymap.set("n", "<leader><Right>", "<C-w>l", opts)

-- Disables default macro record

keymap.set("n", "q", "<Nop>", opts)

-- Reload neovim

keymap.set("n", "<leader>rr", "<cmd>lua os.exit(1)<CR>")
