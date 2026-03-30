return {
  {
    "coder/claudecode.nvim",
    opts = {
      -- This becomes the base command the plugin runs.
      -- The plugin appends its own args after this.
      terminal_cmd = "claude --permission-mode auto",
    },
    config = function(_, opts)
      require("claudecode").setup(opts)
      -- Force redraw when re-entering the terminal window to fix cursor
      -- misalignment caused by TUI apps using absolute ANSI cursor positioning.
      vim.api.nvim_create_autocmd("WinEnter", {
        callback = function()
          if vim.bo.buftype == "terminal" then
            vim.cmd("redraw!")
          end
        end,
      })
    end,
  },
}
