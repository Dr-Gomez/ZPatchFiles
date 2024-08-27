-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local opts = { noremap = true, silent = true }
local keymap = vim.keymap

-- j/k = down/up, h/l = left/right

keymap.set("n", "<leader><Left>", "<C-w>h", opts)
keymap.set("n", "<leader><Right>", "<C-w>l", opts)
