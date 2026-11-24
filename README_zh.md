# auto-english-ime

[English](./README.md)

一个极简（约 60 KB）、零第三方依赖的原生 macOS 后台小工具：**每次切换到任何应用，或从休眠唤醒时，自动把输入法切回英文（ABC / U.S.）**。

## 为什么做这个？

在 macOS 上日常使用中文/日文/韩文输入法时，经常在聊天软件打完字，切回终端、编辑器或浏览器时忘记切回英文。

- **零权限弹窗**：仅使用原生 `NSWorkspace` + `Carbon`（`TISSelectInputSource`）API，不需要「辅助功能」或「输入监控」权限。
- **完全无感**：无菜单栏图标、无程序坞图标，单文件编译约 60 KB，内存占用极低。
- **开箱即用**：默认自动识别 `ABC`（或 `U.S.` / `British`），零配置即可使用。
- **支持按需配置**：可通过 JSON 配置文件自定义目标键盘、设置排除列表（如微信），修改后自动热加载。

## 环境要求

- macOS 13+（支持 Apple Silicon 和 Intel）
- Xcode Command Line Tools（自带 `swiftc`）

## 一键安装

```bash
git clone https://github.com/<your-username>/auto-english-ime.git
cd auto-english-ime
make install
```

安装脚本会自动完成：
1. 编译 `Sources/main.swift` 到 `~/.local/bin/auto-english-ime`
2. 关闭 macOS 的「自动切换到文稿的输入法」选项
3. 注册并启动开机自启服务（`~/Library/LaunchAgents/com.auto-english-ime.agent.plist`）

## 可选配置

如需自定义目标输入法或排除某些 App，创建 `~/.config/auto-english-ime/config.json`：

```json
{
  "targetInputSource": "com.apple.keylayout.ABC",
  "excludedApps": [
    "com.tencent.xinWeChat"
  ],
  "switchOnWake": true
}
```

保存后无需重启，下次切换应用时自动生效。

### 查看本机所有可用输入法 ID

```bash
~/.local/bin/auto-english-ime --list
```

### 查看某个 App 的 Bundle ID

```bash
osascript -e 'id of app "WeChat"'
```

## 卸载

```bash
make uninstall
# 如需一并删除配置文件：
bash scripts/uninstall.sh --purge
```

## 开源协议

[MIT](./LICENSE)
