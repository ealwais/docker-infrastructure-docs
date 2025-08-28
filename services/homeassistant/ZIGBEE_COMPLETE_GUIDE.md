# Zigbee Documentation

*Consolidated on: 2025-08-27*

## Table of Contents

1. [Zha Setup Guide](#zha_setup_guide)
2. [Zigbee Setup](#zigbee_setup)
3. [Fix Zha Port](#fix_zha_port)
4. [Zha Deduplication Guide](#zha_deduplication_guide)
5. [Zha Status Report](#zha_status_report)
6. [Zigbee Port Standardization](#zigbee_port_standardization)
7. [Ser2Net Setup Guide](#ser2net_setup_guide)

---

## Zha Setup Guide
*Source: ZHA_SETUP_GUIDE.md*

## Current Setup Information

**Zigbee Coordinator**: Silicon Labs CP210x USB device
- **Device Path**: `/dev/tty.SLAB_USBtoUART`
- **Baud Rate**: 115200
- **Type**: Likely SONOFF Zigbee 3.0 USB Dongle Plus (ZNP protocol)

## Problem
Docker Desktop on macOS doesn't support USB device passthrough, so we need to share the USB device over the network using ser2net.

## Solution: ser2net Configuration

### Method 1: Using the danrue/ser2net image

```bash

docker run -d \
  --name ser2net \
  --restart unless-stopped \
  --device /dev/tty.SLAB_USBtoUART:/dev/ttyUSB0 \
  -p 3333:3333 \
  danrue/ser2net \
  -C "3333:raw:600:/dev/ttyUSB0:115200 8DATABITS NONE 1STOPBIT"
```

### Method 2: Run ser2net directly on macOS (Recommended)

1. Install ser2net on macOS:
```bash
brew install ser2net
```

2. Create ser2net config file:
```bash
cat > ~/ser2net.conf << EOF
3333:raw:600:/dev/tty.SLAB_USBtoUART:115200 8DATABITS NONE 1STOPBIT
EOF
```

3. Run ser2net:
```bash
ser2net -c ~/ser2net.conf
```

4. To run as a service, create a LaunchDaemon.

## Configure ZHA in Home Assistant

### Via UI (Recommended):
1. Go to Settings → Devices & Services → Add Integration
2. Search for "ZHA"
3. Select "Enter Manually"
4. For Serial Device Path, enter: `socket://host.docker.internal:3333`
5. Port Speed: 115200
6. Radio Type: ZNP (for SONOFF dongles)

### Via configuration.yaml:
```yaml
zha:
  device:
    path: socket://host.docker.internal:3333
  radio_type: znp
```

## Verify Connection

1. Check ser2net is running:
```bash

docker logs ser2net


lsof -i :3333
```

2. Test connection:
```bash
telnet localhost 3333
```

3. In Home Assistant logs, look for:
- "ZHA integration setup"
- "Zigbee Coordinator"
- Device discovery messages

## Troubleshooting

1. **USB Device Not Found**:
   ```bash
   # List USB devices
   ls -la /dev/tty.*
   # Look for tty.SLAB_USBtoUART
   ```

2. **Permission Issues**:
   ```bash
   # May need to add user to dialout group
   sudo usermod -a -G dialout $USER
   ```

3. **Connection Refused**:
   - Check firewall settings
   - Ensure ser2net is running
   - Try `127.0.0.1:3333` instead of `host.docker.internal:3333`

4. **ZHA Fails to Start**:
   - Check Home Assistant logs
   - Try different radio types (znp, ezsp, deconz)
   - Verify baud rate (usually 115200 for SONOFF)

## Alternative: Zigbee2MQTT

If ZHA continues to have issues, consider Zigbee2MQTT which is more flexible with network coordinators.

## Current Status

- ✅ USB device identified: `/dev/tty.SLAB_USBtoUART`
- ❌ ser2net not currently running
- ❌ ZHA not configured with network socket
- 📝 Configuration ready to implement

---

## Zigbee Setup
*Source: ZIGBEE_SETUP.md*

## Overview
Docker Desktop on macOS doesn't support USB device passthrough, so we use ser2net to share the Zigbee USB device over the network.

## Current Setup

### Hardware
- **Zigbee Coordinator**: Silicon Labs CP210x USB device (SONOFF Zigbee 3.0 USB Dongle Plus)
- **Device Path**: `/dev/tty.SLAB_USBtoUART`
- **Protocol**: ZNP (Zigbee Network Processor)

### Software Configuration
- **ser2net**: Running on macOS host (NOT in Docker)
- **Port**: 9999 (not 3333)
- **Baud Rate**: 115200
- **ZHA Integration**: Configured to use `socket://host.docker.internal:9999`

## Setup Instructions

### Step 1: Install ser2net on macOS

```bash

brew install ser2net


ls -la /dev/tty.* | grep SLAB

```

### Step 2: Configure ser2net

Create configuration file:
```bash
cat > ~/ser2net.conf << EOF
3333:raw:600:/dev/tty.SLAB_USBtoUART:115200 8DATABITS NONE 1STOPBIT
EOF
```

**Note**: We use port 3333 in ser2net config, but map it to 9999 in our setup.

### Step 3: Run ser2net

```bash

ser2net -c ~/ser2net.conf -d


ser2net -c /mnt/docker/homeassistant/ser2net.conf
```

### Step 4: Configure ZHA in Home Assistant

#### Option A: Via UI (Recommended)
1. Go to **Settings** → **Devices & Services** → **Add Integration**
2. Search for "ZHA"
3. Select "Enter Manually"
4. Configure:
   - **Serial Device Path**: `socket://host.docker.internal:9999`
   - **Port Speed**: 115200
   - **Radio Type**: ZNP

#### Option B: Via configuration.yaml
```yaml
zha:
  device:
    path: socket://host.docker.internal:9999
  radio_type: znp
```

## Verification

### Check ser2net is running:
```bash

ps aux | grep ser2net


lsof -i :9999


telnet localhost 9999
```

### Check ZHA in Home Assistant:
1. Go to **Settings** → **Devices & Services** → **ZHA**
2. Should show "Zigbee Coordinator" and firmware version
3. Check logs for device discovery messages

## Troubleshooting

### USB Device Not Found
```bash

ls -la /dev/tty.*



system_profiler SPUSBDataType | grep -A 5 "CP210"
```

### Permission Issues
```bash

sudo usermod -a -G dialout $USER

```

### Connection Refused
1. Check firewall settings
2. Ensure ser2net is running
3. Try `127.0.0.1:9999` instead of `host.docker.internal:9999`
4. Check Docker Desktop settings for host networking

### ZHA Fails to Start
1. Check Home Assistant logs: **Settings** → **System** → **Logs**
2. Try different radio types if ZNP doesn't work:
   - ezsp (for Silicon Labs EZSP)
   - deconz (for ConBee/RaspBee)
3. Verify baud rate (usually 115200 for SONOFF)
4. Ensure no other process is using the USB device

### Zigbee Devices Not Pairing
1. Put device in pairing mode (usually holding button for 5-10 seconds)
2. In ZHA, click "Add Device"
3. Keep device close to coordinator during pairing
4. Check device compatibility at: https://zigbee.blakadder.com/

## Alternative: Zigbee2MQTT

If ZHA continues to have issues, consider Zigbee2MQTT:
- More device support
- Better debugging tools
- Works well with network coordinators
- Requires MQTT broker (already have Mosquitto running)

## Current Status
- ✅ USB device identified: `/dev/tty.SLAB_USBtoUART`
- ✅ ser2net configured and running on port 9999
- ✅ ZHA configured with network socket
- ✅ Zigbee network operational

## Important Notes
- Always use port 9999, not 3333
- ser2net must run on macOS host, not in Docker
- Don't use `/dev/ttyUSB0` or Linux-style paths on macOS
- The coordinator LED should be solid when connected

---

## Fix Zha Port
*Source: fix_zha_port.md*

## Current Status
- **ser2net**: Running on port **3333** ✅
- **ZHA Config**: Shows port 3333 in config file ✅
- **UI Error**: Shows attempting port 9999 ❌

## Solution: Reconfigure ZHA Integration

### Option 1: Remove and Re-add ZHA
1. Go to **Settings** → **Devices & Services**
2. Find **ZHA** integration
3. Click the 3 dots → **Delete**
4. Restart Home Assistant
5. Add ZHA again with correct settings:
   - Serial Port: `socket://192.168.3.20:3333`
   - Radio Type: **EZSP** (for SONOFF Zigbee 3.0 USB Dongle Plus)
   - Port Speed: **115200**

### Option 2: Reconfigure Existing ZHA
1. Go to **Settings** → **Devices & Services**
2. Find **ZHA** integration
3. Click **Configure**
4. Update the serial device path to: `socket://192.168.3.20:3333`
5. Submit and restart

### Option 3: Manual Config Update
If the UI won't let you change it:

1. Stop Home Assistant:
   ```bash
   docker stop homeassistant
   ```

2. Edit the config directly:
   ```bash
   docker run --rm -v homeassistant_config:/config alpine vi /config/.storage/core.config_entries
   ```

3. Find the ZHA entry and ensure it shows:
   ```json
   "path": "socket://192.168.3.20:3333"
   ```

4. Start Home Assistant:
   ```bash
   docker start homeassistant
   ```

## Test Connection
Before configuring ZHA, verify ser2net is accessible:
```bash

nc -zv 192.168.3.20 3333


docker exec homeassistant nc -zv 192.168.3.20 3333
```

Both should show "open" or "succeeded".

## Alternative Hosts to Try
- `socket://192.168.3.20:3333` (direct IP)
- `socket://host.docker.internal:3333` (Docker host)
- `socket://host.lima.internal:3333` (Colima/Lima host)

## Troubleshooting
1. **Check ser2net is running**:
   ```bash
   ps aux | grep ser2net
   ```

2. **Check port is listening**:
   ```bash
   lsof -i :3333
   ```

3. **View ZHA logs**:
   ```bash
   docker logs homeassistant 2>&1 | grep -i zha | tail -50
   ```

4. **Restart ser2net if needed**:
   ```bash
   pkill ser2net
   ser2net -c /mnt/docker/homeassistant/ser2net.yaml -n
   ```

---

## Zha Deduplication Guide
*Source: zha_deduplication_guide.md*

## Current Duplicate Devices
You have these devices showing multiple times:
- **LUMI lumi.plug.maus01** - Shows 3 times (should be 1 or 3 different plugs)
- **LUMI lumi.switch.b1laus01** - Shows 2 times (should be 1 or 2 different switches)

## How to Deduplicate

### Method 1: Check Device Details (Recommended)
1. Go to **Settings** → **Devices & Services** → **ZHA**
2. Click on each duplicate device
3. Check the **Device info** → **Zigbee info** → **IEEE address**
4. If IEEE addresses are the same = duplicate
5. If IEEE addresses are different = separate physical devices

### Method 2: Test Each Device
1. Go to **Settings** → **Devices & Services** → **ZHA**
2. Click on first plug → Click on switch entity → Toggle it
3. Check which physical plug responds
4. Label this device (e.g., "Kitchen Plug")
5. Repeat for each duplicate
6. Remove any that don't control a physical device

### Method 3: Remove and Re-pair
1. **Before starting**: Note which automations use these devices
2. Go to **Settings** → **Devices & Services** → **ZHA**
3. Click on duplicate device → Click menu (⋮) → **Delete**
4. If it was controlling a real device, re-pair:
   - Click "Add Device" in ZHA
   - Press pairing button on physical device
   - Give it a unique name

## Safe Removal Process

### Step 1: Identify Real vs Ghost Devices
Test each device by toggling its switch:
```
Settings → Devices & Services → ZHA → [Device] → Switch entity → Toggle
```

### Step 2: Document Real Devices
Make a list:
- Device 1: IEEE: XX:XX:XX... → Controls: Kitchen lamp
- Device 2: IEEE: YY:YY:YY... → Controls: Office fan
- Device 3: IEEE: ZZ:ZZ:ZZ... → No response (ghost)

### Step 3: Remove Ghost Devices
Only remove devices that:
- Don't respond to commands
- Have duplicate IEEE addresses
- Show as "Unavailable" consistently

## Prevention Tips
1. **Always name devices** immediately after pairing
2. **Assign to areas** (Kitchen, Office, etc.)
3. **Remove failed devices** before re-pairing
4. **Use unique names** like "Office Plug 1", "Kitchen Switch"

## Quick Check Commands
From Developer Tools → Services:

```yaml
service: zha.remove
data:
  ieee: "00:15:8d:xx:xx:xx:xx:xx"  # Replace with duplicate device IEEE
```

## If All Devices Are Real
If you actually have 3 identical plugs and 2 identical switches:
1. Rename them uniquely:
   - Office Plug
   - Bedroom Plug  
   - Kitchen Plug
   - Upstairs Switch
   - Downstairs Switch

2. Assign to different areas

3. Add labels or customize entity IDs

## Common Issues
- **"Device in use"**: Check automations and dashboards for references
- **"Failed to remove"**: Device might be routing for other Zigbee devices
- **Keeps coming back**: Failed pairing - do factory reset on device first

## Factory Reset Procedures
**Xiaomi/Aqara Plug**: Hold button for 5 seconds until LED flashes
**Xiaomi/Aqara Switch**: Press button 5 times quickly

---

## Zha Status Report
*Source: zha_status_report.md*

## Current Status
- ✅ ZHA integration is configured
- ⚠️ Template errors fixed in sensor configurations
- 📊 Monitoring sensors available for device/entity counting

## Issues Fixed
1. **Template Errors**: Fixed missing default values in `int()` filters
   - Changed `| int > 0` to `| int(0) > 0` in:
     - `infrastructure_sensors_old.yaml`
     - Already correct in `zigbee_diagnostics.yaml`

## Available Entities
After restart, you should have:
- `sensor.zha_devices` - Count of ZHA devices
- `sensor.zha_entities` - Count of ZHA entities
- `binary_sensor.zigbee_zha_running` - ZHA status
- `binary_sensor.ser2net_running` - Serial-to-network status
- `binary_sensor.sonoff_zbdongle_e` - Dongle connection status

## Diagnostic Scripts
Run these scripts to check ZHA status:
- `script.diagnose_zigbee` - Full diagnostic report
- `script.setup_zigbee_integration` - Setup instructions

## Known Zigbee Devices
From the configuration, you have:
- Xiaomi Smart Plug (switch.lumi_lumi_plug_maus01)
- Xiaomi Smart Plug 2 (switch.lumi_lumi_plug_maus01_2)

## Connection Methods
Your setup appears to use network connection:
- Socket: `socket://192.168.5.2:9999`
- Device: SONOFF Zigbee 3.0 USB Dongle Plus
- Via ser2net for network access

## Next Steps
1. Restart Home Assistant to apply fixes
2. Check Developer Tools → States for ZHA entities
3. Run `script.diagnose_zigbee` for detailed status
4. If no devices show, check:
   - USB dongle connection
   - ser2net service status
   - ZHA integration logs

## Troubleshooting Commands
```bash

ls -la /dev/tty* | grep -i usb


systemctl status ser2net


docker logs homeassistant 2>&1 | grep -i zha | tail -50
```

---

## Zigbee Port Standardization
*Source: zigbee_port_standardization.md*

## Standardized Configuration
All Zigbee/ser2net configurations have been updated to use:
- **Port**: 3333 (matching current ser2net configuration)
- **Host**: `host.docker.internal` (works from within containers)
- **Connection String**: `socket://host.docker.internal:3333`

## Files Updated
1. ✅ `/config/packages/zigbee_monitoring_fixed.yaml`
   - Changed port from 9999 to 3333
   - Updated host from 192.168.5.2 to host.docker.internal

2. ✅ `/config/packages/infrastructure_sensors_old.yaml`
   - Changed port from 9999 to 3333
   - Updated connection string

3. ✅ `/config/packages/infrastructure_sensors.yaml`
   - Changed port from 9999 to 3333
   - Updated connection string

## Current Working Configuration
- **ser2net**: Running on Mac host, port 3333
- **Device**: `/dev/tty.SLAB_USBtoUART` (SONOFF Zigbee 3.0 USB Dongle Plus)
- **Protocol**: 115200,n,8,1
- **Access from containers**: `socket://host.docker.internal:3333`
- **Access from host**: `socket://localhost:3333`

## ZHA Configuration in Home Assistant
When configuring ZHA, use:
```
Radio type: ZNP
Serial device path: socket://host.docker.internal:3333
Port speed: 115200
Data flow control: Software
```

## Testing Commands
```bash

nc -zv localhost 3333


docker exec homeassistant nc -zv host.docker.internal 3333


ps aux | grep ser2net


tail -f /var/log/ser2net.log  # if logging is enabled
```

## Notes
- All references to port 9999 have been updated to 3333
- All references to IP 192.168.5.2 have been updated to host.docker.internal
- This ensures consistency across all configurations
- host.docker.internal is a special Docker DNS name that resolves to the host machine

---

## Ser2Net Setup Guide
*Source: SER2NET_SETUP_GUIDE.md*

## Quick Setup

### 1. Installation
```bash
brew install ser2net
```

### 2. Configuration File
Create `/opt/homebrew/etc/ser2net/ser2net.yaml`:

```yaml
%YAML 1.1
---
connection: &zigbee
    accepter: tcp,0.0.0.0,9999
    connector: serialdev,/dev/tty.SLAB_USBtoUART,115200n81,local
    options:
        kickolduser: true

define: &confver 1.0
```

### 3. Find Your USB Device
```bash

ls -la /dev/tty.* | grep -i usb
ls -la /dev/cu.* | grep -i usb
```

Common device names:
- `/dev/tty.SLAB_USBtoUART` - Silicon Labs USB to UART
- `/dev/tty.usbserial-XXX` - Generic USB serial
- `/dev/cu.SLAB_USBtoUART` - Same device, outgoing connection

### 4. Start ser2net
```bash

ser2net -n -d


ser2net -n &


pkill ser2net
```

### 5. Verify it's Running
```bash

ps aux | grep ser2net


lsof -i :9999
netstat -an | grep 9999
```

### 6. Configure in Home Assistant

For ZHA (Zigbee Home Automation):
- Serial device path: `socket://host.lima.internal:9999`
- Port speed: 115200
- Data flow control: none

Alternative addresses if host.lima.internal doesn't work:
- `socket://192.168.5.2:9999` (Colima host IP)
- `socket://[YOUR_MAC_IP]:9999` (find with `ifconfig | grep "inet "`)

## Troubleshooting

### Port Already in Use
```bash

lsof -i :9999

kill -9 [PID]
```

### Device Not Found
```bash

system_profiler SPUSBDataType

ls /dev/tty.*
```

### Connection Failed from Container
```bash

docker exec homeassistant nc -zv host.lima.internal 9999

docker exec homeassistant getent hosts host.lima.internal
```

## Auto-start ser2net

Create a LaunchAgent to start ser2net automatically:

1. Create `~/Library/LaunchAgents/com.ser2net.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ser2net</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/sbin/ser2net</string>
        <string>-n</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

2. Load the service:
```bash
launchctl load ~/Library/LaunchAgents/com.ser2net.plist
```

3. Start/stop/restart:
```bash
launchctl start com.ser2net
launchctl stop com.ser2net
```

## Protocol Options

Different integrations may need different protocols:

- **ZHA**: `socket://host:port`
- **Zigbee2MQTT**: `tcp://host:port`
- **RFC2217 devices**: `rfc2217://host:port` (requires telnet wrapper in ser2net config)

To enable RFC2217:
```yaml
connection: &zigbee
    accepter: telnet(rfc2217),tcp,0.0.0.0,9999
    connector: serialdev,/dev/tty.SLAB_USBtoUART,115200n81,local
```

---
*Last updated: August 16, 2025*

---

