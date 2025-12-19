#!/bin/bash
# Script to create a disk image for the emulator

set -e

echo "================================================"
echo "Disk Image Creation Tool"
echo "================================================"

# Default values
SIZE=${1:-64G}
FORMAT=${2:-qcow2}
OUTPUT_DIR="/var/lib/silicon-emulator"
IMAGE_NAME="macos-arm64.${FORMAT}"

echo "Creating disk image with following parameters:"
echo "  Size: $SIZE"
echo "  Format: $FORMAT"
echo "  Location: $OUTPUT_DIR/$IMAGE_NAME"

# Create directory if it doesn't exist
sudo mkdir -p "$OUTPUT_DIR"

# Create the disk image
echo ""
echo "Creating disk image..."
sudo qemu-img create -f "$FORMAT" "$OUTPUT_DIR/$IMAGE_NAME" "$SIZE"

# Set appropriate permissions
sudo chown $USER:$USER "$OUTPUT_DIR/$IMAGE_NAME"

echo ""
echo "================================================"
echo "Disk image created successfully!"
echo "================================================"
echo ""
echo "Image details:"
qemu-img info "$OUTPUT_DIR/$IMAGE_NAME"

echo ""
echo "To use this image, update your config:"
echo "  DISK_IMAGE=$OUTPUT_DIR/$IMAGE_NAME"
