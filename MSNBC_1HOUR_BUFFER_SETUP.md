# MSNBC 1-Hour Buffer Configuration

## Overview
MSNBC is configured with a dedicated 1-hour buffer using the RAM disk at `/mnt/ramdisk` for smooth, uninterrupted streaming with optional GPU transcoding support.

## Current Configuration

### Buffer Settings
- **Buffer Duration**: 1 hour (3600 seconds)
- **Storage Location**: `/mnt/ramdisk/xteve-buffer/MSNBC` (RAM disk)
- **Transcode Temp**: `/mnt/transcode/msnbc_temp` (SSD for GPU transcoding)
- **Expected Size**: 4-5 GB for HD stream
- **Segment Duration**: 10 seconds
- **Total Segments**: 360 (maintained as rolling buffer)
- **Proxy Port**: 8888

### GPU Transcoding (Enhanced Version)
- **NVIDIA GPU**: H.264 NVENC encoding
- **Intel/AMD GPU**: VAAPI hardware acceleration
- **Output Quality**: 6Mbps @ 1920x1080
- **Fallback**: Codec copy mode if no GPU detected

### Stream Details
- **Channel Number**: 215
- **Channel Name**: MSNBC
- **Buffer URL (Local)**: `http://192.168.3.11:8888/playlist.m3u8`
- **Buffer URL (External)**: `https://msnbc.yourdomain.com/playlist.m3u8` (via NPM)
- **Status API**: `http://192.168.3.11:8888/status`

## Starting the Buffer

### Standard Version (Codec Copy)
```bash
cd /mnt/docker/xteve
./msnbc_1hour_buffer.sh
```

### GPU-Enhanced Version (Hardware Transcoding)
```bash
cd /mnt/docker/xteve
./msnbc_1hour_buffer_gpu.sh
```

The GPU-enhanced script will:
1. Detect available GPU (NVIDIA/Intel/AMD)
2. Clean up any existing MSNBC buffers
3. Create buffer directory on RAM disk
4. Use `/mnt/transcode` for temporary transcoding if available
5. Start FFmpeg with hardware acceleration
6. Launch HTTP proxy server with status API on port 8888
7. Build up to 1 hour of buffered content

## Monitoring the Buffer

### Check Buffer Status
```bash
# See segment count (should reach 360 for full 1-hour)
ls -la /mnt/ramdisk/xteve-buffer/MSNBC/*.ts | wc -l

# Check buffer size
du -sh /mnt/ramdisk/xteve-buffer/MSNBC

# Monitor RAM disk usage
df -h /mnt/ramdisk
```

### View Buffer Logs
```bash
# Check if buffer process is running
ps aux | grep msnbc_1hour_buffer

# View segment creation in real-time
watch -n 5 'ls -la /mnt/ramdisk/xteve-buffer/MSNBC/*.ts | tail -5'
```

## Using the Buffered Stream

### In xTeve
Add this URL as a custom M3U source:
```
#EXTM3U
#EXTINF:-1 tvg-id="I16300.labs.zap2it.com" tvg-name="MSNBC (1hr Buffer)" tvg-chno="215",MSNBC Buffered
http://192.168.3.11:8888/playlist.m3u8
```

### Direct Playback
Use VLC or any HLS-compatible player:
```bash
vlc http://192.168.3.11:8888/playlist.m3u8
```

## Stopping the Buffer

### Manual Stop
```bash
# Find and kill the buffer processes
kill $(cat /mnt/ramdisk/xteve-buffer/MSNBC/ffmpeg.pid)
kill $(cat /mnt/ramdisk/xteve-buffer/MSNBC/proxy.pid)

# Or kill all MSNBC buffer processes
pkill -f "msnbc.*buffer"
```

### Clean Up
```bash
# Remove buffer files (frees RAM disk space)
rm -rf /mnt/ramdisk/xteve-buffer/MSNBC
```

## Automatic Startup

To start the buffer automatically at system boot, add to crontab:
```bash
@reboot sleep 60 && cd /mnt/docker/xteve && ./msnbc_1hour_buffer.sh > /var/log/msnbc_buffer.log 2>&1
```

## Benefits of 1-Hour Buffer

1. **Smooth Playback**: Eliminates stuttering from network issues
2. **Time-Shifting**: Can pause/rewind up to 1 hour
3. **Fast Channel Loading**: Pre-buffered content starts instantly
4. **Network Resilience**: Handles connection drops gracefully
5. **RAM Disk Speed**: Ultra-fast read/write performance

## Troubleshooting

### Buffer Not Starting
- Check RAM disk space: `df -h /mnt/ramdisk`
- Verify stream URL is active: `curl -I http://pvserver.link:8080/play/LSTZs2UO40ys7tCxS8rNVc5VhbKk6ljzMZXroB5I2qc`
- Check for port conflicts: `sudo ss -tlnp | grep 8888`

### Buffer Size Too Large
- Reduce segment count in script (BUFFER_SEGMENTS)
- Clear old segments: `rm /mnt/ramdisk/xteve-buffer/MSNBC/segment_*.ts`

### Stream Interruptions
- Check FFmpeg process: `ps aux | grep ffmpeg | grep MSNBC`
- Review FFmpeg errors: `tail -f /mnt/ramdisk/xteve-buffer/MSNBC/ffmpeg.log`

## Resource Usage

### Standard Mode (Codec Copy)
- **RAM**: ~5GB maximum for 1-hour HD buffer
- **CPU**: Minimal (copy codec, no transcoding)
- **Network**: Same as regular streaming
- **Disk I/O**: None (RAM disk only)

### GPU Transcoding Mode
- **RAM**: ~5GB for buffer + ~500MB for transcoding
- **GPU**: 20-40% utilization (hardware encoding)
- **CPU**: Minimal (offloaded to GPU)
- **SSD**: Temporary segments in `/mnt/transcode` if configured
- **Network**: Same as regular streaming

## Integration with xTeve/Plex

The buffered stream integrates seamlessly:
1. xTeve treats it as a standard HLS stream
2. Plex can access through xTeve
3. Multiple clients can watch simultaneously
4. Each client can pause/resume independently

## External Access

### Via Nginx Proxy Manager
Configure NPM to expose the stream externally:
- Domain: `msnbc.yourdomain.com`
- SSL: Let's Encrypt certificate
- See `/mnt/docker/documentation/MSNBC_EXTERNAL_ACCESS_SETUP.md` for detailed configuration

### Via VPN
Connect through WireGuard VPN for secure access:
- Direct stream URL: `http://192.168.3.11:8888/playlist.m3u8`
- No additional configuration needed once VPN is connected

## GPU Monitoring

### NVIDIA GPU
```bash
# Real-time GPU usage
nvidia-smi dmon -s pucvmet

# Check encoder usage
nvidia-smi encodersessions
```

### Intel/AMD GPU (VAAPI)
```bash
# Install Intel GPU tools if needed
sudo apt install intel-gpu-tools

# Monitor GPU usage
sudo intel_gpu_top
```

---
*Last Updated: 2025-09-05*
*Standard Script: `/mnt/docker/xteve/msnbc_1hour_buffer.sh`*
*GPU Script: `/mnt/docker/xteve/msnbc_1hour_buffer_gpu.sh`*
*External Access: `/mnt/docker/documentation/MSNBC_EXTERNAL_ACCESS_SETUP.md`*