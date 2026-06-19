-- Single source of truth for the active theme, shared with wezterm and tmux.
-- Reads ~/.config/theme/current ("light" or "dark"); defaults to "light".
local M = {}

local function theme_file()
  return (os.getenv("HOME") or "") .. "/.config/theme/current"
end

function M.current()
  local f = io.open(theme_file(), "r")
  if not f then
    return "light"
  end
  local value = f:read("l")
  f:close()
  if value then
    value = value:gsub("%s+", "")
  end
  return value == "dark" and "dark" or "light"
end

function M.is_dark()
  return M.current() == "dark"
end

-- Re-theme the running neovim instance to match the current file value.
function M.apply()
  local dark = M.is_dark()
  vim.o.background = dark and "dark" or "light"

  local ok_ayu, ayu = pcall(require, "ayu")
  if ok_ayu then
    ayu.setup({
      mirage = dark,
      terminal = true,
      -- transparent background only in the dark theme
      overrides = dark and {
        Normal = { bg = "None" },
        NormalFloat = { bg = "none" },
        ColorColumn = { bg = "None" },
        SignColumn = { bg = "None" },
        Folded = { bg = "None" },
        FoldColumn = { bg = "None" },
        CursorLine = { bg = "None" },
        CursorColumn = { bg = "None" },
        VertSplit = { bg = "None" },
      } or {},
    })
  end

  vim.cmd("colorscheme " .. (dark and "ayu-mirage" or "ayu-light"))

  -- regenerate lualine's ayu palette and redraw the statusline
  pcall(function()
    require("ayu.colors").generate(dark)
    require("lualine").refresh()
  end)
end

-- Write the chosen theme to disk, apply it to nvim live, and nudge tmux.
function M.set(target)
  if target == nil or target == "" then
    vim.notify("Theme: " .. M.current(), vim.log.levels.INFO)
    return
  end
  if target == "toggle" then
    target = M.is_dark() and "light" or "dark"
  end
  if target ~= "light" and target ~= "dark" then
    vim.notify("Theme: expected light | dark | toggle", vim.log.levels.ERROR)
    return
  end

  local path = theme_file()
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local f = io.open(path, "w")
  if f then
    f:write(target .. "\n")
    f:close()
  end

  M.apply()

  -- tmux re-sources on the running server (wezterm auto-reloads via file watch)
  if vim.env.TMUX and vim.env.TMUX ~= "" then
    vim.fn.jobstart({ "tmux", "source-file", vim.fn.expand("~/.tmux.conf") })
  end

  vim.notify("Theme: " .. target, vim.log.levels.INFO)
end

-- :Theme [light|dark|toggle]   (no argument reports the current theme)
vim.api.nvim_create_user_command("Theme", function(opts)
  M.set(opts.args)
end, {
  nargs = "?",
  complete = function()
    return { "light", "dark", "toggle" }
  end,
  desc = "Switch theme (light/dark/toggle) live across nvim, tmux, wezterm",
})

return M
