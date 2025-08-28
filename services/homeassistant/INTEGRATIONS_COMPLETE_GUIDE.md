# Integrations Documentation

*Consolidated on: 2025-08-27*

## Table of Contents

1. [Integration Setup Guide](#integration_setup_guide)
2. [Integration Setup Guide](#integration_setup_guide)
3. [Setup-Integrations](#setup-integrations)
4. [Setup Missing Integrations](#setup_missing_integrations)
5. [Integration Migration Notes](#integration_migration_notes)
6. [Integrations Guide](#integrations_guide)
7. [Integration Checklist](#integration_checklist)
8. [Integration Status](#integration_status)
9. [Integrations To Add](#integrations_to_add)
10. [Integration Monitoring](#integration_monitoring)

---

## Integration Setup Guide
*Source: INTEGRATION_SETUP_GUIDE.md*

## Core Integrations to Add

### 1. UniFi Network
- **URL**: https://192.168.3.1
- **Username**: emalwais
- **Password**: Dunc@n21
- **Note**: This will discover all UniFi devices and create 120+ entities

### 2. UniFi Protect
- **Already installed** in previous setup
- **Credentials**: Same as UniFi Network
- **Provides**: Camera entities and motion sensors

### 3. Plex Media Server
- **Host**: 192.168.3.11
- **Port**: 32400
- **Token**: sZVW3KXXGNrYuxy1nRyx (already in secrets.yaml)

### 4. Radarr
- **URL**: http://192.168.3.11:7878
- **API Key**: fe233d143de84bffa4ee38a7f090564a

### 5. Sonarr
- **URL**: http://192.168.3.11:8989
- **API Key**: 3be3aaefca434dc792861d4060ba865d

### 6. SABnzbd
- **URL**: http://192.168.3.11:8080
- **API Key**: c6717f7e71c24f5184451ab708aa399a

### 7. Synology DSM
- **Host**: 192.168.3.120
- **Username**: ealwais
- **Password**: Dunc@n21

### 8. QNAP
- **Host**: 192.168.3.11
- **Username**: ealwais
- **Password**: Dunc@n21

### 9. Arlo Cameras
- **Uses Gmail for 2FA**
- **Gmail**: alwais@gmail.com
- **App Password**: puulnsbmtkkpmmiw
- **IMAP Settings**: Already configured in packages

### 10. Tesla (if you have Tesla products)
- Use the Tesla custom integration from HACS

### 11. Zigbee (ZHA)
- Already configured in configuration.yaml
- Requires ser2net setup for macOS USB passthrough

## Email Notifications
Already configured in `/packages/email_notifications.yaml`:
- **SMTP Server**: smtp.gmail.com:587
- **Username**: alwais@gmail.com
- **Password**: puulnsbmtkkpmmiw
- **Recipient**: alwais@gmail.com

## Portainer Monitoring
Already configured in `/packages/portainer_integration.yaml`:
- **Local**: http://localhost:9001 (needs setup)
- **Docker Server**: https://192.168.3.11:9443
- **API Token**: In secrets.yaml

## Custom Integrations (via HACS)
Based on the previous setup, these were installed:
- adaptive_lighting
- aarlo (Arlo integration)
- browser_mod
- config_editor
- flightradar24
- google_home
- localtuya
- meross_cloud
- meross_lan
- monitor_docker
- powercalc
- pyscript
- smartthinq_sensors
- tesla_custom
- xiaomi_home
- xiaomi_miot

## Dashboard Configuration
The following dashboards are already configured and should appear in the sidebar:
1. **Docker & Portainer** - Container monitoring
2. **Tesla Energy** - Solar and battery stats
3. **Ubiquiti Network** - Network devices and status

## Setup Order
1. First, access Home Assistant and complete onboarding
2. Install HACS from https://hacs.xyz
3. Add integrations via Settings → Devices & Services
4. Start with UniFi Network - it will discover many devices
5. Add media server integrations (Plex, Radarr, Sonarr)
6. Configure NAS integrations
7. Set up Arlo through HACS aarlo integration
8. Test email notifications
9. Verify dashboards appear in sidebar

## Testing
- Email test: Developer Tools → Services → notify.email
- Portainer: Check sensors in Developer Tools → States
- Dashboards: Should appear in left sidebar automatically

---

## Integration Setup Guide
*Source: integration_setup_guide.md*

## Devices to Add Through UI

### 1. **Bond Bridge** (Ceiling Fans/Shades) ✓ ALREADY INSTALLED
- Already configured at IP: `192.168.3.167`
- Check status in Settings → Devices & Services → Bond

### 2. **Lutron Caseta** (Lighting Control) ✓ ALREADY INSTALLED
- Already configured at IP: `192.168.3.226`
- Check status in Settings → Devices & Services → Lutron Caseta

### 3. **MyQ** (Garage Door) - Requires HACS
- Install MyQ from HACS first
- Then Settings → Devices & Services → Add Integration
- Search for "MyQ"
- Login with MyQ credentials
- Device at: `192.168.3.149`

### 4. **Brilliant** (Smart Switch) - Check HACS
- Search HACS for "Brilliant" integration
- Device at: `192.168.3.128`

### 5. **Meross LAN** (Local Control for Plugs) ✓ ALREADY INSTALLED
- Already configured
- Devices should be auto-discovered at IPs:
  - `192.168.3.9`
  - `192.168.3.151`
  - `192.168.3.28`
- Check status in Settings → Devices & Services → Meross LAN

### 6. **Arlo** (Security Cameras)
- Settings → Devices & Services → Add Integration
- Search for "Arlo"
- Login with Arlo credentials
- Your base stations:
  - VMB4540: `192.168.253.242`
  - VMB4000: `192.168.253.15`

### 7. **Apple TV** (Media Control)
- Should auto-discover
- Or add manually with IP: `192.168.3.169`

### 8. **HDHomeRun** (Live TV)
- Settings → Devices & Services → Add Integration
- Search for "HDHomeRun"
- Should find device at: `192.168.3.6`

## Already Configured (Just Verify)
- ✓ Bond Bridge (`192.168.3.167`)
- ✓ Lutron Caseta (`192.168.3.226`)
- ✓ Meross LAN (3 devices)
- ✓ Synology DSM (`192.168.3.120`)
- ✓ QNAP (`192.168.3.10`)
- ✓ Plex (multiple devices)
- ✓ UniFi Network
- ✓ Apple devices (for presence detection)

## Automations You Can Create

1. **Ceiling Fan Control** (after adding Bond)
   - Auto-adjust based on temperature
   - Turn off when no one home

2. **Smart Lighting** (after adding Lutron)
   - Sunset/sunrise automation
   - Motion-based control

3. **Garage Security**
   - Alert if garage open > 10 minutes
   - Auto-close at night

4. **Media Automation**
   - Turn on TV setup with one command
   - Dim lights when movie starts

5. **Smart Plug Scheduling**
   - Christmas lights timer
   - Device power management

---

## Setup-Integrations
*Source: setup-integrations.md*

## 1. Claude AI Integration

### Create Claude API Credentials in n8n:
1. Go to n8n (http://localhost:5678)
2. Navigate to **Settings > Credentials**
3. Click **Add Credential**
4. Search for "Header Auth"
5. Configure:
   - **Name**: Claude API
   - **Header Name**: x-api-key
   - **Header Value**: [Your Claude API Key]

### Get Claude API Key:
1. Visit https://console.anthropic.com/
2. Create an account or login
3. Go to API Keys section
4. Create new key

### Test the Integration:
- Import workflow #6 (Claude Integration)
- Execute the webhook: `curl -X POST http://localhost:5678/webhook/ask-claude -d '{"query":"Hello Claude!"}'`

## 2. Docker Integration

n8n can control Docker containers directly:

### Add Docker Socket:
Edit `/mnt/docker/n8n/docker-compose.yml` and add to volumes:
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

### Use Execute Command node:
- Docker commands work directly
- Example: `docker ps`, `docker logs`, etc.

## 3. File System Integration

Already configured! n8n has access to:
- `/home/node/.n8n` - n8n data
- `/backups` - Backup directory

To add more directories, edit docker-compose.yml volumes section.

## 4. Recommended Service Integrations

### A. Telegram Bot (Notifications)
1. Create bot via @BotFather
2. Get bot token
3. Add Telegram credentials in n8n
4. Use for alerts and notifications

### B. Email (SMTP)
1. Add SMTP credentials
2. Gmail: Use app passwords
3. Configure in n8n credentials

### C. Database
PostgreSQL is already available! Use:
- **Host**: postgres
- **Database**: n8n
- **User**: n8n
- **Password**: [from .env]

### D. Webhook.site (Testing)
Great for testing webhooks:
1. Visit https://webhook.site
2. Get unique URL
3. Use in HTTP Request nodes

## 5. Useful n8n Nodes for Your Setup

### System Monitoring:
- **Execute Command**: Run bash commands
- **Schedule Trigger**: Cron-like scheduling
- **HTTP Request**: API calls

### Data Processing:
- **Code**: JavaScript functions
- **IF**: Conditional logic
- **Set**: Data transformation

### Storage:
- **Read/Write File**: Local file operations
- **Postgres**: Database operations
- **Redis**: Already running for queues

## 6. Example Automations for Your Server

1. **HEVC Conversion Monitor** (Workflow #5)
   - Checks conversion progress
   - Alerts when complete

2. **Disk Space Monitor**
   - Daily disk usage check
   - Alert if > 90% full

3. **Backup Automation**
   - Weekly database backups
   - Compress and store

4. **Log Analysis**
   - Parse error logs
   - Send summaries via Claude

## 7. Import the Example Workflows

1. In n8n, go to **Workflows**
2. Click **Import from File**
3. Select each JSON file from `/mnt/docker/n8n/example-workflows/`

Or use the CLI:
```bash
docker exec -it n8n n8n import:workflow --input=/home/node/.n8n/example-workflows/
```

## Security Notes

- Keep API keys in n8n credentials (encrypted)
- Use environment variables for sensitive data
- Limit file system access to necessary directories
- Regular credential rotation

## Next Steps

1. Import example workflows
2. Set up Claude API credentials
3. Test HEVC monitoring workflow
4. Customize for your needs!

---

## Setup Missing Integrations
*Source: setup_missing_integrations.md*

## 1. System Monitor Integration

The System Monitor integration is currently not configured. To add it:

1. Go to **Settings → Devices & Services**
2. Click **"+ Add Integration"**
3. Search for **"System Monitor"**
4. Click on it to add
5. Select the sensors you want to monitor:
   - Disk usage (/)
   - Memory usage
   - CPU usage
   - Network throughput
   - Last boot
   - Load averages
   - Temperature (if available)

## 2. Fix UniFi Network Integration

The UniFi integration is having connection issues. The current setup shows:
- Using port 443 (which responds with 200 OK)
- Getting "Server disconnected" errors on API calls

To fix:
1. Go to **Settings → Devices & Services**
2. Find **UniFi Network** integration
3. Click **Configure**
4. Verify these settings:
   - Host: `192.168.3.1`
   - Port: `443`
   - Username: `emalwais`
   - Site ID: `default`
   - Verify SSL: **Unchecked**

If it still doesn't work:
1. Delete the integration
2. Re-add it with the same settings
3. Make sure your UniFi Dream Machine Pro SE is accessible

## 3. Add UniFi Protect Integration (for cameras)

If you have UniFi cameras:
1. Go to **Settings → Devices & Services**
2. Click **"+ Add Integration"**
3. Search for **"UniFi Protect"**
4. Enter:
   - Host: `192.168.3.1`
   - Port: `443`
   - Username: `emalwais`
   - Password: Your UniFi password
   - Verify SSL: **Unchecked**

## After Setup

Once all integrations are working, your Ubiquiti dashboard at http://192.168.3.20:8123/ubiquiti-dash/overview should show:
- Network statistics
- Connected devices
- Camera feeds (if Protect is configured)
- System monitoring data

## Troubleshooting

If UniFi still won't connect:
1. Check if you can access https://192.168.3.1 in a browser
2. Verify your credentials work there
3. Check Home Assistant logs: `docker logs homeassistant 2>&1 | grep -i unifi`
4. Try using the local UniFi account instead of Ubiquiti cloud account

---

## Integration Migration Notes
*Source: integration_migration_notes.md*

## Fixed Issues (2025-08-18)

### 1. Country Configuration
- **Issue**: "The country has not been configured"
- **Fix**: Added `country: US` to the homeassistant section in configuration.yaml
- **Status**: ✅ Fixed

### 2. Sonarr Integration
- **Issue**: "Unused YAML configuration for the sonarr integration"
- **Cause**: Sonarr integration has moved from YAML to UI configuration
- **Action Required**: 
  - Configure Sonarr via UI: Settings → Devices & Services → Add Integration → Sonarr
  - The REST sensors in packages/sonarr_sensors.yaml will continue to work
  - No YAML changes needed (the file already uses REST sensors, not the deprecated sonarr platform)

### 3. File Integration
- **Issue**: "Unused YAML configuration for the file integration"
- **Cause**: File integration has moved from YAML to UI configuration
- **Action Required**:
  - Configure File integration via UI: Settings → Devices & Services → Add Integration → File
  - Remove any `platform: file` configurations from YAML files
  - No file platform configurations were found in your setup

### 4. UniFi Template Sensor Error
- **Issue**: Syntax error in configuration.yaml line 196
- **Fix**: Changed `sensor: \!include sensors.yaml` to `sensor: !include sensors.yaml`
- **Status**: ✅ Fixed

## Summary
- Country configuration has been added
- Template sensor syntax error has been fixed
- Sonarr and File integration warnings are informational - these integrations should be configured through the UI
- Your existing REST sensors for Sonarr will continue to work properly

---

## Integrations Guide
*Source: INTEGRATIONS_GUIDE.md*

## Overview
This guide consolidates all integration setup instructions. Most integrations should be added via the UI to ensure they're properly stored in `.storage`.

## ✅ Currently Installed Integrations

### Core Integrations
- **HACS** - Home Assistant Community Store
- **HomeKit Bridge** (3 instances) - Apple HomeKit compatibility
- **Mobile App** (2 instances) - iOS/Android apps
- **Shopping List** - Built-in shopping list
- **Sun** - Sunrise/sunset tracking
- **Radio Browser** - Internet radio stations
- **Google Translate** - Text-to-speech
- **Met.no** - Weather service

### Device Integrations
- **Bond** - Ceiling fans and motorized shades
- **Lutron Caseta** - Smart switches and dimmers
- **SmartThings** - Samsung SmartThings devices
- **Samsung TV** - TV control
- **Apple TV** (2 instances) - Media control
- **Synology DSM** - NAS monitoring
- **IPP** - Printer integration
- **DLNA** - Media streaming

### Smart Home Protocols
- **ZHA** - Zigbee devices (via ser2net)
- **Matter** - Matter/Thread devices
- **MQTT** - Message broker for IoT

### Cloud Services
- **iCloud** - Apple device tracking

## 📝 Integrations to Add

### Priority 1: Media Services
These are referenced in dashboards but not yet configured:

#### Plex Media Server
- **Host**: 192.168.3.11:32400
- **Token**: `sZVW3KXXGNrYuxy1nRyx` (from secrets.yaml)
- Add via: **Settings** → **Integrations** → **Add** → Search "Plex"

#### Radarr
- **Host**: 192.168.3.11:7878
- **API Key**: `fe233d143de84bffa4ee38a7f090564a`
- Add via: **Settings** → **Integrations** → **Add** → Search "Radarr"

#### Sonarr
- **Host**: 192.168.3.11:8989
- **API Key**: `3be3aaefca434dc792861d4060ba865d`
- Add via: **Settings** → **Integrations** → **Add** → Search "Sonarr"

#### SABnzbd
- **Host**: 192.168.3.11:8080
- **API Key**: `c6717f7e71c24f5184451ab708aa399a`
- Add via: **Settings** → **Integrations** → **Add** → Search "SABnzbd"

### Priority 2: Network Infrastructure

#### UniFi Network
- **Host**: 192.168.3.1
- **Port**: 8443 (HTTPS)
- **Username**: `emalwais`
- **Password**: `Dunc@n21`
- **Site**: default
- Provides: Network device tracking, WiFi clients, network statistics

#### UniFi Protect
- **Host**: 192.168.3.1
- **Username**: `emalwais`
- **Password**: `Dunc@n21`
- Provides: Camera feeds, motion detection

### Priority 3: Additional Devices

#### Tesla (if applicable)
- Custom integration via HACS
- Already installed: `tesla_custom`
- Configure via UI after HACS

#### Carrier HVAC (if applicable)
- Custom integration via HACS
- Already installed: `ha_carrier`

#### HDHomeRun
- **Host**: 192.168.3.34
- YAML configuration already present
- Just needs to be enabled

## Adding Integrations - Best Practices

### Via UI (Recommended)
1. Go to **Settings** → **Devices & Services**
2. Click **Add Integration** (+ button)
3. Search for the integration
4. Follow the setup wizard
5. Test the integration immediately

### Why UI is Preferred
- Stores configuration in `.storage` (survives YAML errors)
- Automatic discovery of devices
- Built-in validation
- Easy to modify later
- No restart required

### Via YAML (Only When Required)
Some integrations still require YAML configuration:
```yaml

hdhomerun:
  host: 192.168.3.34
```

## Custom Integrations via HACS

### Already Installed
- `wevolor` - Motorized blinds
- `monitor_docker` - Docker container monitoring
- `ha_carrier` - Carrier HVAC
- `anker_solix` - Solar systems
- `meross_lan` - Meross devices (local)
- `tesla_custom` - Tesla vehicles
- `kleenex_pollenradar` - Pollen data
- `weatheralerts` - Weather alerts
- `xiaomi_home` - Xiaomi devices
- `google_home` - Google Home devices
- `solcast_solar` - Solar forecasting
- `xiaomi_miot` - Xiaomi IoT
- `wyzeapi` - Wyze devices
- `unifi_network_rules` - UniFi firewall rules

### Installing New HACS Integrations
1. Open HACS from sidebar
2. Click "Integrations"
3. Search for desired integration
4. Click "Download"
5. Restart Home Assistant
6. Add via **Settings** → **Integrations**

## Troubleshooting Integration Issues

### Integration Not Showing
1. Check HACS for updates
2. Restart Home Assistant
3. Clear browser cache
4. Check logs for errors

### Authentication Failures
1. Verify credentials in secrets.yaml
2. Check if service is accessible
3. Try from Home Assistant terminal:
   ```bash
   curl -k https://192.168.3.1:8443  # UniFi
   curl http://192.168.3.11:32400    # Plex
   ```

### Network Connection Issues
1. Ensure Home Assistant can reach the service
2. Check firewall rules
3. Verify correct ports
4. Try IP instead of hostname

### Session Closed Errors
If you see "Session is closed" errors:
1. The integration will auto-retry
2. Check if service is online
3. May need to reload integration
4. See automation `monitor_session_closed_errors`

## API Keys Reference
All API keys and passwords are stored in `secrets.yaml`:
- Never commit secrets.yaml to git
- Use `!secret` references in configuration
- Keep a secure backup of secrets

## Next Steps
1. Add Plex, Radarr, Sonarr integrations
2. Configure UniFi Network and Protect
3. Test all integrations
4. Set up dashboards for new integrations

---

## Integration Checklist
*Source: INTEGRATION_CHECKLIST.md*

## ✅ Already Working:

### 1. **MQTT (Mosquitto)**
- **Status**: ✓ Running on port 1883
- **Integration**: Already configured
- **Entities**: Working with Meross devices

### 2. **ZHA (Zigbee)**
- **Status**: ✓ ser2net running on port 3333
- **Integration**: Available via socket://host.docker.internal:3333
- **Next Step**: Add devices via UI

## 🔧 Monitoring Created (Needs Testing):

### 3. **AdGuard Home** (192.168.3.11)
- **Files Created**: 
  - `/packages/adguard_monitoring.yaml`
  - `/packages/adguard_npm_simple.yaml`
- **To Complete**:
  1. **Option A - Official Integration**:
     ```
     Settings → Devices & Services → Add Integration → AdGuard Home
     Host: 192.168.3.11
     Port: 80 (or 3000)
     Username/Password: (if required)
     ```
  2. **Option B - Use Created Sensors**:
     - Already loaded after restart
     - Check Developer Tools → States → filter "adguard"

### 4. **Nginx Proxy Manager** (192.168.3.11:81)
- **Files Created**: 
  - `/packages/npm_monitoring.yaml`
  - `/packages/adguard_npm_simple.yaml`
- **Status**: Basic monitoring ready
- **Entities Available**:
  - `sensor.npm_api_status`
  - `binary_sensor.npm_running`
  - `sensor.npm_proxy_hosts`
  - `sensor.npm_ssl_certificates`

## 📋 Quick Actions Needed:

### 1. **Check Entities** (30 seconds)
```bash

Developer Tools → States → Filter: "adguard"
Developer Tools → States → Filter: "npm"
Developer Tools → States → Filter: "mqtt"
Developer Tools → States → Filter: "zha"
```

### 2. **Add Dashboard Cards** (2 minutes)
Go to your dashboard → Edit → Add Card → Manual

**AdGuard Card:**
```yaml
type: entities
title: AdGuard Home
entities:
  - entity: binary_sensor.adguard_dns_running
  - entity: sensor.adguard_total_queries
  - entity: sensor.adguard_blocked_queries
  - entity: sensor.adguard_block_percentage
```

**NPM Card:**
```yaml
type: entities
title: Nginx Proxy Manager
entities:
  - entity: sensor.npm_api_status
  - entity: sensor.npm_proxy_hosts
  - entity: sensor.npm_ssl_certificates
```

**Network Services Overview:**
```yaml
type: glance
title: Network Services
entities:
  - entity: binary_sensor.adguard_dns_running
    name: AdGuard
  - entity: binary_sensor.npm_running
    name: NPM
  - entity: binary_sensor.mosquitto_running
    name: MQTT
  - entity: binary_sensor.zigbee_running
    name: Zigbee
```

### 3. **Optional - Add Official Integrations**

**For AdGuard** (if you want official integration):
1. Settings → Devices & Services → Add Integration
2. Search "AdGuard"
3. Enter: `192.168.3.11` and port (try 80 or 3000)

**For MQTT devices** (if not auto-discovered):
1. Settings → Devices & Services → MQTT
2. Configure → Listen to a topic: `homeassistant/#`
3. Devices should auto-discover

### 4. **Test Services**
- Click on each entity in Developer Tools → States
- Verify values are updating
- Check History graphs after a few minutes

## 🎯 Summary:
- **MQTT & ZHA**: ✅ Already integrated
- **AdGuard & NPM**: 📊 Basic monitoring ready
- **Action needed**: Just add dashboard cards to see the data!

## 🚀 Next Steps After Integration:
1. Set up automations (e.g., alert if AdGuard blocks > 50%)
2. Create more detailed dashboards
3. Add official integrations if needed
4. Configure notifications

---

## Integration Status
*Source: INTEGRATION_STATUS.md*

## Date: August 16, 2025

### ✅ FIXED via Configuration Files:

1. **System Monitoring**
   - CPU, Memory, Disk monitoring sensors configured
   - System health checks added
   - Network interface monitoring enabled

2. **Network Monitoring**
   - Ping sensors for Internet, Router, NAS devices
   - WAN IP and DNS response time sensors
   - Device connectivity status

3. **Template Sensors**
   - Lights/Switches counters
   - System health status
   - Device counts

4. **Error Counters**
   - Created counters for Bond, UniFi, Sonarr, SABnzbd, Radarr errors
   - These will track integration failures

5. **Helper Scripts & Inputs**
   - Added configuration status tracking
   - REST commands for service checking
   - API key storage helpers

6. **Basic Configurations**
   - HomeKit bridge configured
   - Themes and frontend configured
   - Logging configured

### ⚠️ NEEDS UI CONFIGURATION:

1. **MQTT Integration**
   - Go to Settings → Devices & Services → Add Integration → MQTT
   - Broker: `192.168.3.20` or `localhost`
   - Port: `1883`
   - No authentication required

2. **Media Services** (Add via UI):
   - **Plex**: Host `192.168.3.20:32400`, Token from secrets
   - **SABnzbd**: Host `192.168.3.20:8080`, API key from secrets
   - **Radarr**: Host `192.168.3.20:7878`, API key from secrets
   - **Sonarr**: Host `192.168.3.20:8989`, API key from secrets

3. **Network/NAS**:
   - **UniFi Network**: Host `192.168.3.1:8443`, credentials from secrets
   - **Speedtest**: Add via UI integration
   
4. **Re-authentication Required**:
   - Gmail account (alwais@gmail.com)
   - Samsung TV
   - Lutron Caseta (check certificates)

### 📊 Current Status:
- Core system: ✅ Running
- Dashboards: ⚠️ Partial (waiting for entities)
- Automations: ⚠️ Partial (waiting for entities)
- MQTT: ❌ Needs UI setup
- Media Services: ❌ Needs UI setup

### 🔧 Next Steps:
1. Add MQTT integration via UI
2. Add media service integrations via UI
3. Re-authenticate expired services
4. Check device connectivity

### 📝 Notes:
- All configuration files backed up
- Original .storage restored from Aug 4 backup
- System monitoring working
- Network monitoring working

---

## Integrations To Add
*Source: INTEGRATIONS_TO_ADD.md*

## Access Home Assistant
Go to: http://192.168.3.20:8123
Then: Settings → Devices & Services → Add Integration

## Priority 1 - Media Servers

### Plex Media Server
1. Search for "Plex"
2. Enter:
   - Host: 192.168.3.11
   - Port: 32400
   - Token: sZVW3KXXGNrYuxy1nRyx
3. Select your Plex server when discovered

### Radarr
1. Search for "Radarr"
2. Enter:
   - URL: http://192.168.3.11:7878
   - API Key: fe233d143de84bffa4ee38a7f090564a

### Sonarr
1. Search for "Sonarr"
2. Enter:
   - URL: http://192.168.3.11:8989
   - API Key: 3be3aaefca434dc792861d4060ba865d

## Priority 2 - Network & Security

### UniFi Network
1. Search for "UniFi"
2. Select "UniFi Network" (NOT Protect)
3. Enter:
   - Host: 192.168.3.1
   - Username: emalwais
   - Password: Dunc@n212025
   - Uncheck "Verify SSL certificate"

### UniFi Protect (if not already added)
1. Search for "UniFi"
2. Select "UniFi Protect"
3. Use same credentials as Network

## Priority 3 - Energy & Climate

### Tesla (if you have Tesla vehicles)
1. In HACS, search for "Tesla Custom Integration"
2. Download and restart
3. Add via Settings → Integrations → Tesla
4. Follow authentication flow

### Tesla Powerwall (if the REST sensors aren't working)
1. Search for "Tesla Powerwall"
2. Enter IP: 192.168.3.253
3. No authentication needed for local access

### Carrier HVAC (if you have Carrier Infinity)
1. Search for "Carrier" or check HACS
2. Follow setup instructions

## Verification Steps

After adding each integration:
1. Check Developer Tools → States for new entities
2. Look for any errors in Settings → System → Logs
3. Verify data is updating (not "unavailable")

## Current Status
- ✅ Backup created: homeassistant.backup_20250810_075237
- ✅ Config backup: backups/config_backup_20250810_075357.tar.gz
- ⏳ Plex: Needs UI setup
- ⏳ Radarr: REST sensors configured, UI integration recommended
- ⏳ Sonarr: REST sensors configured, UI integration recommended  
- ⏳ UniFi Network: Needs re-authentication
- ⏳ UniFi Protect: Check if still active
- ⏳ Tesla: Needs setup if you have vehicles/Powerwall
- ⏳ Carrier: Not found, add if needed

---

## Integration Monitoring
*Source: INTEGRATION_MONITORING.md*

**Last Updated**: August 14, 2025  
**Status**: ✅ Active and Running

## Overview

The integration monitoring system automatically detects and recovers from integration failures, specifically targeting "Session is closed" errors that can occur with network-based integrations.

## Current Configuration

### Monitored Integrations
- **Bond** - Ceiling fans and shades controller
- **UniFi** - Network management (when added)
- **Sonarr** - TV show management (when added)
- **SABnzbd** - Download management (when added)

### Monitor Location
- **Script**: `/config/monitor_integration.py` (inside container)
- **Logs**: `/config/logs/integration_monitor.log`
- **Process**: Running inside Home Assistant container (PID varies)

## How It Works

1. **Continuous Monitoring**: Checks integration status every 60 seconds
2. **Error Detection**: Identifies integrations in non-loaded states
3. **Automatic Recovery**: Attempts to reload failed integrations
4. **Logging**: Records all activities for troubleshooting

## Setup Instructions

### Starting the Monitor

```bash

./scripts/start_monitor.sh


docker exec -d homeassistant bash -c "
    export HA_TOKEN='your_token_here'
    export HA_URL='http://localhost:8123'
    cd /config
    python3 monitor_integration.py > /config/logs/integration_monitor.log 2>&1
"
```

### Checking Status

```bash

docker exec homeassistant ps aux | grep monitor_integration


docker exec homeassistant tail -20 /config/logs/integration_monitor.log


curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://192.168.3.20:8123/api/config/config_entries/entry | \
  jq '.[] | select(.domain == "bond")'
```

### Stopping the Monitor

```bash

docker exec homeassistant pkill -f monitor_integration.py
```

## Configuration

### Environment Variables
- `HA_TOKEN`: Long-lived access token for Home Assistant API
- `HA_URL`: Home Assistant URL (default: `http://localhost:8123`)

### Adding New Integrations to Monitor

Edit the monitor script to add new domains:
```python
if entry.get('domain') in ['bond', 'unifi', 'sonarr', 'sabnzbd', 'new_integration']:
    logger.info(f"Attempting to reload {entry.get('domain')}...")
    reload_integration(entry.get('entry_id'))
```

## Troubleshooting

### Monitor Not Starting
1. Check token validity:
   ```bash
   curl -H "Authorization: Bearer YOUR_TOKEN" http://192.168.3.20:8123/api/
   ```
2. Verify script exists in container:
   ```bash
   docker exec homeassistant ls -la /config/monitor_integration.py
   ```

### File Sync Issues
Due to Docker Desktop for macOS limitations, files may not sync. See [Docker Sync Issues](troubleshooting/DOCKER_SYNC_ISSUES.md).

### Integration Not Reloading
- Check integration is in the monitored list
- Verify integration supports reload via API
- Check Home Assistant logs for errors

## Log Examples

### Successful Operation
```
2025-08-14 08:44:22,609 - integration_monitor - INFO - Integration monitor started
2025-08-14 08:44:22,618 - integration_monitor - INFO - Connected to Home Assistant 2025.8.1
```

### Integration Reload
```
2025-08-14 08:45:22,XXX - integration_monitor - WARNING - Integration bond is not loaded: failed_unload
2025-08-14 08:45:22,XXX - integration_monitor - INFO - Attempting to reload bond...
2025-08-14 08:45:23,XXX - integration_monitor - INFO - Successfully reloaded integration bond
```

## Related Documentation

- [Scripts Documentation](../scripts/README.md)
- [Current System Status](CURRENT_STATUS.md)
- [Docker Sync Troubleshooting](troubleshooting/DOCKER_SYNC_ISSUES.md)

## Future Enhancements

1. **Extended Monitoring**
   - Add ZHA/Zigbee coordinator monitoring
   - Monitor MCP container health
   - Track integration response times

2. **Smart Recovery**
   - Implement exponential backoff for failed reloads
   - Add integration-specific recovery strategies
   - Create alerts for repeated failures

3. **Metrics Collection**
   - Track failure frequency per integration
   - Generate uptime reports
   - Create Grafana dashboards for monitoring

---

