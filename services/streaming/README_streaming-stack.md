# Docker Streaming Stack Setup Guide

## Overview
This streaming stack has been consolidated into a single docker-compose.yml file that includes:
- **NGINX Proxy Manager (NPM)** - SSL termination and domain management
- **Xteve** - IPTV buffering and streaming (MSNBC Channel 215)
- **Plex Media Server** - Local HDHomeRun content with host networking
- **AdGuard Home** - DNS and ad blocking
- **Portainer** - Docker management interface
- **Portainer Agent** - Container management agent
- **Watchtower** - Automatic container updates

## Directory Structure

```
/mnt/docker/streaming-stack/
├── docker-compose.yml          # Consolidated compose file (all services)
├── .env                        # Environment variables
├── README.md                   # This file
├── NPM_PROXY_CONFIGURATION.md # NPM setup instructions
│
/mnt/docker/                    # Service data directories
├── adguard/                    # AdGuard Home
│   ├── work/                   # Working directory
│   └── conf/                   # Configuration
├── adguard-npm/               # Nginx Proxy Manager
│   └── nginx-proxy-manager/
│       ├── data/              # Database and config
│       └── letsencrypt/       # SSL certificates
├── xteve/                      # Xteve data
│   ├── config/                # Xteve configuration
│   ├── data/                  # M3U and XML files
│   └── playlists/             # IPTV playlists
├── portainer/                  # Portainer
│   └── data/                  # Portainer data
│
/opt/plex/                      # Plex configuration
└── config/                     # Plex configuration files

/mnt/                          # Media and temporary files
├── ramdisk/                   # RAM disk for performance
│   ├── xteve-buffer/          # Xteve buffer
│   ├── plex-transcode/        # Plex transcode temp
│   └── plex-buffer/           # Plex buffer
├── television.shows/          # TV shows
├── movies/                    # Movies
└── Transcoding/               # Persistent transcoding
```

## Initial Setup

### 1. Create Directory Structure
```bash
# Create base directory
mkdir -p /mnt/docker/streaming-stack
cd /mnt/docker/streaming-stack

# Create subdirectories
mkdir -p npm/{data,letsencrypt,custom}
mkdir -p xteve/{config,data,playlists,buffer,cache}
mkdir -p plex/{config,transcode}
mkdir -p media/{tv,movies,music}

# Set permissions
sudo chown -R 1000:1000 xteve plex media
sudo chmod -R 755 npm xteve plex media
```

### 2. Configure Environment Variables
Edit the `.env` file:
```bash
nano .env
```

Replace `PLEX_CLAIM` with your token from https://www.plex.tv/claim/

### 3. Update MSNBC Stream URL
Edit `xteve/playlists/msnbc.m3u` and replace the placeholder URL with your actual IPTV provider's MSNBC stream URL.

### 4. Start the Stack
```bash
# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f
```

## Service Access

### Local Access (Before NPM Configuration)
- **NPM Admin Panel:** http://your-server-ip:81
- **Xteve Management:** http://your-server-ip:34400
- **Plex:** http://your-server-ip:32400
- **AdGuard Home:** http://your-server-ip:3000
- **Portainer:** http://your-server-ip:9443 (HTTPS)
- **Portainer Agent:** http://your-server-ip:9001

### After NPM Configuration
- **Xteve Management:** https://xteve.alwais.org (via NPM proxy)
- **MSNBC Stream:** https://msnbc.alwais.org/msnbc (via NPM proxy)
- **Plex Media Server:** https://plex.alwais.org (via NPM proxy)

## Xteve Configuration

### Initial Setup
1. Access Xteve at http://your-server-ip:34400
2. Skip authentication setup (disabled in config)
3. Import playlist:
   - Click "Playlist"
   - Add new playlist
   - Type: M3U
   - File: `/data/xteve.m3u`
   - Save

### MSNBC GPU-Buffered Stream
MSNBC (Channel 215) uses a dedicated GPU-accelerated buffer service:
- **Buffer URL:** `http://192.168.3.11:8888/playlist.m3u8`
- **GPU Acceleration:** NVIDIA CUDA with h264_nvenc
- **Buffer Location:** `/mnt/ramdisk/buffer-MSNBC/`
- **HLS Segments:** 180 x 10-second segments (30-minute buffer)

### Buffer Settings (Pre-configured)
- **Buffer Type:** Xteve
- **Buffer Size:** 8192 KB
- **Timeout:** 3000 ms
- **FFmpeg Options:** Optimized for CUDA acceleration

### Channel Mapping
1. Go to "Mapping"
2. Channel 215 should appear as MSNBC
3. Stream URL should be: `http://192.168.3.11:8888/playlist.m3u8`
4. Save settings

## NPM Configuration

See `NPM_PROXY_CONFIGURATION.md` for detailed proxy setup instructions.

### Quick Setup:
1. Access NPM at http://your-server-ip:81
2. Login with default credentials (change immediately):
   - Email: admin@example.com
   - Password: changeme
3. Add proxy hosts in NPM for all three domains:
   - **xteve.alwais.org** → xteve:34400 (Xteve management)
   - **msnbc.alwais.org** → xteve:34401 (MSNBC streaming)
   - **plex.alwais.org** → your-server-ip:32400 (Plex interface)
4. Request SSL certificates through NPM for each domain

## Plex Configuration

### HDHomeRun Setup
1. Access Plex at http://your-server-ip:32400
2. Go to Settings → Live TV & DVR
3. Your HDHomeRun should auto-detect (host networking enabled)
4. Follow the setup wizard

### Adding Xteve as Tuner (Optional)
1. In Plex Live TV settings
2. Add HDHomeRun manually
3. Enter: http://172.25.0.10:34400 (Xteve container IP)
4. Select channels and configure EPG

## Maintenance

### Update Services
```bash
# Update all services
docker-compose pull
docker-compose up -d

# Update specific service
docker-compose pull xteve
docker-compose up -d xteve

# Note: Watchtower automatically updates containers daily
# To disable auto-updates for a specific container, add label:
# com.centurylinklabs.watchtower.enable=false
```

### Backup
```bash
# Backup configuration
tar -czf streaming-backup-$(date +%Y%m%d).tar.gz npm/data xteve/config plex/config

# Backup with media (large)
tar -czf streaming-full-backup-$(date +%Y%m%d).tar.gz .
```

### Monitor Services
```bash
# Check container health
docker-compose ps

# View resource usage
docker stats

# Check logs
docker-compose logs -f xteve
docker-compose logs -f npm
docker-compose logs -f plex
```

## Troubleshooting

### AdGuard Port 68 Conflict
If AdGuard fails to start with "bind: address already in use" error on port 68:
```bash
# Port 68 is used by system DHCP client (dhcpcd)
# Solution: Remove port 68 mapping from docker-compose.yml
# The DHCP server feature in AdGuard won't be available, but DNS/ad-blocking will work
```

### Xteve Not Accessible
```bash
# Check if running
docker ps | grep xteve

# Restart service
docker-compose restart xteve

# Check logs
docker logs xteve --tail 50
```

### NPM 502 Bad Gateway
```bash
# Verify network connectivity
docker exec npm ping xteve

# Check Xteve is listening
docker exec xteve netstat -tulpn | grep 34400
```

### Stream Buffering Issues
1. Increase buffer segments in Xteve settings
2. Check network bandwidth
3. Verify IPTV provider stability

### Plex Can't Find HDHomeRun
1. Ensure Plex is using host networking
2. Check firewall rules
3. Restart Plex container

## Performance Tuning

### Xteve Optimization
```json
{
  "buffer.xteve.segments": 12,
  "buffer.xteve.segment.duration": 5,
  "buffer.size.kb": 16384
}
```

### NPM Optimization
Add to custom Nginx config:
```nginx
worker_connections 2048;
proxy_cache_path /tmp/cache levels=1:2 keys_zone=cache:10m max_size=1g;
```

### Docker Resource Limits
Add to docker-compose.yml services:
```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 2G
    reservations:
      cpus: '0.5'
      memory: 512M
```

## Security Recommendations

1. **Change Default Passwords**
   - NPM admin password
   - Add Xteve authentication if needed

2. **Firewall Rules**
```bash
# Allow only necessary ports
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 32400/tcp
sudo ufw deny 81/tcp from any to any
```

3. **SSL/TLS**
   - Always use HTTPS for external access
   - Enable HSTS in NPM
   - Use strong SSL ciphers

4. **Access Control**
   - Implement IP whitelisting in NPM
   - Use VPN for management interfaces
   - Enable fail2ban for brute force protection

## Support & Updates

- **NPM Documentation:** https://nginxproxymanager.com/
- **Xteve Project:** https://github.com/xteve-project/xTeVe
- **Plex Support:** https://support.plex.tv/

## License
This configuration is provided as-is for personal use.