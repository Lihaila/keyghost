#!/usr/bin/env bash
set -euo pipefail

INSTALL_BIN="$HOME/.local/bin/keyghost"
PLIST_PATH="$HOME/Library/LaunchAgents/com.keyghost.agent.plist"
CONFIG_DIR="$HOME/.config/keyghost"
UID_NUM="$(id -u)"

echo "==> Stopping KeyGhost..."
launchctl bootout "gui/$UID_NUM" "$PLIST_PATH" 2>/dev/null || true

echo "==> Removing binary and LaunchAgent..."
rm -f "$PLIST_PATH" "$INSTALL_BIN"

if [[ "${1:-}" == "--purge" ]]; then
    echo "==> Removing config directory $CONFIG_DIR..."
    rm -rf "$CONFIG_DIR"
fi

echo "✅ Done! KeyGhost has vanished cleanly."
