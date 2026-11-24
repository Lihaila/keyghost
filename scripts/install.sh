#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

INSTALL_BIN_DIR="$HOME/.local/bin"
INSTALL_BIN="$INSTALL_BIN_DIR/keyghost"
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST_LABEL="com.keyghost.agent"
PLIST_PATH="$PLIST_DIR/$PLIST_LABEL.plist"
UID_NUM="$(id -u)"

echo "==> Building KeyGhost..."
mkdir -p "$PROJECT_DIR/build" "$INSTALL_BIN_DIR" "$PLIST_DIR"
swiftc -O "$PROJECT_DIR/Sources/main.swift" -o "$PROJECT_DIR/build/keyghost"
cp "$PROJECT_DIR/build/keyghost" "$INSTALL_BIN"
chmod +x "$INSTALL_BIN"

echo "==> Disabling macOS per-document input source switching..."
defaults write com.apple.HIToolbox AppleGlobalTextInputProperties -dict TextInputGlobalPropertyPerContextInput -int 0

echo "==> Installing LaunchAgent at $PLIST_PATH..."
cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$INSTALL_BIN</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ProcessType</key>
    <string>Interactive</string>
</dict>
</plist>
EOF

echo "==> Starting KeyGhost LaunchAgent..."
launchctl bootout "gui/$UID_NUM" "$PLIST_PATH" 2>/dev/null || true
launchctl bootstrap "gui/$UID_NUM" "$PLIST_PATH"

echo ""
echo "✅ Done! KeyGhost is installed and running."
echo "Optional config file: ~/.config/keyghost/config.json"
echo "Run '$INSTALL_BIN --list' to see available input source IDs."
