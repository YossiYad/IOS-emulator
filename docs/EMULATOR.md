# Silicon M1 iOS Emulator — Enhanced Setup

This document describes the enhanced setup, run scripts, manager API, Docker and Kubernetes manifests added to the repository.

Quick start (dev container / Ubuntu):

1. Run the advanced setup (installs dependencies and prepares edk2):

```bash
sudo bash linux-emulator-server/src/scripts/advanced-setup.sh
```

2. Build manager binary (from repo root):

```bash
cd linux-emulator-server
go build -o cmd/manager/manager ./cmd/manager
```

3. Start manager locally:

```bash
./cmd/manager/manager
```

4. Start a VM via API:

```bash
curl -X POST -H "Content-Type: application/json" -d '{"name":"testvm","args":["--profile","iphone14"]}' http://localhost:8080/api/v1/vm/start
```

5. Stream logs with WebSocket (example in JavaScript):

```js
const ws = new WebSocket('ws://localhost:8080/api/v1/ws/logs?name=testvm');
ws.onmessage = e => console.log(e.data);
```

Docker:

```bash
docker compose -f docker-compose.qemu.yml up --build
```

Kubernetes:

```bash
kubectl apply -f infra/k8s/deployment.yaml
kubectl apply -f infra/k8s/service.yaml
kubectl apply -f infra/k8s/hpa.yaml
```

Notes & security:
- Logs and VM images are stored under `/var/log/silicon-emulator` and `/var/lib/silicon-emulator` by default — ensure proper permissions and backups.
- The manager runs system commands and spawns QEMU processes; run it with limited privileges or in containers.
- For production, use non-root users, secure websockets, and put the manager behind an authenticated API gateway.
