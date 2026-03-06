-- Auto-detect project formatter based on config files.
-- conform.nvim tries formatters in the listed order and stops after the first
-- one whose `condition` passes and which succeeds (stop_after_first = true).
--
-- To add a new formatter:
--   1. Add its name to the filetypes list below.
--   2. Add a `condition` entry in opts.formatters that checks for its config file.
--
-- Prettier is handled by the LazyVim extra (formatting.prettier), which already
-- adds its own condition checking for .prettierrc / prettier.config.* files.

-- Resolve oxfmt binary: local node_modules → global → npx fallback.
-- Returns (command, args_prefix) where args_prefix is prepended to the final args.
local function resolve_oxfmt(ctx)
  local dir = vim.fn.fnamemodify(ctx.filename, ":h")
  local local_bin = vim.fn.findfile("node_modules/.bin/oxfmt", dir .. ";")
  if local_bin ~= "" then
    return vim.fn.fnamemodify(local_bin, ":p"), {}
  end
  if vim.fn.executable("oxfmt") == 1 then
    return "oxfmt", {}
  end
  -- Fall back to npx (uses locally installed package without global install)
  return "npx", { "oxfmt" }
end

return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters = opts.formatters or {}

      -- Formatters tried in priority order (first matching condition wins).
      -- Prettier is appended last by the LazyVim extra for the JS/TS filetypes below.
      local competing_formatters = { "oxfmt", "biome" }

      local fts = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "jsonc",
        "css",
        "graphql",
      }

      for _, ft in ipairs(fts) do
        local existing = opts.formatters_by_ft[ft] or {}
        local seen = {}
        local formatters = {}
        for _, f in ipairs(competing_formatters) do
          seen[f] = true
          table.insert(formatters, f)
        end
        for _, f in ipairs(existing) do
          if not seen[f] then
            table.insert(formatters, f)
          end
        end
        formatters.stop_after_first = true
        opts.formatters_by_ft[ft] = formatters
      end

      -- oxfmt: only active when .oxfmtrc.json is found in the project.
      -- Resolves the binary at format-time: local node_modules → global → npx.
      opts.formatters.oxfmt = {
        command = function(_, ctx)
          local cmd, _ = resolve_oxfmt(ctx)
          return cmd
        end,
        args = function(_, ctx)
          local _, prefix = resolve_oxfmt(ctx)
          local args = vim.deepcopy(prefix)
          vim.list_extend(args, { "--stdin-filepath", "$FILENAME" })
          return args
        end,
        stdin = true,
        condition = function(_, ctx)
          return vim.fs.find({ ".oxfmtrc.json" }, {
            path = ctx.filename,
            upward = true,
          })[1] ~= nil
        end,
      }

      -- Biome: only active when biome.json or biome.jsonc is found in the project
      opts.formatters.biome = {
        condition = function(_, ctx)
          return vim.fs.find({ "biome.json", "biome.jsonc" }, {
            path = ctx.filename,
            upward = true,
          })[1] ~= nil
        end,
      }
    end,
  },
}
