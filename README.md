# QEMU iOS Emulator - iOS on Linux & Windows Servers

**Run iOS apps in QEMU. No physical device needed. Works on Linux, Windows, macOS servers.**

## The Problem

- Need to test iOS apps but only have Linux/Windows servers
- iOS Simulator only works on macOS with Xcode
- Physical devices are expensive and limited
- QEMU supports ARM64 but setup is extremely complex

## The Solution

**QEMU iOS Emulator** - Automated iOS device management for QEMU

```bash
# Old way: memorize 50+ QEMU flags and manually setup firmware
qemu-system-aarch64 -M virt -cpu cortex-a78 -smp 6 -m 6G \
  -bios /path/to/firmware -kernel /path/to/kernel ...
  # (40+ more complex parameters)

# New way: one command
make ios-setup && make ios-run
```

## Quick Features

✅ **iPhone 14/15 Emulation** | ✅ **iPad Pro** | ✅ **Automated Setup** | ✅ **VNC + SSH** | ✅ **Docker Ready**

## What This Provides

1. **iOS Device Emulation** - iPhone 14/15 (A15/A16), iPad Pro (M2)
2. **Automated Firmware** - Download EDK2, XNU kernel, device tree automatically
3. **One-Click Setup** - `make ios-setup` downloads & configures everything
4. **Multi-Device** - Run multiple iOS versions simultaneously
5. **VNC + SSH** - Access iOS emulator over network (perfect for remote servers)
6. **Web Dashboard** - Manage VMs from browser with Electron UI
7. **Docker Support** - Deploy as container for CI/CD pipelines
8. **Performance Monitoring** - Real-time CPU/RAM/disk graphs

## Quick Start

```bash
# Backend setup (Linux server)
cd linux-emulator-server
make ios-setup       # Downloads firmware & creates disk images
make ios-run         # Starts iPhone 14 emulator

# Or use specific device
make ios-run-iphone15
make ios-run-ipad

# Frontend (optional - web UI on Linux, Electron on any OS)
npm install
npm run dev          # React + Electron dashboard
```

## Use Cases

- **CI/CD Testing** - Run iOS app tests on Linux build servers
- **Remote Development** - Centralized iOS emulation infrastructure
- **Development Teams** - Shared emulation farm via Docker
- **Cloud Deployment** - Kubernetes-ready iOS emulation
- **Testing at Scale** - Parallel multiple iOS versions

## Why QEMU iOS Emulator?

| Feature | This | Xcode Sim | Physical |
|---------|------|-----------|----------|
| Linux Support | ✅ | ❌ | ✅ |
| Server Deploy | ✅ | ❌ | ❌ |
| Headless/VNC | ✅ | ❌ | ❌ |
| Cost | Free | Free* | $800+ |
| CI/CD Ready | ✅ | Limited | ❌ |

*macOS only

Tech: QEMU + Go + React + Electron
