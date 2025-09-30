# CarPlay Movie Streaming Setup Guide

## Overview
This guide configures secure remote access to your media library for CarPlay streaming without VPN.

## Solution 1: Plex (Recommended)

### Why Plex for CarPlay?
- Native CarPlay app support
- Automatic transcoding for mobile
- Bandwidth optimization
- Secure authentication
- Works over cellular

### Setup Steps

#### 1. Enable Plex Remote Access
1. Access Plex Web UI: http://localhost:32400
2. Go to Settings → Server → Remote Access
3. Click "Enable Remote Access"
4. Check "Manually specify public port" if needed (32400)

#### 2. Configure Nginx Proxy Manager

Create new proxy host in NPM (http://localhost:81):

**Domain:** `plex.alwais.org`
**Forward to:** `192.168.1.10:32400` (use your server IP)
**Settings:**
- Cache Assets: OFF
- Block Common Exploits: ON
- Websockets Support: ON

**Custom Nginx Configuration:**
```nginx
# Plex specific configuration
client_max_body_size 100M;
proxy_buffering off;

# Plex headers
proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
proxy_set_header X-Plex-Device $http_x_plex_device;
proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
proxy_set_header X-Plex-Platform $http_x_plex_platform;
proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
proxy_set_header X-Plex-Product $http_x_plex_product;
proxy_set_header X-Plex-Token $http_x_plex_token;
proxy_set_header X-Plex-Version $http_x_plex_version;

# WebSocket support
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";

# Timeouts
proxy_connect_timeout 600;
proxy_send_timeout 600;
proxy_read_timeout 600;
send_timeout 600;
```

#### 3. Configure SSL
In NPM SSL tab:
- Request new Let's Encrypt certificate
- Force SSL: ON
- HTTP/2 Support: ON
- HSTS Enabled: ON

#### 4. Claim Your Plex Server
```bash
# Get claim token from https://plex.tv/claim
CLAIM_TOKEN="claim-xxxxxxxxxxxx"

# Claim server
curl -X POST "http://localhost:32400/myplex/claim?token=$CLAIM_TOKEN"
```

#### 5. Setup CarPlay

1. **Install Plex app on iPhone**
2. **Sign in to your Plex account**
3. **In CarPlay:**
   - Plex will appear automatically
   - Browse your libraries
   - Download content for offline (recommended)

### Optimize for Mobile/CarPlay

#### Plex Transcoding Settings:
1. Settings → Server → Transcoder
   - Transcoder quality: Automatic
   - Enable hardware acceleration if available

2. Settings → Server → Remote Access
   - Limit remote stream bitrate: 4 Mbps (for cellular)

3. Settings → Server → Network
   - Enable "Treat WAN IP as LAN"
   - Custom server access URLs: `https://plex.alwais.org`

## Solution 2: Jellyfin (Free Alternative)

If you prefer a free, open-source alternative:

### Install Jellyfin
```yaml
# Add to docker-compose.yml
jellyfin:
  image: jellyfin/jellyfin:latest
  container_name: jellyfin
  ports:
    - "8096:8096"
  volumes:
    - /mnt/docker/jellyfin/config:/config
    - /mnt/docker/jellyfin/cache:/cache
    - /mnt/media/movies:/media/movies:ro
    - /mnt/media/television.shows:/media/tv:ro
  environment:
    - PUID=1000
    - PGID=1000
    - TZ=America/Chicago
  restart: unless-stopped
  networks:
    - docker_network
```

### Configure NPM for Jellyfin
Similar to Plex setup but forward to port 8096

### Use with CarPlay
- Install "Jellyfin Mobile" app
- Or use "VLC for Mobile" with Jellyfin server URL

## Solution 3: Direct File Access via WebDAV

For simple file browsing in VLC:

### Setup WebDAV Server
```yaml
# Add to docker-compose.yml
webdav:
  image: bytemark/webdav
  container_name: webdav
  ports:
    - "8080:80"
  volumes:
    - /mnt/media:/var/lib/dav/data
  environment:
    - AUTH_TYPE=Basic
    - USERNAME=carplay
    - PASSWORD=SecurePassword123!
  restart: unless-stopped
```

### Configure NPM
- Domain: `files.alwais.org`
- Forward to: `webdav:80`
- Enable SSL

### Access in VLC
1. Open VLC on iPhone
2. Network → Add connection
3. URL: `https://files.alwais.org`
4. Username/Password from above

## Security Considerations

### 1. Authentication
- Always use strong passwords
- Enable 2FA where possible (Plex supports it)
- Use Plex Home users for family

### 2. Rate Limiting
Add to NPM custom config:
```nginx
limit_req_zone $binary_remote_addr zone=carplay:10m rate=10r/s;
limit_req zone=carplay burst=20 nodelay;
```

### 3. Geo-blocking (Optional)
If only using in specific regions:
```nginx
# Allow only US IPs
if ($geoip_country_code != "US") {
    return 403;
}
```

### 4. Bandwidth Management
- Set upload limits in Plex
- Use quality limits for remote streams
- Consider data caps

## Testing CarPlay Access

### 1. Test from iPhone (on cellular):
```
1. Disable WiFi
2. Open Plex app
3. Verify server connection
4. Play a movie
5. Connect to CarPlay
6. Verify Plex appears and works
```

### 2. Monitor bandwidth:
```bash
# Check current connections
docker exec nginx-proxy-manager netstat -an | grep :443

# Monitor Plex bandwidth
docker stats plex-new
```

### 3. Check logs for issues:
```bash
# Plex logs
docker logs plex-new -f

# NPM logs
docker logs nginx-proxy-manager -f
```

## Troubleshooting

### Plex not appearing in CarPlay:
- Ensure Plex app is installed on iPhone
- Sign out and back into Plex
- Restart iPhone
- Check Settings → General → CarPlay

### Buffering issues:
- Lower remote quality in Plex settings
- Enable "Automatically adjust quality"
- Pre-download content for offline

### Connection refused:
- Check firewall rules (ports 80, 443, 32400)
- Verify DNS points to correct IP
- Check NPM proxy configuration

### SSL certificate issues:
- Renew certificate in NPM
- Check domain DNS records
- Ensure ports 80/443 are open

## Data Usage Warning

Streaming over cellular uses significant data:
- 720p: ~1.5 GB/hour
- 1080p: ~3 GB/hour
- 4K: ~7 GB/hour

Recommendations:
- Set quality limits for cellular
- Download content when on WiFi
- Monitor data usage