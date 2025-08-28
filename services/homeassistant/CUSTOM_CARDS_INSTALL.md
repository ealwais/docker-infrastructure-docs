# Custom Cards Installation for UniFi DevOps Dashboard

The advanced dashboard uses custom cards that need to be installed via HACS (Home Assistant Community Store).

## Required Custom Cards

1. **ApexCharts Card** - Advanced charting
2. **Mini Graph Card** - Compact graphs
3. **Button Card** - Customizable buttons
4. **Auto Entities** - Dynamic entity lists
5. **Template Entity Row** - Custom entity rows
6. **Logbook Card** - Enhanced logbook display

## Installation Options

### Option 1: Use the Standard Dashboard (Recommended)
The `dashboard_ubiquiti_devops_standard.yaml` version uses only built-in Home Assistant cards and requires no additional installations. This is already configured and should work at:
http://192.168.3.20:8123/dashboard-ubiquiti-devops/executive

### Option 2: Install Custom Cards via HACS

1. **Open HACS** in Home Assistant sidebar
2. Click **Frontend** tab
3. Click **+ Explore & Download Repositories**
4. Search and install each card:
   - `apexcharts-card`
   - `mini-graph-card`
   - `button-card`
   - `auto-entities`
   - `template-entity-row`
   - `logbook-card`
5. Restart Home Assistant after installation

### Option 3: Switch to Advanced Dashboard After Installing Cards

Once cards are installed, update the configuration:

```bash
# Edit lovelace_dashboards.yaml and change:
filename: dashboard_ubiquiti_devops_standard.yaml
# to:
filename: dashboard_ubiquiti_devops.yaml
```

Then restart Home Assistant.

## Current Status

✅ **Standard Dashboard is Active** - No additional installation needed
- Uses only built-in Home Assistant cards
- Full functionality with standard visualizations
- Located at: http://192.168.3.20:8123/dashboard-ubiquiti-devops/executive

The standard dashboard provides all the same monitoring capabilities and data, just with the built-in visualization options instead of the fancier custom cards.