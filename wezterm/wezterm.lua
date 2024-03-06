local wezterm = require 'wezterm'
local user = os.getenv('USERNAME')

return {
  color_scheme = "tokyonight",
  use_fancy_tab_bar = false,
  default_cwd = string.format("C:\\Users\\%s\\code", user),
  default_prog = { 'powershell.exe' },
  hide_tab_bar_if_only_one_tab = true,
  tab_bar_at_bottom = true,
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0
  },
  font_size = 13,
  font = wezterm.font_with_fallback {
    'CaskaydiaCove Nerd Font',
    'Noto Color Emoji',
    'DengXian'
  },
  window_background_image = string.format('C:\\Users\\%s\\Downloads\\Dark 2 Schein Wallpaper 1.png', user),

  window_background_image_hsb = {
    brightness = 0.05,
  },

  window_background_opacity = 0.9,
  text_background_opacity = 0.7,
  keys = {
    {
      key = 'w',
      mods = 'CTRL|META',
      action = wezterm.action { CloseCurrentPane =
      {
        confirm = true
      }
      }
    },
    {
      key = 'n',
      mods = 'CTRL|META',
      action = wezterm.action { SpawnTab = {
        DomainName = "WSL:Debian",
      }
      }
    },
    {
      key = 'b',
      mods = 'CTRL|META',
      action = wezterm.action { SpawnCommandInNewTab = {
        label = 'Backoffice',
        args = { 'dotnet', 'watch', '--non-interactive' },
        cwd = string.format('C:\\Users\\%s\\code\\Univer.CRM\\CRM.Backoffice.Web', user)
      } }
    },
    {
      key = 'a',
      mods = 'CTRL|META',
      action = wezterm.action { SpawnCommandInNewTab = {
        label = 'API',
        args = { 'dotnet', 'watch', '--non-interactive' },
        cwd = string.format('C:\\Users\\%s\\code\\Univer.CRM\\CRM.API', user)
      } }
    },
    {
      key = 'u',
      mods = 'CTRL|META',
      action = wezterm.action { SpawnCommandInNewTab = {
        label = 'UserPortal',
        args = { 'dotnet', 'watch', '--non-interactive' },
        cwd = string.format('C:\\Users\\%s\\code\\Univer.CRM\\CRM.UserPortal.Web', user)
      } }
    }
  },
}
