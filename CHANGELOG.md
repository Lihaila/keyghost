# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2026-11-24

### Added
- Native zero-dependency Swift daemon for macOS (`NSWorkspace` + `Carbon` `TISSelectInputSource`).
- Automatic English input source detection (`ABC`, `U.S.`, `British`).
- Optional JSON configuration (`~/.config/auto-english-ime/config.json`) with hot-reloading and per-app exclusions (`excludedApps`).
- CLI flags: `--list`, `--input-source`, `--config`, `--verbose`, `--version`, `--help`.
- One-line installer (`scripts/quick-install.sh`) downloading prebuilt Universal Binary (`arm64` + `x86_64`), plus source install (`scripts/install.sh`) and uninstall (`scripts/uninstall.sh`).
- GitHub Actions CI and automated Universal Binary Release workflows.
