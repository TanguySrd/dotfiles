local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Active theme is read from ~/.config/theme/current ("light" or "dark").
-- Defaults to "light" if the file is missing.
local theme_file = (os.getenv("HOME") or "") .. "/.config/theme/current"

local function read_theme()
	local f = io.open(theme_file, "r")
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

-- Reload the config (and thus re-read the theme) whenever the theme file changes,
-- so `theme light` / `theme dark` switches WezTerm live.
wezterm.add_to_config_reload_watch_list(theme_file)

local themes = {
	light = {
		colors = {
			foreground = "#575F66",
			background = "#FAFAFA",
			cursor_bg = "#FFAA33",
			cursor_border = "#FFAA33",
			cursor_fg = "#FAFAFA",
			selection_bg = "#D3E1F5",
			selection_fg = "#575F66",
			ansi = { "#000000", "#EA6C73", "#56A02D", "#B36C00", "#399EE6", "#A37ACC", "#4CBF99", "#8A9199" },
			brights = { "#5C6166", "#EA6C73", "#56A02D", "#B36C00", "#399EE6", "#A37ACC", "#4CBF99", "#8A9199" },
		},
	},
	dark = {
		colors = {
			foreground = "#CBE0F0",
			background = "#011423",
			cursor_bg = "#47FF9C",
			cursor_border = "#47FF9C",
			cursor_fg = "#011423",
			selection_bg = "#033259",
			selection_fg = "#CBE0F0",
			ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
			brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
		},
		window_background_opacity = 0.8,
		macos_window_background_blur = 10,
	},
}

local theme = themes[read_theme()]

config.colors = theme.colors
if theme.window_background_opacity then
	config.window_background_opacity = theme.window_background_opacity
end
if theme.macos_window_background_blur then
	config.macos_window_background_blur = theme.macos_window_background_blur
end

config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 16

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

config.window_padding = {
	left = 0,
	right = 0,
	top = 10,
	bottom = 0,
}

config.use_resize_increments = true

return config
