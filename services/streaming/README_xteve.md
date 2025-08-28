# xTeVe IPTV Proxy Setup - Simplified & Working

## Overview
This is a cleaned-up, working xTeVe setup for ARM64 Mac systems. It provides IPTV proxy functionality for Plex, with GPU-accelerated buffering for critical channels like MSNBC.

## Current Configuration

### Components
- **xTeVe Version**: 2.2.0 (alturismo/xteve:latest)
- **Ports**: 34400 (management), 34401 (streaming)
- **Channels**: 91 active channels with Schedules Direct EPG
- **Container**: Docker with GPU support (NVIDIA CUDA)
- **Buffering**: GPU-accelerated HLS buffering for MSNBC
- **Automation**: Cron jobs for automatic EPG updates

### Directory Structure
```
/mnt/docker/xteve/
├── config/           # xTeVe configuration files
│   ├── settings.json # Main settings (SSDP disabled)
│   └── data/        # M3U and XML files
├── data/            # Downloaded playlists
│   ├── texas.m3u    # Texas channels
│   ├── usa.m3u      # USA channels
│   └── merged.m3u   # Active playlist
├── logs/            # Update logs
├── update_xteve.sh  # Main update script
└── archive/         # Old scripts (archived)
```

## Quick Start

### Access xTeVe
- Web Interface: http://localhost:34400
- API Endpoint: http://localhost:34400/api/

### Container Management
```bash
# Start xTeVe
docker-compose -f /mnt/docker/plex/docker-compose-xteve.yml up -d

# Stop xTeVe
docker-compose -f /mnt/docker/plex/docker-compose-xteve.yml down

# View logs
docker logs xteve

# Restart
docker restart xteve
```

### Manual Update
```bash
/mnt/docker/xteve/update_xteve.sh
```

## Automatic Updates
Cron jobs run automatically:
- Daily at 3 AM - Full update
- Every 6 hours - Quick refresh

View cron jobs:
```bash
crontab -l
```

## Plex Integration

1. Open Plex Web UI: http://localhost:32400/web
2. Go to Settings → Live TV & DVR
3. Click "SET UP PLEX DVR"
4. Select "HDHomeRun" as device type
5. Enter xTeVe URL: http://localhost:34400
6. Plex should detect "xTeVe (1 Tuner)"
7. Follow the setup wizard

## Adding Your Own IPTV Provider

Edit `/mnt/docker/xteve/update_xteve.sh` and uncomment/configure:
```bash
IPTV_URL='http://your-provider.com/get.php?username=xxx&password=xxx&type=m3u_plus'
```

Then run:
```bash
/mnt/docker/xteve/update_xteve.sh
```

## MSNBC GPU-Buffered Stream

### Overview
MSNBC (Channel 215) uses a dedicated GPU-accelerated buffer to prevent stuttering and provide reliable streaming.

### Buffer Configuration
- **Service**: Running at `http://192.168.3.11:8888/playlist.m3u8`
- **GPU**: NVIDIA CUDA hardware acceleration (ffmpeg with h264_nvenc)
- **Buffer Location**: `/mnt/ramdisk/buffer-MSNBC/`
- **Segments**: 180 x 10-second HLS segments (30 minutes buffer)
- **Bitrate**: 2Mbps with 2.5Mbps max

### Monitoring Buffer Status
```bash
# Check if buffer service is running
ps aux | grep -i msnbc | grep -v grep

# View buffer segments
ls -la /mnt/ramdisk/buffer-MSNBC/ | head -10

# Check buffer logs
tail -f /tmp/MSNBC.log

# Test buffered stream
curl -I http://192.168.3.11:8888/playlist.m3u8
```

### Restarting MSNBC Buffer
```bash
# Find and kill existing processes
pkill -f msnbc-buffer
pkill -f "python3 -m http.server 8888"

# Restart buffer service (if script exists)
/mnt/docker/tvheadend/msnbc-buffer-fixed.sh &
```

## Channel Number Management

### Automatic Channel Number Fixing
xTeVe assigns sequential channel numbers (1000-1090) by default, but our setup automatically corrects these to match actual provider channel numbers (e.g., 215 for MSNBC, 140 for Comedy Central).

**How it works:**
- The `fix_channel_numbers_live.py` script reads correct channel numbers from `good.csv`
- Updates xTeVe's internal mappings to use actual channel numbers
- Runs automatically after each EPG update via cron (daily at 4 AM)
- Affects 91 channels total

**Manual execution:**
```bash
cd /mnt/docker/xteve
python3 fix_channel_numbers_live.py
```

**Channel number examples:**
- MSNBC: 1035 → 215
- Comedy Central: 1090 → 140
- CBS KEYE: 1009 → 5
- HBO: 1042 → 502

**Verify channel numbers:**
```bash
# Check current mappings in container
docker exec xteve-streaming cat /root/.xteve/xepg.json | grep -E '"x-channelID"|"x-name"' | head -20
```

See [CHANNEL_NUMBER_FIX_DOCUMENTATION.md](CHANNEL_NUMBER_FIX_DOCUMENTATION.md) for full details.

## Troubleshooting

### xTeVe not accessible
```bash
# Check if container is running
docker ps | grep xteve

# Check logs
docker logs xteve-streaming --tail 50

# Restart container
docker restart xteve-streaming
```

### No channels showing
```bash
# Run EPG update manually
/mnt/docker/xteve/epg_update_production.sh

# Check playlist
grep -c "^#EXTINF" /mnt/docker/xteve/data/xteve.m3u
```

### MSNBC buffering issues
```bash
# Check buffer status
curl -s http://192.168.3.11:8888/playlist.m3u8 | head -10

# Verify GPU is being used
nvidia-smi | grep ffmpeg

# Check xTeVe has correct URL
grep MSNBC /mnt/docker/xteve/data/good.csv | cut -d',' -f12
```

### Rebuild container
```bash
cd /mnt/docker/streaming-stack
docker-compose down xteve-streaming
docker-compose up -d xteve-streaming
```

## What Was Fixed

1. **ARM64 Compatibility**: Built native ARM64 image (no more QEMU emulation)
2. **SSDP Disabled**: Removed problematic multicast/SSDP features
3. **Simplified Scripts**: One update script instead of 50+ redundant ones
4. **Working Automation**: Cron jobs properly configured and running
5. **Free Channels**: Using iptv-org for testing (1000+ legal, free channels)
6. **Clean Structure**: Archived old scripts, organized directories

## Files Removed/Archived
- 50+ redundant Python scripts → archived in `/mnt/docker/xteve/archive/`
- Multiple conflicting update scripts → consolidated into one
- Broken Docker configurations → replaced with working setup

## Next Steps

1. Test channels in xTeVe web interface
2. Configure Plex DVR if needed
3. Add your IPTV provider credentials if you have a paid service
4. Monitor logs to ensure updates run successfully

## Support Resources

- xTeVe Documentation: https://github.com/xteve-project/xTeVe
- IPTV-org Channels: https://github.com/iptv-org/iptv
- Container Logs: `/mnt/docker/xteve/logs/`

---
Last Updated: August 23, 2025
Setup Version: 3.0 (GPU-Buffered MSNBC & Schedules Direct EPG)
