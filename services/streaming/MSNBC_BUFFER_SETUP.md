# MSNBC GPU-Accelerated Buffer Configuration

## Overview
This document details the GPU-accelerated buffering system for MSNBC (Channel 215) that prevents stream interruptions and provides smooth playback through xTeVe.

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌────────────────┐
│  IPTV Provider  │────▶│  GPU Buffer      │────▶│  HTTP Server   │
│  pvserver.link  │     │  (FFmpeg/CUDA)   │     │  Port 8888     │
└─────────────────┘     └──────────────────┘     └────────────────┘
                                │                          │
                                ▼                          ▼
                        ┌──────────────────┐     ┌────────────────┐
                        │  HLS Segments    │     │     xTeVe      │
                        │  /mnt/ramdisk/   │────▶│  Port 34400    │
                        └──────────────────┘     └────────────────┘
                                                          │
                                                          ▼
                                                  ┌────────────────┐
                                                  │  Plex/Clients  │
                                                  └────────────────┘
```

## Current Configuration

### Service Details
- **Buffer Service URL**: `http://192.168.3.11:8888/playlist.m3u8`
- **xTeVe Channel**: 215 (MSNBC)
- **GPU Acceleration**: NVIDIA CUDA with h264_nvenc encoder
- **Buffer Location**: `/mnt/ramdisk/buffer-MSNBC/`
- **Process Owner**: ealwais (UID 31337)

### Active Processes
```bash
# Main buffer script
/tmp/msnbc-stream.sh

# Buffer management
/mnt/docker/tvheadend/msnbc-buffer-fixed.sh

# HTTP server for HLS delivery
python3 -m http.server 8888 --bind 0.0.0.0

# FFmpeg transcoding with GPU
ffmpeg -hwaccel cuda -hwaccel_device 0 -i [source] \
  -c:v h264_nvenc -preset p4 -tune hq \
  -b:v 2M -maxrate 2.5M -bufsize 4M \
  -f hls -hls_time 10 -hls_list_size 180
```

## FFmpeg Configuration

### GPU Settings
```
-hwaccel cuda                 # Use CUDA for hardware acceleration
-hwaccel_device 0             # GPU device 0
-c:v h264_nvenc               # NVIDIA H.264 encoder
-preset p4                    # Performance preset (balanced)
-tune hq                      # High quality tuning
```

### Bitrate Control
```
-b:v 2M                       # Target bitrate: 2 Mbps
-maxrate 2.5M                 # Maximum bitrate: 2.5 Mbps
-bufsize 4M                   # VBV buffer size: 4 MB
```

### HLS Output
```
-f hls                        # HLS format output
-hls_time 10                  # 10-second segments
-hls_list_size 180            # Keep 180 segments (30 minutes)
-hls_flags delete_segments    # Auto-delete old segments
-hls_flags append_list        # Append to playlist
```

## File Structure

### Buffer Directory (`/mnt/ramdisk/buffer-MSNBC/`)
```
playlist.m3u8          # Master HLS playlist
segment2310.ts         # Video segments (10 seconds each)
segment2311.ts
segment2312.ts
...
segment2489.ts         # Up to 180 segments maintained
```

### Configuration Files
```
/mnt/docker/xteve/data/good.csv           # Channel mappings with URLs
/mnt/docker/xteve/data/xteve.m3u          # Generated M3U playlist
/mnt/docker/xteve/config/settings.json    # xTeVe configuration
```

## Monitoring & Maintenance

### Check Buffer Status
```bash
# View running processes
ps aux | grep -E "msnbc|8888" | grep -v grep

# Check buffer segments
ls -la /mnt/ramdisk/buffer-MSNBC/ | head -20

# Monitor buffer logs
tail -f /tmp/MSNBC.log

# Test stream availability
curl -I http://192.168.3.11:8888/playlist.m3u8

# View HLS playlist
curl -s http://192.168.3.11:8888/playlist.m3u8
```

### GPU Monitoring
```bash
# Check GPU usage
nvidia-smi

# Monitor GPU encoding
nvidia-smi dmon -s pucvmet

# View GPU processes
nvidia-smi pmon -i 0
```

### Stream Health Check
```bash
# Test segment download
curl -o /tmp/test.ts http://192.168.3.11:8888/segment2310.ts
ffprobe /tmp/test.ts

# Check xTeVe stream endpoint
curl -I http://localhost:34400/stream/8f08000e3e4a1332f34b79f31e14f71b
```

## Troubleshooting

### Issue: Buffer Not Running
```bash
# Check if processes are running
ps aux | grep msnbc

# Restart buffer service
pkill -f msnbc
/mnt/docker/tvheadend/msnbc-buffer-fixed.sh &

# Verify HTTP server
python3 -m http.server 8888 --bind 0.0.0.0 &
```

### Issue: No Video Segments
```bash
# Check ramdisk space
df -h /mnt/ramdisk

# Clear old segments
rm -rf /mnt/ramdisk/buffer-MSNBC/*

# Restart FFmpeg process
pkill -f ffmpeg
# Buffer script should auto-restart
```

### Issue: xTeVe Not Using Buffer
```bash
# Verify URL in good.csv
grep MSNBC /mnt/docker/xteve/data/good.csv

# Should show: http://192.168.3.11:8888/playlist.m3u8
# If not, update:
python3 /mnt/docker/xteve/fix_specific_urls.py

# Regenerate M3U
cd /mnt/docker/xteve
python3 create_xteve_m3u.py

# Restart xTeVe
docker restart xteve-streaming
```

### Issue: Stream Stuttering
```bash
# Increase buffer segments
# Edit buffer script to use:
-hls_list_size 360  # 1 hour buffer

# Increase bitrate buffer
-bufsize 8M  # Larger VBV buffer

# Use faster preset
-preset p2  # Faster encoding, lower quality
```

## Performance Tuning

### GPU Optimization
```bash
# Set GPU to maximum performance
sudo nvidia-smi -pm 1
sudo nvidia-smi -pl 350  # Set power limit

# Lock GPU clocks for consistent performance
sudo nvidia-smi -lgc 1410,1410
```

### Network Optimization
```bash
# Increase network buffers
sudo sysctl -w net.core.rmem_max=134217728
sudo sysctl -w net.core.wmem_max=134217728
sudo sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728"
sudo sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728"
```

### Ramdisk Optimization
```bash
# Ensure ramdisk is mounted with optimal settings
mount -t tmpfs -o size=4G,mode=1777 tmpfs /mnt/ramdisk

# Check current mount options
mount | grep ramdisk
```

## Backup & Recovery

### Backup Current Configuration
```bash
# Backup channel mappings
cp /mnt/docker/xteve/data/good.csv /mnt/docker/xteve/backup/good.csv.$(date +%Y%m%d)

# Backup xTeVe settings
docker exec xteve-streaming cat /root/.xteve/settings.json > /mnt/docker/xteve/backup/settings.$(date +%Y%m%d).json
```

### Restore Configuration
```bash
# Restore channel mappings
cp /mnt/docker/xteve/backup/good.csv.20250823 /mnt/docker/xteve/data/good.csv

# Regenerate M3U
cd /mnt/docker/xteve
python3 create_xteve_m3u.py

# Restart services
docker restart xteve-streaming
```

## Integration Points

### xTeVe Configuration
- Channel 215 mapped to `http://192.168.3.11:8888/playlist.m3u8`
- Buffer enabled in settings.json
- FFmpeg path configured

### Plex Integration
- xTeVe acts as HDHomeRun emulator
- Plex connects to `http://localhost:34400`
- Channel 215 available in Live TV

### Direct Access URLs
- Buffer Stream: `http://192.168.3.11:8888/playlist.m3u8`
- xTeVe Stream: `http://localhost:34400/stream/[channel-id]`
- Management UI: `http://localhost:34400/web/`

## Security Considerations

### Network Security
- HTTP server binds to all interfaces (0.0.0.0)
- Consider firewall rules to restrict access
- No authentication on buffer service

### Process Security
- Runs as user ealwais (non-root)
- GPU access requires video group membership
- Ramdisk provides isolation from disk I/O

## Maintenance Schedule

### Daily Tasks
- Monitor buffer logs for errors
- Check segment count (should be ~180)
- Verify GPU utilization < 80%

### Weekly Tasks
- Clear old log files in /tmp
- Check ramdisk usage
- Review stream quality metrics

### Monthly Tasks
- Update FFmpeg parameters if needed
- Review and optimize GPU settings
- Backup configuration files

## Related Documentation
- [README.md](README.md) - Main xTeVe setup guide
- [README_DEVOPS.md](README_DEVOPS.md) - DevOps procedures
- [EPG Update Documentation](epg_update_production.sh) - EPG update system

---
*Last Updated: August 23, 2025*
*Version: 1.0*