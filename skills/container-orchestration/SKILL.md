---
name: container-orchestration
description: "Docker Compose management for KDA-CE devnet containers. Multi-container configuration, networking, volume management, and cross-container communication."
---
# Container Orchestration

## Docker Compose Template
```yaml
version: "3.8"
services:
  devnet:
    image: kadena/devnet:latest
    ports:
      - "{host_port}:8080"
    volumes:
      - devnet-data:/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/info"]
      interval: 10s
      timeout: 5s
      retries: 12
    restart: unless-stopped

volumes:
  devnet-data:
```

## Networking
- Docker bridge network: `172.19.0.1` (Linux default)
- Host-to-container: `localhost:{host_port}`
- Container-to-host: `172.19.0.1:{service_port}` (Linux)
- Cross-container: use service name as hostname

## Volume Management
- Named volumes for persistent data
- `docker compose down -v` to reset (removes volumes)
- Mount config files for custom node configuration

## Resource Considerations
- Each KDA-CE devnet container uses ~500MB RAM
- CPU usage spikes during mining catch-up
- 3 simultaneous devnets: ~1.5GB RAM minimum
