# UniFi Access Points Visibility Fix
**Date**: 2025-08-18 18:15

## Issue
Access points not showing in UniFi dashboard at `/dashboard-ubiquiti-devops/network`

## Root Causes Identified

1. **Missing Network View**: The dashboard file only has these views:
   - `/executive` - Executive Overview ✓
   - `/infrastructure` - Infrastructure ✓
   - `/performance` - Performance ✓
   - `/automation` - Automation ✓
   - `/analytics` - Analytics ✓
   - `/devops` - DevOps Tools ✓
   - **Missing**: `/network` view

2. **Template Sensor Issues**: The client count sensors were using MAC address filtering instead of the actual UniFi sensors

## Fixes Applied

### 1. Updated Template Sensors
Changed from MAC-based counting to using actual UniFi entities:
- `sensor.u6_lr_clients` → Now reads from UniFi integration
- `sensor.flexhd_clients` → Now reads from UniFi integration  
- `sensor.nano_hd_clients` → Added new template
- `sensor.u6_mesh_clients` → Added new template

### 2. Access Point Entities Available
All access points have these entities from UniFi:
- **U6-LR**: sensor.u6_lr_* (clients, CPU, memory, uptime, state)
- **FlexHD**: sensor.flexhd_* (clients, CPU, memory, uptime, state)
- **NanoHD**: sensor.nano_hd_* (clients, CPU, memory, uptime, state)
- **U6-Mesh**: sensor.u6_mesh_* (clients, CPU, memory, uptime, state)

### 3. Dashboard Network View
The `/network` path doesn't exist in the dashboard. Access points are shown in:
- **Infrastructure view** (`/infrastructure`) - Shows all APs with client counts
- **Performance view** (`/performance`) - Shows client distribution chart

## To See Access Points

1. Go to: `http://192.168.3.20:8123/dashboard-ubiquiti-devops/infrastructure`
2. You'll see the "Access Points Grid" section with all 4 APs
3. Each shows:
   - Status (via restart button entity)
   - Connected clients count
   - Last changed time

## Alternative: Add Network View
If you want a dedicated network view at `/network`, I can create one showing:
- Network topology map
- All access points with detailed stats
- Client device list
- Network performance metrics
- VLAN information

## Current Status
✅ All access point entities exist and are enabled
✅ Template sensors updated to use actual UniFi data
✅ Access points visible in Infrastructure view
❌ No dedicated `/network` view (can be added if needed)