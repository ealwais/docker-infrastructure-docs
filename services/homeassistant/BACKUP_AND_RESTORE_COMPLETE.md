# Backup Restore Documentation

*Consolidated on: 2025-08-27*

## Table of Contents

1. [Backup And Restore](#backup_and_restore)
2. [Backup And Restore Guide](#backup_and_restore_guide)
3. [Backup Recovery](#backup_recovery)

---

## Backup And Restore
*Source: BACKUP_AND_RESTORE.md*

## Understanding What Needs Backing Up

### Critical Components

1. **Configuration Files** (`/config/`)
   - `configuration.yaml` - Main configuration
   - `secrets.yaml` - API keys and passwords
   - `automations.yaml` - Automation rules
   - `scripts.yaml` - Script definitions
   - `scenes.yaml` - Scene configurations
   - `groups.yaml` - Group definitions
   - `customize.yaml` - Entity customizations

2. **UI-Configured Data** (`/config/.storage/`)
   - `core.config_entries` - ALL your integrations!
   - `core.device_registry` - Device configurations
   - `core.entity_registry` - Entity customizations
   - `auth` - User accounts
   - `homekit.*` - HomeKit configurations
   - `hacs.*` - HACS data
   - `lovelace.*` - UI dashboard configs

3. **Custom Components** (`/config/custom_components/`)
   - All HACS integrations
   - Manually installed integrations

4. **Media & Resources** (`/config/www/`)
   - Dashboard resources
   - Custom icons
   - Local images

## Backup Strategies

### Quick Integration Backup (Recommended Daily)
```bash
#!/bin/bash


BACKUP_FILE="/mnt/docker/homeassistant/backups/integrations_$(date +%Y%m%d_%H%M%S).tar.gz"


docker exec homeassistant tar -czf - \
  -C /config \
  .storage/core.config_entries \
  .storage/core.device_registry \
  .storage/core.entity_registry \
  .storage/auth* \
  .storage/hacs.* \
  .storage/homekit.* \
  secrets.yaml \
  configuration.yaml > "$BACKUP_FILE"

echo "Integration backup saved: $BACKUP_FILE"
```

### Complete System Backup (Weekly)
```bash
#!/bin/bash


BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/mnt/docker/homeassistant/backups/$BACKUP_DATE"

echo "Creating complete HA backup..."
mkdir -p "$BACKUP_DIR"





docker exec homeassistant tar -czf - \
  -C /config \
  --exclude='.cloud' \
  --exclude='*.log' \
  --exclude='*.log.*' \
  --exclude='*.db' \
  --exclude='*.db-*' \
  --exclude='__pycache__' \
  --exclude='deps' \
  --exclude='tts' \
  . > "$BACKUP_DIR/config_complete.tar.gz"




echo "Backup completed: $BACKUP_DIR"
```

### Automated Backup (Using HA Automation)
```yaml

shell_command:
  backup_integrations: |
    docker exec homeassistant tar -czf /config/backups/auto_$(date +%Y%m%d).tar.gz \
      -C /config .storage/core.* .storage/auth* .storage/hacs.* secrets.yaml

automation:
  - id: daily_backup
    alias: "Daily Integration Backup"
    trigger:
      - platform: time
        at: "03:00:00"
    action:
      - service: shell_command.backup_integrations
      - service: notify.persistent_notification
        data:
          title: "Backup Complete"
          message: "Daily integration backup completed"
```

## Restore Procedures

### Quick Restore (Most Common)
```bash
#!/bin/bash


BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: ./restore-integrations.sh <backup_file>"
    exit 1
fi

echo "Restoring integrations from $BACKUP_FILE..."


docker stop homeassistant


tar -xzf "$BACKUP_FILE" -C /mnt/docker/homeassistant/


docker start homeassistant

echo "Restore complete. HA starting..."
```

### Full System Restore
```bash
#!/bin/bash


BACKUP_DIR=$1

if [ -z "$BACKUP_DIR" ]; then
    echo "Usage: ./restore-complete.sh <backup_dir>"
    exit 1
fi


docker stop homeassistant


mv /mnt/docker/homeassistant /mnt/docker/homeassistant.before_restore


mkdir /mnt/docker/homeassistant


tar -xzf "$BACKUP_DIR/config_complete.tar.gz" -C /mnt/docker/homeassistant/


docker start homeassistant

echo "Full restore complete"
```

### Selective Restore (Just Integrations)
```bash

docker stop homeassistant
cd /mnt/docker/homeassistant
tar -xzf /path/to/backup.tar.gz .storage/
docker start homeassistant
```

## Disaster Recovery

### If HA Won't Start After Restore
1. Check logs:
   ```bash
   docker logs homeassistant
   ```

2. Check configuration:
   ```bash
   docker exec homeassistant hass --script check_config
   ```

3. Start in safe mode:
   ```bash
   docker run -it --rm \
     -v /mnt/docker/homeassistant:/config \
     ghcr.io/home-assistant/home-assistant:stable \
     hass --safe-mode
   ```

### Recovery Mode Prevention
Always keep a backup of `.storage` before major changes:
```bash

docker exec homeassistant cp -r /config/.storage /config/.storage.bak
```

### If Integrations Are Lost
1. Check if `.storage` exists
2. Restore from most recent integration backup
3. Restart Home Assistant
4. Re-add only missing integrations via UI

## Current Backup Status

### Existing Backups
- **Working Backup**: `/mnt/docker/homeassistant.backup_20250810_083925_WORKING`
- **Config Backup**: `/mnt/docker/homeassistant/backups/config_backup_20250810_075357.tar.gz`
- **Archived Backups**: `/mnt/docker/homeassistant_archive/backups/`

### Quick Commands
```bash

docker exec homeassistant cp -r /config/.storage /config/.storage.$(date +%Y%m%d_%H%M%S)


ls -la /mnt/docker/homeassistant/backups/
ls -la /mnt/docker/homeassistant.backup*
```

## Best Practices

### Do's ✅
- Backup before ANY major change
- Test restore procedure periodically
- Keep multiple backup versions
- Store critical backups off-site
- Document what each backup contains

### Don'ts ❌
- Don't delete `.storage` directory
- Don't restore while HA is running
- Don't mix backup versions
- Don't ignore backup failures
- Don't forget to backup secrets.yaml

## Backup Checklist
- [ ] Integration configurations (.storage)
- [ ] YAML configuration files
- [ ] Custom components
- [ ] Dashboard resources (www)
- [ ] Secrets file
- [ ] Automation/Script files
- [ ] SSL certificates (if applicable)
- [ ] Custom themes
- [ ] Documentation of setup

---

## Backup And Restore Guide
*Source: BACKUP_AND_RESTORE_GUIDE.md*

## Preserving All Integrations

### Understanding What Needs Backing Up

1. **YAML Configuration** (`/config/`)
   - configuration.yaml
   - secrets.yaml
   - packages/
   - dashboards (*.yaml)
   - automations.yaml, scripts.yaml, scenes.yaml

2. **UI Integrations** (`/config/.storage/`)
   - core.config_entries (ALL your integrations!)
   - core.device_registry (device configurations)
   - core.entity_registry (entity customizations)
   - auth (user accounts)
   - Integration-specific files (hacs.*, homekit.*, etc.)

3. **Custom Components** (`/config/custom_components/`)
   - HACS
   - All downloaded integrations

4. **Media/Resources** (`/config/www/`)
   - Community cards
   - Custom resources

### Complete Backup Script

```bash
#!/bin/bash


BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/mnt/docker/ha-backups/$BACKUP_DATE"

echo "Creating complete HA backup..."


mkdir -p "$BACKUP_DIR"





docker exec homeassistant tar -czf - \
  -C /config \
  --exclude='.cloud' \
  --exclude='*.log' \
  --exclude='*.db' \
  --exclude='*.db-*' \
  --exclude='__pycache__' \
  . > "$BACKUP_DIR/config_complete.tar.gz"


docker exec homeassistant tar -czf - \
  -C /config/.storage \
  core.config_entries \
  core.device_registry \
  core.entity_registry \
  auth \
  auth_provider.homeassistant \
  hacs.* \
  homekit.* > "$BACKUP_DIR/storage_critical.tar.gz"




echo "Backup completed: $BACKUP_DIR"
```

### Quick Integration-Only Backup

```bash
#!/bin/bash


BACKUP_FILE="/mnt/docker/homeassistant/backups/integrations_$(date +%Y%m%d_%H%M%S).tar.gz"


docker exec homeassistant tar -czf - \
  -C /config \
  .storage/core.config_entries \
  .storage/core.device_registry \
  .storage/core.entity_registry \
  .storage/auth* \
  .storage/hacs.* \
  secrets.yaml > "$BACKUP_FILE"

echo "Integration backup saved: $BACKUP_FILE"
```

### Restore Process

```bash
#!/bin/bash


BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: ./restore-ha.sh <backup_file>"
    exit 1
fi

echo "Restoring from $BACKUP_FILE..."


docker stop homeassistant


tar -xzf "$BACKUP_FILE" -C /mnt/docker/homeassistant/


docker start homeassistant

echo "Restore complete. HA starting..."
```

### Prevent Integration Loss - Best Practices

1. **Before ANY Major Change**:
   ```bash
   # Quick backup of integrations
   docker exec homeassistant cp -r /config/.storage /config/.storage.bak
   ```

2. **Regular Automated Backups**:
   ```yaml
   # Add to configuration.yaml
   shell_command:
     backup_integrations: |
       docker exec homeassistant tar -czf /config/backups/integrations_$(date +%Y%m%d).tar.gz \
         -C /config .storage/core.* .storage/auth* .storage/hacs.*
   
   automation:
     - id: daily_integration_backup
       alias: Daily Integration Backup
       trigger:
         - platform: time
           at: "03:00:00"
       action:
         - service: shell_command.backup_integrations
   ```

3. **Test Deployment Without Losing Integrations**:
   ```bash
   # Create test instance with COPY of .storage
   cp -r /mnt/docker/homeassistant /mnt/docker/ha-test
   
   # Run test instance
   docker run -d --name ha-test \
     -v /mnt/docker/ha-test:/config \
     -p 8124:8123 \
     ghcr.io/home-assistant/home-assistant:stable
   ```

### Recovery Mode Prevention

1. **Always Keep .storage Backup**:
   ```bash
   # Before restart
   docker exec homeassistant cp -r /config/.storage /config/.storage.pre-restart
   ```

2. **If HA Goes to Recovery Mode**:
   ```bash
   # Don't panic! Your integrations are safe
   # Check what's wrong
   docker logs homeassistant
   
   # Fix the issue (usually bad YAML)
   # Restore .storage if needed
   docker exec homeassistant cp -r /config/.storage.bak /config/.storage
   
   # Restart
   docker restart homeassistant
   ```

3. **Safe Configuration Testing**:
   ```bash
   # Check config before restart
   docker exec homeassistant hass --script check_config
   ```

### Your Current Backup

I already created:
- Full backup: `/mnt/docker/homeassistant.backup_20250810_075237`
- Config backup: `/mnt/docker/homeassistant/backups/config_backup_20250810_075357.tar.gz`

Let me also create an integration-specific backup now!

---

## Backup Recovery
*Source: BACKUP_RECOVERY.md*

## Backup Procedures

### 1. Configuration Backup

#### Claude Desktop Configuration
```bash

cp ~/Library/Application\ Support/Claude/claude_desktop_config.json \
   ~/Library/Application\ Support/Claude/claude_desktop_config.backup.$(date +%Y%m%d_%H%M%S).json


BACKUP_DIR="$HOME/ha-mcp-backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"
cp ~/Library/Application\ Support/Claude/claude_desktop_config.json "$BACKUP_DIR/"
echo "Backup created in: $BACKUP_DIR"
```

#### Save Critical Information
```bash

cat > ~/ha-mcp-backups/backup_info.txt << EOF
Home Assistant MCP Backup Information
Created: $(date)

Home Assistant URL: http://192.168.3.20:8123
MCP Server Port: 3000
Container Name (HA): homeassistant
Container Name (MCP): homeassistant-mcp

API Token:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJiNGExZTU4YjdjMjg0OTM4YTVhOWYxYjZmYjNjOTc3OCIsImlhdCI6MTc1NDM0NDYwMSwiZXhwIjoyMDY5NzA0NjAxfQ.UFZO4Wm_6E05VXLQxpK24a6adQzXLnrhZ77ecVFZ0uQ

Docker Images:
- HA: ghcr.io/home-assistant/home-assistant:stable
- MCP: homeassistant-homeassistant-mcp
EOF
```

### 2. Docker Configuration Backup

```bash

docker inspect homeassistant > ~/ha-mcp-backups/homeassistant_container.json
docker inspect homeassistant-mcp > ~/ha-mcp-backups/mcp_container.json


if [ -f /mnt/docker/homeassistant/docker-compose.yml ]; then
  cp /mnt/docker/homeassistant/docker-compose.yml ~/ha-mcp-backups/
fi
```

### 3. Full System Backup Script

```bash
#!/bin/bash


BACKUP_ROOT="$HOME/ha-mcp-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

echo "Creating Home Assistant MCP backup..."
mkdir -p "$BACKUP_DIR"


echo "Backing up configurations..."
cp ~/Library/Application\ Support/Claude/claude_desktop_config.json "$BACKUP_DIR/" 2>/dev/null
docker inspect homeassistant > "$BACKUP_DIR/homeassistant_container.json" 2>/dev/null
docker inspect homeassistant-mcp > "$BACKUP_DIR/mcp_container.json" 2>/dev/null


echo "Documenting system state..."
cat > "$BACKUP_DIR/system_state.txt" << EOF
Backup created: $(date)

Running Containers:
$(docker ps | grep -E "(homeassistant|mcp)")

MCP Health Check:
$(curl -s localhost:3000/health 2>/dev/null | jq . || echo "MCP not responding")

Home Assistant Status:
$(curl -s http://192.168.3.20:8123/api/ -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJiNGExZTU4YjdjMjg0OTM4YTVhOWYxYjZmYjNjOTc3OCIsImlhdCI6MTc1NDM0NDYwMSwiZXhwIjoyMDY5NzA0NjAxfQ.UFZO4Wm_6E05VXLQxpK24a6adQzXLnrhZ77ecVFZ0uQ" | jq -r .message 2>/dev/null || echo "HA not responding")

Claude MCP Processes:
$(ps aux | grep hass-mcp | grep -v grep || echo "No hass-mcp processes running")
EOF


cat > "$BACKUP_DIR/restore.sh" << 'EOF'
#!/bin/bash
echo "Restoring Home Assistant MCP configuration..."


if [ -f claude_desktop_config.json ]; then
  cp claude_desktop_config.json ~/Library/Application\ Support/Claude/
  echo "Claude config restored"
fi


echo "To restore Docker containers, run:"
echo "docker stop homeassistant homeassistant-mcp"
echo "Then recreate containers using the saved JSON configurations"

echo "Restart Claude Desktop to apply changes:"
echo "osascript -e 'quit app \"Claude\"' && open -a \"Claude\""
EOF

chmod +x "$BACKUP_DIR/restore.sh"

echo "Backup completed: $BACKUP_DIR"
echo "Total size: $(du -sh "$BACKUP_DIR" | cut -f1)"
```

## Recovery Procedures

### 1. Quick Recovery (Config Only)

```bash

ls -la ~/Library/Application\ Support/Claude/claude_desktop_config.backup.*


cp ~/Library/Application\ Support/Claude/claude_desktop_config.backup.20250806_120000.json \
   ~/Library/Application\ Support/Claude/claude_desktop_config.json


osascript -e 'quit app "Claude"' && sleep 2 && open -a "Claude"
```

### 2. Container Recovery

#### Recreate MCP Container
```bash

docker stop homeassistant-mcp
docker rm homeassistant-mcp


cd /path/to/docker-compose
docker-compose up -d homeassistant-mcp



```

#### Recreate Home Assistant Container
```bash

docker stop homeassistant
docker rm homeassistant


docker run -d \
  --name homeassistant \
  --restart=unless-stopped \
  -v /path/to/config:/config \
  -e TZ=America/New_York \
  --network=host \
  ghcr.io/home-assistant/home-assistant:stable
```

### 3. Full System Recovery

```bash
#!/bin/bash


echo "=== Home Assistant MCP Full Recovery ==="


echo "Stopping services..."
docker stop homeassistant homeassistant-mcp 2>/dev/null
pkill -f hass-mcp 2>/dev/null


LATEST_BACKUP=$(ls -dt ~/ha-mcp-backups/*/ | head -1)
echo "Using backup: $LATEST_BACKUP"


if [ -f "$LATEST_BACKUP/claude_desktop_config.json" ]; then
  cp "$LATEST_BACKUP/claude_desktop_config.json" ~/Library/Application\ Support/Claude/
  echo "Claude config restored"
fi


echo "Starting containers..."
docker start homeassistant
sleep 10
docker start homeassistant-mcp


echo "Restarting Claude Desktop..."
osascript -e 'quit app "Claude"'
sleep 2
open -a "Claude"


sleep 5
echo -e "\nVerifying services..."
docker ps | grep -E "(homeassistant|mcp)"
ps aux | grep hass-mcp | grep -v grep
curl -s localhost:3000/health | jq .status

echo -e "\nRecovery complete!"
```

### 4. Token Recovery

If API token is lost or expired:

```bash

open http://192.168.3.20:8123





NEW_TOKEN="your-new-token-here"
jq --arg token "$NEW_TOKEN" '.mcpServers["hass-mcp"].env.HA_TOKEN = $token' \
  ~/Library/Application\ Support/Claude/claude_desktop_config.json > /tmp/claude_config.json && \
  mv /tmp/claude_config.json ~/Library/Application\ Support/Claude/claude_desktop_config.json


osascript -e 'quit app "Claude"' && open -a "Claude"
```

## Disaster Recovery Checklist

- [ ] Stop all running services
- [ ] Locate most recent backup
- [ ] Restore Claude Desktop configuration
- [ ] Verify Home Assistant is accessible
- [ ] Recreate Docker containers if needed
- [ ] Update API token if expired
- [ ] Test MCP server connectivity
- [ ] Verify Claude Desktop integration
- [ ] Document any changes made

## Automated Backup Setup

### Create Daily Backup Cron Job
```bash

crontab -e


0 2 * * * /bin/bash ~/ha-mcp-backups/backup_ha_mcp.sh > ~/ha-mcp-backups/backup.log 2>&1


```

### Backup Retention Policy
```bash

find ~/ha-mcp-backups -type d -mtime +30 -exec rm -rf {} \;
```

## Important Files to Preserve

1. **Claude Config**: `~/Library/Application Support/Claude/claude_desktop_config.json`
2. **Docker Compose**: `/mnt/docker/homeassistant/docker-compose.yml`
3. **Documentation**: `/mnt/docker/homeassistant/*.md`
4. **API Token**: Keep secure copy of Home Assistant token
5. **Container Names**: homeassistant, homeassistant-mcp

Last Updated: 2025-08-06

---

