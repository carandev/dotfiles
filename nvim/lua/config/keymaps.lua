-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.api.nvim_create_user_command("UserSecrets", function() require("user_secrets").open() end, { desc = "Open .NET user secrets" })
vim.keymap.set("n", "<leader>fu", function() require("user_secrets").open() end, { desc = "User Secrets (.NET)" })
