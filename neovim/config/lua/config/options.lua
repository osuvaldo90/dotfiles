-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Show diagnostics on their own line below the code instead of inline
-- vim.diagnostic.config({ virtual_lines = true, virtual_text = false })

-- Over SSH (including inside tmux), LazyVim disables clipboard. Override with
-- the built-in OSC 52 provider so yanks reach the macOS clipboard via the
-- terminal emulator.
if vim.env.SSH_TTY ~= nil then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
  vim.opt.clipboard = "unnamedplus"
end
