# HACS Custom Cards Installation Guide
**Date**: 2025-08-18
**Purpose**: Install missing custom cards for UniFi DevOps Dashboard

## Current Status

### ✅ Already Installed
1. **mini-graph-card** - Compact graphs ✓
2. **auto-entities** - Dynamic lists ✓

### ❌ Need to Install
1. **apexcharts-card** - Advanced graphs
2. **button-card** - Custom buttons  
3. **template-entity-row** - Custom rows

## Installation Instructions

### Method 1: Via Home Assistant UI (Recommended)

1. **Open HACS**
   - Go to your Home Assistant sidebar
   - Click on **HACS**
   - If not visible, go to Settings → Integrations → HACS

2. **Install apexcharts-card**
   - Click **Frontend** tab
   - Click **+ Explore & download repositories**
   - Search for: `apexcharts-card`
   - Click on it and select **Download**
   - Choose latest version and click **Download**

3. **Install button-card**
   - Back to Frontend tab
   - Click **+ Explore & download repositories**
   - Search for: `button-card`
   - Click on it and select **Download**
   - Choose latest version and click **Download**

4. **Install template-entity-row**
   - Back to Frontend tab
   - Click **+ Explore & download repositories**
   - Search for: `template-entity-row`
   - Click on it and select **Download**
   - Choose latest version and click **Download**

5. **Clear Cache and Restart**
   - Clear browser cache: Press `Ctrl+F5` (Windows/Linux) or `Cmd+Shift+R` (Mac)
   - Go to **Settings** → **System** → **Restart**
   - Click **Restart Home Assistant**

### Method 2: Direct URLs (Alternative)

If you can't find them in HACS, add these repositories manually:

1. Go to HACS → Frontend → ⋮ (3 dots menu) → Custom repositories
2. Add these one by one:
   - Repository: `https://github.com/RomRider/apexcharts-card`
   - Category: Lovelace
   
   - Repository: `https://github.com/custom-cards/button-card`
   - Category: Lovelace
   
   - Repository: `https://github.com/thomasloven/lovelace-template-entity-row`
   - Category: Lovelace

3. After adding, install each from the Frontend tab

## Verification

After installation and restart, verify the cards are loaded:

1. Go to **Developer Tools** → **Resources**
2. You should see entries for:
   - `/hacsfiles/apexcharts-card/apexcharts-card.js`
   - `/hacsfiles/button-card/button-card.js`
   - `/hacsfiles/lovelace-template-entity-row/template-entity-row.js`

## Using the Cards in Dashboard

Once installed, these cards will be available in your dashboards:

### ApexCharts Example
```yaml
type: custom:apexcharts-card
header:
  show: true
  title: Network Traffic
series:
  - entity: sensor.dream_machine_special_edition_wan_download_throughput
    name: Download
  - entity: sensor.dream_machine_special_edition_wan_upload_throughput
    name: Upload
```

### Button Card Example
```yaml
type: custom:button-card
entity: switch.dream_machine_special_edition_dpi
name: Deep Packet Inspection
icon: mdi:shield-check
```

### Template Entity Row Example
```yaml
type: entities
entities:
  - type: custom:template-entity-row
    entity: sensor.dream_machine_special_edition_cpu_utilization
    name: CPU Usage
    state: "{{ states(config.entity) }}%"
```

## Troubleshooting

### Cards Not Showing
1. Clear browser cache again
2. Try incognito/private mode
3. Check browser console for errors (F12)

### HACS Not Working
1. Check internet connectivity
2. Verify GitHub API access
3. Check HACS logs in Settings → System → Logs

### Resource Not Found
1. Restart Home Assistant again
2. Check if files exist in `/config/www/community/`
3. Manually add resources in Dashboard → ⋮ → Resources

## Quick Installation Summary

1. **HACS** → **Frontend** → **Explore & download**
2. Search and install:
   - apexcharts-card
   - button-card
   - template-entity-row
3. Clear cache (`Ctrl+F5`)
4. Restart Home Assistant
5. Ready to use!

Your UniFi dashboard will now have access to all required custom cards for full functionality.