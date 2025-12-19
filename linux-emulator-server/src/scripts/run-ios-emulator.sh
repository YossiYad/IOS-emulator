#!/bin/bash
# Run iOS emulator in QEMU with ARM64 support
# Starts iPhone/iPad emulation with proper bootloader and device parameters

set -e

CONFIG_DIR="/etc/silicon-emulator"
FIRMWARE_DIR="/usr/share/qemu/ios-firmware"
IMAGE_DIR="/var/lib/silicon-emulator/ios-images"

# Default values
DEVICE="${1:-iPhone14}"
MEMORY="${2:-6G}"
CPUS="${3:-6}"
VNC_DISPLAY="${4:-:1}"

# Load config
if [ -f "$CONFIG_DIR/ios-qemu.conf" ]; then
    source "$CONFIG_DIR/ios-qemu.conf"
fi

echo "================================================"
echo "iOS ARM64 QEMU Emulator"
echo "================================================"
echo ""
echo "Device: $DEVICE"
echo "Memory: $MEMORY"
echo "CPUs: $CPUS"
echo "VNC: $VNC_DISPLAY"
echo ""

# Verify components
if [ ! -f "$FIRMWARE_DIR/QEMU_EFI.fd" ]; then
    echo "ERROR: EDK2 firmware not found!"
    echo "Run: bash download-edk2-firmware.sh"
    exit 1
fi

if [ ! -f "$FIRMWARE_DIR/kernel" ]; then
    echo "ERROR: iOS kernel not extracted!"
    echo "Run: bash download-ios-image.sh && bash setup-ios-qemu.sh"
    exit 1
fi

# Create disk image if not exists
DISK_IMAGE="$IMAGE_DIR/${DEVICE}.qcow2"
if [ ! -f "$DISK_IMAGE" ]; then
    echo "Creating disk image: $DISK_IMAGE"
    qemu-img create -f qcow2 "$DISK_IMAGE" 128G
fi

# Detect KVM availability
ACCEL_OPTS=""
if [[ "$(uname -s)" == "Linux" ]] && [ -c /dev/kvm ]; then
    ACCEL_OPTS="-accel kvm"
    echo "✓ KVM acceleration enabled"
fi

echo ""
echo "Starting iOS emulation..."
echo "VNC: localhost${VNC_DISPLAY} (port $(( 5900 + ${VNC_DISPLAY##*:} )))"
echo "SSH: localhost:2222"
echo "HTTP: localhost:8080"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# iOS bootloader parameters
BOOTARGS="-append"
BOOTARGS_VALUE="console=hvc0 earlyprintk=pl011,mmio32,0x09000000 debug=0x2014e cs_enforcement_disable=1"

# Start QEMU with iOS configuration
qemu-system-aarch64 \
  -M virt,highmem=on \
  -cpu cortex-a78 \
  -smp "$CPUS" \
  -m "$MEMORY" \
  $ACCEL_OPTS \
  -bios "$FIRMWARE_DIR/QEMU_EFI.fd" \
  -kernel "$FIRMWARE_DIR/kernel" \
  -initrd "$FIRMWARE_DIR/ramdisk" 2>/dev/null || true \
  $BOOTARGS "$BOOTARGS_VALUE" \
  -device virtio-blk-device,drive=hd0 \
  -drive if=none,file="$DISK_IMAGE",format=qcow2,id=hd0,cache=writeback \
  -device virtio-net-device,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:80 \
  -device virtio-gpu-pci \
  -display gtk \
  -vnc "$VNC_DISPLAY" \
  -device virtio-balloon \
  -device usb-host,vendorid=0x05ac 2>/dev/null || true \
  -device usb-tablet \
  -rtc base=utc \
  -no-reboot

echo ""
echo "Emulator stopped."
