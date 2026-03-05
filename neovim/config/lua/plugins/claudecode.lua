return {
  {
    "coder/claudecode.nvim",
    opts = {
      -- This becomes the base command the plugin runs.
      -- The plugin appends its own args after this.
      terminal_cmd = "claude --dangerously-skip-permissions",
    },
  },
}
