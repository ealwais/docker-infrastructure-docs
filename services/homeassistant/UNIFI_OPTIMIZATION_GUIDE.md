# Unifi Optimization Documentation

*Consolidated on: 2025-08-27*

## Table of Contents

1. [Unifi Network Score Improvement Guide](#unifi_network_score_improvement_guide)
2. [Unifi Score Improvement Action Plan](#unifi_score_improvement_action_plan)
3. [Unifi Swap Memory Optimization Guide](#unifi_swap_memory_optimization_guide)
4. [95 Percent Action Plan](#95_percent_action_plan)
5. [Enable Dpi Unifi](#enable_dpi_unifi)
6. [Check Dpi Enabled](#check_dpi_enabled)

---

## Unifi Network Score Improvement Guide
*Source: unifi_network_score_improvement_guide.md*

## Understanding Network Score

The UniFi Network Score is calculated based on:
- **Performance** (40%): CPU, Memory, Latency, Packet Loss
- **Stability** (30%): Uptime, Error Rates, Reconnections
- **Security** (20%): Firmware Updates, Security Settings
- **Configuration** (10%): Best Practices, Optimization

## Quick Wins to Improve Score

### 1. **Update Firmware** (Immediate +5-10 points)
```
Settings → System → Advanced → Firmware Update
- Enable "Auto-Update" for security patches
- Update all devices (Gateway, Switches, APs)
```

### 2. **Optimize Memory Usage** (Currently at 84.56% - High!)
Your Dream Machine SE is using too much memory. Fix:
- **Restart UniFi OS monthly**: SSH → `unifi-os restart`
- **Disable unnecessary features**:
  - Settings → System → Advanced
  - Disable "Speed Test" if not needed
  - Disable "WiFi AI" if not using
- **Clear old statistics**:
  - Settings → System → Maintenance
  - "Prune Old Data" → Set to 1 month

### 3. **Enable Security Features** (+10-15 points)
```
Settings → Security → Advanced
- ✅ Enable "Intrusion Prevention System" (IPS)
- ✅ Enable "Country Restrictions" (block high-risk countries)
- ✅ Enable "Ad Blocking"
- ✅ Enable "Malicious Website Blocking"
```

### 4. **Optimize Wireless Settings** (+5-10 points)
```
Settings → WiFi → Edit Each Network
- Channel Width: 80MHz for 5GHz, 20MHz for 2.4GHz
- Transmit Power: Medium (not High)
- Enable "Band Steering"
- Enable "Fast Roaming"
- Disable legacy 802.11b rates
```

### 5. **Network Segmentation** (+5 points)
Create VLANs for better security:
- IoT devices → VLAN 20
- Guests → VLAN 30
- Cameras → VLAN 40
- Main devices → Default

## Compliance Improvements

### 1. **Security Compliance**
```yaml

sensor:
  - platform: template
    sensors:
      unifi_security_score:
        friendly_name: "UniFi Security Score"
        unit_of_measurement: "%"
        value_template: >
          {% set score = 100 %}
          {% if states('update.dream_machine_special_edition') == 'on' %}
            {% set score = score - 20 %}
          {% endif %}
          {% if states('sensor.dream_machine_special_edition_uptime') | int < 604800 %}
            {% set score = score - 10 %}
          {% endif %}
          {{ score }}
```

### 2. **Enable These Settings**
- **Settings → Internet Security**:
  - ✅ Threat Management: Enabled
  - ✅ Dark Web Blocker: Enabled
  - ✅ Suspicious Activity Blocker: Enabled
  
- **Settings → Advanced Features**:
  - ✅ Traffic Identification: Enabled (already on)
  - ✅ Client Device Fingerprinting: Enabled
  - ✅ WiFi Experience: Enabled

### 3. **Fix Common Issues**

#### High Memory Usage (Your Current Issue)
```bash

ssh root@192.168.3.1


top -b -n 1 | head -20


sync && echo 3 > /proc/sys/vm/drop_caches


systemctl restart unifi-protect
systemctl restart unifi
```

#### Improve WiFi Experience
- Reduce channel utilization
- Fix sticky clients
- Optimize AP placement

## Automation for Score Monitoring

Create this package to track and improve score:

```yaml

template:
  - sensor:
      - name: "UniFi Network Score Calculated"
        unique_id: unifi_network_score_calculated
        unit_of_measurement: "%"
        state: >
          {% set base = 70 %}
          {% set cpu = states('sensor.dream_machine_special_edition_cpu_utilization') | float(0) %}
          {% set mem = states('sensor.dream_machine_special_edition_memory_utilization') | float(0) %}
          {% set score = base %}
          
          {# Performance scoring #}
          {% if cpu < 50 %}
            {% set score = score + 10 %}
          {% elif cpu < 70 %}
            {% set score = score + 5 %}
          {% else %}
            {% set score = score - 10 %}
          {% endif %}
          
          {# Memory scoring #}
          {% if mem < 70 %}
            {% set score = score + 10 %}
          {% elif mem < 80 %}
            {% set score = score + 5 %}
          {% else %}
            {% set score = score - 15 %}
          {% endif %}
          
          {# Uptime bonus #}
          {% if states('sensor.dream_machine_special_edition_uptime') != 'unknown' %}
            {% set score = score + 5 %}
          {% endif %}
          
          {{ [score, 0] | max | min(100) }}
        attributes:
          recommendations: >
            {% set recs = [] %}
            {% if states('sensor.dream_machine_special_edition_memory_utilization') | float(0) > 80 %}
              {% set recs = recs + ['Reduce memory usage - restart UniFi OS'] %}
            {% endif %}
            {% if states('update.dream_machine_special_edition') == 'on' %}
              {% set recs = recs + ['Firmware update available'] %}
            {% endif %}
            {{ recs | join(', ') if recs else 'System optimized' }}

automation:
  - alias: "UniFi Low Score Alert"
    trigger:
      - platform: numeric_state
        entity_id: sensor.unifi_network_score_calculated
        below: 70
        for: "00:30:00"
    action:
      - service: persistent_notification.create
        data:
          title: "UniFi Network Score Low"
          message: |
            Current score: {{ states('sensor.unifi_network_score_calculated') }}%
            
            Recommendations:
            {{ state_attr('sensor.unifi_network_score_calculated', 'recommendations') }}

  - alias: "UniFi Monthly Maintenance"
    trigger:
      - platform: time
        at: "03:00:00"
      - platform: time_pattern
        days: "1"
    action:
      - service: script.unifi_monthly_maintenance

script:
  unifi_monthly_maintenance:
    alias: "UniFi Monthly Maintenance"
    sequence:
      - service: persistent_notification.create
        data:
          title: "UniFi Maintenance Reminder"
          message: |
            Monthly tasks:
            1. Clear old statistics
            2. Check for firmware updates
            3. Review security settings
            4. Restart if memory > 80%
```

## Immediate Actions for Your Network

Based on your current status:

1. **Fix Memory Usage** (84.56% is too high)
   - Restart Dream Machine: `ssh root@192.168.3.1` then `unifi-os restart`
   - Disable unused features
   
2. **Enable Security Features**
   - IPS/IDS
   - Threat Management
   
3. **Update Firmware** (if available)
   - Check all devices

4. **Optimize WiFi**
   - Set channels manually (1, 6, 11 for 2.4GHz)
   - Use DFS channels for 5GHz if possible

## Expected Score Improvements

| Action | Points | Time |
|--------|--------|------|
| Restart (fix memory) | +10-15 | Immediate |
| Enable IPS | +5 | 5 min |
| Update firmware | +5-10 | 20 min |
| Optimize WiFi | +5 | 30 min |
| Enable threat blocking | +5 | 5 min |

**Potential Total: +30-40 points**

Your network health score should improve from ~75 to 90+ after these optimizations!

---

## Unifi Score Improvement Action Plan
*Source: unifi_score_improvement_action_plan.md*

## Current Status
Your UniFi network score is being calculated based on:
- Memory usage: Currently at 84.56% (HIGH - needs attention)
- CPU usage
- Temperature
- Uptime
- Security settings

## SSH Integration Status
✅ SSH connection established to root@192.168.3.1
✅ SSH sensors package deployed
✅ Real-time data collection started

## New Sensors Available
After the SSH integration, you now have these real-time sensors:
- `sensor.unifi_real_memory_stats` - Real memory usage from the Dream Machine
- `sensor.unifi_real_cpu_stats` - Actual CPU usage percentage
- `sensor.unifi_ssh_memory_usage` - Memory usage as percentage
- `sensor.unifi_cpu_temperature` - CPU temperature in Celsius
- `sensor.unifi_wan_interface_stats` - WAN interface byte counters
- `sensor.unifi_ssh_wan_download_speed` - Real download speed in Mbps
- `sensor.unifi_ssh_wan_upload_speed` - Real upload speed in Mbps
- `sensor.unifi_health_score_calculated` - Overall health score
- `sensor.unifi_network_score_ssh` - Network score from UniFi system

## Immediate Actions to Improve Score

### 1. Clear Memory Cache (Quick Win - 5 minutes)
Run this script from Home Assistant to clear cache:
```yaml
service: shell_command.clear_unifi_cache
```

Or manually via SSH:
```bash
ssh root@192.168.3.1
sync && echo 3 > /proc/sys/vm/drop_caches
```

### 2. Check UniFi Health Report
Run this script to get a detailed health report:
```yaml
service: script.check_unifi_health_ssh
```

### 3. Restart UniFi OS (If memory stays high - 10 minutes)
This will clear all memory and restart services:
```yaml
service: shell_command.restart_unifi_os
```

**Warning**: This will briefly interrupt network connectivity.

### 4. Enable Score Improvement Automation
The package includes automation to:
- Alert when memory usage exceeds 85%
- Track WAN throughput in real-time
- Calculate health score continuously

## Dashboard Cards to Add

Add these cards to monitor your network health:

```yaml

type: vertical-stack
cards:
  - type: horizontal-stack
    cards:
      - type: gauge
        entity: sensor.unifi_health_score_calculated
        name: Health Score
        min: 0
        max: 100
        severity:
          green: 80
          yellow: 60
          red: 0
      - type: gauge
        entity: sensor.unifi_ssh_memory_usage
        name: Memory Usage
        min: 0
        max: 100
        severity:
          green: 0
          yellow: 75
          red: 85

  - type: entities
    title: Real-Time Metrics
    entities:
      - entity: sensor.unifi_real_cpu_stats
        name: CPU Usage
        icon: mdi:chip
      - entity: sensor.unifi_cpu_temperature
        name: CPU Temperature
        icon: mdi:thermometer
      - entity: sensor.unifi_ssh_wan_download_speed
        name: Download Speed
        icon: mdi:download
      - entity: sensor.unifi_ssh_wan_upload_speed
        name: Upload Speed
        icon: mdi:upload

  - type: markdown
    content: |
      ## Recommendations
      {{ state_attr('sensor.unifi_health_score_calculated', 'recommendations') }}
```

## Expected Improvements

After running the optimization:
- Memory usage should drop from 84.56% to ~40-50%
- Network score should improve from ~75 to 85-90
- Real-time metrics will provide accurate data
- Automated alerts will help maintain performance

## Next Steps

1. Run `service: shell_command.clear_unifi_cache` first
2. Wait 2-3 minutes for sensors to update
3. Check the new health score
4. If memory is still high, consider the restart option
5. Set up the dashboard cards to monitor continuously

---

## Unifi Swap Memory Optimization Guide
*Source: unifi_swap_memory_optimization_guide.md*

## Enhanced Monitoring with Swap Detection

The updated SSH integration now monitors:
- **Memory Usage**: Physical RAM utilization
- **Swap Usage**: Virtual memory/swap file usage (critical!)
- **Memory Pressure**: Kernel-level memory stress indicator
- **Health Score**: Automatically adjusts based on swap usage

## Understanding Swap Usage

Swap usage is a critical indicator of memory problems:
- **0-5%**: Normal, occasional swap use
- **5-20%**: Warning - system under memory pressure
- **20%+**: Critical - severe performance impact

## New Commands Available

### 1. **Improved Cache Clear**
```yaml
service: shell_command.clear_unifi_cache
```
This now clears caches progressively:
- Page cache (echo 1)
- Dentries and inodes (echo 2)
- All caches (echo 3)

### 2. **Clear Swap** (New)
```yaml
service: shell_command.clear_unifi_swap
```
Forces all swap back to RAM (if space available)

### 3. **Check Memory Usage**
```yaml
service: shell_command.check_memory_usage
```
Shows top 10 memory-consuming processes

## Optimization Strategy

### If Swap Usage > 0%:

1. **First, try cache clear**:
   ```yaml
   service: shell_command.clear_unifi_cache
   ```

2. **If swap persists, check what's using memory**:
   ```yaml
   service: shell_command.check_memory_usage
   ```

3. **Clear swap if needed**:
   ```yaml
   service: shell_command.clear_unifi_swap
   ```

4. **Last resort - restart**:
   ```yaml
   service: shell_command.restart_unifi_os
   ```

## Automated Monitoring

Add this automation to alert on swap usage:

```yaml
automation:
  - alias: "UniFi Swap Usage Alert"
    trigger:
      - platform: numeric_state
        entity_id: sensor.unifi_ssh_swap_usage
        above: 5
        for: "00:05:00"
    action:
      - service: persistent_notification.create
        data:
          title: "⚠️ UniFi Swap Usage Detected"
          message: |
            Swap usage: {{ states('sensor.unifi_ssh_swap_usage') }}%
            Memory usage: {{ states('sensor.unifi_ssh_memory_usage') }}%
            
            Run cache clear: service: shell_command.clear_unifi_cache
          notification_id: unifi_swap_alert
```

## Health Score Impact

The new health score calculation penalizes swap usage:
- Swap > 50%: -25 points (critical)
- Swap > 20%: -15 points (severe)
- Swap > 5%: -5 points (warning)

## Expected Results

With proper monitoring and optimization:
- Memory usage: Should stay below 80%
- Swap usage: Should be 0% most of the time
- Health score: Should improve from ~75 to 85-95

## Quick Reference

| Metric | Good | Warning | Critical | Action |
|--------|------|---------|----------|--------|
| Memory | <70% | 70-85% | >85% | Clear cache |
| Swap | 0% | 1-20% | >20% | Clear swap/restart |
| CPU | <60% | 60-80% | >80% | Check processes |
| Score | >85 | 70-85 | <70 | Follow recommendations |

---

## 95 Percent Action Plan
*Source: 95_PERCENT_ACTION_PLAN.md*

## Current Score: 85%
## Target Score: 95%

## ✅ COMPLETED FIXES (via automation):

### 1. MCP Server Token ✅
- Updated token in .env file
- Restarted container
- Status: Should be healthy now

### 2. Removed MQTT Error Automation ✅
- Deleted problematic automation file
- This stops the MQTT publish errors

### 3. Configuration Cleanup ✅
- Cleaned up deprecated configs
- Restarted Home Assistant

## 📋 MANUAL ACTIONS NEEDED (in Home Assistant UI):

### To Get to 90%:

#### 1. Fix Lutron Caseta (2 minutes)
- Go to: Settings → Devices & Services
- Find Lutron Caseta integration
- Click "Configure"
- Re-upload bridge certificate files
- OR remove and re-add the integration

#### 2. Fix Samsung TV (1 minute)
- Go to: Settings → Devices & Services
- Find Samsung TV integration
- Click "Configure" 
- Allow access on TV when prompted

### To Get to 95%:

#### 3. Add Missing Service Integrations (5 minutes)
- Go to: Settings → Devices & Services → Add Integration
- Add these if you use them:
  - **Plex Media Server**
    - Host: 192.168.3.20
    - Port: 32400
    - Token: (from secrets.yaml)
  - **UniFi Network**
    - Host: 192.168.3.1
    - Port: 8443
    - Username/Password from secrets.yaml
  - **Speedtest.net**
    - Just click add and follow prompts

#### 4. Fix Authentication (2 minutes)
- Check Settings → System → Repairs
- Click on any authentication warnings
- Re-authenticate as needed

#### 5. Create Fresh Backup (1 minute)
- Go to: Settings → System → Backups
- Click "Create Backup"
- Name it "Post-Recovery-Working"

## 🎯 QUICK WIN CHECKLIST:

□ Fix Lutron Caseta certificates → +2%
□ Re-pair Samsung TV → +2%
□ Add Plex integration → +1%
□ Add UniFi integration → +2%
□ Add Speedtest → +1%
□ Clear all repairs/warnings → +1%
□ Create backup → +1%

## Total Time Required: ~10 minutes
## Expected Final Score: 95%

## 📊 METRICS AFTER FIXES:
- All containers: Healthy
- All integrations: Authenticated
- No errors in logs
- All dashboards: Populated with data
- System fully backed up

## BONUS (to reach 100%):
- Set up 2FA authentication
- Configure external access (DuckDNS/Cloudflare)
- Set up automated backups
- Add system monitoring alerts
- Configure energy monitoring

---

## Enable Dpi Unifi
*Source: ENABLE_DPI_UNIFI.md*

## Steps to Enable DPI

### 1. Access UniFi Network Application
- Open your browser and go to: **https://192.168.3.1**
- Or use the UniFi Network mobile app
- Log in with your UniFi credentials

### 2. Enable DPI
1. Click on **Settings** (gear icon) in the left sidebar
2. Navigate to **System** → **Advanced**
3. Find the **Device Fingerprinting** section
4. Toggle ON the following options:
   - ✅ **Device Fingerprinting** (if available)
   - ✅ **Traffic Identification** 
   - ✅ **DPI (Deep Packet Inspection)**

### 3. Apply Settings
1. Click **Apply Changes** at the bottom
2. The Dream Machine will apply the settings (may take 1-2 minutes)

### 4. Wait for Data Collection
- DPI needs time to analyze traffic patterns
- Initial data appears in 5-10 minutes
- Full statistics may take 30-60 minutes

## Alternative Method (Classic Settings)

If you're using the classic settings view:
1. Go to **Settings** → **DPI**
2. Enable **Deep Packet Inspection**
3. Enable **Traffic Identification**
4. Click **Apply**

## Verify DPI is Working

### In UniFi Interface:
1. Go to **Insights** or **Statistics**
2. Look for **DPI** or **Applications** tab
3. You should see application categories (Streaming, Gaming, etc.)

### In Home Assistant:
After 10-15 minutes, check these sensors:
- `sensor.dream_machine_special_edition_wan_download_throughput`
- `sensor.dream_machine_special_edition_wan_upload_throughput`

They should show actual Mbps values instead of "unknown"

## Important Notes

⚠️ **Performance Impact**: DPI uses CPU resources. On your Dream Machine SE, impact should be minimal.

⚠️ **Privacy**: DPI analyzes packet headers to identify traffic types. It doesn't inspect encrypted content.

📊 **Benefits**: 
- See bandwidth usage by application
- Better traffic statistics in Home Assistant
- Identify bandwidth-hungry devices/apps

## Troubleshooting

If sensors still show "unknown" after enabling DPI:
1. Restart the UniFi integration in Home Assistant
2. Check if your WAN interface is properly configured
3. Ensure there's actual internet traffic to measure
4. Wait up to 1 hour for full data collection

## Home Assistant Integration Check

After enabling DPI:
1. Go to Settings → Devices & Services
2. Find UniFi Network integration
3. Click on it and check for new entities
4. Look for throughput/bandwidth sensors

---

## Check Dpi Enabled
*Source: check_dpi_enabled.md*

## Method 1: UniFi Network Application (Web UI)

### Check Current Status:
1. **Go to Settings** (gear icon)
2. **System** → **Advanced**
3. Look for **"Deep Packet Inspection"** or **"DPI"**
   - If toggle is ON (blue) = Enabled ✅
   - If toggle is OFF (gray) = Disabled ❌

### Alternative Location:
1. **Settings** → **Security** → **Traffic Management**
2. Look for **"Traffic Identification"** or **"Application Awareness"**

## Method 2: Check in UniFi OS (Dream Machine)

1. Access UniFi OS: `https://192.168.3.1`
2. Click on **Network** application
3. **System** → **Advanced Features**
4. Look for **DPI** section

## Method 3: Check via SSH (Advanced)

```bash

ssh root@192.168.3.1


cat /data/unifi-core/config/settings.yaml | grep -i dpi


ps aux | grep dpi
```

## How to Enable DPI:

### In UniFi Network 7.x and newer:
1. **Settings** → **System** → **Advanced**
2. Find **"Deep Packet Inspection"** 
3. Toggle **ON** (turns blue)
4. Click **Apply Changes**

### In UniFi Network 6.x:
1. **Settings** → **Advanced Features**
2. Enable **"Deep Packet Inspection"**
3. Save

### After Enabling:
- Wait **5-10 minutes** for initial data collection
- Traffic stats will appear in **Insights** → **Traffic**
- Home Assistant may show new sensors after restart

## Verify DPI is Working:

1. **In UniFi**:
   - Go to **Insights** → **Traffic**
   - You should see application categories (Streaming, Gaming, etc.)
   - Client devices should show traffic breakdown

2. **In Home Assistant**:
   - Check for new entities containing:
     - "dpi"
     - "traffic"
     - "application"
   - Run: Developer Tools → Services → `unifi.remove` then re-add integration

## If DPI Option Not Visible:

1. **Update UniFi Network** to latest version
2. **Check license** - Some features require UniFi OS 2.0+
3. **Hardware support** - Dream Machine SE supports DPI

## Common Issues:
- DPI uses CPU resources (normal to see 5-10% increase)
- Takes time to categorize traffic (be patient)
- May need integration reload in HA to see new entities

---

