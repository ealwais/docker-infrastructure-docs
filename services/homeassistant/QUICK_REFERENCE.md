# Home Assistant Quick Reference Card

## 🚀 Quick Commands

### Check System Health
```bash
bash /mnt/docker/homeassistant/scripts/system_health_check.sh
```

### View Logs
```bash
# Home Assistant logs
docker logs homeassistant --tail 50 -f

# MCP server logs
docker logs homeassistant-mcp --tail 50 -f

# All containers
docker-compose logs -f
```

### Restart Services
```bash
# Restart Home Assistant only
docker restart homeassistant

# Restart all services
docker-compose restart

# Restart MCP server
docker restart homeassistant-mcp

# Restart ser2net (Zigbee)
sudo killall ser2net && ser2net -n &
```

### Check Status
```bash
# Container status
docker ps

# Home Assistant API
curl -s http://localhost:8123/api/ | jq .

# MCP health
curl -s http://localhost:3000/health | jq .

# Zigbee connections
netstat -an | grep 9999
```

## 🔧 Common Fixes

### Dashboard Not Updating
```bash
# Copy dashboard file to container
docker cp dashboard_name.yaml homeassistant:/config/
docker restart homeassistant
```

### MCP Connection Failed
```bash
# Restart MCP with correct config
docker-compose up -d homeassistant-mcp
# Then restart Claude Desktop
```

### Zigbee Devices Offline
```bash
# Check USB device
ls -la /dev/tty.SLAB_USBtoUART

# Restart ser2net
sudo killall ser2net
ser2net -n &
```

### Integration Errors
```bash
# Start monitor
bash /mnt/docker/homeassistant/scripts/start_monitor.sh

# Check specific integration
docker exec homeassistant grep "integration_name" /config/home-assistant.log
```

## 📁 Important Locations

| What | Where |
|------|-------|
| Config files | `/mnt/docker/homeassistant/` |
| Backup | `/mnt/docker/homeassistant.backup_20250810_083925_WORKING` |
| Logs | Container logs via `docker logs` |
| Claude config | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Scripts | `/mnt/docker/homeassistant/scripts/` |

## 🌐 Web Access

- **Home Assistant**: http://192.168.3.20:8123
- **Portainer**: http://192.168.3.20:9001
- **MCP API**: http://localhost:3000 (local only)

## 🔐 Tokens

Get token from Home Assistant:
1. Go to http://192.168.3.20:8123
2. Click your profile (bottom left)
3. Scroll to "Long-lived access tokens"
4. Create new token

## 🚨 Emergency Recovery

```bash
# Full restore from backup
docker-compose down
sudo rm -rf /mnt/docker/homeassistant/*
sudo cp -r /mnt/docker/homeassistant.backup_20250810_083925_WORKING/* /mnt/docker/homeassistant/
docker-compose up -d
```

## 📊 Monitor Commands

```bash
# Resource usage
docker stats

# Disk space
df -h /mnt/docker

# Network connections
netstat -an | grep -E "8123|3000|9999|1883"

# Process check
ps aux | grep -E "ser2net|docker"
```

---
*Keep this handy for quick troubleshooting!*