<div align="center">

# ⌨️ auto-english-ime

**每次切换 Mac 应用时，自动把输入法切回英文。**

*约 60 KB · 零权限弹窗 · 无菜单栏图标 · 支持 Apple Silicon 与 Intel*

[![macOS](https://img.shields.io/badge/macOS-13%2B-000000?logo=apple&logoColor=white)](https://github.com/Lihaila/auto-english-ime)
[![Release](https://img.shields.io/github/v/release/Lihaila/auto-english-ime?color=blue)](https://github.com/Lihaila/auto-english-ime/releases)
[![CI](https://github.com/Lihaila/auto-english-ime/actions/workflows/ci.yml/badge.svg)](https://github.com/Lihaila/auto-english-ime/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

[English](./README.md) | **简体中文**

</div>

---

## ✨ 为什么做这个小工具？

在 Mac 上用中文输入法，最烦的瞬间之一就是：刚在微信回完消息，切回浏览器、终端或编辑器准备输网址/命令/快捷键，结果敲出一长串拼音……

**auto-english-ime** 用最干净原生的方式彻底解决这个问题：

| 特性 | auto-english-ime | 常见图形界面切换工具 |
| :--- | :---: | :---: |
| **需要「辅助功能 / 输入监控」权限** | ❌ 不需要 | ✅ 通常需要 |
| **菜单栏 / 程序坞图标** | 完全无感、零打扰 | 常驻图标 |
| **程序体积** | 约 60 KB | 10 – 50 MB |
| **内存占用** | < 3 MB | 30 – 100 MB |
| **安装耗时** | 10 秒（复制一行命令） | 下载、拖拽、层层授权 |
| **隐私安全** | 无法读取任何按键输入 | 部分需要输入监控权限 |

---

## 🚀 小白 10 秒安装指南

不需要装 Xcode，不需要懂 Git，全程只需要复制粘贴一行命令：

1. 按下键盘 **`⌘ Command + 空格`**，输入 **`终端`**（或 `Terminal`），按 **`回车`** 打开。
2. 复制下面这行命令，粘贴到终端里，按 **`回车`**：

```bash
curl -fsSL https://raw.githubusercontent.com/Lihaila/auto-english-ime/main/scripts/quick-install.sh | bash
```

3. 看到 **`✅ Installation complete!`** 就搞定了！它会立即生效，以后每次重启电脑也会自动运行。

> **怎么测试是否生效？**
> 在任意软件里切到中文输入法，然后鼠标点一下另一个软件窗口 —— 看看屏幕右上角，输入法已经瞬间自动切回 **ABC（英文）** 了！

### 随时一键卸载

如果以后不想用了，同样打开 **终端**，粘贴回车即可干净卸载：

```bash
curl -fsSL https://raw.githubusercontent.com/Lihaila/auto-english-ime/main/scripts/uninstall.sh | bash
```

---

## ⚙️ 进阶配置（可选）

**默认零配置即可使用**（会自动识别你电脑上的 `ABC` / `U.S.` / `British` 英文键盘）。

如果你想**排除某些软件**（例如：切到微信时不要自动切回英文），或者指定别的默认键盘，只需新建文件 `~/.config/auto-english-ime/config.json`：

```json
{
  "targetInputSource": "com.apple.keylayout.ABC",
  "excludedApps": [
    "com.tencent.xinWeChat"
  ],
  "switchOnWake": true
}
```

保存后**无需重启**，下次切换应用时自动生效。

<details>
<summary><b>📋 常用 App 的 Bundle ID 速查表（点击展开）</b></summary>

| 软件 | Bundle ID（直接复制到 `excludedApps`） |
| :--- | :--- |
| 微信 | `com.tencent.xinWeChat` |
| 企业微信 | `com.tencent.WeWorkMac` |
| 钉钉 | `com.alibaba.DingTalkMac` |
| 飞书 | `com.electron.lark` |
| QQ | `com.tencent.qq` |
| 苹果备忘录 | `com.apple.Notes` |

查看任意软件的 Bundle ID：
```bash
osascript -e 'id of app "WeChat"'
```

查看你电脑上所有已启用的输入法 ID：
```bash
~/.local/bin/auto-english-ime --list
```

</details>

---

## 🛠️ 开发者：从源码编译安装

如果你更喜欢亲自查看源码并在本地编译：

```bash
git clone https://github.com/Lihaila/auto-english-ime.git
cd auto-english-ime
make install
```

常用命令：
- `make build` — 编译 `Sources/main.swift` 到 `build/auto-english-ime`
- `make install` — 编译并安装启动后台服务
- `make status` — 查看后台服务运行状态
- `make list` — 列出所有可用输入法 ID
- `make uninstall` — 停止并卸载服务

---

## ❓ 常见问题（FAQ）

<details>
<summary><b>1. 安全吗？会记录我打的字吗？</b></summary>

**绝对不会。** 全部源码就在 [`Sources/main.swift`](./Sources/main.swift) 里（仅约 200 行，完全开源可审查）。它不申请「辅助功能」也不申请「输入监控」权限，从系统机制上就不可能读取你的任何按键内容——它只监听系统发出的“切换了应用”和“电脑唤醒”通知，然后调用苹果官方 API 把输入法切回英文。

</details>

<details>
<summary><b>2. 重启电脑后还需要手动打开吗？</b></summary>

不需要。安装脚本已经帮你配置了标准的 macOS 开机自启服务（`~/Library/LaunchAgents/com.auto-english-ime.agent.plist`），以后每次开机自动静默运行。

</details>

<details>
<summary><b>3. 我只是偶尔需要打中文，会妨碍我切中文吗？</b></summary>

完全不会！你在当前软件里随时可以正常按 `Caps Lock` / `⌃ + 空格` 切到中文打字；只有在你**切换到另一个软件**时，它才会贴心地帮你切回英文。

</details>

---

## 📄 开源协议

[MIT](./LICENSE) © 2026 [Lihaila](https://github.com/Lihaila)
