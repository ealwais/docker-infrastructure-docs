# Dashboard Documentation

*Consolidated on: 2025-08-27*

## Table of Contents

1. [Dashboard Access Guide](#dashboard_access_guide)
2. [Dashboard Entity Analysis](#dashboard_entity_analysis)
3. [Dashboard Url Analysis](#dashboard_url_analysis)
4. [Dashboard Fix Summary](#dashboard_fix_summary)
5. [Dashboard Issues](#dashboard_issues)
6. [Dashboard Migration Complete](#dashboard_migration_complete)
7. [Dashboard Mode Switching Guide](#dashboard_mode_switching_guide)
8. [Fix 404 Dashboard](#fix_404_dashboard)
9. [Fix Unifi Dashboard](#fix_unifi_dashboard)
10. [Check Dashboard Mode](#check_dashboard_mode)

---

## Dashboard Access Guide
*Source: DASHBOARD_ACCESS_GUIDE.md*

## Current Dashboard URLs

Based on the `lovelace_dashboards.yaml` configuration, your dashboards should be available at:

### Main Dashboards:
1. **Lights**: http://192.168.3.20:8123/lovelace/dashboard-lights
2. **Family Dashboard**: http://192.168.3.20:8123/lovelace/dashboard-family
3. **Smart Home**: http://192.168.3.20:8123/lovelace/dashboard-smart-home
4. **Main Overview**: http://192.168.3.20:8123/lovelace/dashboard-main-overview
5. **Infrastructure**: http://192.168.3.20:8123/lovelace/dashboard-infrastructure
6. **UniFi Network**: http://192.168.3.20:8123/lovelace/dashboard-ubiquiti
7. **UniFi DevOps**: http://192.168.3.20:8123/lovelace/dashboard-ubiquiti-devops

## ⚠️ The Issue
When you go to `/lovelace/0`, that's the default auto-generated dashboard, NOT your custom dashboards.

## ✅ To Access Your UniFi DevOps Dashboard:

### Method 1: Direct URL
Go directly to: **http://192.168.3.20:8123/lovelace/dashboard-ubiquiti-devops**

### Method 2: From the UI
1. Click the hamburger menu (☰) in the top left
2. You should see all your dashboards listed:
   - Lights
   - Family Dashboard
   - Smart Home
   - Main Overview
   - Infrastructure
   - UniFi Network
   - UniFi DevOps ← Click this one

### Method 3: Set Default Dashboard
1. Go to your user profile (bottom left corner)
2. Under "Dashboard" select "UniFi DevOps" as your default
3. Now when you go to Home Assistant, it will load that dashboard by default

## 🔧 If Dashboards Are Missing from Sidebar:

1. **Check Configuration**:
   - Go to Settings → Dashboards
   - You should see all 7 dashboards listed
   - Make sure they all show "Visible in sidebar"

2. **Force Reload**:
   - Press Ctrl+F5 (or Cmd+Shift+R on Mac) to hard refresh
   - Or clear browser cache

3. **Restart Home Assistant**:
   - Settings → System → Restart
   - This will reload all dashboard configurations

## 📊 Your Memory Fix Status:
The corrected memory sensor (showing 77% instead of 85.6%) will only appear on the UniFi DevOps dashboard at:
**http://192.168.3.20:8123/lovelace/dashboard-ubiquiti-devops**

The default dashboard (`/lovelace/0`) won't have these customizations.

---

## Dashboard Entity Analysis
*Source: dashboard_entity_analysis.md*

## Summary
Analysis of `/mnt/docker/homeassistant/dashboard_lights_fixed.yaml` to identify missing entities and potential issues.

## Entities Referenced in Dashboard

### Light Entities
- `light.ceiling_fan_down_light` - Ceiling Fan Down
- `light.ceiling_fan_up_light` - Ceiling Fan Up  
- `light.primary_room_fan` - Primary Room
- `light.hallway_main_lights` - Hallway
- `light.kitchen_main_lights` - Kitchen
- `light.office_ceiling_fan_light` - Office
- `light.lumi_lumi_switch_b1laus01` - Dining Room Switch
- `light.lumi_lumi_switch_b1laus01_2` - Kitchen Fan Switch

### Fan Entities
- `fan.office_ceiling_fan` - Office Fan
- `fan.primary_room_fan_2` - Primary Room Fan
- **`fan.ceiling_fan_2`** - Ceiling Fan 2 ⚠️ **POTENTIALLY MISSING**

### Switch Entities
- `switch.desk_lamp` - Desk Lamp
- `switch.smart_plug_mini` - Smart Plug Mini
- `switch.smart_wi_fi_plug_mini_3` - Smart Wi-Fi Plug Mini 3
- `switch.lumi_lumi_plug_maus01_2` - Xiaomi Smart Plug 1
- `switch.lumi_lumi_plug_maus01_3` - Xiaomi Smart Plug 2

### Sensor Entities
- `sensor.lights_on_count` - Lights On Count
- `sensor.switches_on_count` - Switches On Count

### Commented Out Entities (Unavailable)
- `fan.dyson_ceiling_fan` - Dyson Fan (line 66-67)
- `switch.lumi_lumi_plug_maus01` - Xiaomi Smart Plug 1 (line 76-77)

## Service Calls
- `homeassistant.turn_off` with `entity_id: all`
- `light.turn_off` with `entity_id: all`
- `fan.turn_off` with `entity_id: all`
- `switch.turn_off` with specific entities

## Potential Issues

### 1. Missing Entity: `fan.ceiling_fan_2`
This entity is referenced on line 63-64 but may not exist in your system. This could cause errors when trying to control this fan.

**Recommendation**: Either:
- Remove or comment out this entity from the dashboard
- Check if this entity exists with a different name in your system
- Set up the missing fan integration

### 2. Template Sensors
The dashboard uses two template sensors (`sensor.lights_on_count` and `sensor.switches_on_count`). These are defined in `/mnt/docker/homeassistant/packages/dashboard_sensors.yaml`.

**Status**: ✅ These sensors are properly configured and should work.

### 3. Commented Entities
Two entities are commented out, suggesting they were previously problematic:
- `fan.dyson_ceiling_fan` - Likely a Dyson fan that's not integrated
- `switch.lumi_lumi_plug_maus01` - First Xiaomi plug that may be offline

### 4. YAML Syntax
No syntax errors were found in the YAML structure.

## Recommendations

1. **Verify `fan.ceiling_fan_2`**: Check if this entity exists in your Home Assistant:
   - Go to Developer Tools > States
   - Search for "fan.ceiling_fan_2"
   - If it doesn't exist, either remove it from the dashboard or rename it to match an existing fan entity

2. **Check Entity Availability**: For all entities, verify they're available:
   - Check Developer Tools > States
   - Look for entities showing as "unavailable" or "unknown"

3. **Consider Renaming**: Based on the `customize_entities.yaml` file, `fan.ceiling_fan_2` is expected to be "Family Room Ceiling Fan". If this fan exists with a different entity ID, update the dashboard accordingly.

## Cross-Reference with customize_entities.yaml

The `customize_entities.yaml` file shows that `fan.ceiling_fan_2` should have a friendly name of "Family Room Ceiling Fan". This suggests the entity is expected to exist but might:
- Be offline or disconnected
- Have a different entity ID
- Need to be re-added through its integration

## Action Items
1. ✅ Remove or fix reference to `fan.ceiling_fan_2` 
2. ✅ Verify all other entities are available
3. ✅ Test all service calls work correctly
4. ✅ Consider uncommenting entities if they become available again

---

## Dashboard Url Analysis
*Source: dashboard_url_analysis.md*

## Findings

### 1. URL Structure Pattern
Home Assistant custom dashboard URLs follow this pattern:
```
http://[IP]:[PORT]/[dashboard-key]/[view-path]
```

Where:
- `dashboard-key` = The key defined in configuration.yaml under `lovelace.dashboards`
- `view-path` = The path defined in the dashboard YAML file under `views[].path`

### 2. Working Dashboard Analysis
- Default dashboard: http://192.168.3.20:8123/lovelace/0 ✓ (works)
- This accesses the ui-lovelace.yaml file

### 3. Lights Dashboard Configuration
From configuration.yaml:
```yaml
lovelace:
  dashboards:
    lights-only:
      mode: yaml
      title: Lights
      icon: mdi:lightbulb-group
      show_in_sidebar: true
      filename: dashboard_lights_only.yaml
```

From dashboard_lights_only.yaml:
```yaml
views:
  - title: All Lights
    path: lights  # <-- This is the view path
```

### 4. Correct URL for Lights Dashboard
The correct URL should be:
```
http://192.168.3.20:8123/lights-only/lights
```

### 5. Why "/lights-only/lights" gives 404

If you're getting a 404 error, possible reasons:
1. **Home Assistant needs restart** after dashboard configuration changes
2. **Browser cache** - Try hard refresh (Ctrl+F5 or Cmd+Shift+R)
3. **YAML syntax error** in dashboard file (though the file looks correct)

### 6. Other Dashboard URLs (from configuration.yaml)

- UniFi: http://192.168.3.20:8123/unifi/[view-path]
- Home Control: http://192.168.3.20:8123/home-control/[view-path]
- Simple Home: http://192.168.3.20:8123/simple-home/[view-path]
- Smart Home: http://192.168.3.20:8123/smart-home/[view-path]
- Lights Only: http://192.168.3.20:8123/lights-only/lights

### 7. Sidebar Navigation
Since `show_in_sidebar: true` is set, the "Lights" dashboard should appear in the Home Assistant sidebar with a lightbulb-group icon.

## Recommended Troubleshooting Steps

1. **Check if dashboard appears in sidebar**
   - Look for "Lights" with lightbulb-group icon in the left sidebar

2. **Try direct URL access**
   - http://192.168.3.20:8123/lights-only/lights
   - http://192.168.3.20:8123/lights-only/0 (if no path specified, defaults to 0)

3. **Restart Home Assistant**
   - Dashboard changes require restart to take effect

4. **Check browser console**
   - Press F12 and check for JavaScript errors

5. **Verify YAML syntax**
   - Use Home Assistant's Configuration validation tool

---

## Dashboard Fix Summary
*Source: DASHBOARD_FIX_SUMMARY.md*

## Problems Identified

### 1. **Entity Naming Issues**
- `light.light` - Generic unhelpful name
- `switch.dining_rom_power` - Typo (should be "room")
- `switch.device` and `switch.devicew` - Test/placeholder entities
- Technical names like `light.lumi_lumi_switch_b1laus01` from Zigbee devices

### 2. **Domain Mismatches**
- `switch.desk_light` - Should be in light domain
- `switch.bae_fan` - Should be in fan domain
- Switches controlling lights/fans not properly categorized

### 3. **Duplicate Entities**
- `light.primary_room_fan` and `fan.primary_room_fan_2` - Same device split
- Multiple ceiling fans with inconsistent naming patterns
- Entities appearing in multiple dashboard sections

### 4. **Dashboard Filter Issues**
- Wildcard filters (`*kitchen*`) catching unintended entities
- No exclusions for diagnostic entities (power, energy, voltage sensors)
- Case-sensitive duplicates from searching both "kitchen" and "Kitchen"

## Solutions Provided

### 1. **Analysis Scripts**
- `/scripts/fix_entity_names.py` - Analyzes all entities and identifies issues
- `/scripts/check_dashboard_entities.py` - Shows dashboard-specific duplicates
- `/scripts/apply_entity_fixes.sh` - Applies fixes step by step

### 2. **Entity Customizations**
- `/customize_entities.yaml` - Fixes friendly names without changing entity IDs
- Hides test entities
- Adds proper icons and device classes

### 3. **Improved Dashboards**
- `/dashboard_family_fixed.yaml` - Complete redesign using Mushroom cards
- `/dashboard_family_improved.yaml` - Enhanced filtering with auto-entities
- Better organization with dedicated views for Lights, Climate, and Scenes

### 4. **Helper Packages**
- `/packages/house_modes.yaml` - Input booleans for house modes
- `/packages/entity_counters.yaml` - Template sensors for device counts

## How to Apply Fixes

### Quick Fix (Just the Dashboard)
```bash

docker exec homeassistant cp /config/dashboard_family.yaml /config/dashboard_family_backup.yaml


docker exec homeassistant cp /config/dashboard_family_fixed.yaml /config/dashboard_family.yaml


docker restart homeassistant
```

### Full Fix (Entities + Dashboard)
```bash

docker exec -e HA_TOKEN='your-token' homeassistant python3 /config/scripts/fix_entity_names.py







docker exec homeassistant cp /config/dashboard_family_fixed.yaml /config/dashboard_family.yaml


docker restart homeassistant
```

## Required HACS Cards

Install these through HACS → Frontend:
1. **Mushroom** - For modern, clean UI cards
2. **Auto-entities** - For dynamic entity filtering
3. **Layout-card** - For masonry grid layouts

## Key Improvements

1. **Cleaner Organization**
   - Separate views for Lights, Climate, and Scenes
   - Room-based grouping with visual icons
   - Quick access to commonly used controls

2. **Smart Filtering**
   - Excludes diagnostic entities automatically
   - No more duplicates from overlapping filters
   - Shows only relevant controllable entities

3. **Better Visual Design**
   - Mushroom cards for consistent look
   - Color-coded states
   - Responsive grid layout
   - Device counters in header

4. **Performance**
   - Auto-entities only loads visible entities
   - Efficient filtering reduces dashboard size
   - Faster loading with focused views

## Testing the Fixes

1. Check for duplicates:
   ```bash
   docker exec -e HA_TOKEN='your-token' homeassistant python3 /config/scripts/check_dashboard_entities.py
   ```

2. Preview the new dashboard by adding it as a test:
   ```yaml
   # In configuration.yaml under lovelace:
   family_test:
     mode: yaml
     title: Family Test
     icon: mdi:test-tube
     show_in_sidebar: true
     filename: dashboard_family_fixed.yaml
   ```

3. Once satisfied, replace the main family dashboard

---

## Dashboard Issues
*Source: DASHBOARD_ISSUES.md*

## Current Dashboard Sync Issue

### Problem Description
Changes made to dashboard YAML files on the host are not reflected in the Home Assistant UI, even after restarting.

### Root Cause
1. **File Sync Issue**: Files edited at `/mnt/docker/homeassistant/` are not syncing to container `/config/`
2. **Docker Volume**: Mount is configured correctly but sync is not happening
3. **Cache Issue**: Possible aggressive caching by Home Assistant

### Symptoms
- Editing dashboard YAML files has no effect
- New dashboards added to configuration.yaml don't appear
- Even direct container file edits don't update UI
- Browser cache clearing doesn't help

## Quick Fixes to Try

### 1. Force Reload Dashboard
```bash

docker exec homeassistant bash
cd /config
touch dashboard_*.yaml  # Update timestamps
exit


docker restart homeassistant
```

### 2. Check File Sync
```bash

diff /mnt/docker/homeassistant/dashboard_family.yaml \
     <(docker exec homeassistant cat /config/dashboard_family.yaml)
```

### 3. Verify YAML Mode
Check that dashboards are truly in YAML mode:
```yaml

lovelace:
  mode: yaml  # This enables YAML mode
  dashboards:
    family:
      mode: yaml
      filename: dashboard_family.yaml
```

### 4. Check for ui-lovelace.yaml Override
```bash

docker exec homeassistant cat /config/ui-lovelace.yaml
```

## Common Dashboard Problems

### Entity Issues
- **Generic names**: `light.light`, `switch.device`
  - Fix: Use `customize.yaml` to set friendly names
- **Wrong domains**: `switch.desk_light` (should be `light.desk_light`)
  - Fix: Correct in dashboard YAML
- **Missing entities**: Entity doesn't exist
  - Fix: Check **Developer Tools** → **States**

### YAML Syntax Errors
Always validate YAML:
```bash

docker exec homeassistant hass --script check_config
```

Common errors:
- Incorrect indentation (use 2 spaces, not tabs)
- Missing quotes around special characters
- Duplicate keys

### Dashboard Not Showing in Sidebar
1. Check `show_in_sidebar: true` in configuration
2. Verify `require_admin: false` for non-admin users
3. Check for typos in dashboard key name

## Advanced Troubleshooting

### 1. Direct Database Check
```bash

docker exec homeassistant sqlite3 /config/home-assistant_v2.db \
  "SELECT * FROM states WHERE entity_id LIKE 'lovelace%';"
```

### 2. Force Dashboard Reload via API
```bash

TOKEN="your_ha_access_token"


curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  http://localhost:8123/api/services/lovelace/reload_resources
```

### 3. Check Docker Volume Mount
```bash

docker inspect homeassistant | grep -A 10 Mounts


docker exec homeassistant touch /config/test_write.txt
ls -la /mnt/docker/homeassistant/test_write.txt
```

### 4. Nuclear Option - Recreate Container
```bash

cd /mnt/docker/homeassistant
docker-compose down
docker-compose up -d
```

## Temporary Workarounds

### Edit Directly in Container
```bash

docker exec -it homeassistant vi /config/dashboard_family.yaml


docker cp dashboard_family.yaml homeassistant:/config/
```

### Use UI Editor
1. Install "File Editor" add-on
2. Edit dashboard files through web UI
3. Changes should apply immediately

### Storage Mode Migration
If YAML mode isn't working, consider migrating to storage mode:
1. Remove `mode: yaml` from configuration
2. Use UI to create dashboards
3. More reliable but less version-control friendly

## Prevention

### Best Practices
1. Always edit in one place (host OR container)
2. Restart HA after dashboard changes
3. Use version control for dashboard files
4. Test changes in a separate dashboard first

### Monitoring
Watch for these in logs:
- "Unable to find dashboard"
- "Invalid config for [lovelace]"
- "Error loading dashboard"

## Known Working Configuration
```yaml

lovelace:
  mode: yaml
  resources:
    - url: /hacsfiles/mushroom/mushroom.js
      type: module
  dashboards:
    example:
      mode: yaml
      title: Example
      icon: mdi:home
      show_in_sidebar: true
      filename: dashboard_example.yaml
```

## Still Not Working?
1. Check container logs: `docker logs homeassistant`
2. Look for `.storage/lovelace.*` files that might override
3. Try a completely new dashboard name
4. Consider filing a bug report if Docker volume sync is broken

## Related Issues
- File permissions (should be owned by UID 1000)
- Docker Desktop for Mac file sync delays
- YAML anchors and includes not working
- Custom cards not loading

---

## Dashboard Migration Complete
*Source: DASHBOARD_MIGRATION_COMPLETE.md*

## What Happened
Home Assistant was using storage mode for dashboards instead of YAML mode. This caused your dashboard changes to not appear because:
- Storage mode saves dashboards in `.storage/lovelace_dashboards`
- YAML mode reads from `lovelace_dashboards.yaml` and individual dashboard files
- When both exist, storage mode takes precedence

## What We Did
1. Backed up storage files to `/config/backups/storage_[timestamp]/`
2. Removed `.storage/lovelace_dashboards` to force YAML mode
3. Restarted Home Assistant

## Your Dashboards Are Now Active
Access your UniFi DevOps dashboard with corrected memory (77%) at:
**http://192.168.3.20:8123/lovelace/dashboard-ubiquiti-devops**

All dashboards from `lovelace_dashboards.yaml`:
- Lights
- Family Dashboard  
- Smart Home
- Main Overview
- Infrastructure
- UniFi Network
- **UniFi DevOps** (with corrected memory sensor)

## Important Notes
- The corrected memory sensor `sensor.dream_machine_memory_usage_corrected` is active
- It shows 76.9% (approximately 77%) instead of the incorrect 85.6%
- Network traffic sensors are ready but need DPI enabled in UniFi

## If Issues Persist
1. Clear browser cache (Ctrl+F5 or Cmd+Shift+R)
2. In Home Assistant: Developer Tools → YAML → Reload Lovelace YAML configuration
3. Check http://192.168.3.20:8123/lovelace/dashboard-ubiquiti-devops directly

## Mode Comparison
| Feature | Storage Mode | YAML Mode (Current) |
|---------|--------------|---------------------|
| Edit via UI | ✅ Yes | ❌ No |
| Version Control | ❌ No | ✅ Yes |
| File Location | `.storage/` | YAML files |
| Persistence | Database | File system |

---

## Dashboard Mode Switching Guide
*Source: DASHBOARD_MODE_SWITCHING_GUIDE.md*

## Overview
Home Assistant supports two modes for managing dashboards:
1. **Storage Mode** - Dashboards are stored in the database and edited through the UI
2. **YAML Mode** - Dashboards are defined in YAML files and edited as code

## Current Configuration
Based on the configuration files:
- Main lovelace: `mode: storage` (in configuration.yaml)
- Individual dashboards: `mode: yaml` (in lovelace_dashboards.yaml)
- This creates a hybrid setup where the main dashboard uses storage mode but additional dashboards use YAML mode

## What Happens When Switching Modes

### From Storage to YAML Mode
1. **Dashboard Data Location Changes**:
   - Storage mode: Dashboard configuration stored in `.storage/lovelace` file
   - YAML mode: Dashboard configuration read from YAML files
   
2. **Potential Data Loss**:
   - ⚠️ **WARNING**: UI-created dashboards in storage mode will NOT automatically convert to YAML
   - You must manually export/recreate dashboards in YAML format
   - The `.storage/lovelace` file is ignored when in YAML mode

3. **How to Preserve Dashboards**:
   ```bash
   # Before switching to YAML mode:
   # 1. Export current dashboard configuration
   # Go to Settings → Dashboards → Your Dashboard → Raw Configuration Editor
   # Copy the entire YAML content
   
   # 2. Save to a YAML file
   # Create dashboard_name.yaml with the copied content
   
   # 3. Update configuration.yaml
   lovelace:
     mode: yaml
     dashboards:
       your_dashboard:
         mode: yaml
         filename: dashboard_name.yaml
         title: Your Dashboard
         icon: mdi:home
         show_in_sidebar: true
   ```

### From YAML to Storage Mode
1. **Dashboard Files Ignored**:
   - YAML dashboard files will stop being read
   - System creates new empty storage-based dashboards
   - Previous YAML dashboards disappear from UI

2. **No Automatic Import**:
   - ⚠️ **WARNING**: YAML dashboards are NOT automatically imported to storage mode
   - You must manually recreate dashboards in the UI

3. **How to Preserve Dashboards**:
   ```bash
   # Before switching to storage mode:
   # 1. Keep YAML files as backup
   cp dashboard_*.yaml backup_dashboards/
   
   # 2. Change mode in configuration.yaml
   lovelace:
     mode: storage
   
   # 3. Restart Home Assistant
   
   # 4. Manually recreate dashboards in UI using YAML as reference
   # Go to Settings → Dashboards → Add Dashboard
   # Use Raw Configuration Editor to paste YAML content
   ```

## Best Practices for Mode Switching

### 1. Always Backup First
```bash

mkdir -p /mnt/docker/homeassistant/backup_dashboards/$(date +%Y%m%d)
cp /mnt/docker/homeassistant/dashboard_*.yaml /mnt/docker/homeassistant/backup_dashboards/$(date +%Y%m%d)/
cp /mnt/docker/homeassistant/.storage/lovelace* /mnt/docker/homeassistant/backup_dashboards/$(date +%Y%m%d)/
```

### 2. Document Current State
```bash

docker exec homeassistant ls -la /config/dashboard_*.yaml
docker exec homeassistant ls -la /config/.storage/lovelace*
```

### 3. Test with a Single Dashboard First
Before switching all dashboards, test with one:
```yaml

lovelace:
  mode: storage  # Keep main in storage
  dashboards:
    test_yaml:
      mode: yaml  # Test one in YAML
      filename: dashboard_test.yaml
      title: Test Dashboard
      show_in_sidebar: true
```

## Storage Mode vs YAML Mode Comparison

| Feature | Storage Mode | YAML Mode |
|---------|--------------|-----------|
| **Editing** | Web UI only | Text editor/IDE |
| **Version Control** | No (database) | Yes (text files) |
| **Backup** | HA backup only | Git/file backup |
| **Collaboration** | Difficult | Easy with Git |
| **UI Helpers** | Yes | No |
| **Live Preview** | Yes | No (need reload) |
| **File Location** | `.storage/lovelace` | `dashboard_*.yaml` |
| **Mode Switching** | Data loss risk | Data loss risk |

## Common Issues When Switching

### 1. Dashboards Disappear
- **Cause**: Mode changed but dashboards not migrated
- **Fix**: Restore from backup and properly migrate

### 2. File Sync Issues (Docker)
- **Cause**: YAML files edited on host not syncing to container
- **Fix**: Edit directly in container or use `docker cp`

### 3. Mixed Mode Confusion
- **Cause**: Main dashboard in storage, others in YAML
- **Fix**: Use consistent mode for all dashboards

### 4. Cache Problems
- **Symptom**: Old dashboard still showing after switch
- **Fix**: Clear browser cache, restart HA

## Recovery Procedures

### If You Lost Dashboards Switching to YAML Mode
```bash

docker exec homeassistant cat /config/.storage/lovelace



docker restart homeassistant





```

### If You Lost Dashboards Switching to Storage Mode
```bash

ls -la /mnt/docker/homeassistant/dashboard_*.yaml





```

## Recommended Approach

1. **For New Users**: Start with Storage Mode
   - Easier to learn
   - Visual editing
   - Less prone to syntax errors

2. **For Advanced Users**: Use YAML Mode
   - Version control with Git
   - Team collaboration
   - Advanced templating
   - Automation of dashboard creation

3. **For Mixed Needs**: Hybrid Approach
   - Main dashboard in storage for easy editing
   - Complex dashboards in YAML for version control
   - Test dashboards in storage before converting to YAML

## Script for Safe Mode Switching

```bash
#!/bin/bash




MODE=$1
BACKUP_DIR="/mnt/docker/homeassistant/backup_dashboards/$(date +%Y%m%d_%H%M%S)"


mkdir -p "$BACKUP_DIR"
cp -r /mnt/docker/homeassistant/.storage "$BACKUP_DIR/"
cp /mnt/docker/homeassistant/dashboard_*.yaml "$BACKUP_DIR/" 2>/dev/null
cp /mnt/docker/homeassistant/configuration.yaml "$BACKUP_DIR/"

echo "Backup created in $BACKUP_DIR"


echo "Current mode:"
grep -A2 "^lovelace:" /mnt/docker/homeassistant/configuration.yaml


read -p "Switch to $MODE mode? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Update configuration
    # This is a simplified example - real implementation would need proper YAML parsing
    echo "Switching to $MODE mode..."
    echo "Please manually update configuration.yaml"
    echo "Then restart Home Assistant"
else
    echo "Cancelled"
fi
```

## Summary

**Key Points:**
1. ⚠️ **Switching modes does NOT automatically convert dashboards**
2. Always backup before switching modes
3. Manual migration is required in both directions
4. Storage mode = UI editing, YAML mode = file editing
5. Data loss is possible if not properly migrated
6. Consider keeping both modes (hybrid) for flexibility

---

## Fix 404 Dashboard
*Source: FIX_404_DASHBOARD.md*

## Issue Found and Fixed
The multi-site monitoring package was referencing undefined secrets, causing Home Assistant to fail loading the configuration. This has been fixed.

## Steps to Access the Dashboard

1. **Wait for Home Assistant to fully restart** (2-3 minutes from now)

2. **Try these URLs in order:**
   - http://192.168.3.20:8123/dashboard-ubiquiti-devops/executive
   - http://192.168.3.20:8123/lovelace/dashboard-ubiquiti-devops
   - Access via the sidebar: Look for "UniFi DevOps" in the left menu

3. **If still getting 404:**
   - Clear browser cache (Ctrl+F5 or Cmd+Shift+R)
   - Try a different browser or incognito mode
   - Check if you can access the regular UniFi dashboard: http://192.168.3.20:8123/dashboard-ubiquiti/overview

4. **Verify from Home Assistant UI:**
   - Go to Configuration → Dashboards
   - Check if "UniFi DevOps" is listed
   - If not, the configuration hasn't loaded properly

## Alternative Quick Access

While waiting, you can access the existing UniFi dashboard that's already working:
http://192.168.3.20:8123/dashboard-ubiquiti/overview

## Manual Configuration Check

From the Home Assistant UI:
1. Go to **Configuration → Server Controls**
2. Click **Check Configuration**
3. If valid, click **Restart** → **Restart Home Assistant**

## The Dashboard Includes

Once accessible, you'll have:
- Executive overview with health scores
- Infrastructure monitoring
- Performance analytics
- Monitoring & alerts
- Analytics & trends
- DevOps tools

All sensors and automations are now properly configured and will start collecting data once Home Assistant loads successfully.

---

## Fix Unifi Dashboard
*Source: FIX_UNIFI_DASHBOARD.md*

## Common Problems and Solutions

### 1. Missing Custom Cards
Your dashboard uses custom cards that may not be installed:
- `custom:auto-entities`
- `custom:mini-graph-card`

**Fix:**
1. Install HACS if not already installed
2. Go to HACS → Frontend
3. Search and install:
   - "auto-entities" 
   - "mini-graph-card"
4. Clear browser cache (Ctrl+Shift+R or Cmd+Shift+R)

### 2. Missing UniFi Entities

The dashboard expects these entities:

**From UniFi Network Integration:**
- `sensor.unifi_gateway_www_speedtest_download`
- `sensor.unifi_gateway_www_speedtest_upload`
- `sensor.unifi_gateway_www_speedtest_ping`
- `sensor.unifi_gateway_wan_download`
- `sensor.unifi_gateway_wan_upload`
- `sensor.unifi_gateway_wan_ip`
- `sensor.unifi_gateway_www_xput_down`
- `sensor.unifi_gateway_www_xput_up`
- `sensor.unifi_gateway_wlan_num_user`
- `sensor.unifi_switch_24_poe_*`

**From UniFi Protect Integration:**
- `camera.g5_pro_high`
- `camera.g4_doorbell_pro_high`
- `binary_sensor.g5_pro_person_detected`
- `binary_sensor.g4_doorbell_pro_person_detected`

### 3. Check Integration Status

```yaml


1. UniFi Network integration
   - Should be connected to 192.168.3.1
   - Username: emalwais
   - Password: (from secrets)

2. UniFi Protect integration  
   - May need separate setup
   - Uses same credentials
   - Provides camera entities
```

### 4. Quick Fixes to Try

**A. Reload Integrations:**
```bash

Developer Tools → YAML → Reload All

Settings → System → Restart
```

**B. Re-add UniFi Integration:**
1. Settings → Devices & Services
2. Delete UniFi integration
3. Add Integration → UniFi
4. Enter:
   - Host: 192.168.3.1
   - Username: emalwais
   - Password: Dunc@n212025
   - Port: 443 (default)

**C. Check Entity Names:**
1. Go to Developer Tools → States
2. Filter by "unifi"
3. Note actual entity names
4. Update dashboard if different

### 5. Dashboard Test Version

Create a test dashboard to verify entities:

```yaml
title: UniFi Test
views:
  - title: Test
    cards:
      - type: entities
        title: UniFi Entities Check
        entities:
          - entity: sensor.unifi_gateway_www
            name: Gateway (if exists)
          - type: section
            label: "Available UniFi Entities:"
      - type: custom:auto-entities
        card:
          type: entities
          title: All UniFi Entities
        filter:
          include:
            - entity_id: "*unifi*"
            - entity_id: "camera.*"
        sort:
          method: entity_id
```

### 6. Manual Entity Creation

If speedtest entities don't exist, you can create command line sensors:

```yaml

sensor:
  - platform: command_line
    name: UniFi Speedtest Download
    command: 'curl -s http://192.168.3.1/api/s/default/stat/health | jq .data[0].speedtest.download'
    unit_of_measurement: "Mbps"
    scan_interval: 3600
```

### 7. Network Connection Issues

Your `network_fixes.yaml` suggests connection drops. Check:
1. Home Assistant logs for UniFi errors
2. Try the network fix automation:
   ```yaml
   service: homeassistant.reload_config_entry
   data:
     entry_id: "{{ config_entry_id('unifi') }}"
   ```

### 8. Browser Issues

Try:
1. Different browser
2. Clear all cache/cookies
3. Incognito/Private mode
4. Disable browser extensions

### 9. Alternative Dashboard

If entities are missing, use the auto-generated dashboard:
1. Settings → Dashboards
2. Add Dashboard
3. Let HA auto-generate from available entities

---

## Check Dashboard Mode
*Source: check_dashboard_mode.md*

The error "unable to edit ui in yaml mode" suggests one of these issues:

## 1. Mixed Mode Issue
Your main Lovelace might be in storage mode while trying to use YAML dashboards.

## 2. Fix Options:

### Option A: Force YAML Mode (Already Set)
Your configuration.yaml has:
```yaml
lovelace:
  mode: yaml
  dashboards: !include lovelace_dashboards.yaml
```

### Option B: Edit via File System
Since the dashboards are in YAML mode, you need to:
1. Edit the YAML files directly (which we've been doing)
2. Reload via Developer Tools → YAML → LOVELACE DASHBOARDS
3. NOT use the UI editor (three dots → Edit Dashboard)

### Option C: Check Default Dashboard
The default dashboard might be in storage mode. Check:
- http://192.168.3.20:8123/lovelace/0 (default dashboard)
- vs http://192.168.3.20:8123/dashboard-lights/home (custom dashboard)

## To See Your Meross Devices:

Since they show on Infrastructure dashboard, try:
1. Go directly to: http://192.168.3.20:8123/dashboard-infrastructure/devices
2. This confirms the devices work

For the Lights dashboard, try:
1. DON'T use the UI editor
2. The changes we made should work after reload
3. Try: http://192.168.3.20:8123/dashboard-lights/home in a new incognito window

## Nuclear Option:
Remove the lights dashboard and recreate it:
1. Remove from lovelace_dashboards.yaml
2. Restart HA
3. Add it back
4. Restart again

---

