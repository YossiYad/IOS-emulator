#!/bin/bash
# Download EDK2 firmware for ARM64/AARCH64 UEFI boot

set -e

echo "================================================"
echo "EDK2 ARM64 UEFI Firmware Download"
echo "================================================"

FIRMWARE_DIR="/usr/share/qemu/edk2-aarch64"
TEMP_DIR="/tmp/edk2-firmware"

echo "Downloading ARM64 UEFI firmware..."

# Create directories
sudo mkdir -p "$FIRMWARE_DIR"
mkdir -p "$TEMP_DIR"

# Download EDK2 AARCH64 firmware
cd "$TEMP_DIR"

# Option 1: From official QEMU firmware repository
wget -q --show-progress \
    https://releases.linaro.org/components/kernel/uefi-linaro/latest/release/qemu64/QEMU_EFI.fd \
    -O QEMU_EFI.fd

wget -q --show-progress \
    https://releases.linaro.org/components/kernel/uefi-linaro/latest/release/qemu64/QEMU_VARS.fd \
    -O QEMU_VARS.fd

# Install firmware files
sudo cp QEMU_EFI.fd "$FIRMWARE_DIR/"
sudo cp QEMU_VARS.fd "$FIRMWARE_DIR/"

# Create flash image combining both
cat QEMU_EFI.fd QEMU_VARS.fd > flash.img
sudo cp flash.img "$FIRMWARE_DIR/"

echo ""
echo "================================================"
echo "EDK2 Firmware Downloaded Successfully!"
echo "================================================"
echo ""
echo "Firmware location: $FIRMWARE_DIR"
echo ""
echo "Files:"
ls -lh "$FIRMWARE_DIR"

# Cleanup
cd -
rm -rf "$TEMP_DIR"

echo ""
echo "To use this firmware, add to QEMU command:"
echo "  -bios $FIRMWARE_DIR/QEMU_EFI.fd"
