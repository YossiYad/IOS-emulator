# QEMU iOS Emulator - Advanced iOS ARM64 Emulation

**Professional iOS emulation for Linux & Windows servers using standard QEMU + ARM64 architecture**

## What This Project Does

**QEMU iOS Emulator** provides an automated, production-ready iOS emulation platform that works on any Linux or Windows server (including cloud VMs). It uses standard QEMU with ARM64 CPU emulation (Cortex-A78) to run iOS in a virtual environment without requiring macOS or expensive hardware.

### What's Included

- ✅ **Automated Setup** - One command downloads all firmware and images
- ✅ **iPhone 14/15 Support** - A15/A16 Bionic CPU emulation
- ✅ **iPad Pro Support** - M2 chip emulation
- ✅ **QEMU KVM** - Hardware acceleration on Linux (10-50x faster)
- ✅ **VNC Display** - Headless operation for servers
- ✅ **SSH + Network** - Remote access via network
- ✅ **Docker Ready** - Deploy in containers for CI/CD
- ✅ **Web Dashboard** - Visual management UI (Electron + React)
- ✅ **Makefile Commands** - Simple DevOps workflow
- ✅ **Multi-Instance** - Run multiple iOS versions simultaneously

### Platform Support

- ✅ **Linux** (Ubuntu 20.04+, Debian, CentOS) - Full KVM acceleration
- ✅ **Windows** (WSL2) - QEMU in WSL2 with VNC
- ✅ **macOS** - Standard ARM64 QEMU
- ✅ **Cloud** - AWS EC2, Azure, GCP, DigitalOcean, etc.
- ✅ **Docker** - Kubernetes-ready containers

## Quick Start

### Backend (Linux Server)

```bash
cd linux-emulator-server

# One-command setup (downloads firmware, kernel, creates disk)
make ios-setup

# Start emulator
make ios-run              # iPhone 14 (6GB RAM, 6 CPUs)
make ios-run-iphone15     # iPhone 15 (8GB RAM, 6 CPUs)
make ios-run-ipad         # iPad Pro 12.9" (8GB RAM, 10 CPUs)
```

### Frontend (Optional - Web Dashboard)

```bash
# React + Electron UI (works on Linux, macOS, Windows)
npm install
npm run dev    # Dev mode with hot reload
npm run build  # Production build
```

### Docker (Production Deployment)

```bash
cd linux-emulator-server/docker
docker-compose up -d

# Access via VNC at localhost:5900
# Or via SSH at localhost:2222
```

### Manual Commands (If Needed)

```bash
# Backend only - download firmware
bash src/scripts/download-edk2-firmware.sh

# Download iOS firmware/kernel
bash src/scripts/download-ios-image.sh

# Configure iOS QEMU
bash src/scripts/setup-ios-qemu.sh

# Run iOS emulator (iPhone14, 6GB RAM, 6 cores)
bash src/scripts/run-ios-emulator.sh iPhone14 6G 6 :1
```

## Project Architecture

```
┌────────────────────────────────────────┐
│  Web UI (React + Electron)             │
│  - Visual Dashboard                    │
│  - Device Management                   │
│  - Performance Monitoring              │
└────────────────┬─────────────────────┘
                 │ HTTP API
┌────────────────┴─────────────────────┐
│  Backend Server (Go)                 │
│  - QEMU Process Manager              │
│  - Device Configuration              │
│  - VNC Server Proxy                  │
│  - SSH Tunneling                     │
└────────────────┬─────────────────────┘
                 │
┌────────────────┴─────────────────────┐
│  QEMU ARM64                          │
│  - Cortex-A78 CPU (iPhone/iPad)      │
│  - EDK2 UEFI Firmware                │
│  - XNU Kernel                        │
│  - VirtIO Devices                    │
└────────────────────────────────────────┘
```

## Features Comparison

| Feature | QEMU iOS Emulator | Xcode Sim | Physical Device |
|---------|------------------|-----------|-----------------|
| **Linux Server** | ✅ | ❌ | Needs networking |
| **Windows Server** | ✅ | ❌ | Needs networking |
| **Headless/VNC** | ✅ | ❌ | ❌ |
| **Docker** | ✅ | ❌ | ❌ |
| **CI/CD Integration** | ✅ | Limited | ❌ |
| **Cost** | Free | Free* | $800+ |
| **Setup Time** | 2 min | 30 min | 1 hour+ |
| **Multiple Instances** | ✅ | Limited | ❌ |

*macOS only

## Architecture Details

**Backend (Go + QEMU)**
- Manages QEMU processes
- Handles disk image creation
- Serves API endpoints
- Manages VNC/SSH forwarding

**Frontend (React + Electron)**
- Cross-platform desktop app
- Real-time monitoring dashboard
- Device templates & creation
- Settings & configuration

**Emulation Core**
- QEMU System (standard qemu-system-aarch64)
- EDK2 UEFI Firmware
- iOS XNU Kernel
- Device Tree Binaries

## System Requirements

### Minimum
- Linux: Ubuntu 20.04+, Debian 11+, CentOS 8+
- CPU: 4 cores (1 core per instance)
- RAM: 8GB total (6GB per iOS instance)
- Disk: 150GB (firmware + images)

### Recommended (Production)
- CPU: 16+ cores
- RAM: 64GB+ (supports 8-10 concurrent instances)
- Disk: SSD with 500GB+
- Network: Gigabit LAN

## Use Cases

### Development
- Test iOS app builds on Linux dev servers
- Multiple iOS versions in parallel
- Integration with CI/CD (Jenkins, GitLab CI, GitHub Actions)

### Testing
- Automated iOS app testing
- Performance benchmarking
- Network condition simulation

### Production
- Cloud-based iOS app testing farm
- Kubernetes deployments
- Multi-tenant testing infrastructure

## Commands Reference

```bash
# Full setup
make ios-setup

# Run specific devices
make ios-run              # iPhone 14
make ios-run-iphone15     # iPhone 15
make ios-run-ipad         # iPad Pro

# Check configuration
make ios-info

# Development
make dev                  # Run backend in dev mode
make run-dev              # Run with debug logging

# Testing
make test                 # Run backend tests
make test-coverage        # Generate coverage report
```

## Next Steps

1. **First Run**: `make ios-setup` (5-10 min)
2. **Start Emulator**: `make ios-run` (2 min boot)
3. **Access UI**: Open VNC at `localhost:5900`
4. **Or Use Web**: `npm run dev` → `http://localhost:3000`
5. **Deploy**: `docker-compose up` (production ready)

- 🧪 **iOS Development** - Test apps without physical device
- 🔬 **Security Research** - Analyze iOS in controlled environment  
- 📚 **Education** - Learn how iOS boot chain works
- 🐛 **Debugging** - Use GDB with iOS kernel
- 💰 **No Hardware** - No need to buy $1000 iPhone

## Limitations

- **Performance**: 10-50x slower than real hardware
- **Compatibility**: iOS 14-15 work best, newer versions problematic
- **Features**: Some iOS features won't work (FaceID, cellular, etc.)
- **Legal**: For research/education only, not for piracy

## Credits

- **QEMU-t8030**: https://github.com/TrungNguyen1909/qemu-t8030
- **checkra1n team**: Boot chain research
- **Project Sandcastle**: iOS on Android research

## License

- QEMU-t8030: GPL v2
- This Manager: MIT

---

**Disclaimer**: This is for educational/research purposes. Don't use for piracy or illegal activities.
