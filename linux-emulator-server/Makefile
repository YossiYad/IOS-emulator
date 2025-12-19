# Makefile for QEMU iOS Emulator
# Professional build system for iOS ARM64 emulation on Linux & Windows

APP_NAME := qemu-ios-emulator
VERSION := 2.0.0
BUILD_DIR := build
SRC_DIR := src
BIN_DIR := bin
CONFIG_DIR := /etc/silicon-emulator
VAR_DIR := /var/lib/silicon-emulator
LOG_DIR := /var/log/silicon-emulator

# Go build settings
GO := go
GOFLAGS := -v
LDFLAGS := -X main.Version=$(VERSION) -X main.BuildTime=$(shell date -u +%Y-%m-%dT%H:%M:%SZ)
TAGS := 

# QEMU settings
QEMU_VERSION := 8.2.0
QEMU_ARCH := aarch64

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

.PHONY: all build clean install uninstall run test deps qemu help

all: deps build

## Build commands

build: ## Build the emulator server
	@echo "$(GREEN)Building $(APP_NAME) v$(VERSION)...$(NC)"
	@mkdir -p $(BUILD_DIR) $(BIN_DIR)
	$(GO) build $(GOFLAGS) -ldflags "$(LDFLAGS)" -o $(BIN_DIR)/$(APP_NAME) $(SRC_DIR)/core/main.go
	@echo "$(GREEN)✓ Build complete: $(BIN_DIR)/$(APP_NAME)$(NC)"

build-static: ## Build static binary
	@echo "$(GREEN)Building static binary...$(NC)"
	@mkdir -p $(BIN_DIR)
	CGO_ENABLED=0 $(GO) build $(GOFLAGS) -ldflags "$(LDFLAGS) -extldflags '-static'" -o $(BIN_DIR)/$(APP_NAME)-static $(SRC_DIR)/core/main.go
	@echo "$(GREEN)✓ Static build complete$(NC)"

release: clean deps ## Build release binaries for multiple platforms
	@echo "$(GREEN)Building release binaries...$(NC)"
	@mkdir -p $(BUILD_DIR)/release
	GOOS=linux GOARCH=amd64 $(GO) build -ldflags "$(LDFLAGS)" -o $(BUILD_DIR)/release/$(APP_NAME)-linux-amd64 $(SRC_DIR)/core/main.go
	GOOS=linux GOARCH=arm64 $(GO) build -ldflags "$(LDFLAGS)" -o $(BUILD_DIR)/release/$(APP_NAME)-linux-arm64 $(SRC_DIR)/core/main.go
	GOOS=darwin GOARCH=amd64 $(GO) build -ldflags "$(LDFLAGS)" -o $(BUILD_DIR)/release/$(APP_NAME)-darwin-amd64 $(SRC_DIR)/core/main.go
	GOOS=darwin GOARCH=arm64 $(GO) build -ldflags "$(LDFLAGS)" -o $(BUILD_DIR)/release/$(APP_NAME)-darwin-arm64 $(SRC_DIR)/core/main.go
	@echo "$(GREEN)✓ Release builds complete$(NC)"

## Dependencies

deps: ## Install Go dependencies
	@echo "$(GREEN)Installing Go dependencies...$(NC)"
	$(GO) mod download
	$(GO) mod verify
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

deps-update: ## Update Go dependencies
	@echo "$(YELLOW)Updating Go dependencies...$(NC)"
	$(GO) get -u ./...
	$(GO) mod tidy
	@echo "$(GREEN)✓ Dependencies updated$(NC)"

## QEMU

qemu-check: ## Check QEMU installation
	@echo "$(GREEN)Checking QEMU installation...$(NC)"
	@which qemu-system-$(QEMU_ARCH) > /dev/null || (echo "$(RED)✗ QEMU not found$(NC)" && exit 1)
	@qemu-system-$(QEMU_ARCH) --version
	@echo "$(GREEN)✓ QEMU is installed$(NC)"

qemu-install: ## Install QEMU (requires sudo)
	@echo "$(YELLOW)Installing QEMU $(QEMU_VERSION)...$(NC)"
	@$(SRC_DIR)/scripts/install-emulator.sh
	@echo "$(GREEN)✓ QEMU installation complete$(NC)"

## iOS Emulation

ios-setup: ## Setup iOS emulation environment
	@echo "$(YELLOW)Setting up iOS emulation...$(NC)"
	@bash $(SRC_DIR)/scripts/download-edk2-firmware.sh
	@bash $(SRC_DIR)/scripts/download-ios-image.sh
	@bash $(SRC_DIR)/scripts/setup-ios-qemu.sh
	@chmod +x $(SRC_DIR)/scripts/run-ios-emulator.sh
	@echo "$(GREEN)✓ iOS emulation ready$(NC)"

ios-run: ## Run iOS emulator (default: iPhone14)
	@echo "$(GREEN)Starting iOS emulator...$(NC)"
	@bash $(SRC_DIR)/scripts/run-ios-emulator.sh iPhone14 6G 6 :1

ios-run-iphone15: ## Run iPhone 15 emulator
	@bash $(SRC_DIR)/scripts/run-ios-emulator.sh iPhone15 8G 6 :1

ios-run-ipad: ## Run iPad Pro emulator
	@bash $(SRC_DIR)/scripts/run-ios-emulator.sh iPad-Pro-12.9 8G 10 :2

ios-info: ## Show iOS emulation configuration
	@echo "$(GREEN)iOS Emulation Configuration:$(NC)"
	@[ -f /etc/silicon-emulator/ios-devices.json ] && cat /etc/silicon-emulator/ios-devices.json || echo "Not configured"

## Installation

install: build ## Install the emulator system-wide (requires sudo)
	@echo "$(YELLOW)Installing $(APP_NAME)...$(NC)"
	sudo install -d $(CONFIG_DIR)
	sudo install -d $(VAR_DIR)
	sudo install -d $(LOG_DIR)
	sudo install -m 755 $(BIN_DIR)/$(APP_NAME) /usr/local/bin/$(APP_NAME)
	sudo install -m 644 configs/systemd/linux-emulator.service /etc/systemd/system/$(APP_NAME).service
	sudo systemctl daemon-reload
	@echo "$(GREEN)✓ Installation complete$(NC)"
	@echo "$(YELLOW)Run 'sudo systemctl enable $(APP_NAME)' to enable auto-start$(NC)"

uninstall: ## Uninstall the emulator (requires sudo)
	@echo "$(YELLOW)Uninstalling $(APP_NAME)...$(NC)"
	sudo systemctl stop $(APP_NAME) 2>/dev/null || true
	sudo systemctl disable $(APP_NAME) 2>/dev/null || true
	sudo rm -f /usr/local/bin/$(APP_NAME)
	sudo rm -f /etc/systemd/system/$(APP_NAME).service
	sudo systemctl daemon-reload
	@echo "$(GREEN)✓ Uninstallation complete$(NC)"

## Running

run: build ## Run the emulator server
	@echo "$(GREEN)Starting $(APP_NAME)...$(NC)"
	./$(BIN_DIR)/$(APP_NAME)

run-dev: build ## Run in development mode with auto-restart
	@echo "$(GREEN)Starting in development mode...$(NC)"
	AUTO_START=true LOG_LEVEL=debug ./$(BIN_DIR)/$(APP_NAME)

service-start: ## Start the systemd service
	sudo systemctl start $(APP_NAME)
	sudo systemctl status $(APP_NAME)

service-stop: ## Stop the systemd service
	sudo systemctl stop $(APP_NAME)

service-logs: ## View service logs
	sudo journalctl -u $(APP_NAME) -f

## Testing

test: ## Run tests
	@echo "$(GREEN)Running tests...$(NC)"
	$(GO) test -v -race ./...

test-coverage: ## Run tests with coverage
	@echo "$(GREEN)Running tests with coverage...$(NC)"
	$(GO) test -v -race -coverprofile=coverage.out ./...
	$(GO) tool cover -html=coverage.out -o coverage.html
	@echo "$(GREEN)✓ Coverage report: coverage.html$(NC)"

benchmark: ## Run benchmarks
	@echo "$(GREEN)Running benchmarks...$(NC)"
	$(GO) test -bench=. -benchmem ./...

## Docker

docker-build: ## Build Docker image
	@echo "$(GREEN)Building Docker image...$(NC)"
	docker-compose -f docker/docker-compose.yml build

docker-run: ## Run in Docker
	@echo "$(GREEN)Starting Docker containers...$(NC)"
	docker-compose -f docker/docker-compose.yml up

docker-stop: ## Stop Docker containers
	docker-compose -f docker/docker-compose.yml down

docker-clean: ## Clean Docker images and containers
	docker-compose -f docker/docker-compose.yml down -v --rmi all

## Maintenance

clean: ## Clean build artifacts
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	rm -rf $(BUILD_DIR) $(BIN_DIR)
	rm -f coverage.out coverage.html
	$(GO) clean
	@echo "$(GREEN)✓ Clean complete$(NC)"

fmt: ## Format Go code
	@echo "$(GREEN)Formatting code...$(NC)"
	$(GO) fmt ./...
	@echo "$(GREEN)✓ Format complete$(NC)"

lint: ## Run linters
	@echo "$(GREEN)Running linters...$(NC)"
	golangci-lint run ./...
	@echo "$(GREEN)✓ Lint complete$(NC)"

vet: ## Run go vet
	@echo "$(GREEN)Running go vet...$(NC)"
	$(GO) vet ./...
	@echo "$(GREEN)✓ Vet complete$(NC)"

mod-tidy: ## Tidy Go modules
	@echo "$(GREEN)Tidying Go modules...$(NC)"
	$(GO) mod tidy
	@echo "$(GREEN)✓ Modules tidied$(NC)"

## Information

version: ## Show version
	@echo "$(APP_NAME) v$(VERSION)"

info: ## Show build information
	@echo "$(GREEN)Build Information:$(NC)"
	@echo "  App Name: $(APP_NAME)"
	@echo "  Version:  $(VERSION)"
	@echo "  Go:       $(shell $(GO) version)"
	@echo "  OS:       $(shell uname -s)"
	@echo "  Arch:     $(shell uname -m)"

help: ## Show this help message
	@echo "$(GREEN)$(APP_NAME) v$(VERSION) - Makefile Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-18s$(NC) %s\n", $$1, $$2}'
	@echo ""