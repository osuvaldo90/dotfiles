-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local function set_prose_wrap()
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.opt_local.textwidth = 100
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "log", "gitcommit" },
  callback = set_prose_wrap,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.log",
  callback = set_prose_wrap,
})

-- Reload buffers changed on disk (supplements LazyVim's FocusGained handler
-- which doesn't always fire inside tmux / when returning from Claude Code)
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold" }, {
  command = "checktime",
})
