# Home Assistant Docker Path Mapping Clarification

**Created**: August 16, 2025
**Purpose**: Resolve confusion about Docker and host system path mappings

## 🚨 CRITICAL FINDING: File Sync is BROKEN

**Testing on August 16, 2025 revealed that the volume mount is NOT working correctly:**
- Files created in the container at `/config/` do NOT appear on the host at `/mnt/docker/homeassistant/`
- Files created on the host at `/mnt/docker/homeassistant/` do NOT appear in the container at `/config/`

This is a critical issue that affects all configuration changes!

## Current Path Mappings (As Configured)

| Purpose | Container Path | Host Path | Status | Notes |
|---------|---------------|-----------|--------|-------|
| Main Config | `/config` | `/mnt/docker/homeassistant/` | ❌ NOT SYNCING | Volume mount appears broken |
| Timezone | `/etc/localtime` | `/etc/localtime` | ✅ Read-only | System time sync |
| Matter Config | `/config` | `/mnt/docker/homeassistant/matter` | ❓ Unknown | Matter server container |
| Docker Socket | `/var/run/docker.sock` | `/var/run/docker.sock` | ✅ Working | Portainer access |
| Portainer Data | `/data` | `portainer_data` (volume) | ✅ Working | Named volume |
| MQTT Data | `/mosquitto/data` | `/mnt/docker/mosquitto/data` | ❓ Unknown | Mosquitto broker |
| MQTT Logs | `/mosquitto/log` | `/mnt/docker/mosquitto/log` | ❓ Unknown | Mosquitto logs |

## The Confusion Explained

### 1. Documentation References
- **Container documentation** refers to `/config/` (the container's internal path)
- **Host documentation** refers to `/mnt/docker/homeassistant/` (the macOS filesystem path)
- **Both should be the same files** due to the volume mount, but they're NOT syncing

### 2. Why This Happens on macOS
Docker Desktop for macOS runs containers inside a Linux VM, causing:
- File system events not propagating between host and container
- Cache inconsistencies
- Permission/ownership mismatches
- Delayed or missing synchronization

### 3. Multiple Docker Environments
Different Docker hosts in your infrastructure use different paths:
- **Mac Mini** (192.168.3.20): `/mnt/docker/homeassistant/` → `/config`
- **Docker Server** (192.168.3.11): Different host paths
- **QNAP NAS** (192.168.3.10): Container Station paths
- **Synology NAS** (192.168.3.120): Docker Package paths

## Current Workarounds

### ✅ WORKING: Direct Container Operations
```bash
# Copy files directly into the container
docker cp dashboard.yaml homeassistant:/config/

# Execute commands inside the container
docker exec homeassistant bash -c "echo 'content' > /config/file.txt"

# Use docker exec with input redirection
docker exec -i homeassistant bash -c "cat > /config/file.py" < host_file.py
```

### ✅ WORKING: Container Restart Force Sync
```bash
# Sometimes restarting forces a resync
docker restart homeassistant

# Or recreate the container
docker-compose down homeassistant
docker-compose up -d homeassistant
```

## Common Pitfalls to Avoid

⚠️ **DON'T** edit files on the host expecting immediate container updates
⚠️ **DON'T** rely on file watchers or hot-reload features
⚠️ **DON'T** mount overlapping paths (e.g., `/config` and `/config/www`)
⚠️ **DON'T** use relative paths in configuration files

## Visual Path Relationship

```
macOS Host System                    Docker Container
─────────────────                    ────────────────
                                     
/mnt/docker/                         (Docker VM Layer)
  └── homeassistant/  ───❌───>      /config/
      ├── configuration.yaml         ├── configuration.yaml
      ├── secrets.yaml               ├── secrets.yaml
      ├── automations.yaml           ├── automations.yaml
      └── custom_components/         └── custom_components/

❌ = Sync is BROKEN (as of Aug 16, 2025)
```

## Immediate Actions Required

1. **For Configuration Changes**: Use `docker cp` or `docker exec`
2. **For Dashboard Updates**: Copy YAML files directly into container
3. **For Script Execution**: Run scripts via `docker exec`
4. **For Debugging**: Always verify file presence in BOTH locations

## Long-term Solutions

1. **Option 1**: Switch to Linux host (eliminates macOS Docker Desktop issues)
2. **Option 2**: Use Docker volumes instead of bind mounts
3. **Option 3**: Implement file sync daemon to manually sync changes
4. **Option 4**: Use remote Docker host on Linux server

## Testing Commands

```bash
# Test if sync is working (it's not as of Aug 16, 2025)
echo "test" > /mnt/docker/homeassistant/test.txt
docker exec homeassistant cat /config/test.txt  # Will fail

# Correct way to add files
echo "test" | docker exec -i homeassistant bash -c "cat > /config/test.txt"
docker exec homeassistant cat /config/test.txt  # Will work
```

## References

- [Docker Desktop for Mac Known Issues](https://docs.docker.com/desktop/troubleshoot/known-issues/)
- Local Documentation: `/mnt/docker/homeassistant/docs/troubleshooting/DOCKER_SYNC_ISSUES.md`
- System Status: `/mnt/docker/homeassistant/docs/CURRENT_STATUS.md`
