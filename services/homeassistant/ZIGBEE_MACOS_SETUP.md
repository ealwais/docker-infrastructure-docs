# Zigbee Macos Documentation

*Consolidated on: 2025-08-27*

## Table of Contents

1. [Colima Zigbee Setup Report](#colima_zigbee_setup_report)
2. [Colima Path Explanation](#colima_path_explanation)

---

## Colima Zigbee Setup Report
*Source: colima_zigbee_setup_report.md*

## System Overview
- **Platform**: macOS with Colima (Docker runtime)
- **Docker Context**: colima (active)
- **Mount Type**: sshfs (standard for qemu VM type)
- **Container Network**: Host mode (full network access)

## USB Devices Found
1. **SONOFF Zigbee Dongle**: `/dev/tty.SLAB_USBtoUART` ✅
2. **Secondary USB Serial**: `/dev/tty.usbserial-830` ✅

## Current Configuration

### 1. Colima Setup
- **Status**: ✅ Running
- **USB Passthrough**: ❌ Not configured (USB devices not visible in containers)
- **Solution**: Using ser2net to expose USB over network

### 2. Network Configuration
- **Container Network**: Host mode (optimal for Home Assistant)
- **IP Access**: Full host network access
- **Port Access**: All ports available

### 3. Zigbee Access Method
**Using ser2net (Network Serial Bridge)**
- **Status**: ✅ Running
- **Config**: `/mnt/docker/homeassistant/ser2net.yaml`
- **Port**: 3333
- **Device**: `/dev/tty.SLAB_USBtoUART`
- **Settings**: 115200,n,8,1
- **Connection**: `socket://localhost:3333` or `socket://192.168.3.20:3333`

### 4. ZHA Configuration
In Home Assistant, configure ZHA with:
- **Connection Type**: Network
- **Socket**: `socket://host.docker.internal:3333`
  - Alternative: `socket://192.168.3.20:3333`
  - From container: `socket://172.17.0.1:3333` (docker0 bridge)

## Working Setup Summary
```
Mac USB Port → SONOFF Dongle → ser2net (port 3333) → Network → Home Assistant Container → ZHA
```

## Advantages of This Setup
1. **No USB passthrough needed** - Colima doesn't support USB passthrough easily
2. **Flexible** - Can move Home Assistant container without losing Zigbee
3. **Debuggable** - Can test connection with `nc localhost 3333`
4. **Stable** - ser2net handles reconnections automatically

## Troubleshooting Commands

### Check ser2net status
```bash
ps aux | grep ser2net
nc -zv localhost 3333
```

### Restart ser2net
```bash
pkill ser2net
ser2net -c /mnt/docker/homeassistant/ser2net.yaml -n
```

### Test from container
```bash
docker exec homeassistant nc -zv host.docker.internal 3333
```

### Check ZHA logs
```bash
docker logs homeassistant 2>&1 | grep -i zha | tail -50
```

## Configuration Files
1. **ser2net.yaml** - Network serial configuration
2. **packages/zigbee_diagnostics.yaml** - ZHA monitoring
3. **packages/infrastructure_sensors_old.yaml** - Fixed templates

## Notes
- USB passthrough in Colima requires VM reconfiguration and is complex
- Network serial (ser2net) is the recommended approach for Zigbee on Mac
- The SLAB_USBtoUART device name indicates a Silicon Labs CP210x chip (common in SONOFF dongles)

---

## Colima Path Explanation
*Source: COLIMA_PATH_EXPLANATION.md*

**Date**: August 16, 2025  
**Status**: MYSTERY SOLVED

## The Real Situation

You have TWO DIFFERENT /mnt/docker/homeassistant/ directories:

### 1. Mac Host Directory
- Location: /mnt/docker/homeassistant/ on your Mac
- Contains: docker-compose.yaml, dashboard YAML files, documentation
- Purpose: Where you edit files and manage configuration
- Problem: NOT connected to the running container!

### 2. Colima VM Directory  
- Location: /mnt/docker/homeassistant/ INSIDE the Colima Linux VM
- Contains: The actual running Home Assistant configuration
- Purpose: What the container actually mounts as /config
- This is: Where Home Assistant is really running from!

## Why This Happened

1. Colima creates its own Linux VM with its own filesystem
2. The path /mnt/docker/homeassistant/ exists in BOTH places
3. Docker containers run inside Colima, so they see Colima version
4. Your docker-compose.yaml reference refers to the Colima VM path

## The Solution

To properly sync your Mac files with the container, restart Colima with mount:

colima stop
colima start --mount /mnt/docker/homeassistant:/mnt/docker/homeassistant:w
docker-compose up -d

Now your Mac directory will be properly mounted through Colima to the container!

---

