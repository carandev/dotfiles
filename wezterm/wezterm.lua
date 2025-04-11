local wezterm = require 'wezterm'

return {
  color_scheme = "tokyonight",
  use_fancy_tab_bar = false,
  default_cwd = "/home/carandev/dev/",
  hide_tab_bar_if_only_one_tab = true,
  tab_bar_at_bottom = true,
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0
  },
  font_size = 11,
  font = wezterm.font 'JetBrainsMono NFM',
  -- window_background_image = '/home/carandev/wallpapers/wallhaven-9mjoy1.png',

  -- window_background_image_hsb = {
  --   brightness = 0.05,
  -- }
  window_background_opacity = 0.8,
  text_background_opacity = 0.7,
  keys = {
    { key = 'w', mods = 'CTRL|META', action = wezterm.action { CloseCurrentPane = { confirm = true } } },
    {
      key = 'e',
      mods = 'CTRL|META',
      action = wezterm.action { SpawnCommandInNewTab = {
        label = 'Ranger',
        args = { 'bash', '-c ranger' },
        cwd = '/home/carandev/dev/'
      } }
    }
  },
  launch_menu = {
    {
      label = 'Explorador de archivos',
      args = { 'ranger' },
    },
  },
}
