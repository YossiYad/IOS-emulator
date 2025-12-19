#!/usr/bin/env bash
set -euo pipefail

# Master install script for Silicon iOS Emulator
# Intended for: curl -sSL <repo>/install.sh | sudo bash

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
LOG=/var/log/silicon-emulator-install.log
mkdir -p /var/log/silicon-emulator
exec > >(tee -a "$LOG") 2>&1

echo "Starting installer: $(date -Is)"

require(){ command -v "$1" >/dev/null 2>&1 || { echo "required: $1"; exit 2; } }

echo "1) Running advanced setup (packages, edk2 scaffolding, disk image)"
bash "$REPO_ROOT/linux-emulator-server/src/scripts/advanced-setup.sh"

echo "2) Create emulator user and directories"
id -u emulator_user >/dev/null 2>&1 || sudo useradd -m -s /bin/bash emulator_user || true
sudo mkdir -p /var/lib/silicon-emulator /var/log/silicon-emulator /workspaces
sudo chown -R emulator_user:emulator_user /var/lib/silicon-emulator /var/log/silicon-emulator /workspaces

echo "3) Build Go manager"
if ! command -v go >/dev/null 2>&1; then
  echo "Go not found, installing..."
  # Minimal install for Debian/Ubuntu
  if [ -f /etc/debian_version ]; then
    apt-get update
    apt-get install -y golang-go
  else
    echo "Please install Go manually"; exit 1
  fi
fi
cd "$REPO_ROOT/linux-emulator-server"
go build -o ./cmd/manager/manager ./cmd/manager

echo "4) Build web UI (React)"
if ! command -v npm >/dev/null 2>&1; then
  echo "npm not found, installing nodejs..."
  if [ -f /etc/debian_version ]; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
  else
    echo "Please install Node.js/npm manually"; exit 1
  fi
fi
cd "$REPO_ROOT/linux-emulator-server/src/ui/web"
npm ci --prefer-offline --no-audit
npm run build

echo "5) Install systemd service and enable"
SERVICE_SRC="$REPO_ROOT/linux-emulator-server/configs/systemd/silicon-emulator.service"
SERVICE_DST="/etc/systemd/system/silicon-emulator.service"
sudo cp "$SERVICE_SRC" "$SERVICE_DST"
sudo systemctl daemon-reload
sudo systemctl enable --now silicon-emulator.service || true

echo "6) Start manager as system service"
MANAGER_SERVICE="/etc/systemd/system/silicon-emulator-manager.service"
cat <<'EOF' | sudo tee "$MANAGER_SERVICE" >/dev/null
[Unit]
Description=Silicon Emulator Manager
After=network.target

[Service]
Type=simple
User=emulator_user
WorkingDirectory=/workspaces/silicon-emulator
ExecStart=/workspaces/silicon-M1-Apple-emulator/linux-emulator-server/cmd/manager/manager
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now silicon-emulator-manager.service || true

echo "7) Serve web UI (static build) via systemd using npx serve"
WEB_SERVICE="/etc/systemd/system/silicon-emulator-web.service"
cat <<'EOF' | sudo tee "$WEB_SERVICE" >/dev/null
[Unit]
Description=Silicon Emulator Web UI
After=network.target

[Service]
Type=simple
User=emulator_user
WorkingDirectory=/workspaces/silicon-M1-Apple-emulator/linux-emulator-server/src/ui/web
ExecStart=/usr/bin/env npx serve -s build -l 8080
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now silicon-emulator-web.service || true

echo "Installation complete. UI: http://$(hostname -I | awk '{print $1}'):8080, Manager API: http://localhost:8080"
echo "VNC: connect to <host>:5900 for headless VM display"
echo "Logs: /var/log/silicon-emulator"
