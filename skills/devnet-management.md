---
name: devnet-management
description: "Docker devnet orchestration for KDA-CE. Container lifecycle, port management, health checks, and devnet reset procedures for development and testing."
---
# Devnet Management

## Container Configuration
Port: 8081 (default). Configurable via `DEVNET_HOST` env var.
Compose file: `docker-compose.yml` in project root.

## Lifecycle Commands
```bash
# Start devnet
docker compose up -d

# Check health
curl http://localhost:8081/info

# View logs
docker compose logs -f

# Reset (clean state)
docker compose down -v && docker compose up -d

# Stop
docker compose down
```

## Health Check
```typescript
async function waitForDevnet(port: number, timeout = 120_000) {
  const start = Date.now();
  while (Date.now() - start < timeout) {
    try {
      const res = await fetch(`http://localhost:${port}/info`);
      if (res.ok) return;
    } catch {}
    await new Promise(r => setTimeout(r, 2000));
  }
  throw new Error('Devnet failed to start');
}
```

## Fresh Devnet Timing
- Genesis blocks have 2019 timestamps
- Mining client catches up to wall clock in ~10-20 seconds
- Wait for chain time to be within 5 minutes of wall clock before deploying
