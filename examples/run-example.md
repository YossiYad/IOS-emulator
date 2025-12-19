# Example: Start an iOS VM and connect

1. Ensure manager is running (see docs).
2. Start VM via API:

```bash
curl -X POST -H "Content-Type: application/json" -d '{"name":"iphone-test","args":["--profile","iphone14","--memory","6G","--cpus","4"]}' http://localhost:8080/api/v1/vm/start
```

3. Connect to VNC on display :1 (port 5901) or use SSH forwarded to host port 2222.
