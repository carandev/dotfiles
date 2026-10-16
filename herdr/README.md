# Herdr

Herdr config, keybindings, plugins and plugin settings for Linux, macOS and Windows.

| File | Installed to |
| --- | --- |
| `config.toml` | `~/.config/herdr/config.toml` · `%APPDATA%\herdr\config.toml` |
| `plugins/repo-worktrees/config.json` | `herdr plugin config-dir repo-worktrees` |

Plugins: [`repo-worktrees`](https://github.com/carandev/herdr-repo-worktrees) and [`user-secrets`](https://github.com/carandev/herdr-user-secrets).

## Requirements

Herdr >= 0.9.5, Node.js >= 22, git and Neovim on `PATH`.

## Install

```sh
./herdr/install.sh                                            # Linux / macOS
```

```powershell
powershell -ExecutionPolicy Bypass -File .\herdr\install.ps1  # Windows
```

The installer backs up an existing `config.toml`, copies the new one, installs the plugins that are missing, copies the `repo-worktrees` config, runs `herdr config check` and reloads the server. It is safe to run again after `git pull`.

## Keybindings

| Key | Action |
| --- | --- |
| `prefix+alt+w` | New worktree at a repository-relative path (`repo-worktrees` plugin). |
| `prefix+alt+s` | Open the .NET user-secrets (`secrets.json`) of the focused project in Neovim, asking which project when there are several (`user-secrets` plugin). |
