<div align="center">

# ⌨️ auto-english-ime

**Automatically switch macOS input source back to English every time you switch apps.**

*Tiny (~60 KB) · Zero Permissions · No Menu Bar Clutter · Apple Silicon & Intel*

[![macOS](https://img.shields.io/badge/macOS-13%2B-000000?logo=apple&logoColor=white)](https://github.com/Lihaila/auto-english-ime)
[![Release](https://img.shields.io/github/v/release/Lihaila/auto-english-ime?color=blue)](https://github.com/Lihaila/auto-english-ime/releases)
[![CI](https://github.com/Lihaila/auto-english-ime/actions/workflows/ci.yml/badge.svg)](https://github.com/Lihaila/auto-english-ime/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

**English** | [简体中文](./README_zh.md)

</div>

---

## ✨ Why auto-english-ime?

If you type in **Chinese, Japanese, or Korean** on macOS, you know the pain: you finish replying to a message in a chat app, switch back to your terminal, IDE, or browser, start typing a command or shortcut—and accidentally type a string of CJK characters.

**auto-english-ime** solves this quietly and natively:

| Feature | auto-english-ime | Typical GUI Switchers |
| :--- | :---: | :---: |
| **Accessibility / Input Monitoring Permission** | ❌ Not needed | ✅ Required |
| **Menu Bar / Dock Icon** | Invisible | Always visible |
| **Binary Size** | ~60 KB | 10 – 50 MB |
| **Memory Usage** | < 3 MB | 30 – 100 MB |
| **Install Time** | 10 seconds (1 command) | Download, drag, grant permissions |
| **Privacy** | Never reads keystrokes | Often requires Input Monitoring |

---

## 🚀 10-Second Install (Beginner Friendly)

No Xcode, no Git, no settings to tweak.

1. Press **`⌘ Command + Space`**, type **`Terminal`**, and press **`Enter`**.
2. Paste the command below and press **`Enter`**:

```bash
curl -fsSL https://raw.githubusercontent.com/Lihaila/auto-english-ime/main/scripts/quick-install.sh | bash
```

3. **Done!** It starts immediately and launches automatically every time you log in.

> **How to verify it works:** Switch to Chinese/Japanese/Korean in any app, then click into another app — your input source in the top-right menu bar will instantly switch back to **ABC / U.S.**

### Uninstall Anytime

Open **Terminal** and run:

```bash
curl -fsSL https://raw.githubusercontent.com/Lihaila/auto-english-ime/main/scripts/uninstall.sh | bash
```

*(Add `| bash -s -- --purge` if you also want to delete your optional config file.)*

---

## ⚙️ Optional Configuration

Works out of the box with zero configuration (automatically detects `ABC`, `U.S.`, or `British`).

If you want to **exclude specific apps** (e.g., keep Chinese when switching to WeChat) or choose a specific keyboard layout, create `~/.config/auto-english-ime/config.json`:

```json
{
  "targetInputSource": "com.apple.keylayout.ABC",
  "excludedApps": [
    "com.tencent.xinWeChat"
  ],
  "switchOnWake": true
}
```

Changes take effect automatically on your next app switch — no restart needed.

<details>
<summary><b>📋 Common App Bundle IDs (click to expand)</b></summary>

| App | Bundle ID |
| :--- | :--- |
| WeChat (微信) | `com.tencent.xinWeChat` |
| WeCom (企业微信) | `com.tencent.WeWorkMac` |
| DingTalk (钉钉) | `com.alibaba.DingTalkMac` |
| Feishu / Lark (飞书) | `com.electron.lark` |
| QQ | `com.tencent.qq` |
| Apple Notes (备忘录) | `com.apple.Notes` |

Find any app's Bundle ID with:
```bash
osascript -e 'id of app "WeChat"'
```

Find all enabled keyboard input source IDs on your Mac with:
```bash
~/.local/bin/auto-english-ime --list
```

</details>

---

## 🛠️ Build from Source

If you prefer inspecting and compiling the single Swift file yourself:

```bash
git clone https://github.com/Lihaila/auto-english-ime.git
cd auto-english-ime
make install
```

Useful `make` targets:
- `make build` — Compile `Sources/main.swift` to `build/auto-english-ime`
- `make install` — Build, install, and start LaunchAgent
- `make status` — Check if the background service is running
- `make list` — List all enabled keyboard input source IDs
- `make uninstall` — Stop and remove the service

---

## ❓ FAQ

<details>
<summary><b>Is it safe? Does it log my keystrokes?</b></summary>

**No.** The entire source code is ~200 lines in [`Sources/main.swift`](./Sources/main.swift). It never requests Accessibility or Input Monitoring permissions and cannot read what you type. It only listens for macOS's built-in "app switched" and "system woke" notifications and calls Apple's `TISSelectInputSource` API.

</details>

<details>
<summary><b>Will it keep working after I restart my Mac?</b></summary>

Yes. The installer sets up a standard macOS `LaunchAgent` (`~/Library/LaunchAgents/com.auto-english-ime.agent.plist`), so it starts automatically whenever you log in.

</details>

<details>
<summary><b>Why doesn't macOS have this built in?</b></summary>

macOS only offers *"Automatically switch to a document's input source"*, which remembers the last input source per document/app instead of resetting to English. Our installer turns that option off and runs this lightweight daemon so every app switch cleanly starts in English.

</details>

---

## 📄 License

[MIT](./LICENSE) © 2026 [Lihaila](https://github.com/Lihaila)
