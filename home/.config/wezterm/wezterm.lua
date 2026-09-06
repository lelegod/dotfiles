local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "VSCodeDark+ (Gogh)"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 15.0
config.window_background_opacity = 1
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

config.keys = {
	-- Copy the whole pane, scrollback included (wezterm only copies selections by default)
	{
		key = "a",
		mods = "CMD|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
			window:copy_to_clipboard(text)
			window:toast_notification("wezterm", ("copied %d chars"):format(#text), nil, 2000)
		end),
	},
}

return config
