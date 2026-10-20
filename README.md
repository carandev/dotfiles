# dotfiles

Personal configuration. Copy (or symlink) each entry to its target path.

## Cross-platform

| Repo path | Windows | Linux |
|---|---|---|
| `nvim/` (LazyVim) | `%LOCALAPPDATA%\nvim` | `~/.config/nvim` |
| `wezterm/wezterm.lua` | `~/.config/wezterm/` | `~/.config/wezterm/` |
| `zellij/config.kdl` | `~/.config/zellij/` | `~/.config/zellij/` |
| `git/.gitconfig*` | `~/` | `~/` |
| `git/ignore` | `~/.config/git/ignore` | `~/.config/git/ignore` |
| `herdr/` | run `herdr/install.ps1` | run `herdr/install.sh` |
| `claude/CLAUDE.md`, `claude/settings.json` | `~/.claude/` | `~/.claude/` |
| `vscode/settings.json` | `%APPDATA%\Code\User\` | `~/.config/Code/User/` |
| `.ideavimrc` | `~/` | `~/` |
| `starship.toml` | `~/.config/` | `~/.config/` |

Notes:

- `wezterm.lua` sets `default_prog = { "wsl.exe" }` (Windows + WSL setup). Remove that line on Linux
  or on a Windows install without WSL.
- `git/.gitconfig` uses the work identity by default and the personal one under `~/personal/`.
  The `insteadOf` rules need the `personal.github.com` / `work.github.com` hosts from `~/.ssh/config`
  (kept in the encrypted backup, not here).
- `claude/CLAUDE.md` only holds the personal rules. Install gentle-ai first (it regenerates
  skills, agents, hooks and the rest of `CLAUDE.md`), then merge these rules back in.

## Windows only

| Repo path | Target |
|---|---|
| `glazewm/config.yaml` | `~/.glzr/glazewm/` |
| `windows/windows-terminal.json` | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` |
| `windows/komorebi.bar.json` | `~/` |
| `windows/winget-apps.json` | `winget import -i windows/winget-apps.json` |
| `windows/scoop-apps.json` | `scoop import windows/scoop-apps.json` |

## Linux only

`bspwm/`, `sxhkd/`, `qtile/`, `eww/`, `ranger/`, `ulauncher/`, `.zshrc`, `.xprofile`, `mimeapps.list`,
`enable-touchpad-tap.sh` → their usual `~/.config/<name>` or `~/` locations.
`lvim/` is the old LunarVim config (superseded by `nvim/`).
