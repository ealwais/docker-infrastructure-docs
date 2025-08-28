# TVHeadend Docker Setup Documentation

## Overview
TVHeadend is running as a Docker container on this system, providing TV streaming and recording capabilities.

## Container Information
- **Image**: lscr.io/linuxserver/tvheadend:latest
- **Container Name**: tvheadend
- **Status**: Running with health checks

## Network Configuration
- **Web Interface Port**: 9981 (HTTP)
- **HTSP Port**: 9982 (for client connections)
- **Host IP**: 192.168.3.11
- **Container IP**: 172.24.0.2

## Port Mappings
```
0.0.0.0:9981-9982->9981-9982/tcp
:::9981-9982->9981-9982/tcp
```

## Access URLs
- **Web Interface**: http://192.168.3.11:9981/
- **Playlist (M3U8)**: http://192.168.3.11:9981/playlist.m3u8

## Authentication
TVHeadend has access control enabled by default. To access the playlist or web interface:

### Option 1: Use Credentials in URL
```
http://username:password@192.168.3.11:9981/playlist.m3u8
```

### Option 2: Configure Anonymous Access
1. Access the web interface at http://192.168.3.11:9981/
2. Navigate to Configuration → Access Entries
3. Create a new access entry allowing anonymous access for streaming

## Configuration Location
- **Config Directory**: /config (inside container)
- **Access Control**: /config/accesscontrol/

## Process Information
- **Main Process**: `/usr/bin/tvheadend -C -c /config`
- **User**: abc (inside container)
- **Supervisor**: s6-supervise managing the service

## Common Commands

### View Container Status
```bash
docker ps | grep tvheadend
```

### View Container Logs
```bash
docker logs tvheadend
```

### Restart Container
```bash
docker restart tvheadend
```

### Check Service Inside Container
```bash
docker exec tvheadend ps aux | grep tvheadend
```

### Check Listening Ports
```bash
docker exec tvheadend netstat -tln | grep -E "9981|9982"
```

## Troubleshooting

### Connection Refused on Port 8888
- TVHeadend uses port 9981 for the web interface, not 8888
- Update your URLs to use port 9981

### Connection Timeouts
1. Check if the container is running:
   ```bash
   docker ps | grep tvheadend
   ```

2. Verify ports are open:
   ```bash
   nc -zv 192.168.3.11 9981
   ```

3. Check firewall rules:
   ```bash
   sudo iptables -L -n | grep -E "9981|9982"
   ```

### Authentication Issues
- TVHeadend requires authentication by default
- Either use credentials in the URL or configure anonymous access
- Access control files are located in /config/accesscontrol/

### Testing Connectivity
```bash
# Test if port is open
nc -zv 192.168.3.11 9981

# Test HTTP response (will show HTML if working)
wget -qO- http://192.168.3.11:9981/ --timeout=5 | head -20
```

## Security Notes
- Access control is enabled by default for security
- Configure appropriate access rules based on your network environment
- Consider using HTTPS if exposing to the internet

## Additional Resources
- Official TVHeadend Documentation: https://tvheadend.org/
- LinuxServer.io TVHeadend Image: https://docs.linuxserver.io/images/docker-tvheadend