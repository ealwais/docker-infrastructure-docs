# Docker Desktop for macOS File Sync Issues

**Last Updated**: August 14, 2025  
**Affected System**: Home Assistant on Docker Desktop for macOS

## Issue Description

Files created or modified on the macOS host in `/mnt/docker/homeassistant/` are not immediately visible or updated inside the Home Assistant Docker container at `/config/`. This is a known limitation of Docker Desktop for macOS's file system implementation.

## Symptoms

- Dashboard YAML files not reflecting changes in UI
- New scripts not visible in container
- Configuration files not updating
- Integration scripts not found errors

## Root Cause

Docker Desktop for macOS uses a virtualization layer that can have delayed or missing file synchronization between the host filesystem and containers, especially with:
- Bind mounts
- File watchers
- Real-time file updates

## Workarounds

### 1. Direct Container File Creation
Instead of creating files on the host, create them directly in the container:

```bash
# Create file directly in container
docker exec -i homeassistant bash -c "cat > /config/filename.py" < host_file.py

# Or use docker cp
docker cp local_file.py homeassistant:/config/
```

### 2. Container Restart
Sometimes restarting the container forces a resync:

```bash
docker restart homeassistant
```

### 3. Docker Compose Recreate
For persistent issues, recreate the container:

```bash
docker-compose stop homeassistant
docker-compose up -d homeassistant
```

### 4. Use Environment Variables
For configuration values, use environment variables instead of files:

```bash
docker exec -d homeassistant bash -c "export VAR=value && python script.py"
```

## Specific Solutions Applied

### Integration Monitor
Created a simplified monitor script and copied directly into container:
```bash
# Copy script into container
docker exec -i homeassistant bash -c "cat > /config/monitor_integration.py" < monitor_integration.py

# Create .env file in container
docker exec homeassistant bash -c "echo -e 'HA_TOKEN=your_token\nHA_URL=http://localhost:8123' > /config/.env"

# Run with environment variables
docker exec -d homeassistant bash -c "export HA_TOKEN='token' && python3 /config/monitor_integration.py"
```

### MCP Container Fix
Updated `.env` file to use `host.docker.internal` instead of container names:
```
HASS_HOST=http://host.docker.internal:8123
HASS_BASE_URL=http://host.docker.internal:8123
HASS_SOCKET_URL=ws://host.docker.internal:8123/api/websocket
```

## Best Practices

1. **Test File Visibility**: Always verify files are visible in container before running scripts
2. **Use Container Exec**: For critical scripts, run them via `docker exec`
3. **Persistent Storage**: Store important data in Docker volumes rather than bind mounts
4. **Health Checks**: Implement health checks that don't rely on file system sync

## Alternative Solutions

### 1. Use Linux VM
Run Docker inside a Linux VM on macOS for better file system compatibility

### 2. Remote Docker Host
Use a dedicated Linux machine as Docker host

### 3. Docker Volumes
Use named volumes instead of bind mounts where possible:
```yaml
volumes:
  homeassistant_config:
    driver: local
```

## Monitoring File Sync

Check if files are synced:
```bash
# List files on host
ls -la /mnt/docker/homeassistant/scripts/

# List files in container
docker exec homeassistant ls -la /config/scripts/

# Compare timestamps
docker exec homeassistant stat /config/configuration.yaml
```

## Related Issues

- Dashboard configuration not updating
- HACS components not loading
- Custom scripts not found
- Integration configurations not applying

## References

- [Docker Desktop for Mac known issues](https://docs.docker.com/desktop/troubleshoot/known-issues/)
- [File sharing performance on macOS](https://docs.docker.com/desktop/mac/#file-sharing)