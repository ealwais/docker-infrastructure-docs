# MSNBC Stream Management Guide

## Quick Reference

### Stream URLs
- **Local Stream**: `http://192.168.3.11:8888/playlist.m3u8`
- **Source Stream**: `http://pvserver.link:8080/play/LSTZs2UO40ys7tCxS8rNVUz-GLQYaW1owXYLzbVH3Iw`

### Essential Commands

#### Check Stream Status
```bash
/mnt/docker/tvheadend/msnbc-monitor-status.sh
```

#### Start/Restart Stream
```bash
# Primary restart script (includes GPU acceleration)
/mnt/docker/tvheadend/restart-msnbc-buffer.sh

# Alternative restart script
/mnt/docker/tvheadend/msnbc-restart.sh

# Direct GPU-accelerated start script
/mnt/docker/tvheadend/msnbc-gpu-buffer-improved.sh
```

#### View Logs
```bash
# Stream logs
tail -f /tmp/MSNBC.log

# Restart logs
tail -f /tmp/msnbc-restart.log
```

## Server Access

### SSH Alias Setup
Add this to your local `~/.ssh/config`:
```
Host tvheadend
    HostName 192.168.3.11
    User ealwais
    Port 22
```

Then connect with:
```bash
ssh tvheadend
```

### Quick Stream Management Alias
Add these to your `~/.bashrc` on the server:
```bash
# MSNBC Stream Management
alias msnbc-status='/mnt/docker/tvheadend/msnbc-monitor-status.sh'
alias msnbc-restart='/mnt/docker/tvheadend/restart-msnbc-buffer.sh'
alias msnbc-start='/mnt/docker/tvheadend/msnbc-gpu-buffer-improved.sh'
alias msnbc-logs='tail -f /tmp/MSNBC.log'
alias msnbc-monitor='watch -n 5 /mnt/docker/tvheadend/msnbc-monitor-status.sh'
```

## Monitoring

### Live Monitor (updates every 5 seconds)
```bash
watch -n 5 /mnt/docker/tvheadend/msnbc-monitor-status.sh
```

### What to Look For
- **Green checkmarks** (✓) = Healthy
- **Yellow warnings** (⚠) = Needs attention
- **Red X marks** (✗) = Problem detected

### Key Indicators
1. **Process Status**: Both FFmpeg and HTTP server should be running
2. **Playlist Age**: Should update every 10-30 seconds
3. **Segment Count**: Should maintain 30-180 segments
4. **HTTP Test**: Stream should be accessible

## Script Overview

### Main Scripts
- **`msnbc-gpu-buffer-improved.sh`**: Primary GPU-accelerated streaming script with CUDA/NVENC support
- **`restart-msnbc-buffer.sh`**: Wrapper that stops existing streams and starts the GPU-accelerated version
- **`msnbc-monitor-status.sh`**: Real-time status monitoring showing process health, playlist updates, and buffer size
- **`msnbc-auto-monitor.sh`**: Automatic health monitoring and restart capability

### Features
- **GPU Acceleration**: Uses NVIDIA CUDA for hardware decoding and NVENC for encoding
- **30-minute buffer**: Maintains 180 HLS segments (10 seconds each)
- **Auto-reconnect**: Handles stream interruptions with exponential backoff
- **Health monitoring**: Continuous stream health checks and automatic recovery
- **2Mbps bitrate**: Optimized for quality streaming

## Troubleshooting

### Stream Not Working
1. Check status: `msnbc-status` or `/mnt/docker/tvheadend/msnbc-monitor-status.sh`
2. If processes missing or playlist stale: `msnbc-restart` or `/mnt/docker/tvheadend/restart-msnbc-buffer.sh`
3. Check source stream: `ffprobe http://pvserver.link:8080/play/LSTZs2UO40ys7tCxS8rNVUz-GLQYaW1owXYLzbVH3Iw`

### Common Issues

#### "Stream NOT accessible"
- Restart the stream: `msnbc-restart`
- Check if port 8888 is blocked: `sudo iptables -L -n | grep 8888`

#### "Playlist is STALE"
- Stream has stopped updating
- Run: `msnbc-restart`

#### "Source stream test failed"
- Upstream server is down
- Wait and try again later
- Check alternative streams in `/mnt/docker/tvheadend/config/`

### Manual Process Management
```bash
# Find process IDs
ps aux | grep -E 'ffmpeg.*msnbc|python3.*8888'

# Kill specific processes
kill <PID>

# Force kill all MSNBC processes
pkill -f "stream-MSNBC|ffmpeg.*msnbc|python3.*8888"
```

## Auto-Recovery

### Enable Auto-Monitor (Optional)
The auto-monitor will check stream health every minute and restart if needed:
```bash
# Start auto-monitor in background
nohup /mnt/docker/tvheadend/msnbc-auto-monitor.sh > /tmp/msnbc-auto-monitor.log 2>&1 &

# Check auto-monitor logs
tail -f /tmp/msnbc-auto-monitor.log

# Stop auto-monitor
pkill -f msnbc-auto-monitor
```

## Integration with Plex/Jellyfin

Add this M3U playlist to your media server:
```
#EXTM3U
#EXTINF:-1,MSNBC HD
http://192.168.3.11:8888/playlist.m3u8
```

## Quick One-Liners

```bash
# Check if stream is up (returns 0 if OK)
curl -s -f -m 2 http://192.168.3.11:8888/playlist.m3u8 > /dev/null && echo "Stream OK" || echo "Stream DOWN"

# Get stream uptime
ps -o etime= -p $(pgrep -f "ffmpeg.*msnbc" | head -1) 2>/dev/null || echo "Not running"

# Buffer size
du -sh /tmp/buffer-MSNBC/

# Segment count
ls /tmp/buffer-MSNBC/*.ts 2>/dev/null | wc -l
```

## Emergency Recovery

If nothing else works:
```bash
# Nuclear option - clean everything and restart
sudo pkill -9 -f "msnbc|8888"
sudo rm -rf /tmp/buffer-MSNBC /tmp/MSNBC* /tmp/msnbc*
cd /mnt/docker/tvheadend
./msnbc-restart.sh
```