-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n", "v" }, "<leader>gc", function()
  local remote = vim.fn.system("git remote get-url origin 2>/dev/null"):gsub("\n", "")
  if remote == "" then
    vim.notify("No git remote found", vim.log.levels.ERROR)
    return
  end
  remote = remote:gsub("git@github%.com:", "https://github.com/")
  remote = remote:gsub("%.git$", "")

  local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
  local file = vim.api.nvim_buf_get_name(0)
  local rel_path = file:sub(#git_root + 2)

  local line_suffix
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" then
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    line_suffix = start_line == end_line and ("#L" .. start_line) or ("#L" .. start_line .. "-L" .. end_line)
  else
    line_suffix = "#L" .. vim.fn.line(".")
  end

  local url = remote .. "/blob/" .. branch .. "/" .. rel_path .. line_suffix
  vim.fn.setreg("+", url)
  vim.notify("Copied: " .. url)
end, { desc = "Copy GitHub URL" })

vim.keymap.set("n", "<leader>bc", function()
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Copy buffer relative path" })

vim.keymap.set("i", "<M-BS>", "<C-w>", { desc = "Delete word backward" })
