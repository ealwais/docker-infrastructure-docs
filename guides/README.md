# HEVC Video Converter

Automatically converts video files to HEVC/H.265 using NVIDIA GPU acceleration.

## Two Modes Available

### 1. Simple Mode (Recommended)
Single container that processes all files and shuts down when complete.

```bash
# Start conversion (will exit when done)
docker-compose -f docker-compose-simple.yml up

# Or use startup script
./startup.sh simple

# Check if still running
docker ps | grep hevc-worker

# View logs
docker logs hevc-worker
```

**Features:**
- Processes all non-HEVC videos
- Automatically shuts down when complete
- Resumes from previous state if interrupted
- Uses both GPUs intelligently

### 2. Enterprise Mode
Full monitoring stack with API, metrics, and alerts.

```bash
# Start all services
docker-compose up -d

# Or use startup script
./startup.sh

# Access services
- API: http://localhost:8000
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000
```

## Quick Start

```bash
cd /mnt/docker/hevc-converter

# Simple mode (recommended for one-time conversion)
docker-compose -f docker-compose-simple.yml up

# Watch progress
docker logs -f hevc-worker
```

## File Locations
- **Videos**: `/mnt/television.shows/`
- **Temp files**: `/mnt/ramdisk/`
- **Logs**: `./logs/`
- **State**: `./state/upgrade_state.pkl`

## How It Works
1. Scans for non-HEVC video files
2. Converts using GPU acceleration (prefers GPU 0)
3. Replaces original file after verification
4. Saves state for resume capability
5. Exits automatically when no files left

## Safety Features
- **Size validation**: Rejects suspiciously small outputs or >90% reduction
- **Video verification**: Quick probe to ensure output is valid
- **Atomic replacement**: Uses temporary backup during file swap
- **Automatic rollback**: Restores original if replacement fails
- **Progress tracking**: State saved after each file
- **Emergency stop**: `./emergency_stop.sh` to halt immediately

## Resume After Interruption
The state is saved in `./state/upgrade_state.pkl`. Just run again:
```bash
docker-compose -f docker-compose-simple.yml up
```

## Monitoring & Control

### Check Progress
```bash
./check_progress.sh
```

### Emergency Stop
```bash
./emergency_stop.sh
```

### View Live Logs
```bash
docker logs -f hevc-worker
```

### Check Failed Files
Failed files are tracked in the state file and won't be retried automatically.

## Configuration
Edit environment variables in docker-compose files:
- `MAX_CONCURRENT_JOBS`: Parallel conversions (default: 8)
- `GPU_ENCODER_THRESHOLD`: Reduce jobs when >90%
- `GPU_UTIL_THRESHOLD`: Reduce jobs when >80%