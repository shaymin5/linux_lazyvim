-- keymap.lua
-- local term_utils = require("utils.terminal")

local term_utils = require("utils.open-terminal")

-- Normal / Insert mode: 打开/切换终端
vim.keymap.set({ "n", "i" }, "<C-_>", function()
  term_utils.toggle_terminal()
end, { desc = "Toggle terminal at project root" })

vim.keymap.set({ "n", "i" }, "<C-/>", function()
  term_utils.toggle_terminal()
end, { desc = "Toggle terminal at project root" })

-- Terminal mode: 关闭终端
vim.keymap.set("t", "<C-_>", "<C-\\><C-n>:q<CR>", { desc = "Close terminal" })
vim.keymap.set("t", "<C-/>", "<C-\\><C-n>:q<CR>", { desc = "Close terminal" })
