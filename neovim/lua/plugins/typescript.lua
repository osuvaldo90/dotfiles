return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local has_tsgo = vim.fn.executable("node_modules/.bin/tsgo") == 1
        or vim.fn.executable("tsgo") == 1

      opts.servers = opts.servers or {}
      opts.servers.tsgo = { enabled = has_tsgo }
      opts.servers.vtsls = vim.tbl_deep_extend("force", opts.servers.vtsls or {}, {
        enabled = not has_tsgo,
      })
    end,
  },
}
