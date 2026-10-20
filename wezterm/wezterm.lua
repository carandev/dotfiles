local wezterm = require 'wezterm'

return {
  color_scheme = "tokyonight",
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,
  tab_bar_at_bottom = true,
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0
  },
  font_size = 12,
  font = wezterm.font 'VictorMono Nerd Font',
  -- window_background_image = '/home/carandev/wallpapers/wallhaven-9mjoy1.png',

  -- window_background_image_hsb = {
  --   brightness = 0.05,
  -- }
  -- window_background_opacity = 0.8,
  -- text_background_opacity = 0.7,
  default_prog = { "wsl.exe" },
  keys = {
    { key = 'w', mods = 'CTRL|META', action = wezterm.action { CloseCurrentPane = { confirm = true } } },
    {
      key = 'e',
      mods = 'CTRL|META',
      action = wezterm.action { SpawnCommandInNewTab = {
        label = 'Explorador de archivos',
        args = { 'spf' },
        cwd = 'C:/Users/Carlos Gomez'
      } }
    },
{
    key = "p",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SpawnCommandInNewTab {
      args = { "powershell.exe" },
    },
  },
  },
  launch_menu = {
    {
      label = 'Explorador de archivos',
      args = { 'spf' },
    },
    {
      label = "PowerShell",
      args = { "powershell.exe" },
    },
  },
}
