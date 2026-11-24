# Changelog

All notable changes to this project will be documented in this file.

## [0.2.1] - 2026-11-24

### Improved
- Automatic fallback to the first enabled ASCII-capable keyboard layout (e.g. German, French, Dvorak, Colemak) when `ABC`, `U.S.`, or `British` is not enabled.

## [0.2.0] - 2026-11-24

### Changed
- Rebranded project to **KeyGhost** (`keyghost`) with a custom macOS icon logo.
- Updated LaunchAgent label to `com.keyghost.agent` and config path to `~/.config/keyghost/config.json`.

## [0.1.0] - 2026-11-24

### Added
- Native zero-dependency Swift daemon for macOS (`NSWorkspace` + `Carbon` `TISSelectInputSource`).
- Automatic English input source detection (`ABC`, `U.S.`, `British`).
- Optional JSON configuration with hot-reloading and per-app exclusions (`excludedApps`).
- One-line installer (`scripts/quick-install.sh`) downloading prebuilt Universal Binary (`arm64` + `x86_64`), plus source install and uninstall scripts.
- GitHub Actions CI and automated Universal Binary Release workflows.
