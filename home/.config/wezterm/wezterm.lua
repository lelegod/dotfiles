local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Tokyo Night here and in nvim, so the editor has no seam against the terminal
config.color_scheme = "Tokyo Night"
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 15.0
config.line_height = 1.15  -- packed lines are harder to scan than small glyphs are to read
config.window_background_opacity = 1
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
