# Home Assistant Infrastructure Overview

## Network Devices

### 192.168.3.1 - UniFi Dream Machine Pro SE
- UniFi Network Controller
- UniFi Protect (Cameras)
- Gateway/Router/DHCP

### 192.168.3.11 - Docker Server (with GPU)
- Main Docker host with GPU for transcoding
- **Portainer**:
  - HTTPS Web UI: https://192.168.3.11:9443
  - Agent Port: 192.168.3.11:9001
  - Reverse Tunnel: 192.168.3.11:8000
- Plex Media Server (port 32400)
- Jellyfin (port 8096)
- Radarr (port 7878)
- Sonarr (port 8989)
- SABnzbd (port 8080)
- FFmpeg transcoding

### 192.168.3.20 - Mac (Current Machine)
- Home Assistant (Docker)
- ser2net for Zigbee (port 9999)
- Portainer (port 9001)
- MCP Server (port 3000)
- Matter Server

### 192.168.3.120 - Synology NAS
- Storage
- Media files
- Backups

## Services Running

### On Mac (192.168.3.20):
- **Home Assistant**: Main instance
- **Portainer**: http://192.168.3.20:9001
- **ser2net**: Zigbee coordinator on port 9999
- **MCP Server**: Claude AI integration on port 3000
- **Matter Server**: Thread/Matter support

### On Docker Server (192.168.3.11):
- Potentially other Docker containers
- May have its own Portainer instance

## Port Mappings
- 8123: Home Assistant (using host network)
- 9001: Portainer Web UI
- 9444: Portainer HTTPS
- 9999: ser2net (Zigbee)
- 3000: MCP Server

## Integration Connections
- Zigbee: via ser2net at localhost:9999
- UniFi: via 192.168.3.1
- NAS: via 192.168.3.10 (Synology)
- Gmail: via app password for Arlo 2FA