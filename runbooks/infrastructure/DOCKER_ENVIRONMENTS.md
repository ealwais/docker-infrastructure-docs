# Docker Environments Configuration

## Environment Overview

| Environment | Host IP | Docker Version | Runtime | Orchestrator | GPU Support |
|-------------|---------|----------------|---------|--------------|-------------|
| Mac Mini | 192.168.3.20 | 24.0.5 | Colima | Docker Compose | No |
| Docker Server | 192.168.3.11 | 24.0.7 | Native | Docker Compose | NVIDIA |
| QNAP NAS | 192.168.3.10 | 20.10.17 | Container Station | QNAP CS | No |
| Synology | 192.168.3.120 | 20.10.3 | Synology Docker | Docker Package | No |

## Mac Mini Environment (192.168.3.20)

### Docker Configuration
```bash
# Colima Configuration
colima start --cpu 4 --memory 8 --disk 100 --runtime docker

# Docker Context
docker context use colima

# Socket Location
/var/run/docker.sock
```

### Container Specifications

#### homeassistant
```yaml
container_name: homeassistant
image: homeassistant/home-assistant:stable
restart: unless-stopped
network_mode: host
privileged: true
volumes:
  - /mnt/docker/homeassistant:/config
  - /var/run/docker.sock:/var/run/docker.sock
environment:
  - TZ=America/Chicago
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8123/api/"]
  interval: 30s
  timeout: 10s
  retries: 3
```

#### homeassistant-mcp
```yaml
container_name: homeassistant-mcp
image: custom/ha-mcp:latest
restart: unless-stopped
ports:
  - "3000:3000"
environment:
  - HASS_HOST=host.docker.internal
  - HASS_TOKEN=${HA_TOKEN}
  - HASS_SOCKET_URL=ws://host.docker.internal:8123/api/websocket
  - PORT=3000
  - NODE_ENV=production
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
```

#### mosquitto
```yaml
container_name: mosquitto
image: eclipse-mosquitto:latest
restart: unless-stopped
ports:
  - "1883:1883"
  - "9002:9001"
volumes:
  - /mnt/docker/mosquitto/config:/mosquitto/config
  - /mnt/docker/mosquitto/data:/mosquitto/data
  - /mnt/docker/mosquitto/log:/mosquitto/log
```

#### portainer
```yaml
container_name: portainer
image: portainer/portainer-ce:latest
restart: always
ports:
  - "9001:9000"
  - "9444:9443"
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
  - portainer_data:/data
command: --admin-password-file /data/admin-password
```

## Docker Server Environment (192.168.3.11)

### GPU Configuration
```bash
# NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list
apt update && apt install -y nvidia-container-toolkit
systemctl restart docker

# Verify GPU
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi
```

### Container Specifications

#### plex
```yaml
container_name: plex
image: plexinc/pms-docker:latest
restart: unless-stopped
network_mode: host
runtime: nvidia
environment:
  - NVIDIA_VISIBLE_DEVICES=all
  - NVIDIA_DRIVER_CAPABILITIES=compute,video,utility
  - VERSION=docker
  - PLEX_CLAIM=${PLEX_CLAIM}
  - TZ=America/Chicago
volumes:
  - /mnt/docker/plex/config:/config
  - /mnt/docker/plex/transcode:/transcode
  - /mnt/media:/media
devices:
  - /dev/dri:/dev/dri
```

#### jellyfin
```yaml
container_name: jellyfin
image: jellyfin/jellyfin:latest
restart: unless-stopped
runtime: nvidia
environment:
  - NVIDIA_VISIBLE_DEVICES=all
  - NVIDIA_DRIVER_CAPABILITIES=compute,video,utility
ports:
  - "8096:8096"
  - "8920:8920"
  - "7359:7359/udp"
  - "1900:1900/udp"
volumes:
  - /mnt/docker/jellyfin/config:/config
  - /mnt/docker/jellyfin/cache:/cache
  - /mnt/media:/media
```

#### sonarr
```yaml
container_name: sonarr
image: linuxserver/sonarr:latest
restart: unless-stopped
environment:
  - PUID=1000
  - PGID=1000
  - TZ=America/Chicago
ports:
  - "8989:8989"
volumes:
  - /mnt/docker/sonarr/config:/config
  - /mnt/downloads:/downloads
  - /mnt/media/tv:/tv
```

#### radarr
```yaml
container_name: radarr
image: linuxserver/radarr:latest
restart: unless-stopped
environment:
  - PUID=1000
  - PGID=1000
  - TZ=America/Chicago
ports:
  - "7878:7878"
volumes:
  - /mnt/docker/radarr/config:/config
  - /mnt/downloads:/downloads
  - /mnt/media/movies:/movies
```

## QNAP Container Station (192.168.3.10)

### Access Methods
```bash
# SSH Access
ssh admin@192.168.3.10

# Docker Binary
/share/CACHEDEV1_DATA/.qpkg/container-station/bin/docker

# Container Station UI
https://192.168.3.10/container-station/

# Via Portainer
Endpoint #5 in main Portainer
```

### Running Containers
- portainer-agent (port 9001)
- overseerr (port 5055)
- tautulli (port 8181)

## Synology Docker (192.168.3.120)

### Access Methods
```bash
# SSH Access
ssh admin@192.168.3.120

# Docker UI
https://192.168.3.120:5001

# Via Portainer
Endpoint #4 in main Portainer
```

### Running Containers
- portainer-agent (port 9001)
- syncthing (port 8384)
- duplicati (port 8200)

## Docker Networks

### Network Types
| Network | Driver | Subnet | Purpose |
|---------|--------|--------|---------|
| bridge | bridge | 172.17.0.0/16 | Default bridge |
| host | host | N/A | Host networking |
| macvlan | macvlan | 192.168.3.0/24 | Direct LAN access |
| overlay | overlay | 10.0.0.0/24 | Swarm services |

### Custom Networks
```bash
# Create macvlan network for direct LAN access
docker network create -d macvlan \
  --subnet=192.168.3.0/24 \
  --gateway=192.168.3.1 \
  -o parent=eth0 \
  lan_network

# Create isolated network for services
docker network create --internal isolated_network
```

## Volume Management

### Volume Locations
| Host | Volume Type | Path | Backup |
|------|-------------|------|--------|
| Mac Mini | Bind Mount | /mnt/docker/* | Daily |
| Docker Server | Named Volume | /var/lib/docker/volumes/* | Weekly |
| QNAP | Container Station | /share/Container/* | Daily |
| Synology | Docker Package | /volume1/docker/* | Daily |

### Volume Backup Commands
```bash
# Backup volume to tar
docker run --rm -v volume_name:/data -v $(pwd):/backup alpine \
  tar czf /backup/volume_backup.tar.gz -C /data .

# Restore volume from tar
docker run --rm -v volume_name:/data -v $(pwd):/backup alpine \
  tar xzf /backup/volume_backup.tar.gz -C /data
```

## Resource Limits

### CPU and Memory Limits
```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 2048M
    reservations:
      cpus: '0.5'
      memory: 512M
```

### GPU Resource Allocation
```yaml
# Specific GPU
environment:
  - NVIDIA_VISIBLE_DEVICES=0

# GPU Memory Limit
environment:
  - NVIDIA_DRIVER_CAPABILITIES=compute,utility
  - NVIDIA_COMPUTE_CAPABILITY=8.6
```

## Monitoring

### Container Metrics
```bash
# Real-time stats
docker stats --no-stream

# Resource usage by container
docker ps -q | xargs docker inspect -f '{{.Name}}: {{.HostConfig.Memory}}'

# Disk usage
docker system df
```

### Log Management
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```