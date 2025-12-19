#!/usr/bin/env bash
set -euo pipefail

LOGFILE="/var/log/silicon-emulator-setup.log"
mkdir -p "$(dirname "$LOGFILE")"

log(){
  echo "[$(date -Is)] $*" | tee -a "$LOGFILE"
}

err(){
  echo "[$(date -Is)] ERROR: $*" | tee -a "$LOGFILE" >&2
}

require_cmd(){
  command -v "$1" >/dev/null 2>&1 || { err "required command '$1' not found"; exit 2; }
}

detect_os(){
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  else
    uname -s
  fi
}

ARCH=$(uname -m)
OS=$(detect_os)
log "Detected OS=$OS ARCH=$ARCH"

install_packages_apt(){
  sudo apt-get update -y
  sudo apt-get install -y build-essential git ninja-build python3 python3-pip python3-venv qemu-utils qemu-system-aarch64 qemu-system-x86 gcc-multilib pkg-config libglib2.0-dev libfdt-dev libpixman-1-dev libncurses5
}

install_packages(){
  case "$OS" in
    ubuntu|debian)
      install_packages_apt
      ;;
    fedora)
      sudo dnf install -y @development-tools git python3 python3-pip qemu-img qemu-system-x86 qemu-system-aarch64
      ;;
    arch)
      sudo pacman -Sy --noconfirm base-devel git python qemu
      ;;
    *)
      log "Unknown OS '$OS', please install QEMU, git, python3 and build tools manually"
      ;;
  esac
}

setup_edk2(){
  TARGET_DIR="$HOME/edk2-qemu"
  if [ -d "$TARGET_DIR" ]; then
    log "EDK2 already present in $TARGET_DIR"
    return
  fi
  log "Cloning EDK2 repos to $TARGET_DIR"
  git clone --depth 1 https://github.com/tianocore/edk2.git "$TARGET_DIR/edk2"
  git clone --depth 1 https://github.com/tianocore/edk2-platforms.git "$TARGET_DIR/edk2-platforms"
  pushd "$TARGET_DIR/edk2" >/dev/null
  export WORKSPACE="$TARGET_DIR/edk2"
  git submodule update --init --recursive || true
  pip3 install --user setuptools wheel
  log "Building EDK2 for AARCH64 (may take a while)"
  . edksetup.sh || true
  build -a AARCH64 -t GCC5 -p "${TARGET_DIR}/edk2-platforms/Platform/Arm/Qemu/QemuArmPkg/QemuArmPkg.dsc" || log "EDK2 build may have failed; check $LOGFILE"
  popd >/dev/null
}

create_disk_image(){
  IMG_PATH=${1:-"${PWD}/images/ios_disk.img"}
  IMG_SIZE=${2:-"32G"}
  mkdir -p "$(dirname "$IMG_PATH")"
  log "Creating disk image $IMG_PATH size $IMG_SIZE"
  qemu-img create -f qcow2 "$IMG_PATH" "$IMG_SIZE"
  log "Partitioning and formatting image"
  # create loopback, partition, format using guestfish if available, else leave qcow2 raw
  if command -v virt-resize >/dev/null 2>&1 || command -v guestfish >/dev/null 2>&1; then
    log "guestfish/virt tools detected — you can customize partitions later"
  else
    log "No guestfs tools found; image created as qcow2 without internal partitions"
  fi
}

configure_networking(){
  # Setup NAT user mode with port forwarding instructions
  log "Networking: will use QEMU user-mode NAT by default with port forwarding options when launching VMs."
  log "If you prefer bridged networking, create a bridge and a tap device, then pass -netdev tap," 
}

setup_vnc_ssh(){
  log "VNC/SSH: QEMU will expose VNC display and SSH port forwarding by run script. Ensure firewall allows forwarded ports."
}

main(){
  log "Starting advanced setup"
  install_packages
  setup_edk2
  create_disk_image
  configure_networking
  setup_vnc_ssh
  log "Setup completed. See $LOGFILE for details"
}

main "$@"
