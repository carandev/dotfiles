# Herdr

Herdr config, keybindings, scripts and plugin settings for Linux, macOS and Windows.

| File | Installed to |
| --- | --- |
| `config.toml` (template) | `~/.config/herdr/config.toml` · `%APPDATA%\herdr\config.toml` |
| `scripts/open-user-secrets.mjs` | `<herdr dir>/scripts/` |
| `plugins/repo-worktrees/config.json` | `herdr plugin config-dir repo-worktrees` |

## Requirements

Herdr >= 0.9.5, Node.js >= 22, git and Neovim on `PATH`.

## Install

```sh
./herdr/install.sh                                            # Linux / macOS
```

```powershell
powershell -ExecutionPolicy Bypass -File .\herdr\install.ps1  # Windows
```

The installer backs up an existing `config.toml`, renders the template (replacing `@SCRIPTS_DIR@` with the absolute scripts path), installs the [`repo-worktrees`](https://github.com/carandev/herdr-repo-worktrees) plugin if missing, copies its config, runs `herdr config check` and reloads the server. It is safe to run again after `git pull`.

## Keybindings

| Key | Action |
| --- | --- |
| `prefix+alt+w` | New worktree at a repository-relative path (`repo-worktrees` plugin). |
| `prefix+alt+s` | Open the .NET user-secrets (`secrets.json`) of the current project in Neovim. In a solution with several projects that have a `<UserSecretsId>`, asks which one. |

`open-user-secrets.mjs` starts from the focused pane's directory, creates `secrets.json` if it does not exist and opens it with `nvim` (override with `USER_SECRETS_EDITOR`). Tests: `node --test herdr/scripts`.
