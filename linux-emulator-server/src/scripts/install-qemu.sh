#!/bin/bash
# Script to install QEMU with ARM64/M1 support

set -e

echo "================================================"
echo "QEMU Installation Script for M1/ARM64 Emulation"
echo "================================================"

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

echo "Detected OS: $OS"

install_linux() {
    echo "Installing QEMU on Linux..."
    
    # Update package list
    sudo apt-get update
    
    # Install dependencies
    sudo apt-get install -y \
        build-essential \
        git \
        libglib2.0-dev \
        libfdt-dev \
        libpixman-1-dev \
        zlib1g-dev \
        ninja-build \
        python3-pip \
        libusb-1.0-0-dev \
        libgtk-3-dev \
        libvte-2.91-dev \
        libsdl2-dev \
        libspice-server-dev \
        libusbredirparser-dev
    
    # Install QEMU from package manager (faster)
    sudo apt-get install -y qemu-system-arm qemu-system-aarch64 qemu-utils
    
    # Or build from source for latest version (commented out)
    # build_qemu_from_source
    
    echo "QEMU installed successfully!"
    qemu-system-aarch64 --version
}

install_macos() {
    echo "Installing QEMU on macOS..."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install QEMU
    brew install qemu
    
    echo "QEMU installed successfully!"
    qemu-system-aarch64 --version
}

build_qemu_from_source() {
    echo "Building QEMU from source..."
    
    QEMU_VERSION="8.2.0"
    QEMU_DIR="/tmp/qemu-${QEMU_VERSION}"
    
    # Download QEMU source
    cd /tmp
    wget https://download.qemu.org/qemu-${QEMU_VERSION}.tar.xz
    tar xvJf qemu-${QEMU_VERSION}.tar.xz
    cd qemu-${QEMU_VERSION}
    
    # Configure with ARM64 support
    ./configure \
        --target-list=aarch64-softmmu,arm-softmmu \
        --enable-virtfs \
        --enable-sdl \
        --enable-gtk \
        --enable-kvm \
        --enable-vnc
    
    # Build
    make -j$(nproc)
    
    # Install
    sudo make install
    
    # Cleanup
    cd /tmp
    rm -rf qemu-${QEMU_VERSION}*
    
    echo "QEMU built and installed from source!"
}

# Main installation
if [ "$OS" == "linux" ]; then
    install_linux
elif [ "$OS" == "macos" ]; then
    install_macos
fi

# Verify installation
echo ""
echo "Verifying QEMU installation..."
which qemu-system-aarch64 || (echo "QEMU installation failed!" && exit 1)

echo ""
echo "================================================"
echo "QEMU Installation Complete!"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Download an ARM64 disk image or ISO"
echo "2. Configure the emulator settings"
echo "3. Start the emulator with 'make run'"
