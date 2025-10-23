# DevOps Master Runbook
**Version**: 1.0  
**Last Updated**: August 26, 2025  
**Environment**: Home Lab Infrastructure  

## Quick Navigation
- [Server Inventory](#server-inventory)
- [Network Map](#network-map)
- [Docker Environments](#docker-environments)
- [Service Catalog](#service-catalog)
- [Emergency Contacts](#emergency-contacts)
- [Critical Procedures](#critical-procedures)

---

## Server Inventory

### Physical Hosts

| Hostname | IP Address | OS | Role | SSH Access | Hardware | Status |
|----------|------------|-----|------|------------|----------|--------|
| mac-mini | 192.168.3.20 | macOS | Primary HA Host | `ssh ealwais@192.168.3.20` | Mac Mini M1, 16GB RAM | ✅ Active |
| docker-server | 192.168.3.11 | Linux | GPU Docker Host | `ssh admin@192.168.3.11` | NVIDIA GPU, 32GB RAM | ✅ Active |
| qnap-nas | 192.168.3.10 | QTS | Storage/Containers | `ssh admin@192.168.3.10` | QNAP TS-453Be, 16GB RAM | ✅ Active |
| synology-nas | 192.168.3.120 | DSM 7 | Storage/Backup | `ssh admin@192.168.3.120` | Synology DS920+, 8GB RAM | ✅ Active |
| unifi-dream | 192.168.3.1 | UniFi OS | Network Gateway | `ssh ubnt@192.168.3.1` | Dream Machine Pro SE | ✅ Active |

### GPU Resources

| Host | GPU Model | Driver | CUDA | Usage | Services |
|------|-----------|--------|------|--------|----------|
| docker-server | NVIDIA RTX 3060 | 535.129.03 | 12.2 | Transcoding | Plex, Jellyfin, FFmpeg |

---

## Network Map

### VLANs and Subnets

| VLAN | Network | Purpose | Gateway | DHCP Range |
|------|---------|---------|---------|------------|
| Default | 192.168.3.0/24 | Main LAN | 192.168.3.1 | .100-.254 |
| IoT | 192.168.10.0/24 | IoT Devices | 192.168.10.1 | .100-.254 |
| Guest | 192.168.20.0/24 | Guest Network | 192.168.20.1 | .100-.254 |

### Critical Port Mappings

| Service | Host | Internal Port | External Port | Protocol | Notes |
|---------|------|---------------|---------------|----------|-------|
| Home Assistant | 192.168.3.20 | 8123 | 8123 | HTTP | Main UI |
| Portainer (Mac) | 192.168.3.20 | 9001 | 9001 | HTTP | Docker Management |
| Portainer (Server) | 192.168.3.11 | 9443 | 9443 | HTTPS | Docker Management |
| MQTT Broker | 192.168.3.20 | 1883 | 1883 | TCP | Mosquitto |
| Zigbee Bridge | 192.168.3.20 | 9999 | 9999 | TCP | ser2net |
| MCP Server | 192.168.3.20 | 3000 | 3000 | HTTP | Claude AI |
| Plex Media | 192.168.3.11 | 32400 | 32400 | HTTP | Media Server |
| Jellyfin | 192.168.3.11 | 8096 | 8096 | HTTP | Media Server |
| UniFi Controller | 192.168.3.1 | 443 | 443 | HTTPS | Network Management |
| Synology DSM | 192.168.3.120 | 5001 | 5001 | HTTPS | NAS Management |
| QNAP Admin | 192.168.3.10 | 443 | 8443 | HTTPS | NAS Management |

---

## Docker Environments

### 1. Mac Mini (192.168.3.20) - Colima Docker

**Docker Type**: Colima (macOS Docker Desktop alternative)  
**Management**: http://192.168.3.20:9001  
**Docker Socket**: `/var/run/docker.sock`  

#### Running Containers
```yaml
homeassistant:
  image: homeassistant/home-assistant:stable
  network: host
  volumes:
    - /mnt/docker/homeassistant:/config
  environment:
    - TZ=America/Chicago

homeassistant-mcp:
  image: custom/ha-mcp:latest
  ports: 3000:3000
  environment:
    - HASS_HOST=host.docker.internal
    - HASS_TOKEN=${HA_TOKEN}

mosquitto:
  image: eclipse-mosquitto:latest
  ports: 1883:1883, 9002:9001
  volumes:
    - /mnt/docker/mosquitto:/mosquitto

matter-server:
  image: ghcr.io/home-assistant-libs/python-matter-server:stable
  network: host
  volumes:
    - /mnt/docker/matter:/data

portainer:
  image: portainer/portainer-ce:latest
  ports: 9001:9000, 9444:9443
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - portainer_data:/data
```

### 2. Docker Server (192.168.3.11) - Native Linux

**Docker Type**: Native Linux Docker with NVIDIA Runtime  
**Management**: https://192.168.3.11:9443  
**GPU Support**: NVIDIA Container Toolkit  

#### Running Containers
```yaml
plex:
  image: plexinc/pms-docker:latest
  ports: 32400:32400
  devices:
    - /dev/dri:/dev/dri  # Intel QuickSync
  runtime: nvidia  # NVIDIA GPU
  environment:
    - NVIDIA_VISIBLE_DEVICES=all
    - PLEX_CLAIM=${PLEX_CLAIM}

jellyfin:
  image: jellyfin/jellyfin:latest
  ports: 8096:8096
  runtime: nvidia
  environment:
    - NVIDIA_VISIBLE_DEVICES=all

sonarr:
  image: linuxserver/sonarr:latest
  ports: 8989:8989

radarr:
  image: linuxserver/radarr:latest
  ports: 7878:7878

sabnzbd:
  image: linuxserver/sabnzbd:latest
  ports: 8080:8080
```

### 3. QNAP NAS (192.168.3.10) - Container Station

**Docker Path**: `/share/CACHEDEV1_DATA/.qpkg/container-station/bin/docker`  
**Management**: Via Portainer Agent  
**Endpoint**: #5 in main Portainer  

#### Running Containers
- Portainer Agent
- Overseerr
- Additional Sonarr/Radarr instances

### 4. Synology NAS (192.168.3.120) - Docker Package

**Docker UI**: https://192.168.3.120:5001  
**Management**: Via Portainer Agent  
**Endpoint**: #4 in main Portainer  

#### Running Containers
- Portainer Agent
- Backup services
- File sync services

---

## Service Catalog

### Core Services

| Service | Container | Host | Health Check | Logs |
|---------|-----------|------|--------------|------|
| Home Assistant | homeassistant | 192.168.3.20 | http://192.168.3.20:8123/api/ | `docker logs homeassistant` |
| Portainer CE | portainer | 192.168.3.20 | http://192.168.3.20:9001/api/system/status | `docker logs portainer` |
| MQTT Broker | mosquitto | 192.168.3.20 | `mosquitto_sub -t '$SYS/#' -C 1` | `docker logs mosquitto` |
| MCP Server | homeassistant-mcp | 192.168.3.20 | http://192.168.3.20:3000/health | `docker logs homeassistant-mcp` |

### Media Services

| Service | URL | GPU | Storage | Status |
|---------|-----|-----|---------|--------|
| Plex | http://192.168.3.11:32400 | ✅ NVIDIA | /mnt/media | Active |
| Jellyfin | http://192.168.3.11:8096 | ✅ NVIDIA | /mnt/media | Active |
| Sonarr | http://192.168.3.11:8989 | ❌ | /mnt/downloads | Active |
| Radarr | http://192.168.3.11:7878 | ❌ | /mnt/downloads | Active |
| SABnzbd | http://192.168.3.11:8080 | ❌ | /mnt/downloads | Active |

---

## Emergency Contacts

### Internal Systems
- **UniFi Controller**: https://192.168.3.1
- **Portainer Primary**: https://192.168.3.11:9443
- **Home Assistant**: http://192.168.3.20:8123

### External Access (via VPN/Proxy)
- Configure as needed via Nginx Proxy Manager

---

## Critical Procedures

### Container Restart Procedures

```bash
# Restart Home Assistant
docker restart homeassistant

# Restart all containers on host
docker restart $(docker ps -q)

# Force recreate with compose
cd /mnt/docker/homeassistant
docker-compose down && docker-compose up -d
```

### Service Health Checks

```bash
# Check all container status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check specific service health
curl -f http://192.168.3.20:8123/api/ || echo "HA is down"
curl -f http://192.168.3.20:3000/health || echo "MCP is down"
```

### Backup Locations

| Type | Location | Schedule | Retention |
|------|----------|----------|-----------|
| HA Config | `/mnt/docker/homeassistant.backup_*` | Daily | 7 days |
| Container Volumes | `/mnt/docker/*/backup/` | Weekly | 4 weeks |
| NAS Sync | `192.168.3.120:/volume1/backups/` | Daily | 30 days |

---

## Quick Reference

### SSH Commands
```bash
# Mac Mini (Home Assistant)
ssh ealwais@192.168.3.20

# Docker Server (GPU)
ssh admin@192.168.3.11

# QNAP NAS
ssh admin@192.168.3.10

# Synology NAS
ssh admin@192.168.3.120

# UniFi Dream Machine
ssh ubnt@192.168.3.1
```

### Docker Commands
```bash
# View logs
docker logs -f --tail 100 [container_name]

# Enter container
docker exec -it [container_name] /bin/bash

# Resource usage
docker stats --no-stream

# Clean up
docker system prune -a --volumes
```

### Service URLs
- **Home Assistant**: http://192.168.3.20:8123
- **Portainer Mac**: http://192.168.3.20:9001
- **Portainer Server**: https://192.168.3.11:9443
- **Plex**: http://192.168.3.11:32400
- **UniFi**: https://192.168.3.1

---

## Notes
- Colima Docker on macOS has known file sync delays
- GPU transcoding requires NVIDIA Container Toolkit
- Zigbee coordinator uses ser2net on port 9999
- MQTT broker allows anonymous connections internally