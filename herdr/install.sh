#!/usr/bin/env sh
# Installs the Herdr config, scripts and plugin settings on Linux/macOS.
set -eu

SRC="$(cd "$(dirname "$0")" && pwd)"
HERDR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/herdr"
SCRIPTS_DIR="$HERDR_DIR/scripts"

for cmd in herdr node git nvim; do
  command -v "$cmd" >/dev/null 2>&1 || echo "warning: '$cmd' is not on PATH" >&2
done

mkdir -p "$SCRIPTS_DIR"
cp "$SRC/scripts/open-user-secrets.mjs" "$SCRIPTS_DIR/"

if [ -f "$HERDR_DIR/config.toml" ]; then
  cp "$HERDR_DIR/config.toml" "$HERDR_DIR/config.toml.$(date +%Y%m%d%H%M%S).bak"
fi
sed "s|@SCRIPTS_DIR@|$SCRIPTS_DIR|g" "$SRC/config.toml" > "$HERDR_DIR/config.toml"

if ! herdr plugin list 2>/dev/null | grep -q '^- repo-worktrees '; then
  herdr plugin install --yes carandev/herdr-repo-worktrees
fi
PLUGIN_CONFIG_DIR="$(herdr plugin config-dir repo-worktrees)"
mkdir -p "$PLUGIN_CONFIG_DIR"
cp "$SRC/plugins/repo-worktrees/config.json" "$PLUGIN_CONFIG_DIR/config.json"

herdr config check
herdr server reload-config >/dev/null 2>&1 || echo "Herdr server not running; the config applies on next start."
echo "Herdr config installed in $HERDR_DIR"
