return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- Replace whatever LazyVim put in lualine_c with a non-truncating path component.
    opts.sections.lualine_c = {
      LazyVim.lualine.pretty_path({
        length = 0,      -- 0/false => don't truncate in the helper
        relative = "cwd" -- optional: show path relative to cwd
        -- relative = "root" -- alternative: relative to project root
      }),
    }
  end,
}
