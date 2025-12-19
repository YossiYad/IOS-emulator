#!/bin/bash
set -euo pipefail
# Simple wrapper to run an AArch64 VM with QEMU using EDK2 UEFI firmware.
# This is intended for ARM64 Linux images (Ubuntu, Asahi, etc.).
# NOT for iOS — emulating iOS requires Apple proprietary firmware and
# signed boot chain which cannot be provided here.

FIRMWARE_DIR="/usr/share/qemu/edk2-aarch64"
DEFAULT_DISK="/var/lib/silicon-emulator/macos-arm64.qcow2"

DISK_IMAGE="${1:-$DEFAULT_DISK}"
MEMORY="${2:-8G}"
CPUS="${3:-4}"
VNC_DISPLAY="${4:-:1}"

if [ ! -f "$DISK_IMAGE" ]; then
  echo "Disk image not found: $DISK_IMAGE"
  echo "Use create-disk-image.sh to create one or pass a valid disk image path."
  exit 1
fi

if [ ! -f "$FIRMWARE_DIR/QEMU_EFI.fd" ]; then
  echo "EDK2 firmware not found in $FIRMWARE_DIR" >&2
  echo "Run download-edk2-firmware.sh first." >&2
  exit 1
fi

echo "Starting ARM64 VM"
echo "  Disk: $DISK_IMAGE"
echo "  Memory: $MEMORY  CPUs: $CPUS  VNC: $VNC_DISPLAY"

# Detect whether KVM is available (Linux host)
ACCEL_OPTS=""
if [[ "$(uname -s)" == "Linux" ]] && [ -c /dev/kvm ]; then
  ACCEL_OPTS="-accel kvm"
fi

qemu-system-aarch64 \
  -machine virt,highmem=on -cpu cortex-a72 -smp "$CPUS" -m "$MEMORY" \
  $ACCEL_OPTS \
  -bios "$FIRMWARE_DIR/QEMU_EFI.fd" \
  -device virtio-blk-device,drive=hd0 -drive if=none,file="$DISK_IMAGE",format=qcow2,id=hd0,cache=writeback \
  -device virtio-net-device,netdev=net0 -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -device virtio-gpu-pci -display gtk \
  -vnc "$VNC_DISPLAY" \
  -device virtio-balloon

echo "QEMU exited."
