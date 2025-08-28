# Infrastructure Guide

**Last Updated**: August 15, 2025

## Network Infrastructure

### Home Assistant Primary
- **Host**: Mac Mini (Colima Docker)
- **IP Address**: 192.168.3.20
- **Services**:
  - Home Assistant: http://192.168.3.20:8123
  - Portainer: http://192.168.3.20:9001
  - MCP Server: http://192.168.3.20:3000
  - MQTT Broker: 192.168.3.20:1883
  - ser2net (Zigbee): 192.168.3.20:9999

### Docker Environments

#### 1. Mac Mini - Primary Home Assistant Host
- **IP**: 192.168.3.20
- **Docker Type**: Colima (Docker Desktop alternative for macOS)
- **Portainer**: http://192.168.3.20:9001
- **Status**: ✅ Fully Operational
- **Running Containers**:
  - homeassistant
  - homeassistant-mcp
  - matter-server
  - portainer
  - mosquitto

#### 2. Docker Server - Dedicated Docker Host
- **IP**: 192.168.3.11
- **Docker Type**: Native Linux Docker
- **Portainer**: https://192.168.3.11:9443 (HTTPS)
- **Status**: ✅ Fully Operational
- **Purpose**: Additional Docker services

#### 3. QNAP NAS - Container Station
- **IP**: 192.168.3.10
- **Docker Type**: QNAP Container Station
- **Management URL**: https://192.168.3.10/container-station/ (native)
- **Portainer Access**: https://192.168.3.11:9443/#!/5/docker/dashboard (via primary Portainer)
- **Admin URL**: https://192.168.3.10
- **Status**: ✅ Managed via Portainer endpoint #5
- **Purpose**: NAS-based containers
- **Docker Path**: `/share/CACHEDEV1_DATA/.qpkg/container-station/bin/docker`
- **Running**: Portainer Agent, Sonarr, SABnzbd, Overseerr

#### 4. Synology NAS - Docker Package
- **IP**: 192.168.3.120
- **Docker Type**: Synology Docker Package
- **Docker UI**: https://192.168.3.120:5001 (native UI)
- **Portainer Access**: https://192.168.3.11:9443/#!/4/docker/host (via primary Portainer)
- **Status**: ✅ Managed via Portainer endpoint #4
- **Purpose**: NAS-based containers and storage

## Network Services

### Core Services
| Service | Location | Port | Purpose |
|---------|----------|------|---------|
| Home Assistant | 192.168.3.20 | 8123 | Home automation |
| Portainer (Mac) | 192.168.3.20 | 9001 | Docker management |
| Portainer (Server) | 192.168.3.11 | 9443 | Docker management |
| MQTT Broker | 192.168.3.20 | 1883 | IoT messaging |
| ser2net | 192.168.3.20 | 9999 | Zigbee USB passthrough |

### Integrations
| Integration | Type | Location | Notes |
|------------|------|----------|--------|
| Synology DSM | NAS | 192.168.3.120 | File storage, backups |
| QNAP | NAS | 192.168.3.10 | Container Station (currently not accessible) |
| UniFi | Network | TBD | To be configured |
| Tesla Powerwall | Cloud API | N/A | Configured via cloud |

## File Paths

### Mac Mini (Host)
- Home Assistant Config: `/mnt/docker/homeassistant/`
- Backup Location: `/mnt/docker/homeassistant.backup_20250810_083925_WORKING`
- Archive Location: `/mnt/docker/homeassistant_archive/`

### Container Paths
- Inside Container: `/config`
- Mapped to Host: `/mnt/docker/homeassistant/`

## Access URLs

### Working Services
- Home Assistant: http://192.168.3.20:8123
- Portainer (Mac Mini): http://192.168.3.20:9001
- Portainer (Docker Server): https://192.168.3.11:9443
- MCP Health Check: http://192.168.3.20:3000/health

### Services Requiring Attention
- Synology Docker: https://192.168.3.120:5001 (Requires login)

## Network Topology

```
Internet Gateway
    |
UniFi Dream Machine
    |
    +-- Mac Mini (192.168.3.20) - Home Assistant
    |
    +-- Docker Server (192.168.3.11) - Additional Services
    |
    +-- QNAP NAS (192.168.3.10) - Storage & Containers
    |
    +-- Synology NAS (192.168.3.120) - Storage & Backup
    |
    +-- IoT Devices (Various IPs)
```

## Troubleshooting

### Docker Access Issues

1. **Mac Mini Portainer**: Working normally at http://192.168.3.20:9001
2. **Docker Server**: Working normally at https://192.168.3.11:9443
3. **QNAP Container Station**: Working at https://192.168.3.10/container-station/
   - Note: URL requires hyphen and trailing slash
   - Docker binary located at: `/share/CACHEDEV1_DATA/.qpkg/container-station/bin/docker`
4. **Synology Docker**: Requires login - this is normal behavior
   - Access DSM first, then Docker package

### File Sync Issues
- Docker Desktop on macOS has known sync delays
- Use `docker exec` to copy files directly into containers
- See [Docker Sync Troubleshooting](../troubleshooting/DOCKER_SYNC_ISSUES.md)