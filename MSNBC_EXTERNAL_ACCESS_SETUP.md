# MSNBC Buffer External Access Configuration

## Overview
This guide configures the MSNBC 1-hour buffer for secure external access through Nginx Proxy Manager (NPM) and VPN connections.

## Architecture
```
Internet → NPM (443) → MSNBC Buffer (8888)
VPN → Direct Access (8888)
```

## Nginx Proxy Manager Configuration

### 1. Create Proxy Host in NPM

1. Access NPM at `http://192.168.3.11:81`
2. Navigate to **Proxy Hosts** → **Add Proxy Host**

### 2. Details Tab Configuration
```
Domain Names: msnbc.yourdomain.com
Scheme: http
Forward Hostname/IP: 192.168.3.11
Forward Port: 8888
Cache Assets: OFF (important for live streams)
Block Common Exploits: ON
Websockets Support: ON
```

### 3. SSL Tab Configuration
```
SSL Certificate: Request new Let's Encrypt certificate
Force SSL: ON
HTTP/2 Support: ON
HSTS Enabled: ON
HSTS Subdomains: OFF
```

### 4. Custom Nginx Configuration
Add to the **Advanced** tab:

```nginx
# CORS headers for stream access
add_header Access-Control-Allow-Origin * always;
add_header Access-Control-Allow-Methods "GET, OPTIONS" always;
add_header Access-Control-Allow-Headers "Range" always;
add_header Access-Control-Expose-Headers "Content-Length,Content-Range" always;

# Streaming optimizations
proxy_buffering off;
proxy_cache off;
proxy_set_header Connection "";
proxy_http_version 1.1;

# Timeouts for long-running streams
proxy_read_timeout 86400s;
proxy_send_timeout 86400s;
proxy_connect_timeout 60s;

# Buffer settings
proxy_buffer_size 4k;
proxy_buffers 8 4k;
proxy_busy_buffers_size 8k;

# Disable request/response buffering
proxy_request_buffering off;

# Pass through range requests (for seeking)
proxy_set_header Range $http_range;
proxy_set_header If-Range $http_if_range;

# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;

# Rate limiting (optional - adjust as needed)
limit_req_zone $binary_remote_addr zone=stream_limit:10m rate=10r/s;
limit_req zone=stream_limit burst=20 nodelay;

# Logging
access_log /data/logs/msnbc_stream_access.log;
error_log /data/logs/msnbc_stream_error.log warn;
```

### 5. Access Lists (Optional)
For additional security, create an access list:

1. Go to **Access Lists** → **Add Access List**
2. Name: `MSNBC Stream Access`
3. Add authorized users or IP ranges
4. Apply to the proxy host under **Access** tab

## Authentication Options

### Basic Authentication
Add to NPM Advanced configuration:
```nginx
auth_basic "MSNBC Stream Access";
auth_basic_user_file /data/access/.htpasswd_msnbc;
```

Create password file:
```bash
docker exec -it nginx-proxy-manager bash
htpasswd -c /data/access/.htpasswd_msnbc username
```

### Token-Based Authentication
Use NPM's built-in access lists with user accounts for easier management.

## VPN Access Configuration

### WireGuard Setup
For VPN access, ensure WireGuard is configured:

```yaml
# In docker-compose.yml
wireguard:
  image: linuxserver/wireguard
  container_name: wireguard
  cap_add:
    - NET_ADMIN
    - SYS_MODULE
  environment:
    - PUID=1000
    - PGID=1000
    - TZ=America/New_York
    - SERVERURL=yourdomain.com
    - SERVERPORT=51820
    - PEERS=phone,laptop,tablet
    - PEERDNS=auto
    - INTERNAL_SUBNET=10.13.13.0
  volumes:
    - /mnt/docker/wireguard/config:/config
    - /lib/modules:/lib/modules
  ports:
    - 51820:51820/udp
  sysctls:
    - net.ipv4.conf.all.src_valid_mark=1
  restart: unless-stopped
```

### Client Configuration
Once connected via VPN, access the stream directly:
```
http://192.168.3.11:8888/playlist.m3u8
http://192.168.3.11:8888/status
```

## Stream URLs

### External Access (via NPM)
```
https://msnbc.yourdomain.com/playlist.m3u8
https://msnbc.yourdomain.com/status
```

### VPN Access
```
http://192.168.3.11:8888/playlist.m3u8
http://192.168.3.11:8888/status
```

### Local Network
```
http://192.168.3.11:8888/playlist.m3u8
http://localhost:8888/playlist.m3u8
```

## Player Configuration

### VLC
```bash
# External
vlc https://msnbc.yourdomain.com/playlist.m3u8

# VPN/Local
vlc http://192.168.3.11:8888/playlist.m3u8
```

### Web Player (HTML5)
```html
<!DOCTYPE html>
<html>
<head>
    <title>MSNBC Live Stream</title>
    <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
</head>
<body>
    <video id="video" controls style="width: 100%; max-width: 1920px;"></video>
    <script>
        var video = document.getElementById('video');
        var videoSrc = 'https://msnbc.yourdomain.com/playlist.m3u8';
        
        if (Hls.isSupported()) {
            var hls = new Hls({
                maxBufferLength: 60,
                maxMaxBufferLength: 120,
                enableWorker: true
            });
            hls.loadSource(videoSrc);
            hls.attachMedia(video);
        } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
            video.src = videoSrc;
        }
    </script>
</body>
</html>
```

## Mobile App Configuration

### TiviMate
1. Add playlist URL: `https://msnbc.yourdomain.com/playlist.m3u8`
2. Set User-Agent: `TiviMate/4.3.0`
3. Enable EPG if configured

### IPTV Apps
Most IPTV apps support direct HLS URLs:
- GSE Smart IPTV
- IPTV Smarters Pro
- Perfect Player

## Security Considerations

### 1. Rate Limiting
Implement in NPM to prevent abuse:
```nginx
limit_conn_zone $binary_remote_addr zone=stream_conn:10m;
limit_conn stream_conn 3;  # Max 3 concurrent connections per IP
```

### 2. Geo-Blocking (Optional)
Add to NPM configuration:
```nginx
# Block countries (requires GeoIP module)
if ($geoip_country_code !~ ^(US|CA)$) {
    return 403;
}
```

### 3. Monitor Access
Check logs regularly:
```bash
docker exec -it nginx-proxy-manager bash
tail -f /data/logs/msnbc_stream_access.log
```

## Troubleshooting

### Stream Not Loading Externally
1. Check NPM proxy host is active
2. Verify SSL certificate is valid
3. Check firewall allows port 443
4. Test DNS resolution: `nslookup msnbc.yourdomain.com`

### Buffering Issues
1. Check bandwidth: Stream requires ~6-8 Mbps
2. Verify GPU transcoding is working
3. Monitor buffer status: `curl https://msnbc.yourdomain.com/status`

### VPN Connection Issues
1. Check WireGuard container logs
2. Verify port 51820/udp is forwarded
3. Regenerate peer configuration if needed

### Authentication Problems
1. Verify .htpasswd file exists and has correct permissions
2. Check NPM access lists are properly configured
3. Clear browser cache/cookies

## Monitoring

### Status Endpoint
The `/status` endpoint provides real-time buffer information:
```json
{
  "channel": "MSNBC",
  "segments": 360,
  "max_segments": 360,
  "buffer_minutes": 60,
  "buffer_size_mb": 4500,
  "gpu_type": "nvidia",
  "transcoding": true,
  "timestamp": "2025-09-05T12:00:00"
}
```

### Health Check Script
```bash
#!/bin/bash
# health_check.sh

EXTERNAL_URL="https://msnbc.yourdomain.com/status"
LOCAL_URL="http://192.168.3.11:8888/status"

# Check external access
if curl -s "$EXTERNAL_URL" | jq -e '.segments > 0' > /dev/null; then
    echo "External access: OK"
else
    echo "External access: FAILED"
    # Send alert
fi

# Check local access
if curl -s "$LOCAL_URL" | jq -e '.segments > 0' > /dev/null; then
    echo "Local access: OK"
else
    echo "Local access: FAILED"
fi
```

## Integration with Home Assistant

Add to Home Assistant configuration:
```yaml
camera:
  - platform: generic
    name: MSNBC Stream
    stream_source: https://msnbc.yourdomain.com/playlist.m3u8
    verify_ssl: true

sensor:
  - platform: rest
    name: MSNBC Buffer Status
    resource: https://msnbc.yourdomain.com/status
    json_attributes:
      - segments
      - buffer_minutes
      - buffer_size_mb
      - gpu_type
    value_template: '{{ value_json.buffer_minutes }} min'
    scan_interval: 60
```

## Bandwidth Considerations

### Upload Requirements
- HD Stream (1080p): 6-8 Mbps per viewer
- SD Stream (720p): 3-4 Mbps per viewer
- Mobile (480p): 1-2 Mbps per viewer

### CDN Integration (Optional)
For multiple external viewers, consider CDN:
1. CloudFlare Stream
2. AWS CloudFront
3. Akamai

---
*Last Updated: 2025-09-05*