#!/usr/bin/env bash
set -euo pipefail

REPO="Lihaila/keyghost"
INSTALL_BIN_DIR="$HOME/.local/bin"
INSTALL_BIN="$INSTALL_BIN_DIR/keyghost"
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST_LABEL="com.keyghost.agent"
PLIST_PATH="$PLIST_DIR/$PLIST_LABEL.plist"
UID_NUM="$(id -u)"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Error: KeyGhost only supports macOS." >&2
    exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "👻 Installing KeyGhost..."
mkdir -p "$INSTALL_BIN_DIR" "$PLIST_DIR"

DOWNLOAD_URL="https://github.com/$REPO/releases/latest/download/keyghost-macos-universal.tar.gz"

echo "==> Downloading prebuilt Universal Binary (Apple Silicon & Intel)..."
if curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/keyghost.tar.gz"; then
    tar -xzf "$TMP_DIR/keyghost.tar.gz" -C "$TMP_DIR"
    cp "$TMP_DIR/keyghost" "$INSTALL_BIN"
    chmod +x "$INSTALL_BIN"
    xattr -d com.apple.quarantine "$INSTALL_BIN" 2>/dev/null || true
else
    echo "⚠️  Prebuilt release not available yet, falling back to building from source..."
    if ! command -v swiftc >/dev/null 2>&1; then
        echo "Error: swiftc not found. Please install Xcode Command Line Tools (xcode-select --install) or try again later." >&2
        exit 1
    fi
    curl -fsSL "https://raw.githubusercontent.com/$REPO/main/Sources/main.swift" -o "$TMP_DIR/main.swift"
    swiftc -O "$TMP_DIR/main.swift" -o "$INSTALL_BIN"
    chmod +x "$INSTALL_BIN"
fi

echo "==> Disabling macOS per-document input source switching..."
defaults write com.apple.HIToolbox AppleGlobalTextInputProperties -dict TextInputGlobalPropertyPerContextInput -int 0

echo "==> Configuring auto-start LaunchAgent..."
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

echo "==> Starting KeyGhost..."
launchctl bootout "gui/$UID_NUM" "$PLIST_PATH" 2>/dev/null || true
launchctl bootstrap "gui/$UID_NUM" "$PLIST_PATH"

echo ""
echo "✅ KeyGhost is now haunting your keyboard in the background!"
echo ""
echo "Try it now:"
echo "  1. Switch to Chinese (or any non-English input method) in one app"
echo "  2. Switch to any other app — KeyGhost silently snaps it back to English!"
echo ""
echo "Optional config: ~/.config/keyghost/config.json"
echo "Uninstall anytime: curl -fsSL https://raw.githubusercontent.com/$REPO/main/scripts/uninstall.sh | bash"
