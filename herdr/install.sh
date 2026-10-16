#!/usr/bin/env sh
# Installs the Herdr config, plugins and plugin settings on Linux/macOS.
set -eu

SRC="$(cd "$(dirname "$0")" && pwd)"
HERDR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/herdr"

for cmd in herdr node git nvim; do
  command -v "$cmd" >/dev/null 2>&1 || echo "warning: '$cmd' is not on PATH" >&2
done

mkdir -p "$HERDR_DIR"
if [ -f "$HERDR_DIR/config.toml" ]; then
  cp "$HERDR_DIR/config.toml" "$HERDR_DIR/config.toml.$(date +%Y%m%d%H%M%S).bak"
fi
cp "$SRC/config.toml" "$HERDR_DIR/config.toml"

# plugin id -> GitHub source
for plugin in repo-worktrees:carandev/herdr-repo-worktrees user-secrets:carandev/herdr-user-secrets; do
  id="${plugin%%:*}"
  if ! herdr plugin list 2>/dev/null | grep -q "^- $id "; then
    herdr plugin install --yes "${plugin#*:}"
  fi
done

PLUGIN_CONFIG_DIR="$(herdr plugin config-dir repo-worktrees)"
mkdir -p "$PLUGIN_CONFIG_DIR"
cp "$SRC/plugins/repo-worktrees/config.json" "$PLUGIN_CONFIG_DIR/config.json"

herdr config check
herdr server reload-config >/dev/null 2>&1 || echo "Herdr server not running; the config applies on next start."
echo "Herdr config installed in $HERDR_DIR"
