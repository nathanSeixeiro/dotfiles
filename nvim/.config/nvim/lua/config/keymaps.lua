-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

--- Maps de Undo Redo
map("i", "<C-z>", "<Esc>u", { desc = "Undo (insert mode)" })
map("i", "<C-y>", "<Esc><C-r>", { desc = "Redo (insert mode)" })
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save" })

--- Save
map("i", "<C-s>", "<Esc><cmd>w<cr>", { desc = "Save" })

--- Select All
map("n", "<leader>aa", "ggVG", { desc = "Select all" })
