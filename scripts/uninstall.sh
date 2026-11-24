#!/usr/bin/env bash
set -euo pipefail

INSTALL_BIN="$HOME/.local/bin/auto-english-ime"
PLIST_PATH="$HOME/Library/LaunchAgents/com.auto-english-ime.agent.plist"
CONFIG_DIR="$HOME/.config/auto-english-ime"
UID_NUM="$(id -u)"

echo "==> Stopping LaunchAgent..."
launchctl bootout "gui/$UID_NUM" "$PLIST_PATH" 2>/dev/null || true

echo "==> Removing binary and LaunchAgent..."
rm -f "$PLIST_PATH" "$INSTALL_BIN"

if [[ "${1:-}" == "--purge" ]]; then
    echo "==> Removing config directory $CONFIG_DIR..."
    rm -rf "$CONFIG_DIR"
fi

echo "Done! auto-english-ime has been uninstalled."
