# Docker Services Consolidation Guide

## Overview
All Docker services have been consolidated into a single `docker-compose.yml` file located at `/mnt/docker/docker-compose.yml`. This simplifies management while maintaining the existing folder structure for each service's data and configuration.

## File Structure
```
/mnt/docker/
├── docker-compose.yml           # Main consolidated compose file
├── docker-compose.override.yml  # Local overrides (optional)
├── .env                         # Environment variables
├── .env.example                 # Example environment file
│
├── plex/                        # Service folders remain unchanged
│   ├── config/
│   └── data/
├── homeassistant/
│   ├── config files...
├── xteve/
│   ├── config/
│   └── playlists/
└── [other service folders...]
```

## Services Included

### Media Streaming
- **Plex** - Media server (port 32400)
- **xTeve** - IPTV proxy (ports 34400-34401)
- **TVHeadend** - TV streaming (ports 9981-9982)
- **Overseerr** - Media requests (port 5055)
- **Whisparr** - Adult content (port 6969)

### Media Management
- **Sonarr** - TV shows management
- **Radarr** - Movies management
- **SABnzbd** - Usenet downloads (port 8080)

### Home Automation
- **Home Assistant** - Home automation platform
- **Matter Server** - Matter protocol support
- **Mosquitto** - MQTT broker (port 1883)

### Infrastructure
- **AdGuard Home** - DNS & ad blocking (port 53, 8080)
- **Nginx Proxy Manager** - Reverse proxy (ports 80, 443, 81)
- **Portainer** - Docker management (port 9443)
- **Watchtower** - Auto updates

### Automation
- **n8n** - Workflow automation (port 5678)
- **PostgreSQL** - n8n database
- **Redis** - n8n queue

## Usage Commands

### Start all services
```bash
cd /mnt/docker
docker-compose up -d
```

### Start specific services
```bash
docker-compose up -d plex xteve overseerr
```

### Stop all services
```bash
docker-compose down
```

### View logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f plex
```

### Restart a service
```bash
docker-compose restart plex
```

### Update services
```bash
docker-compose pull
docker-compose up -d
```

## Environment Variables
1. Copy `.env.example` to `.env`
2. Fill in required values:
   - `PLEX_CLAIM` - Your Plex claim token
   - Database passwords for n8n
   - Authentication credentials

## Customization
Use `docker-compose.override.yml` for local customizations:
1. Copy `docker-compose.override.yml.example` to `docker-compose.override.yml`
2. Add your custom configurations
3. Docker Compose will automatically merge both files

## Networks
- **docker_network** (172.20.0.0/24) - Main network for most services
- **n8n_network** - Isolated network for n8n and its databases
- Services using `network_mode: host` have direct access to all host ports

## Migration Notes
- All service data remains in original folders
- No data migration required
- Old individual compose files can be kept as backup
- Services maintain their original container names for compatibility

## Rollback Plan
If you need to revert:
1. Stop services: `docker-compose down`
2. Use original compose files in each service directory
3. Start services individually with their original compose files

## Benefits
✓ Single point of management
✓ Consistent network configuration
✓ Easier backup and restore
✓ Simplified updates
✓ Better resource overview
✓ Maintains folder structure