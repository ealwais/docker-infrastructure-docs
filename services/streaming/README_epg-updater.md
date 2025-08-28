# EPG Updater Container

A production-grade containerized solution for updating EPG and M3U files for xTeve.

## Why Containers?

As recommended by DevOps best practices:
- **Isolation**: Dependencies don't affect host system
- **Consistency**: Same environment every execution
- **Portability**: Runs anywhere Docker runs
- **Resource Control**: Built-in CPU/memory limits
- **Monitoring**: Centralized logging and health checks
- **Version Control**: Tagged container images
- **Zero Host Dependencies**: No need to install xmltv, python packages, etc.

## Architecture

```
┌─────────────────┐
│   Host Cron     │  Triggers every 4 hours
└────────┬────────┘
         │
         v
┌─────────────────┐
│  EPG Updater    │  Runs as container
│   Container     │  then exits
├─────────────────┤
│ - Downloads M3U │
│ - Updates EPG   │
│ - Validates     │
│ - Updates xTeve │
└────────┬────────┘
         │
         v
┌─────────────────┐
│ Persistent Data │
│ /mnt/docker/epg │
└─────────────────┘
```

## Quick Start

### 1. Build the Container
```bash
cd /mnt/docker/xteve/epg-updater
chmod +x build.sh
./build.sh
```

### 2. Configure Schedules Direct (Optional)
```bash
# Copy your tv_grab_na_dd config if you have one
cp ~/.xmltv/tv_grab_na_dd.conf /mnt/docker/epg/config/
```

### 3. Set Up Automated Updates

**Option A: Host Cron (Recommended)**
```bash
# Add to crontab
crontab -e

# Add these lines:
# EPG Update at 4 AM and 4 PM
0 4,16 * * * cd /mnt/docker/xteve/epg-updater && docker-compose run --rm epg-updater >> /mnt/docker/epg/logs/cron.log 2>&1
```

**Option B: Container Daemon Mode**
```bash
# Run container with built-in cron
docker-compose --profile daemon up -d epg-updater-daemon
```

### 4. Manual Run
```bash
# One-time update
docker-compose run --rm epg-updater

# View logs
tail -f /mnt/docker/epg/logs/update_*.log
```

## Configuration

### Environment Variables
Create `.env` file in this directory:
```env
# Timezone
TZ=America/Chicago

# User/Group IDs
PUID=1000
PGID=1000

# xTeve connection
XTEVE_HOST=xteve
XTEVE_PORT=34400

# Notifications (optional)
WEBHOOK_URL=https://discord.com/api/webhooks/YOUR/WEBHOOK
NOTIFICATION_LEVEL=ERROR  # ERROR, WARN, INFO

# M3U settings
M3U_URL=http://your-provider.com/playlist.m3u
M3U_USER_AGENT=TiviMate/4.3.0
M3U_MIN_CHANNELS=50

# Cron schedule (daemon mode only)
EPG_UPDATE_SCHEDULE=0 4,16 * * *
```

### File Locations
- **Data**: `/mnt/docker/epg/data/`
  - `xteve.m3u` - Generated M3U for xTeve
  - `epg.xml` - EPG data
  - `playlist.m3u` - Downloaded raw M3U
  
- **Logs**: `/mnt/docker/epg/logs/`
  - `update_*.log` - Update logs
  - `metrics.json` - Performance metrics
  - `health.log` - Health check logs
  
- **Config**: `/mnt/docker/epg/config/`
  - `tv_grab_na_dd.conf` - Schedules Direct config

## Monitoring

### Health Checks
The container includes automatic health monitoring:
- xTeve API availability
- File freshness (25-hour threshold)
- Update success/failure metrics

### View Health Status
```bash
# Check container health
docker inspect epg-updater-daemon | jq '.[0].State.Health'

# View metrics
tail -f /mnt/docker/epg/logs/metrics.json | jq '.'

# Check last update
ls -la /mnt/docker/epg/data/
```

### Notifications
Configure `WEBHOOK_URL` for Discord/Slack alerts on:
- Update failures
- Validation errors  
- Missing files
- API connection issues

## Troubleshooting

### Container Won't Start
```bash
# Check logs
docker-compose logs epg-updater

# Verify network
docker network ls | grep xteve-network

# Test manually
docker-compose run --rm epg-updater shell
```

### Updates Failing
```bash
# Run with debug output
docker-compose run --rm -e LOG_LEVEL=DEBUG epg-updater

# Check file permissions
ls -la /mnt/docker/epg/

# Verify xTeve is accessible
curl http://localhost:34400/api/status
```

### No EPG Data
```bash
# Check Schedules Direct config
cat /mnt/docker/epg/config/tv_grab_na_dd.conf

# Test EPG fetch manually
docker-compose run --rm epg-updater shell
tv_grab_na_dd --config-file /app/config/tv_grab_na_dd.conf --days 1
```

## Advanced Usage

### Custom Scripts
Mount additional scripts:
```yaml
volumes:
  - ./custom-scripts:/app/custom:ro
```

### Resource Limits
Add to docker-compose.yml:
```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
```

### Multiple Instances
Run different configs:
```bash
# Dev environment
docker-compose -f docker-compose.yml -f docker-compose.dev.yml run epg-updater

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml run epg-updater
```

## Maintenance

### Update Container
```bash
# Rebuild with latest changes
docker-compose build --no-cache epg-updater

# Remove old images
docker image prune -f
```

### Backup Data
```bash
# Backup EPG data
tar -czf epg-backup-$(date +%Y%m%d).tar.gz -C /mnt/docker/epg .
```

### Log Rotation
Logs are automatically rotated. To adjust:
```bash
# Edit log retention in container
docker-compose run --rm epg-updater shell
vi /app/epg_update_container.sh  # Adjust cleanup function
```

## Security

- Runs as non-root user (UID 1000)
- Read-only mount for xTeve directory
- No host network access required
- Minimal Alpine Linux base
- Regular security updates via rebuild

## Support

For issues:
1. Check `/mnt/docker/epg/logs/` for errors
2. Run health check: `docker-compose run --rm epg-updater healthcheck`
3. Enable debug logging: `LOG_LEVEL=DEBUG`
4. Test in shell: `docker-compose run --rm epg-updater shell`