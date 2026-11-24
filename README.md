# auto-english-ime

[中文文档](./README_zh.md)

A tiny (~60 KB), zero-dependency native macOS background daemon that automatically switches your input source back to English (**ABC** / **U.S.**) whenever you switch applications or wake from sleep.

## Why?

If you use Chinese, Japanese, or Korean input methods on macOS, switching from a chat app to a terminal, browser, or IDE only to realize you're still in CJK input mode is frustrating.

- **Zero Accessibility Permissions**: Uses native `NSWorkspace` + `Carbon` (`TISSelectInputSource`) APIs—no Accessibility or Input Monitoring prompts required.
- **Invisible & Tiny**: No menu bar icon, no Dock icon, ~60 KB native Swift binary, < 3 MB RAM.
- **Zero Config by Default**: Auto-detects `ABC` (or `U.S.` / `British`) out of the box.
- **Optional Per-App Exclusions**: Exclude specific apps (e.g. WeChat) via a simple JSON file, hot-reloaded automatically.

## Requirements

- macOS 13+ (Apple Silicon & Intel)
- Xcode Command Line Tools (`swiftc`)

## Quick Install

```bash
git clone https://github.com/<your-username>/auto-english-ime.git
cd auto-english-ime
make install
```

This will:
1. Compile `Sources/main.swift` into `~/.local/bin/auto-english-ime`
2. Disable macOS's *"Automatically switch to a document's input source"* setting
3. Register and start a `LaunchAgent` (`~/Library/LaunchAgents/com.auto-english-ime.agent.plist`) so it runs automatically at login

## Configuration (Optional)

Create `~/.config/auto-english-ime/config.json`:

```json
{
  "targetInputSource": "com.apple.keylayout.ABC",
  "excludedApps": [
    "com.tencent.xinWeChat"
  ],
  "switchOnWake": true
}
```

Changes to `config.json` are picked up automatically on the next app switch—no restart needed.

### Finding Your Input Source ID

```bash
~/.local/bin/auto-english-ime --list
```

Example output:
```text
* com.apple.keylayout.ABC  (ABC)
  com.apple.inputmethod.SCIM.ITABC  (Pinyin - Simplified)
```

### Finding an App's Bundle ID

```bash
osascript -e 'id of app "WeChat"'
```

## CLI Usage

```text
auto-english-ime [OPTIONS]

OPTIONS:
  -l, --list                 List all enabled keyboard input source IDs and exit
  -i, --input-source <ID>    Target input source ID (default: auto-detect ABC or U.S.)
  -c, --config <PATH>        Path to JSON config file (default: ~/.config/auto-english-ime/config.json)
  -v, --verbose              Print logs when switching apps/input sources
      --version              Show version
  -h, --help                 Show this help message
```

## Uninstall

```bash
make uninstall
# Or remove config files as well:
bash scripts/uninstall.sh --purge
```

## License

[MIT](./LICENSE)
