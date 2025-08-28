# Home Assistant System Health and Monitoring Guide
**Created**: August 15, 2025  
**Purpose**: Document system setup, health checks, and recovery procedures

## Table of Contents
1. [System Overview](#system-overview)
2. [Health Check Procedures](#health-check-procedures)
3. [Common Issues and Fixes](#common-issues-and-fixes)
4. [Recovery Procedures](#recovery-procedures)
5. [Monitoring Scripts](#monitoring-scripts)
6. [MCP Server Setup](#mcp-server-setup)

## System Overview

### Architecture
```
┌─────────────────┐     ┌──────────────┐     ┌─────────────┐
│   Claude App    │────▶│  MCP Server  │────▶│    Home     │
│  (Desktop App)  │     │ (Port 3000)  │     │  Assistant  │
└─────────────────┘     └──────────────┘     │ (Port 8123) │
                                              └─────────────┘
                                                     │
┌─────────────────┐                                  │
│    ser2net      │──────────────────────────────────┘
│  (Port 9999)    │                         (Zigbee via TCP)
└─────────────────┘
```

### Critical Services
| Service | Type | Port | Purpose |
|---------|------|------|---------|
| homeassistant | Docker | 8123 | Main HA instance |
| homeassistant-mcp | Docker | 3000 | Claude AI bridge |
| ser2net | macOS | 9999 | Zigbee USB proxy |
| matter-server | Docker | - | Matter/Thread |
| mosquitto | Docker | 1883 | MQTT broker |
| portainer | Docker | 9001 | Docker management |
| integration_monitor | Python | - | Auto-heals failed integrations |

### File Locations
- **Config**: `/mnt/docker/homeassistant/`
- **Backups**: `/mnt/docker/homeassistant.backup_20250810_083925_WORKING`
- **Logs**: `/mnt/docker/homeassistant/logs/`
- **Claude Config**: `~/Library/Application Support/Claude/claude_desktop_config.json`

## Health Check Procedures

### 1. Quick System Health Check
Run this command to check all services at once:

```bash
#!/bin/bash
# Save as: /mnt/docker/homeassistant/scripts/system_health_check.sh

echo "=== Home Assistant System Health Check ==="
echo "Date: $(date)"
echo ""

# Check Docker containers
echo "1. Docker Services:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|homeassistant|mcp|mosquitto|matter|portainer"
echo ""

# Check Home Assistant API
echo "2. Home Assistant API:"
if curl -s http://localhost:8123/api/ > /dev/null 2>&1; then
    echo "   ✅ API responding"
else
    echo "   ❌ API not responding"
fi

# Check MCP Server
echo ""
echo "3. MCP Server:"
if curl -s http://localhost:3000/health | grep -q "ok"; then
    echo "   ✅ MCP healthy"
else
    echo "   ❌ MCP not healthy"
fi

# Check ser2net
echo ""
echo "4. Zigbee/ser2net:"
if ps aux | grep -v grep | grep -q ser2net; then
    echo "   ✅ ser2net running"
    echo "   Port 9999 connections: $(netstat -an | grep 9999 | grep ESTABLISHED | wc -l)"
else
    echo "   ❌ ser2net not running"
fi

# Check for errors
echo ""
echo "5. Recent Errors:"
docker logs homeassistant 2>&1 | grep -i error | tail -5 | wc -l | xargs echo "   Error count (last 5):"

echo ""
echo "=== Health Check Complete ==="
```

### 2. Detailed Component Checks

#### Check Home Assistant
```bash
# Status
docker logs homeassistant --tail 50 2>&1 | grep -E "Started Home Assistant|ERROR|WARNING"

# Configuration validity
docker exec homeassistant python -m homeassistant --script check_config

# Integration status
bash /mnt/docker/homeassistant/scripts/check_integrations.sh
```

#### Check MCP Server
```bash
# Health endpoint
curl -s http://localhost:3000/health | jq .

# Logs
docker logs homeassistant-mcp --tail 30

# Environment
docker exec homeassistant-mcp env | grep -E "HA_|HASS" | sed 's/TOKEN=.*/TOKEN=***/'
```

#### Check Zigbee (ser2net)
```bash
# Process
ps aux | grep ser2net

# Port status
lsof -i :9999

# USB device
ls -la /dev/tty.usbserial* /dev/cu.usbserial*
```

## Common Issues and Fixes

### Issue 1: MCP Server Connection Failed
**Symptoms**: 
- Claude can't connect to Home Assistant
- MCP logs show "ECONNREFUSED"

**Fix Applied (Aug 15, 2025)**:
```bash
# 1. Update environment file
cat > /mnt/docker/homeassistant/homeassistant-mcp/.env << EOF
NODE_ENV=production
HASS_HOST=http://192.168.3.20:8123
HASS_TOKEN=YOUR_TOKEN_HERE
HA_TOKEN=YOUR_TOKEN_HERE
HASS_BASE_URL=http://192.168.3.20:8123
PORT=3000
HASS_SOCKET_URL=ws://192.168.3.20:8123/api/websocket
LOG_LEVEL=info
EOF

# 2. Update docker-compose.yaml to include environment overrides
# Added environment section with correct IPs

# 3. Restart container
docker-compose -f /mnt/docker/homeassistant/docker-compose.yaml up -d homeassistant-mcp
```

### Issue 2: Dashboard Sync Issues
**Symptoms**: Dashboard YAML changes don't appear in UI

**Workaround**:
```bash
# Copy files directly into container
docker cp dashboard_file.yaml homeassistant:/config/
docker exec homeassistant chown root:root /config/dashboard_file.yaml
```

### Issue 3: Zigbee Connection Lost
**Symptoms**: Zigbee devices unavailable

**Fix**:
```bash
# Restart ser2net
sudo killall ser2net
ser2net -n &

# Verify USB device
ls -la /dev/tty.SLAB_USBtoUART
```

### Issue 4: Integration Errors
**Symptoms**: "Session is closed" errors

**Fix**:
```bash
# Start integration monitor
bash /mnt/docker/homeassistant/scripts/start_monitor.sh
```

## Recovery Procedures

### Full System Recovery
```bash
# 1. Stop all services
docker-compose -f /mnt/docker/homeassistant/docker-compose.yaml down

# 2. Restore from backup
sudo rm -rf /mnt/docker/homeassistant/*
sudo cp -r /mnt/docker/homeassistant.backup_20250810_083925_WORKING/* /mnt/docker/homeassistant/

# 3. Start services
docker-compose -f /mnt/docker/homeassistant/docker-compose.yaml up -d

# 4. Start ser2net
ser2net -n &
```

### Partial Recovery (Config Only)
```bash
# Restore configuration.yaml
cp /mnt/docker/homeassistant/configuration.yaml.backup /mnt/docker/homeassistant/configuration.yaml

# Restart Home Assistant
docker restart homeassistant
```

## Monitoring Scripts

### Create Automated Health Monitor
```bash
#!/bin/bash
# Save as: /mnt/docker/homeassistant/scripts/continuous_monitor.sh

LOG_FILE="/mnt/docker/homeassistant/logs/health_monitor.log"

while true; do
    echo "=== Health Check: $(date) ===" >> $LOG_FILE
    
    # Check containers
    UNHEALTHY=$(docker ps --filter "health=unhealthy" --format "{{.Names}}" | wc -l)
    if [ $UNHEALTHY -gt 0 ]; then
        echo "WARNING: $UNHEALTHY unhealthy containers" >> $LOG_FILE
        docker ps --filter "health=unhealthy" >> $LOG_FILE
    fi
    
    # Check APIs
    for url in "http://localhost:8123/api/" "http://localhost:3000/health"; do
        if ! curl -s $url > /dev/null 2>&1; then
            echo "ERROR: $url not responding" >> $LOG_FILE
        fi
    done
    
    # Check disk space
    DISK_USAGE=$(df -h /mnt/docker | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ $DISK_USAGE -gt 80 ]; then
        echo "WARNING: Disk usage at $DISK_USAGE%" >> $LOG_FILE
    fi
    
    sleep 300  # Check every 5 minutes
done
```

### Dashboard Status Reporter
```bash
#!/bin/bash
# Save as: /mnt/docker/homeassistant/scripts/dashboard_status.sh

echo "=== Dashboard Status Report ==="
echo ""

# List all dashboards
echo "Configured Dashboards:"
grep -A5 "dashboards:" /mnt/docker/homeassistant/configuration.yaml | grep -E "filename:|title:"

echo ""
echo "Dashboard Files:"
ls -la /mnt/docker/homeassistant/dashboard_*.yaml | wc -l | xargs echo "Total dashboard files:"

echo ""
echo "Recent Dashboard Errors:"
docker logs homeassistant 2>&1 | grep -i dashboard | grep -i error | tail -5
```

## MCP Server Setup

### Configuration Files

#### 1. Docker Environment (.env)
Location: `/mnt/docker/homeassistant/homeassistant-mcp/.env`
```env
NODE_ENV=production
HASS_HOST=http://192.168.3.20:8123
HASS_TOKEN=YOUR_LONG_LIVED_TOKEN
HA_TOKEN=YOUR_LONG_LIVED_TOKEN
HASS_BASE_URL=http://192.168.3.20:8123
PORT=3000
HASS_SOCKET_URL=ws://192.168.3.20:8123/api/websocket
LOG_LEVEL=info
```

#### 2. Claude Desktop Config
Location: `~/Library/Application Support/Claude/claude_desktop_config.json`
```json
{
  "mcpServers": {
    "homeassistant": {
      "command": "npx",
      "args": [
        "-y",
        "@automatalabs/mcp-server-home-assistant@latest"
      ],
      "env": {
        "HOMEASSISTANT_API_KEY": "YOUR_LONG_LIVED_TOKEN",
        "HOMEASSISTANT_BASE_URL": "http://192.168.3.20:8123"
      }
    }
  }
}
```

### Testing MCP Connection
```bash
# Test from command line
curl -s http://localhost:3000/health

# Test Home Assistant API
curl -s http://192.168.3.20:8123/api/ \
  -H "Authorization: Bearer YOUR_TOKEN" | jq .

# Check MCP logs
docker logs homeassistant-mcp --tail 50
```

## Startup Checklist

After system restart, verify:

- [ ] Docker Desktop is running
- [ ] All containers are healthy: `docker ps`
- [ ] Home Assistant UI loads: http://192.168.3.20:8123
- [ ] ser2net is running: `ps aux | grep ser2net`
- [ ] MCP health check passes: `curl http://localhost:3000/health`
- [ ] No critical errors in logs
- [ ] Claude Desktop has MCP configured

## Troubleshooting Commands

```bash
# View all logs
docker-compose logs -f

# Restart everything
docker-compose restart

# Check resource usage
docker stats

# Find configuration errors
docker exec homeassistant python -m homeassistant --script check_config

# Test network connectivity
docker exec homeassistant ping -c 1 192.168.3.20

# Clear caches
bash /mnt/docker/homeassistant/scripts/clear_dashboard_cache.sh
```

## Important Notes

1. **Never delete `.storage/`** - Contains all UI-configured integrations
2. **Always backup before major changes**
3. **ser2net runs on macOS**, not in Docker
4. **Use port 9999 for Zigbee**, not 3333
5. **Dashboard changes require container file sync workaround**

---
*Last Updated: August 15, 2025*