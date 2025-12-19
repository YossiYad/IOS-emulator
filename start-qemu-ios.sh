#!/usr/bin/env bash
set -euo pipefail

LOG=/var/log/qemu-ios-emulator.log
mkdir -p /var/log/qemu-ios-emulator
sudo chown $(id -u):$(id -g) /var/log/qemu-ios-emulator || true

echo "Starting QEMU iOS Emulator components. Logs -> $LOG"

# Build manager
cd linux-emulator-server
echo "Building manager..."
go build -o ./cmd/manager/manager ./cmd/manager || true

# Start manager (runs on port 3001 to avoid conflict)
( MANAGER_PORT=3001 ./cmd/manager/manager >> "$LOG" 2>&1 & )
echo "Manager started (PID $!)"

# Start web UI (serve static build) on port 8080
if [ -d "src/ui/web/build" ]; then
  ( cd src/ui/web && npx serve -s build -l 8080 >> "$LOG" 2>&1 & )
  echo "Web UI started on :8080"
else
  echo "Web UI build not found; skip starting web UI" >> "$LOG"
fi

# Start emulator (default iPhone 14 Pro, VNC :0 -> port 5900)
cd - >/dev/null || true
( bash linux-emulator-server/src/scripts/enhanced-run.sh --name default --profile iphone14-pro --vnc :0 --headless >> "$LOG" 2>&1 & )
echo "Emulator starting (VNC -> :0 -> port 5900)"

echo "All start commands issued. Tail the log with: tail -F $LOG"
