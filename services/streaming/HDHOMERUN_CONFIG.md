# HDHomeRun Configuration

## HDHomeRun Device
Your HDHomeRun is on a separate IP address and provides local broadcast channels.

## Plex Configuration
Since `plex-new` is running with **host networking**, it should automatically detect your HDHomeRun device on the network.

### To Add/Verify HDHomeRun in Plex:

1. **Access Plex:**
   - Direct: http://192.168.253.51:32400/web
   - Via NPM: https://plex.alwais.org

2. **Navigate to Live TV & DVR:**
   - Settings → Live TV & DVR
   - Click "SET UP PLEX DVR" or view existing tuners

3. **HDHomeRun Should Auto-Detect:**
   - Plex will scan the network and find HDHomeRun devices
   - Should show: "HDHomeRun [Model] - [IP Address]"

4. **If Not Auto-Detected:**
   - Click "Enter address manually"
   - Enter: `http://[HDHomeRun-IP]:80` (replace with actual IP)
   - Example: `http://192.168.1.100:80`

## Multiple Tuner Setup
You now have TWO tuner sources:

### 1. HDHomeRun (Physical Device)
- **Type:** Hardware tuner
- **Purpose:** Local OTA/Cable channels
- **Access:** Direct via network
- **Channels:** Local broadcasts

### 2. Xteve (Virtual Tuner)
- **Type:** Software/IPTV proxy
- **Purpose:** IPTV streams (MSNBC, etc.)
- **Access:** http://192.168.253.51:34400
- **Channels:** IPTV sources

## Adding Both to Plex:

### Step 1: Add HDHomeRun
- Should auto-detect on network
- Provides local channels

### Step 2: Add Xteve as Second Tuner
1. In Plex Live TV settings
2. Click "Add Device"
3. Enter manually: `http://192.168.253.51:34400`
4. Plex will detect it as "HDHomeRun" (Xteve emulates HDHomeRun)
5. Name it something like "IPTV Tuner" to distinguish

## Channel Management:
- **HDHomeRun channels:** Will use Plex's guide data or OTA EPG
- **Xteve channels:** Will use Xteve's EPG (from your IPTV provider)

## Network Requirements:
Since Plex is using host networking:
- ✅ Can access HDHomeRun on any subnet
- ✅ Can access Xteve on localhost:34400
- ✅ No special routing needed

## Troubleshooting:

### HDHomeRun Not Found:
```bash
# Check if HDHomeRun is reachable
ping [HDHomeRun-IP]

# Scan for HDHomeRun devices
curl http://[HDHomeRun-IP]/discover.json

# Check from Plex container
docker exec plex-new ping [HDHomeRun-IP]
```

### Find HDHomeRun IP:
```bash
# If you don't know the IP, scan network
nmap -p 80 192.168.1.0/24 | grep -B 4 "80/tcp open"

# Or use HDHomeRun config tool
hdhomerun_config discover
```

### Firewall Issues:
HDHomeRun uses:
- Port 80 (HTTP) for discovery/control
- Port 5004 (RTP/UDP) for streaming
- Port 65001 (TCP) for HDHomeRun app

Make sure these aren't blocked between Plex and HDHomeRun.

## EPG (Guide) Configuration:

### For Mixed Sources:
1. **HDHomeRun Channels:**
   - Use Plex Pass guide data
   - Or use TVGuide/Gracenote

2. **Xteve Channels:**
   - Configure in Xteve: http://192.168.253.51:34400
   - Point to your IPTV provider's EPG
   - Or use http://192.168.253.51:34400/xmltv.xml in Plex

## Optimal Setup:
1. Let HDHomeRun handle local channels
2. Let Xteve handle IPTV streams
3. Both appear as separate tuners in Plex
4. Can record from both simultaneously

## Quick Commands:

### Check HDHomeRun Status:
```bash
curl http://[HDHomeRun-IP]/status.json
```

### Check Xteve Status:
```bash
curl http://localhost:34400/api/status
```

### View All Plex Tuners:
Access: http://192.168.253.51:32400/web/index.html#!/settings/server/[server-id]/live-tv-dvr