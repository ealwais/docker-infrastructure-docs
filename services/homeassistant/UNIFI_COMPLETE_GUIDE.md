# Unifi Main Documentation

*Consolidated on: 2025-08-27*

## Table of Contents

1. [Unifi Setup](#unifi_setup)
2. [Unifi Setup Instructions](#unifi_setup_instructions)
3. [Unifi Devops Setup Complete](#unifi_devops_setup_complete)
4. [Unifi Configuration Analysis](#unifi_configuration_analysis)
5. [Unifi Controller Settings Guide](#unifi_controller_settings_guide)
6. [Setup Unifi Ssh Access](#setup_unifi_ssh_access)
7. [Fix Unifi Port](#fix_unifi_port)

---

## Unifi Setup
*Source: UNIFI_SETUP.md*

## Overview
This guide covers setting up both UniFi Network and UniFi Protect integrations in Home Assistant.

## UniFi Network Integration

### Prerequisites
- UniFi Dream Machine Pro SE at 192.168.3.1
- Admin credentials (username: `emalwais`, password in secrets.yaml)
- HTTPS access on port 8443

### Setup Steps

1. **Add Integration**
   - Go to **Settings** → **Devices & Services** → **Add Integration**
   - Search for "UniFi Network"
   - Enter configuration:
     - Host: `192.168.3.1`
     - Port: `8443`
     - Username: `emalwais`
     - Password: `Dunc@n21`
     - Site: `default` (or your site name)

2. **Configure Options**
   - Track network clients: Yes
   - Track network devices: Yes
   - Track DPI sensors: Optional
   - Allow bandwidth sensors: Optional
   - Block client: Enable if you want blocking capability

3. **What You Get**
   - Device trackers for all network clients
   - Network statistics sensors
   - WiFi client counts
   - Port forwarding info
   - Firewall rule sensors

### Custom Dashboard Cards Required
```bash

- mushroom-cards
- universal-remote-card
- custom:config-template-card
```

## UniFi Protect Integration

### Prerequisites
- UniFi Protect running on Dream Machine
- Same credentials as Network
- Cameras configured in Protect

### Setup Steps

1. **Add Integration**
   - **Settings** → **Devices & Services** → **Add Integration**
   - Search for "UniFi Protect"
   - Configuration:
     - Host: `192.168.3.1`
     - Username: `emalwais`
     - Password: `Dunc@n21`
     - Port: `443` (default)

2. **Configure Options**
   - Realtime metrics: Enable for live updates
   - Override connection: Only if having issues

3. **What You Get**
   - Camera entities with live streams
   - Motion sensors for each camera
   - Smart detection sensors (person, vehicle, etc.)
   - Recording controls
   - Camera statistics

### Camera Dashboard Example
```yaml
type: grid
cards:
  - type: picture-entity
    entity: camera.front_door
    camera_view: live
  - type: glance
    entities:
      - binary_sensor.front_door_motion
      - binary_sensor.front_door_person_detected
```

## Troubleshooting

### Connection Issues
1. **Verify connectivity**:
   ```bash
   curl -k https://192.168.3.1:8443/api/login
   ```

2. **Check SSL certificate**:
   - May need to accept self-signed cert
   - Try accessing UniFi web UI first

3. **Firewall rules**:
   - Ensure HA can reach UniFi on required ports
   - Check UniFi firewall settings

### Authentication Failures
1. Verify credentials in UniFi OS (not just Network app)
2. Check for 2FA - may need app password
3. Ensure user has admin privileges

### Entities Not Showing
1. Wait for initial discovery (can take 5 minutes)
2. Check integration options
3. Verify devices are adopted in UniFi

### High CPU Usage
- Disable DPI tracking if not needed
- Reduce update frequency
- Limit tracked devices

## Advanced Configuration

### Device Tracking Automation
```yaml
automation:
  - alias: "Notify when new device connects"
    trigger:
      - platform: event
        event_type: unifi_new_client
    action:
      - service: notify.mobile_app
        data:
          message: "New device connected: {{ trigger.event.data.name }}"
```

### Bandwidth Monitoring
```yaml
sensor:
  - platform: template
    sensors:
      total_wan_download:
        value_template: "{{ state_attr('sensor.dream_machine_wan', 'rx_bytes') | int / 1073741824 }}"
        unit_of_measurement: "GB"
```

## Known Issues

### Session Closed Errors
- Integration will auto-reconnect
- Check UniFi controller status
- May need to reload integration

### Missing Cameras
- Ensure Protect is updated
- Check camera adoption status
- Verify user permissions in Protect

### Slow Updates
- Normal for large networks
- Consider reducing tracked entities
- Check network latency to UniFi

## Related Dashboards
- `dashboard_ubiquiti.yaml` - Network overview
- `dashboard_unifi_modern.yaml` - Modern UI design
- `dashboard_unifi_diagnostic.yaml` - Troubleshooting view

## Current Status
- ❌ UniFi Network - Not yet configured
- ❌ UniFi Protect - Not yet configured
- ✅ Dashboard files ready
- ✅ Credentials available in secrets.yaml

---

## Unifi Setup Instructions
*Source: UNIFI_SETUP_INSTRUCTIONS.md*

## Step 1: Install Required Custom Cards

First, install these HACS frontend cards:
1. Go to HACS → Frontend
2. Search and install:
   - **auto-entities** - For dynamic entity lists
   - **mini-graph-card** - For beautiful graphs
   - **mushroom** - For modern UI cards (optional but recommended)
3. Clear browser cache (Ctrl+Shift+R or Cmd+Shift+R)

## Step 2: Setup UniFi Network Integration

1. Go to **Settings → Devices & Services**
2. Click **+ Add Integration**
3. Search for **UniFi Network**
4. Configure with:
   - Host: `192.168.3.1`
   - Port: `443` (default)
   - Username: `emalwais`
   - Password: `Dunc@n212025`
   - Site: `default` (usually)
   - Verify SSL: OFF (for self-signed cert)

5. Select what to track:
   - ✅ Track network clients
   - ✅ Track network devices  
   - ✅ Track wired clients
   - ✅ Include wired bug workaround
   - ✅ Track DPI (if you want bandwidth stats)

## Step 3: Setup UniFi Protect Integration (for cameras)

1. Go to **Settings → Devices & Services**
2. Click **+ Add Integration**
3. Search for **UniFi Protect**
4. Configure with:
   - Host: `192.168.3.1`
   - Port: `443`
   - Username: `emalwais`
   - Password: `Dunc@n212025`
   - Verify SSL: OFF

## Step 4: Check Your Dashboards

After setup, you'll have 3 UniFi dashboards:

### 1. **UniFi Diagnostic** (Check this first!)
Shows what entities are actually available. Use this to verify the integration is working.

### 2. **UniFi Modern**
A clean, modern dashboard using Mushroom cards and auto-entities. Will automatically show available entities.

### 3. **Ubiquiti Network** (Original)
Your existing dashboard - may need entity names updated based on what's shown in the diagnostic dashboard.

## Step 5: Restart and Test

```bash

docker restart homeassistant



```

## Common Entity Names

After setup, you should have entities like:
- `sensor.unifi_gateway_www_xput_down` - Current download speed
- `sensor.unifi_gateway_www_xput_up` - Current upload speed
- `sensor.unifi_gateway_www_clients` - Total connected clients
- `sensor.unifi_gateway_wlan_clients` - WiFi clients
- `binary_sensor.unifi_gateway` - Gateway online status
- `device_tracker.*` - For each network device
- `camera.g5_pro_*` - Your G5 Pro camera
- `camera.g4_doorbell_pro_*` - Your doorbell camera

## Troubleshooting

### Missing Entities?
1. Check the diagnostic dashboard first
2. Verify integration is connected (no errors)
3. Enable more entity types in integration options
4. Check Home Assistant logs for errors

### Custom Cards Not Working?
1. Clear browser cache completely
2. Try incognito/private mode
3. Check browser console for errors (F12)
4. Restart Home Assistant after installing cards

### Slow Updates?
- Increase scan interval in integration options
- Disable DPI tracking if not needed
- Check UniFi controller performance

## Alternative: Let Home Assistant Auto-Generate

If you prefer, you can let HA create a dashboard automatically:
1. Go to your UniFi integration
2. Click on a device
3. Click "Add to Dashboard"
4. HA will create cards with all available entities

---

## Unifi Devops Setup Complete
*Source: UNIFI_DEVOPS_SETUP_COMPLETE.md*

## Installation Summary

✅ **All components have been successfully installed:**

### 1. Dashboard File
- `dashboard_ubiquiti_devops.yaml` - Main DevOps dashboard with 6 views:
  - Executive Overview
  - Infrastructure
  - Performance
  - Automation
  - Analytics
  - DevOps Tools

### 2. Package Files
- `packages/unifi_devops_monitoring.yaml` - Core monitoring and automation
- `packages/unifi_multi_site.yaml` - Multi-site network support
- `packages/unifi_advanced_sensors.yaml` - Advanced metrics and sensors

### 3. Configuration
- Dashboard added to `lovelace_dashboards.yaml`
- Packages automatically loaded via existing configuration

## Access the Dashboard

1. **Wait for Home Assistant to fully restart** (2-3 minutes total)
2. **Navigate to the sidebar** and look for "UniFi DevOps"
3. **Click to open** the comprehensive monitoring dashboard

## Features Included

### Executive Overview
- Real-time network health score
- Multi-site monitoring readiness
- KPI dashboard with CPU, Memory, Bandwidth metrics
- Active alerts summary

### Advanced Monitoring
- Network latency tracking (Google DNS, Cloudflare)
- SLA compliance monitoring
- Predictive maintenance scoring
- Bandwidth per client metrics
- AP density calculations

### DevOps Tools
- Emergency runbooks (Outage response, DDoS mitigation)
- Performance report generation
- Network diagnostics
- Configuration backup scripts
- CLI command reference

### Automation
- High resource usage alerts
- Network health degradation notifications
- Automated AP restart capabilities
- Weekly performance reports
- Multi-site failover testing

## Initial Setup Tasks

1. **Verify Sensors**: Some sensors may show "unavailable" initially. They will populate as data becomes available.

2. **Configure Multi-Site** (Optional):
   - Add secondary site credentials to `secrets.yaml`
   - Update the multi-site configuration with your remote UniFi controller details

3. **Customize Thresholds**:
   - CPU alert threshold (default: 85%)
   - Memory alert threshold (default: 85%)
   - Health score threshold (default: 70%)
   - SLA target (default: 99.9%)

4. **Enable Automations**:
   - Check the input booleans on the Automation page
   - Configure notification preferences

## Troubleshooting

If sensors show as unavailable:
1. Check that the UniFi Network integration is properly configured
2. Verify entity names match your UniFi devices
3. Review logs at Configuration → Logs
4. Use Developer Tools → States to search for "unifi" entities

## Next Steps

1. **Monitor the dashboard** for 24 hours to establish baseline metrics
2. **Review and adjust** alert thresholds based on your network patterns
3. **Configure multi-site** monitoring if you have multiple locations
4. **Set up external monitoring** integration (Prometheus/Grafana) if desired

The dashboard is designed for a DevOps professional with extensive experience and includes enterprise-grade monitoring capabilities suitable for production networks.

---

## Unifi Configuration Analysis
*Source: unifi_configuration_analysis.md*

## Date: 2025-08-18

## Summary of Findings

### 1. Memory Sensor Configuration Issues

**Critical Issue Found**: Template sensor error causing high CPU/memory usage

**Problem**: 
- The template sensor `Dream Machine Memory Usage Corrected` in configuration.yaml has a malformed state template
- The error log shows: `ValueError: Sensor sensor.dream_machine_memory_usage_correct has device class 'None', state class 'None' unit '%' and suggested precision 'None' thus indicating it has a numeric value; however, it has the non-numeric value: '# Total RAM in MB (3.9GB)     # What HA thinks is total (3.5GB)  76.5'`

**Cause**: 
- The template is outputting comments and multiple values instead of a single numeric value
- This causes constant template re-evaluation and error handling, contributing to high resource usage

### 2. Duplicate Sensor Definitions

**Found duplicate/conflicting sensor definitions**:
1. `configuration.yaml` - Contains UniFi template sensors
2. `packages/unifi_memory_fix.yaml` - Contains similar sensors with different unique_ids
3. Multiple UniFi packages that may overlap:
   - unifi_advanced_sensors.yaml
   - unifi_sensors_fixed.yaml
   - unifi_devops_monitoring.yaml
   - unifi_memory_monitoring.yaml

### 3. Entity Naming Inconsistencies

**AP Client Sensors**:
- Looking for entities like `sensor.u6_lr_clients` but actual entities might be named differently
- Template sensors trying to fallback between multiple possible entity names
- This causes constant "unknown" evaluations

### 4. Command Line Sensors

**SSH-based sensors in unifi_memory_fix.yaml**:
- Attempting SSH connections to Dream Machine every 5 minutes
- May fail if SSH keys aren't properly configured
- Adds unnecessary load if UniFi integration already provides this data

### 5. Package Organization Issues

**Too many overlapping packages**:
- 16 UniFi-related YAML files in packages directory
- Many appear to be different attempts to fix the same issues
- Some are disabled (.disabled extension) but still present

## Recommendations

### Immediate Actions

1. **Fix the template sensor error**:
   - Remove or fix the `Dream Machine Memory Usage Corrected` sensor in configuration.yaml
   - The state template should return only a numeric value, not comments

2. **Consolidate UniFi packages**:
   - Merge all UniFi functionality into a single, well-organized package
   - Remove duplicate sensor definitions
   - Clean up disabled/backup files

3. **Verify entity names**:
   - Use Developer Tools → States to find actual entity IDs
   - Update templates to use correct entity names
   - Remove fallback logic that constantly checks for unavailable entities

### Configuration Cleanup

1. **Remove from configuration.yaml**:
   - Move all UniFi-related template sensors to a single package file
   - Keep configuration.yaml minimal

2. **Disable unnecessary monitoring**:
   - Command line sensors that duplicate integration data
   - Excessive template sensor updates
   - Redundant health checks

3. **Optimize template sensors**:
   - Add availability templates to prevent unknown state evaluations
   - Use proper error handling
   - Reduce update frequency where appropriate

### Memory Usage Specific

The Dream Machine SE appears to be reporting 83.8% memory usage, but this is based on incorrect total RAM calculation:
- Actual: 3.9GB total RAM
- Integration thinks: ~3.5GB total RAM
- Real usage: ~77% (3.0GB of 3.9GB)

While 77% is still elevated, it's not critical. Common causes:
1. IDS/IPS enabled (can use 20-40% RAM)
2. DPI (Deep Packet Inspection) enabled
3. UniFi Protect with multiple cameras
4. Large number of firewall rules
5. Extended uptime without restart

## File Cleanup List

Consider removing or consolidating these files:
- packages/unifi_monitoring.yaml.disabled
- packages/unifi_connection_diagnostic.yaml
- packages/unifi_debug.yaml
- packages/unifi_multi_site.yaml (unless you have multiple sites)
- Backup copies of dashboard files related to UniFi

## Next Steps

1. Fix the immediate template sensor error
2. Verify actual entity names from UniFi integration
3. Create a single, clean UniFi package file
4. Remove all duplicate/experimental configurations
5. Monitor resource usage after cleanup

---

## Unifi Controller Settings Guide
*Source: unifi_controller_settings_guide.md*

## Settings to Enable for Better Data in Home Assistant

### 1. **System Settings → Advanced Features**
Look for and enable:
- ✅ **Deep Packet Inspection (DPI)** - This will provide traffic statistics
- ✅ **Traffic Identification** - Helps categorize network usage
- ✅ **Device Fingerprinting** - Better device identification

### 2. **System Logs**
Enable these for better monitoring:
- ✅ **System Events** - For alerts in Home Assistant
- ✅ **Device Events** - Track device connections/disconnections
- ✅ **IDS/IPS Events** - Security alerts

### 3. **Debug Tools**
If available, enable:
- ✅ **Statistics Collection** - For historical data
- ✅ **Performance Metrics** - CPU, memory, throughput data

### 4. **API Access** (if shown)
Ensure:
- ✅ **Local Access** is enabled
- ✅ **API Authentication** is set up

## After Enabling These Settings:

1. **Wait 5-10 minutes** for UniFi to start collecting data

2. **In Home Assistant**:
   - Go to Settings → Devices & Services → UniFi Network
   - Click "..." → Reload
   - Or restart the integration

3. **Check for New Entities**:
   - Go to Developer Tools → States
   - Search for "wan" or "throughput"
   - Look for new sensors like:
     - `sensor.dream_machine_wan_download`
     - `sensor.dream_machine_wan_upload`
     - `sensor.dream_machine_dpi_stats`

## What Each Setting Does:

### Deep Packet Inspection (DPI)
- Analyzes network traffic
- Provides bandwidth usage per client/application
- Creates traffic statistics entities

### Traffic Identification
- Categorizes traffic (streaming, gaming, work)
- Helps create usage pattern sensors

### Device Fingerprinting
- Better identifies device types
- Improves device_tracker accuracy

## If DPI Settings Not Visible:

1. **Update UniFi Controller** to latest version
2. **Check UniFi OS Settings** (separate from Network app)
3. **Enable Advanced Features** toggle if present

## Alternative: Manual Speed Test

If throughput data still doesn't appear:
1. In UniFi, go to **Insights** → **Internet**
2. Run a speed test
3. Note your actual speeds
4. Update in Home Assistant:
   - Settings → Devices & Services → Helpers
   - Add Number helper for "WAN Download Override"
   - Add Number helper for "WAN Upload Override"
   - Set your actual speeds

The simulated data will be replaced with your manual values.

---

## Setup Unifi Ssh Access
*Source: setup_unifi_ssh_access.md*

## Step 1: Generate SSH Key in Home Assistant Container

```bash

docker exec -it homeassistant bash


ssh-keygen -t rsa -b 2048 -f /config/.ssh/id_rsa -N ""


cat /config/.ssh/id_rsa.pub
```

## Step 2: Add Key to UniFi Dream Machine

```bash

ssh root@192.168.3.1


mkdir -p /root/.ssh
chmod 700 /root/.ssh


echo "YOUR_PUBLIC_KEY_HERE" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys


exit
```

## Step 3: Test Connection

```bash

docker exec -it homeassistant bash
ssh -o StrictHostKeyChecking=no root@192.168.3.1 "echo 'Connection successful'"
```

## Alternative: Use Password in Shell Commands

If you prefer not to set up SSH keys, update the commands to use sshpass:

```yaml

sensor:
  - platform: command_line
    name: UniFi Real Memory Stats
    command: >
      sshpass -p 'YOUR_PASSWORD' ssh -o StrictHostKeyChecking=no 
      root@192.168.3.1 
      "free -m | grep Mem"
```

## Quick Setup Script

Run this to set up SSH access:

```bash

docker exec -it homeassistant bash -c "
  mkdir -p /config/.ssh
  ssh-keygen -t rsa -b 2048 -f /config/.ssh/id_rsa -N ''
  cat /config/.ssh/id_rsa.pub
"


ssh root@192.168.3.1 "
  mkdir -p /root/.ssh
  echo 'PASTE_PUBLIC_KEY_HERE' >> /root/.ssh/authorized_keys
  chmod 600 /root/.ssh/authorized_keys
"
```

## After Setup

The SSH sensors will provide:
- Real memory usage (more accurate than SNMP)
- Real CPU usage
- Actual WAN throughput from interface counters
- System temperature
- Network score
- Service status

This data will be much more accurate than the UniFi integration provides!

---

## Fix Unifi Port
*Source: FIX_UNIFI_PORT.md*

## Problem Identified
The UniFi integration is configured with port **443** but should be using port **8443** for the UniFi Network Controller.

## How to Fix

1. Go to **Settings → Devices & Services**
2. Find the **UniFi Network** integration
3. Click the 3 dots menu → **Reconfigure**
4. Change the port from `443` to `8443`
5. Keep all other settings the same:
   - Host: 192.168.3.1
   - Username: emalwais
   - Password: (keep existing)
   - Site: default
6. Click **Submit**

## Alternative: Remove and Re-add

If reconfigure doesn't work:
1. Click the 3 dots → **Delete**
2. Click **Add Integration**
3. Search for "UniFi Network"
4. Configure with:
   - Host: 192.168.3.1
   - Port: **8443** (not 443!)
   - Username: emalwais
   - Password: Dunc@n212025!
   - Site: default

## Why This Happened
- Port 443 is typically for UniFi Protect
- Port 8443 is for UniFi Network Controller
- The integration was configured with the wrong port

After fixing this, all your UniFi entities should start working properly!

---

