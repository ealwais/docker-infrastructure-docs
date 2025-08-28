# Home Assistant Working State Documentation
**Date**: August 10, 2025 - 08:42 CST
**Status**: ✅ FULLY OPERATIONAL

## Backup Information
- **Full System Backup**: `/mnt/docker/homeassistant.backup_20250810_083925_WORKING`
- **Integration Backup (in container)**: `/config/backups/working_integrations_20250810_084236.tar.gz`
- **Integration Backup (on host)**: `/mnt/docker/homeassistant/backups/working_integrations_20250810_084236.tar.gz`
- **Config Backup**: `/mnt/docker/homeassistant/backups/config_backup_20250810_075357.tar.gz`

## System Configuration

### Docker Containers Running
1. **homeassistant** - Main HA container (port 8123)
2. **homeassistant-mcp** - Claude integration (port 3000) [unhealthy but working]
3. **matter-server** - Matter/Thread support
4. **portainer** - Docker management (port 9001)

### Zigbee Configuration
- **ser2net**: Running on macOS (not Docker)
- **Port**: 9999 (NOT 3333)
- **Device**: `/dev/tty.SLAB_USBtoUART`
- **ZHA Config**: `socket://host.docker.internal:9999`

### Working Integrations (Restored)
- ✅ HACS (Home Assistant Community Store)
- ✅ HomeKit Bridge (3 instances)
- ✅ Synology DSM
- ✅ Bond (ceiling fans/shades)
- ✅ Lutron Caseta
- ✅ SmartThings
- ✅ Samsung TV
- ✅ Apple TV (2 instances)
- ✅ iCloud
- ✅ Matter/Thread
- ✅ MQTT
- ✅ Mobile Apps (2 instances)
- ✅ Google Translate (TTS)
- ✅ Weather (Met.no)
- ✅ Radio Browser
- ✅ DLNA
- ✅ IPP (printer)
- ✅ Shopping List
- ✅ Backup
- ✅ Sun

### Custom Components (via HACS)
- wevolor
- monitor_docker
- ha_carrier
- anker_solix
- meross_lan
- tesla_custom
- kleenex_pollenradar
- weatheralerts
- xiaomi_home
- google_home
- solcast_solar
- xiaomi_miot
- wyzeapi
- unifi_network_rules

### Fixed Issues
1. ✅ Removed deprecated platform configurations
2. ✅ Fixed package configuration errors
3. ✅ Disabled missing shell commands
4. ✅ Cleaned up invalid YAML keys

### Still Need to Add (via UI)
- Plex Media Server (192.168.3.11:32400)
- Radarr (192.168.3.11:7878)
- Sonarr (192.168.3.11:8989)
- UniFi Network (192.168.3.1)
- UniFi Protect (192.168.3.1)
- Tesla Powerwall (if applicable)
- Carrier HVAC (if applicable)

### Access URLs
- **Home Assistant**: http://192.168.3.20:8123
- **Portainer**: http://192.168.3.20:9001
- **Matter Server**: Running on host network
- **MCP Server**: http://192.168.3.20:3000

### Important Notes
1. **DO NOT** delete `.storage` directory - contains all integrations
2. **DO NOT** remove the full backup before making changes
3. ser2net is running on macOS, not in Docker
4. Use port 9999 for Zigbee, not 3333
5. Configuration is in YAML mode (not storage mode)

### Quick Recovery Commands
```bash
# If something breaks, restore from backup:
sudo cp -r /mnt/docker/homeassistant.backup_20250810_083925_WORKING/* /mnt/docker/homeassistant/
docker restart homeassistant

# Or restore just integrations from host:
docker stop homeassistant
cd /mnt/docker/homeassistant
tar -xzf backups/working_integrations_20250810_084236.tar.gz
docker start homeassistant

# Or restore from container backup:
docker exec homeassistant tar -xzf /config/backups/working_integrations_20250810_084236.tar.gz -C /config
docker restart homeassistant
```

### Path Reference
- **Host Path**: `/mnt/docker/homeassistant/` (where you edit files)
- **Container Path**: `/config/` (inside the Docker container)
- **Mapping**: `/mnt/docker/homeassistant/` → `/config/`

## Validation Checklist
- ✅ Web interface accessible
- ✅ No critical errors in logs
- ✅ Integrations loaded from .storage
- ✅ Custom components available
- ✅ Dashboards configured
- ✅ Automations can run
- ✅ Zigbee network available (via ser2net)