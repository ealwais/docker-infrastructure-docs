# Setting Up xTeve with Plex

## xTeve Status
✅ **xTeve is ready for Plex integration!**
- Container: Running on port 34400
- Channels: Active in lineup
- EPG: Available at `/xmltv.xml`
- HDHomeRun Emulation: Working

## Add xTeve to Plex

### Step 1: Access Plex Web UI
1. Go to http://localhost:32400/web
2. Sign in to your Plex account

### Step 2: Add Live TV & DVR
1. Go to **Settings** → **Live TV & DVR**
2. Click **SET UP PLEX DVR**

### Step 3: Add xTeve as Tuner
1. Plex should auto-detect xTeve as "HDHomeRun" device
   - Device Name: **xTeVe**
   - IP Address: **localhost:34400** or **172.24.0.1:34400**
   
2. If not auto-detected, manually enter:
   - **Device Address**: `http://localhost:34400` or `http://172.24.0.1:34400`

### Step 4: Configure Channels
1. Plex will scan and find channels from xTeve
2. You should see your 91 Austin channels
3. Click **CONTINUE**

### Step 5: Set Up Guide Data
1. Select **Use XMLTV** (not Plex's guide)
2. Enter XMLTV URL: `http://localhost:34400/xmltv.xml`
3. Or use file path: `/mnt/docker/xteve/data/xteve.xml`

### Step 6: Channel Mapping
1. Plex will attempt to match channels to guide data
2. Review and correct any mismatches
3. Click **CONTINUE**

### Step 7: Recording (Optional)
1. Set recording path if you want DVR functionality
2. Configure recording quality

## Test Streaming

### From Plex:
1. Go to **Live TV** in Plex
2. Select a channel to test streaming
3. If stream fails, check:
   - pvserver.link subscription is active
   - Stream URLs are valid (403 = authentication issue)

### Test Individual Stream:
```bash
# Test a stream directly from xTeve
curl -I http://localhost:34400/stream/[stream_id]

# Test source stream (requires pvserver.link auth)
curl -I http://pvserver.link:8080/play/[stream_key]
```

## Troubleshooting

### If Plex Can't Find xTeve:
1. Check both containers are on same network:
```bash
docker network ls
docker inspect plex | grep NetworkMode
docker inspect xteve | grep NetworkMode
```

2. Try using host IP instead of localhost:
```bash
ip addr show | grep "inet 172"
# Use that IP:34400 in Plex
```

### If Channels Don't Play:
1. Check xTeve web UI: http://localhost:34400
2. Verify channels are active (not 0 as shown earlier)
3. Test stream URL directly
4. Check pvserver.link subscription

### Network Configuration:
- Plex: Running on ports 32400 (web), multiple others
- xTeve: Running on port 34400 (host network)
- Both containers should be accessible to each other

## Current Endpoints:
- Discovery: http://localhost:34400/discover.json ✅
- Lineup: http://localhost:34400/lineup.json ✅
- XMLTV: http://localhost:34400/xmltv.xml ✅
- M3U: http://localhost:34400/lineup.m3u ✅

All endpoints are responding correctly. xTeve is ready for Plex integration!