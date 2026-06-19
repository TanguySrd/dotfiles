-- Single source of truth for the active theme, shared with wezterm and tmux.
-- Reads ~/.config/theme/current ("light" or "dark"); defaults to "light".
local M = {}

function M.current()
  local home = os.getenv("HOME") or ""
  local f = io.open(home .. "/.config/theme/current", "r")
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

return M
