# EPG Update System - DevOps Documentation

## Executive Summary
Production-grade EPG/M3U update system for xTeve IPTV proxy with 95% reliability target. System processes 185,565+ programs across 598 channels with automated daily updates from Schedules Direct.

## 🐳 Docker Architecture

### Container Specification
```yaml
Container: xteve-streaming
Image: alturismo/xteve:latest
Network: bridge mode (172.30.0.9:34400-34401)
User: root (container internal)
Restart: unless-stopped
GPU: NVIDIA runtime enabled
Healthcheck: 
  - Test: wget -q --spider http://localhost:34400/web/
  - Interval: 30s
  - Timeout: 10s
  - Retries: 3
  - Start Period: 40s
```

### Volume Mount Matrix
```
HOST PATH                      →  CONTAINER PATH              PERMISSIONS  PURPOSE
/mnt/docker/xteve/             →  /home/xteve/conf            rw           Configuration root
/mnt/docker/xteve/data/        →  /home/xteve/conf/data/      rw           M3U/XML data files  
/mnt/docker/xteve/playlists/   →  /mnt/playlists              rw           Additional playlists
/mnt/docker/xteve/config/      →  /home/xteve/conf/config/    rw           xTeve settings
```

### Critical File Paths
```
# Container Internal Paths
/home/xteve/.xteve/settings.json     # xTeve main configuration
/home/xteve/.xteve/data/             # xTeve generated files
/home/xteve/conf/data/sd.xml         # Schedules Direct EPG
/home/xteve/conf/data/xteve.xml      # Processed EPG for xTeve
/home/xteve/conf/data/xteve.m3u      # Channel playlist

# Host System Paths  
/mnt/docker/xteve/epg_update.lock    # Lock directory for updates
/mnt/docker/xteve/logs/               # Application logs (host only)
~/.xmltv/tv_grab_na_dd.conf          # Schedules Direct config
```

## System Components

### 1. Main Update Script (`epg_update_production.sh`)

#### Recent Fixes (August 11, 2025)
- **Lock Mechanism**: Migrated from `/var/run/` to `/mnt/docker/xteve/epg_update.lock` (permission fix)
- **Function Execution**: Fixed bash subshell sourcing with `EPG_UPDATE_SOURCED=1` environment variable
- **Timeout Values**: Increased from 300s to 900s for EPG downloads
- **Recursion Prevention**: Script detects when sourced vs executed directly

#### Technical Specifications
```bash
# Configuration Constants
SCRIPT_DIR="/mnt/docker/xteve"
LOG_DIR="${SCRIPT_DIR}/logs"
LOCK_FILE="${SCRIPT_DIR}/epg_update.lock"
MAX_RETRIES=3
TIMEOUT_SECONDS=900  # 15 minutes
HEALTHCHECK_URL="http://localhost:34400/api/status"
```

#### Features
- **Concurrency Control**: Directory-based lock using `mkdir` for atomicity
- **Retry Logic**: Exponential backoff (3 attempts, 10s * attempt number)
- **Validation**: XML syntax check, minimum channel count (50)
- **Rollback**: Automatic `.backup` file creation and restoration on failure
- **Error Handling**: Comprehensive error codes and logging
- **Alerting**: Slack webhook, Pushover, syslog integration points

### 2. Health Monitoring (`monitor_epg_health.sh`)
- **Schedule**: Every 5 minutes via cron
- **Metrics**: Container health, file freshness (24h threshold), API availability, disk space
- **Alert Threshold**: 3 consecutive failures
- **Output**: JSON metrics at `/mnt/docker/xteve/logs/health_metrics.json`

### 3. EPG Data Flow
```
Schedules Direct API (72.8MB compressed)
    ↓ tv_grab_na_dd (5-10 min, 70-80% CPU)
    ↓ /tmp/epg_XXXXX.xml (temporary)
    ↓ iconv (ISO-8859-1 → UTF-8)
    ↓ /mnt/docker/xteve/data/sd.xml (101MB)
    ↓ cp to data/xteve.xml
    ↓ Docker container reads from /home/xteve/conf/data/
    ↓ xTeve processes and serves on port 34400
```

## Performance Metrics

### EPG Download Performance
| Metric | Initial Fetch | Daily Update | Notes |
|--------|--------------|--------------|-------|
| Duration | 5-10 minutes | 2-3 minutes | Incremental after initial |
| CPU Usage | 70-80% | 40-50% | XML parsing intensive |
| Memory | ~500MB | ~300MB | Perl process memory |
| Network | 72.8MB | 10-20MB | Compressed transfer |
| Disk I/O | 200MB write | 100MB write | Uncompressed XML |

### System Requirements
- **CPU**: 2+ cores recommended (single core at 80% during update)
- **Memory**: 1GB minimum, 2GB recommended
- **Disk**: 500MB for EPG data, 100MB for logs
- **Network**: 10Mbps+ for timely downloads

## Operational Procedures

### Deployment Checklist
```bash
# 1. Verify Schedules Direct configuration
test -f ~/.xmltv/tv_grab_na_dd.conf && echo "✓ Config exists"

# 2. Test EPG grabber
tv_grab_na_dd --version

# 3. Verify container health
docker ps --filter name=xteve --format "table {{.Status}}"

# 4. Check disk space
df -h /mnt/docker/xteve

# 5. Validate cron jobs
crontab -l | grep epg_update_production

# 6. Test manual update
./epg_update_production.sh
```

### Incident Response

#### Scenario: EPG Update Failure
```bash
# 1. Check lock status
ls -la /mnt/docker/xteve/epg_update.lock

# 2. View recent logs
tail -100 logs/epg_update_$(date +%Y%m%d).log

# 3. Check for stuck processes
ps aux | grep -E "tv_grab_na_dd|epg_update"

# 4. Force cleanup
rm -rf /mnt/docker/xteve/epg_update.lock
pkill -f tv_grab_na_dd
pkill -f epg_update_production

# 5. Manual update with debug
bash -x ./epg_update_production.sh 2>&1 | tee debug.log
```

#### Scenario: Container Unhealthy
```bash
# 1. Check health status
docker inspect xteve --format='{{json .State.Health}}' | jq

# 2. View container logs
docker logs xteve --since 1h --tail 500

# 3. Check resource usage
docker stats xteve --no-stream

# 4. Restart sequence
docker restart xteve
sleep 30
curl -I http://localhost:34400

# 5. Force recreate if needed
docker-compose down xteve
docker-compose up -d xteve
```

## Monitoring & Alerting

### Key Metrics to Monitor
| Metric | Warning Threshold | Critical Threshold | Check Frequency |
|--------|------------------|-------------------|-----------------|
| EPG Age | > 24 hours | > 48 hours | Hourly |
| Container Health | Unhealthy | Dead/Exited | 5 minutes |
| API Response Time | > 2s | > 5s | 5 minutes |
| Disk Usage | > 80% | > 90% | Hourly |
| Update Duration | > 15 min | > 30 min | Per execution |
| Channel Count | < 80 | < 50 | Daily |

### Log Analysis
```bash
# Failed updates today
grep "ERROR\|FAILED" logs/epg_update_$(date +%Y%m%d).log

# Average update duration
grep "EPG Update.*succeeded" logs/*.log | \
  awk '{print $NF}' | awk -F: '{print ($1*60)+$2}' | \
  awk '{sum+=$1} END {print "Average:",sum/NR,"seconds"}'

# Lock contention events
grep "Waiting for lock" logs/*.log | wc -l
```

## Security Considerations

### Credential Management
- **Schedules Direct**: Stored in `~/.xmltv/tv_grab_na_dd.conf` (mode 600)
- **pvserver.link**: Embedded in M3U URLs (consider proxy/vault)
- **Container**: Runs as non-root (UID 1000)

### Network Security
- **Host networking**: Required for xTeve, increases attack surface
- **API endpoints**: No authentication on localhost:34400
- **Recommendation**: Implement reverse proxy with auth for external access

### File Permissions
```bash
# Recommended permissions
chmod 755 /mnt/docker/xteve
chmod 644 /mnt/docker/xteve/data/*.xml
chmod 644 /mnt/docker/xteve/data/*.m3u
chmod 755 /mnt/docker/xteve/*.sh
chmod 600 ~/.xmltv/tv_grab_na_dd.conf
```

## Backup & Recovery

### Automated Backup Strategy
```bash
# Daily backup before update (in epg_update_production.sh)
cp data/sd.xml data/sd.xml.backup
cp data/xteve.m3u data/xteve.m3u.backup

# Weekly backup retention
find /mnt/docker/xteve/data -name "*.backup" -mtime +7 -delete
```

### Disaster Recovery
```bash
# Full system backup
tar czf xteve_backup_$(date +%Y%m%d).tar.gz \
  /mnt/docker/xteve/data \
  /mnt/docker/xteve/config \
  /mnt/docker/xteve/good.csv \
  ~/.xmltv/tv_grab_na_dd.conf

# Restore procedure
tar xzf xteve_backup_YYYYMMDD.tar.gz -C /
docker-compose up -d xteve
```

## GPU-Accelerated Buffering

### MSNBC Buffer Configuration
MSNBC (Channel 215) uses dedicated GPU-accelerated buffering to prevent stream interruptions.

#### Architecture
```
IPTV Provider → FFmpeg (CUDA) → HLS Segments → HTTP Server → xTeVe → Clients
```

#### Key Components
- **Buffer Service**: `http://192.168.3.11:8888/playlist.m3u8`
- **GPU Encoding**: NVIDIA h264_nvenc with CUDA acceleration
- **Buffer Storage**: `/mnt/ramdisk/buffer-MSNBC/` (RAM disk)
- **Segment Config**: 180 x 10-second HLS segments (30-minute buffer)
- **Bitrate**: 2Mbps target, 2.5Mbps max, 4MB buffer

#### Monitoring
```bash
# Check buffer status
ps aux | grep msnbc
ls -la /mnt/ramdisk/buffer-MSNBC/
nvidia-smi | grep ffmpeg

# View buffer logs
tail -f /tmp/MSNBC.log
```

For detailed buffer configuration, see [MSNBC_BUFFER_SETUP.md](MSNBC_BUFFER_SETUP.md).

## Optimization Opportunities

### Current Bottlenecks
1. **XML Parsing**: Single-threaded Perl process (tv_grab_na_dd)
2. **File I/O**: Large XML files written multiple times
3. **Container Restart**: Required for config reload
4. **Stream Reliability**: Direct IPTV provider streams may fail (403 errors)

### Implemented Solutions
1. **GPU Buffering**: MSNBC now uses GPU-accelerated HLS buffer
2. **RAM Disk**: Buffer segments stored in RAM for fast I/O
3. **Local HTTP Server**: Eliminates external stream dependencies
4. **Automatic Failover**: Buffer service auto-restarts on failure

### Proposed Improvements
1. **Extend buffering** to other critical channels
2. **Implement caching layer** for unchanged program data
3. **Use incremental updates** via Schedules Direct delta API
4. **Add Prometheus metrics** for buffer health monitoring
5. **Implement multi-GPU** load balancing for multiple channels

## Maintenance Schedule

### Daily (Automated)
- 02:00 CST: Video conversion (`/mnt/television.shows/convert/`)
- 04:00 CST: EPG update via `epg_update_production.sh`
- 04:00, 16:00 CST: Docker-compose EPG updater (duplicate at 4 AM)
- Hourly: EPG health check via Docker container
- 23:00 CST: Documentation backup to Google Drive

### Weekly (Manual)
- Review error logs for patterns
- Check disk usage trends
- Validate backup integrity

### Monthly
- Update dependencies (xmltv-util)
- Review Schedules Direct lineup changes
- Performance metrics analysis

### Quarterly
- Security patches for container image
- Credential rotation
- Capacity planning review

## Configuration Management

### Environment Variables
```bash
# Add to /etc/environment or docker-compose.yml
SLACK_WEBHOOK="https://hooks.slack.com/services/..."
PUSHOVER_TOKEN="..."
PUSHOVER_USER="..."
EPG_UPDATE_SOURCED=0  # For script recursion prevention
TZ="America/Chicago"
```

### Version Control Recommendations
```
/mnt/docker/xteve/
├── .gitignore (data/, logs/, *.lock)
├── docker-compose.yml
├── scripts/
│   ├── epg_update_production.sh
│   └── monitor_epg_health.sh
├── config/ (tracked)
└── docs/ (this documentation)
```

## Appendix: Quick Reference

### Command Cheatsheet
```bash
# Status checks
docker ps -f name=xteve
tail -f logs/epg_update_$(date +%Y%m%d).log
curl -s http://localhost:34400/api/status | jq

# Manual operations  
./epg_update_production.sh
tv_grab_na_dd --configure
docker restart xteve

# Troubleshooting
rm -rf epg_update.lock
pkill -f tv_grab_na_dd
docker logs xteve --tail 200
```

### File Sizes Reference
- EPG XML: ~100MB (compressed: 15MB)
- M3U Playlist: ~30KB
- Container Image: ~50MB
- Daily Logs: ~5MB

### Support Contacts
- Schedules Direct: https://schedulesdirect.org (Expires: 2026-04-04)
- xTeve Documentation: https://github.com/xteve-project/xTeVe
- Docker Hub: xteve-uid1000 (custom image)

---
*Last Updated: August 23, 2025*
*Version: 3.0.0*
*Major Update: Added GPU-accelerated buffering for MSNBC*