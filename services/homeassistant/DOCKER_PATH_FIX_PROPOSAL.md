# Docker Path Synchronization Fix Proposal

**Date**: August 16, 2025
**Issue**: Volume mounts not syncing between host and containers on macOS

## Recommended Solutions (In Order of Preference)

### Solution 1: Use Named Docker Volumes (RECOMMENDED)
Convert bind mounts to named volumes for better reliability on macOS.

#### Updated docker-compose.yaml:
```yaml
services:
  homeassistant:
    container_name: homeassistant
    image: ghcr.io/home-assistant/home-assistant:stable
    network_mode: host
    volumes:
      - homeassistant_config:/config  # Named volume instead of bind mount
      - /etc/localtime:/etc/localtime:ro
    environment:
      - TZ=America/Chicago
    restart: unless-stopped

volumes:
  homeassistant_config:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /mnt/docker/homeassistant
```

### Solution 2: Use Docker-Sync for macOS
Install docker-sync to handle file synchronization properly.

```bash
# Install docker-sync
gem install docker-sync

# Create docker-sync.yml
cat > docker-sync.yml << 'SYNC'
version: "2"
syncs:
  homeassistant-sync:
    src: '/mnt/docker/homeassistant'
    sync_strategy: 'native_osx'
SYNC

# Start sync
docker-sync start
```

### Solution 3: Switch to Colima with VirtioFS
Replace Docker Desktop with Colima using VirtioFS for better performance.

```bash
# Install Colima
brew install colima

# Start Colima with VirtioFS
colima start --mount-type virtiofs --mount /mnt/docker/homeassistant:/mnt/docker/homeassistant

# Update DOCKER_HOST
export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
```

### Solution 4: Use a Linux Docker Host
Move Home Assistant to the Linux Docker server at 192.168.3.11.

```bash
# On Linux server (192.168.3.11)
# Copy configuration
scp -r user@192.168.3.20:/mnt/docker/homeassistant /docker/homeassistant

# Run with proper mounts
docker run -d \
  --name homeassistant \
  --network=host \
  -v /docker/homeassistant:/config \
  -e TZ=America/Chicago \
  --restart unless-stopped \
  ghcr.io/home-assistant/home-assistant:stable
```

## Immediate Workaround Scripts

### 1. File Sync Helper Script
```bash
#!/bin/bash
# save as: /mnt/docker/homeassistant/scripts/sync_to_container.sh

FILE=$1
if [ -z "$FILE" ]; then
  echo "Usage: $0 <file_to_sync>"
  exit 1
fi

echo "Syncing $FILE to container..."
docker cp "$FILE" homeassistant:/config/
docker restart homeassistant
echo "Sync complete and Home Assistant restarted"
```

### 2. Configuration Update Script
```bash
#!/bin/bash
# save as: /mnt/docker/homeassistant/scripts/update_config.sh

echo "Updating Home Assistant configuration..."

# Copy all YAML files
for file in *.yaml; do
  if [ -f "$file" ]; then
    echo "Copying $file..."
    docker cp "$file" homeassistant:/config/
  fi
done

# Copy directories
for dir in custom_components packages lovelace; do
  if [ -d "$dir" ]; then
    echo "Copying $dir/..."
    docker cp "$dir" homeassistant:/config/
  fi
done

echo "Restarting Home Assistant..."
docker restart homeassistant
echo "Configuration update complete"
```

### 3. Automated Sync Daemon
```bash
#!/bin/bash
# save as: /mnt/docker/homeassistant/scripts/sync_daemon.sh

WATCH_DIR="/mnt/docker/homeassistant"
CONTAINER="homeassistant"

echo "Starting sync daemon for $WATCH_DIR..."

fswatch -o "$WATCH_DIR" | while read f; do
  echo "Change detected, syncing..."
  
  # Sync changed files
  rsync -av --delete \
    --exclude '.git' \
    --exclude '*.log' \
    --exclude '__pycache__' \
    "$WATCH_DIR/" temp_sync/
  
  # Copy to container
  docker cp temp_sync/. "$CONTAINER:/config/"
  
  echo "Sync complete at $(date)"
done
```

## Best Practice Guidelines

### Directory Structure
```
/mnt/docker/                    # Standard Docker data location
├── homeassistant/              # Home Assistant config
│   ├── configuration.yaml      # Main config
│   ├── secrets.yaml            # Secrets (git-ignored)
│   ├── custom_components/      # HACS components
│   ├── packages/               # Package configurations
│   ├── www/                    # Static files
│   └── backups/                # Local backups
├── homeassistant_data/         # Persistent data (if using volumes)
└── mosquitto/                  # MQTT broker data
```

### Configuration Management
1. **Use packages** for modular configuration
2. **Use secrets.yaml** for sensitive data
3. **Use git** for version control (exclude secrets)
4. **Use includes** to split large configs

### File Operations
```bash
# Always verify file location
docker exec homeassistant ls -la /config/

# Use docker cp for file transfers
docker cp local_file.yaml homeassistant:/config/

# Edit files inside container if needed
docker exec -it homeassistant vi /config/configuration.yaml

# Validate configuration before restart
docker exec homeassistant hass --script check_config
```

## Monitoring Script
```bash
#!/bin/bash
# save as: /mnt/docker/homeassistant/scripts/check_sync_status.sh

echo "=== Sync Status Check ==="
echo "Date: $(date)"
echo ""

# Create test file on host
TEST_FILE="sync_test_$(date +%s).txt"
echo "test" > "/mnt/docker/homeassistant/$TEST_FILE"

# Check in container
if docker exec homeassistant test -f "/config/$TEST_FILE" 2>/dev/null; then
  echo "✅ Host → Container sync: WORKING"
  docker exec homeassistant rm "/config/$TEST_FILE"
else
  echo "❌ Host → Container sync: BROKEN"
fi

# Create test file in container
docker exec homeassistant touch "/config/${TEST_FILE}_container"

# Check on host
if [ -f "/mnt/docker/homeassistant/${TEST_FILE}_container" ]; then
  echo "✅ Container → Host sync: WORKING"
  rm "/mnt/docker/homeassistant/${TEST_FILE}_container"
else
  echo "❌ Container → Host sync: BROKEN"
fi

# Cleanup
rm -f "/mnt/docker/homeassistant/$TEST_FILE"
docker exec homeassistant rm -f "/config/${TEST_FILE}_container" 2>/dev/null

echo ""
echo "=== Current Workaround ==="
echo "Use: docker cp <file> homeassistant:/config/"
echo "Or: docker exec for direct container operations"
```

## Migration Checklist

- [ ] Backup current configuration
- [ ] Choose solution (1-4 above)
- [ ] Test solution with non-critical files
- [ ] Implement automated sync if needed
- [ ] Update documentation
- [ ] Train team on new procedures
- [ ] Monitor for issues

## References

- [Docker Desktop File Sharing Issues](https://docs.docker.com/desktop/mac/#file-sharing)
- [Colima Documentation](https://github.com/abiosoft/colima)
- [Docker-Sync Documentation](https://docker-sync.readthedocs.io/)
