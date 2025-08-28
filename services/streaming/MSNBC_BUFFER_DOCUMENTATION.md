# MSNBC Buffer Stream Documentation

## Overview
The MSNBC buffer system provides a stable, buffered stream with automatic error recovery and GPU acceleration support.

## Fixed Issues
1. **Buffer Directory**: Now consistently uses `/mnt/ramdisk/buffer-MSNBC` for improved performance
2. **Directory Creation**: Ensures buffer directory exists before ffmpeg starts
3. **Error Recovery**: Automatic restart on stream failures
4. **GPU Detection**: Automatically uses GPU acceleration when available, falls back to CPU

## Main Scripts

### 1. msnbc-buffer-fixed.sh
**Purpose**: Main script to start MSNBC buffered stream
**Location**: `/mnt/docker/tvheadend/msnbc-buffer-fixed.sh`
**Features**:
- Auto-detects GPU for hardware acceleration
- Creates buffer in ramdisk for performance
- Health checks before starting
- Automatic error recovery
- HTTP server on port 8888

**Usage**:
```bash
/mnt/docker/tvheadend/msnbc-buffer-fixed.sh
```

### 2. restart-msnbc-buffer.sh
**Purpose**: Cleanly restart the MSNBC stream
**Location**: `/mnt/docker/tvheadend/restart-msnbc-buffer.sh`
**Usage**:
```bash
/mnt/docker/tvheadend/restart-msnbc-buffer.sh
```

### 3. msnbc-monitor-status.sh
**Purpose**: Display real-time stream status
**Location**: `/mnt/docker/tvheadend/msnbc-monitor-status.sh`
**Shows**:
- Process status and PIDs
- CPU/Memory usage
- Stream health
- Buffer statistics
- Recent errors

**Usage**:
```bash
/mnt/docker/tvheadend/msnbc-monitor-status.sh
```

### 4. msnbc-auto-monitor-fixed.sh
**Purpose**: Automatic monitoring with self-healing
**Location**: `/mnt/docker/tvheadend/msnbc-auto-monitor-fixed.sh`
**Features**:
- Checks stream health every 30 seconds
- Auto-restarts on failures
- Max 5 restarts per hour
- Detailed logging

**Usage**:
```bash
# Run in background
nohup /mnt/docker/tvheadend/msnbc-auto-monitor-fixed.sh &

# View monitor logs
tail -f /tmp/msnbc-monitor.log
```

## Stream URLs

- **Main Stream**: `http://192.168.3.11:8888/playlist.m3u8`
- **Buffer Location**: `/mnt/ramdisk/buffer-MSNBC/`
- **Log File**: `/tmp/MSNBC.log`

## Buffer Configuration

- **Buffer Duration**: 30 minutes (180 segments)
- **Segment Duration**: 10 seconds each
- **Video Bitrate**: 2 Mbps
- **Video Codec**: H.264 (NVENC with GPU, libx264 with CPU)
- **Audio**: Copy from source

## Troubleshooting

### Stream Not Starting
1. Check if ramdisk is mounted:
   ```bash
   mount | grep ramdisk
   ```
2. Check stream health:
   ```bash
   timeout 10 ffmpeg -i "http://pvserver.link:8080/play/LSTZs2UO40ys7tCxS8rNVUz-GLQYaW1owXYLzbVH3Iw" -t 1 -f null -
   ```

### Stream Stops Frequently
1. Check logs:
   ```bash
   tail -f /tmp/MSNBC.log
   ```
2. Enable auto-monitor:
   ```bash
   nohup /mnt/docker/tvheadend/msnbc-auto-monitor-fixed.sh &
   ```

### High CPU Usage
- The script automatically detects and uses GPU when available
- Check GPU usage:
  ```bash
  nvidia-smi dmon -s u
  ```

### Port 8888 Already in Use
```bash
# Find and kill process using port
lsof -ti:8888 | xargs kill -9
```

## Systemd Service Setup (Optional)

1. Copy service file:
   ```bash
   sudo cp /mnt/docker/tvheadend/msnbc-buffer.service /etc/systemd/system/
   ```

2. Enable and start:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable msnbc-buffer
   sudo systemctl start msnbc-buffer
   ```

3. Check status:
   ```bash
   sudo systemctl status msnbc-buffer
   ```

## Quick Commands

```bash
# Start stream
/mnt/docker/tvheadend/msnbc-buffer-fixed.sh

# Check status
/mnt/docker/tvheadend/msnbc-monitor-status.sh

# Restart stream
/mnt/docker/tvheadend/restart-msnbc-buffer.sh

# View logs
tail -f /tmp/MSNBC.log

# Test stream
curl -I http://192.168.3.11:8888/playlist.m3u8

# Play stream
vlc http://192.168.3.11:8888/playlist.m3u8

# Stop stream
pkill -f "ffmpeg.*pvserver.*8080"
pkill -f "python3.*8888"
```

## Performance Metrics

- **Startup Time**: ~10-15 seconds
- **Buffer Build Time**: ~30 seconds for full buffer
- **Memory Usage**: ~50-200MB depending on buffer size
- **CPU Usage**: 
  - With GPU: ~5-10%
  - Without GPU: ~15-30%
- **Network Bandwidth**: ~2.5 Mbps

## Known Working Stream URL
```
http://pvserver.link:8080/play/LSTZs2UO40ys7tCxS8rNVUz-GLQYaW1owXYLzbVH3Iw
```

## Integration with Other Services

### Plex
Add to Plex using xTeVe or similar with URL:
```
http://192.168.3.11:8888/playlist.m3u8
```

### VLC
Open network stream with:
```
http://192.168.3.11:8888/playlist.m3u8
```

### Tvheadend
Add as IPTV Automatic Network mux:
```
http://192.168.3.11:8888/playlist.m3u8
```