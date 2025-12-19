#!/bin/bash
# Setup QEMU for iOS ARM64 emulation
# Configure bootloader, kernel, and device parameters

set -e

echo "================================================"
echo "iOS QEMU Configuration Setup"
echo "================================================"

IMAGE_DIR="/var/lib/qemu-ios-emulator/ios-images"
FIRMWARE_DIR="/usr/share/qemu/ios-firmware"
CONFIG_DIR="/etc/qemu-ios-emulator"

sudo mkdir -p "$CONFIG_DIR"

# Create iOS QEMU configuration
sudo tee "$CONFIG_DIR/ios-qemu.conf" > /dev/null << 'EOF'
# iOS ARM64 QEMU Configuration
# Device: iPhone (ARM64)

# Machine type
MACHINE="virt"
CPU="cortex-a78"
CORES="6"
MEMORY="6G"

# Storage
DISK_SIZE="128G"
DISK_FORMAT="qcow2"

# Bootloader
BOOTLOADER="/usr/share/qemu/edk2-aarch64/QEMU_EFI.fd"

# iOS-specific flags
ENABLE_RAMDISK="yes"
ENABLE_VIRTIO="yes"
ENABLE_KVM="yes"

# Display
DISPLAY_TYPE="gtk"
VNC_ENABLED="yes"
VNC_PORT="5900"

# Network
NETWORK="user"
SSH_PORT="2222"
HTTP_PORT="8080"

# Audio (disabled for headless)
AUDIO_ENABLED="no"

# USB (for iOS development)
USB_ENABLED="yes"
EOF

echo "Created iOS QEMU config: $CONFIG_DIR/ios-qemu.conf"

# Create boot script for iOS kernel
sudo tee "$FIRMWARE_DIR/boot-ios.sh" > /dev/null << 'EOF'
#!/bin/bash
# Boot iOS in QEMU with proper kernel parameters

# Extract bootloader from IPSW
IPSW_FILE="${1:-}"
if [ -z "$IPSW_FILE" ]; then
    echo "Usage: $0 <path-to-ios.ipsw>"
    exit 1
fi

echo "Extracting iOS bootloader from $IPSW_FILE..."

# Unzip IPSW (it's a ZIP file)
EXTRACT_DIR="/tmp/ios-ipsw-extract"
mkdir -p "$EXTRACT_DIR"
unzip -q "$IPSW_FILE" -d "$EXTRACT_DIR"

# Find kernel and device tree
KERNEL=$(find "$EXTRACT_DIR" -name "*kernel*" -type f | head -1)
DEVICETREE=$(find "$EXTRACT_DIR" -name "*DeviceTree*" -o -name "*.dtb" | head -1)

if [ -z "$KERNEL" ]; then
    echo "ERROR: Could not find kernel in IPSW"
    exit 1
fi

echo "Found kernel: $KERNEL"
echo "Found device tree: $DEVICETREE"

# Copy to firmware directory
sudo cp "$KERNEL" /usr/share/qemu/ios-firmware/kernel
[ -n "$DEVICETREE" ] && sudo cp "$DEVICETREE" /usr/share/qemu/ios-firmware/devicetree

# Cleanup
rm -rf "$EXTRACT_DIR"

echo "iOS bootloader extracted successfully!"
EOF

sudo chmod +x "$FIRMWARE_DIR/boot-ios.sh"

# Create device definitions
sudo tee "$CONFIG_DIR/ios-devices.json" > /dev/null << 'EOF'
{
  "devices": [
    {
      "name": "iPhone14",
      "chip": "A15 Bionic",
      "cores": 6,
      "ram": "6GB",
      "storage": "128GB",
      "display": "6.1 inch Super Retina XDR",
      "ios_versions": ["16.0", "16.1", "16.2", "16.3", "16.4", "16.5", "16.6", "16.7"],
      "arch": "arm64"
    },
    {
      "name": "iPhone15",
      "chip": "A16 Bionic",
      "cores": 6,
      "ram": "8GB",
      "storage": "128GB",
      "display": "6.1 inch Super Retina",
      "ios_versions": ["17.0", "17.1", "17.2"],
      "arch": "arm64"
    },
    {
      "name": "iPad-Pro-12.9",
      "chip": "M2",
      "cores": 10,
      "ram": "8GB",
      "storage": "128GB",
      "display": "12.9 inch Liquid Retina XDR",
      "ios_versions": ["16.0", "17.0"],
      "arch": "arm64"
    }
  ]
}
EOF

echo "Created iOS device definitions: $CONFIG_DIR/ios-devices.json"

# Create kernel boot parameters file
sudo tee "$FIRMWARE_DIR/ios-boot-params.txt" > /dev/null << 'EOF'
# iOS Kernel Boot Parameters for QEMU

# Device parameters
fw_printenv=1
debug=0x2014e

# RNG seed
rng-seed=1234567890abcdef

# Console settings
console=hvc0
earlycon=pl011,mmio32,0x09000000

# Memory
mem=6G

# Device tree address
fdt=0x40000000

# Ramdisk
initrd=0x42000000

# Skip secure boot checks (QEMU mode)
cs_enforcement_disable=1

# Enable USB for development
usb_mux_sel=2

# Serial/debug output
serialno=000000000000000
EOF

echo "Created iOS boot parameters: $FIRMWARE_DIR/ios-boot-params.txt"

echo ""
echo "================================================"
echo "iOS QEMU Setup Complete!"
echo "================================================"
echo ""
echo "Configuration files created:"
echo "  - $CONFIG_DIR/ios-qemu.conf"
echo "  - $CONFIG_DIR/ios-devices.json"
echo "  - $FIRMWARE_DIR/ios-boot-params.txt"
echo ""
echo "Next: Run setup-ios-images.sh to extract IPSW"
echo "Then: Use run-ios-emulator.sh to start VM"
