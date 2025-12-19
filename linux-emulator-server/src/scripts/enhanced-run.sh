#!/usr/bin/env bash
set -euo pipefail

# Enhanced QEMU runner for iOS images with profiles, snapshots, and monitoring

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/var/log/qemu-ios-emulator"
VM_DIR="/var/lib/qemu-ios-emulator/vms"
mkdir -p "$LOG_DIR" "$VM_DIR"

usage(){
  cat <<EOF
Usage: $0 --name NAME [--profile iphone14-pro|iphone14|iphone15|ipadpro] [--memory 6G] [--cpus 6] [--disk path] [--vnc :1] [--headless]
Controls snapshots: --snapshot save|load --snapshot-name NAME
EOF
  exit 1
}

log(){ echo "[$(date -Is)] $*" >> "$LOG_DIR/runner.log"; }

require(){ command -v "$1" >/dev/null 2>&1 || { echo "missing $1"; exit 2; } }

require qemu-system-aarch64

NAME=""
PROFILE="iphone14-pro"
MEM="6G"
CPUS=6
DISK=""
VNC_DISPLAY="-vnc :0"
HEADLESS=0
SNAP_ACTION=""
SNAP_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="$2"; shift 2;;
    --profile) PROFILE="$2"; shift 2;;
    --memory) MEM="$2"; shift 2;;
    --cpus) CPUS="$2"; shift 2;;
    --disk) DISK="$2"; shift 2;;
    --vnc) VNC_DISPLAY="-vnc $2"; shift 2;;
    --headless) HEADLESS=1; shift;;
    --snapshot) SNAP_ACTION="$2"; shift 2;;
    --snapshot-name) SNAP_NAME="$2"; shift 2;;
    -h|--help) usage;;
    *) echo "Unknown arg $1"; usage;;
  esac
done

if [ -z "$NAME" ]; then
  echo "--name is required"; usage
fi

LOG_FILE="$LOG_DIR/$NAME.log"
VM_STATE_DIR="$VM_DIR/$NAME"
mkdir -p "$VM_STATE_DIR"

# Default disk if none provided
if [ -z "$DISK" ]; then
  DISK="$VM_STATE_DIR/disk.qcow2"
  if [ ! -f "$DISK" ]; then
    qemu-img create -f qcow2 "$DISK" 32G
  fi
fi

# Snapshot handling
if [[ -n "$SNAP_ACTION" ]]; then
  case "$SNAP_ACTION" in
    save)
      require qemu-img
      qemu-img snapshot -c "$SNAP_NAME" "$DISK"
      echo "snapshot $SNAP_NAME saved"; exit 0;;
    load)
      require qemu-img
      qemu-img snapshot -a "$SNAP_NAME" "$DISK"
      echo "snapshot $SNAP_NAME applied"; exit 0;;
    *) echo "Unknown snapshot action"; exit 1;;
  esac
fi

# profile mapping
case "$PROFILE" in
  iphone14|iphone14-pro)
    MACHINE_ARGS=( -machine virt,highmem=on )
    CPU_MODEL="cortex-a78"
    ;;
  iphone15)
    MACHINE_ARGS=( -machine virt,highmem=on )
    CPU_MODEL="cortex-a72"
    ;;
  ipadpro)
    MACHINE_ARGS=( -machine virt,highmem=on )
    CPU_MODEL="cortex-a72"
    ;;
  *) echo "Unknown profile"; exit 1;;
esac

# Build QEMU args
QEMU_ARGS=(
  -name "$NAME"
  "${MACHINE_ARGS[@]}"
  -cpu "$CPU_MODEL"
  -smp "$CPUS"
  -m "$MEM"
  -drive file="$DISK",if=none,id=hd0,format=qcow2,cache=none
  -device virtio-blk-device,drive=hd0
  -device virtio-net-device,netdev=net0
  -netdev user,id=net0,hostfwd=tcp::2222-:22
  -serial file:$LOG_FILE
)

if [ $HEADLESS -eq 0 ]; then
  QEMU_ARGS+=( $VNC_DISPLAY )
else
  QEMU_ARGS+=( -nographic )
fi

# EDK2 firmware (if found in ~/edk2-qemu)
if [ -f "$HOME/edk2-qemu/edk2/Build/QemuArm/RELEASE_GCC5/QemuArmPkg/SEC/SEC" ] || true; then
  # leave placeholder: users should build edk2 and point to firmware files
  :
fi

log "$0 starting qemu for $NAME, log=$LOG_FILE"
echo "Starting QEMU: ${QEMU_ARGS[*]}" >> "$LOG_FILE"

exec qemu-system-aarch64 "${QEMU_ARGS[@]}"
