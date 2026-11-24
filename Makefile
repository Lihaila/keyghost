PREFIX ?= $(HOME)/.local
BIN_DIR = $(PREFIX)/bin
BINARY = build/keyghost

.PHONY: build install uninstall status list clean

build:
	@mkdir -p build
	swiftc -O Sources/main.swift -o $(BINARY)
	@echo "Built $(BINARY)"

install:
	@bash scripts/install.sh

uninstall:
	@bash scripts/uninstall.sh

status:
	@launchctl print gui/$$(id -u)/com.keyghost.agent 2>/dev/null | grep -E "state =|pid =" || echo "Not running"

list: build
	@$(BINARY) --list

clean:
	@rm -rf build
