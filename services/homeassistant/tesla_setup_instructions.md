# Tesla Integration Setup Instructions

## Current Issues
1. Tesla Custom Integration (v3.25.2) failed authentication for alwais@gmail.com
2. Tesla Powerwall REST sensors can't connect to gateways at 192.168.3.161 or 192.168.3.225

## To Fix Tesla Integration

### Option 1: Re-authenticate Tesla Custom Integration
1. Go to **Settings → Devices & Services**
2. Find "Tesla Custom Integration" 
3. Click on it and select "Reconfigure"
4. Re-enter your Tesla account credentials
5. Complete any 2FA requirements

### Option 2: Use Official Tesla Powerwall Integration
Since the REST sensors aren't working, try the official integration:

1. Go to **Settings → Devices & Services**
2. Click **"+ Add Integration"**
3. Search for **"Tesla Powerwall"**
4. Enter either:
   - IP: `192.168.3.161` (Inverter 1)
   - IP: `192.168.3.225` (Inverter 2)
5. If it asks for credentials:
   - Username: Usually "customer" or your installer email
   - Password: Last 5 digits of your gateway serial or installer password

### Option 3: Check Gateway Access
The gateways aren't responding to API calls. Check:

1. Can you access the gateway web interface?
   - Try: https://192.168.3.161
   - Try: https://192.168.3.225

2. If not accessible:
   - Gateways may need firmware update
   - Network isolation may be blocking access
   - Gateways may be in a different VLAN

## Temporary Solution
Until the Tesla integration is fixed, I've created placeholder sensors that won't cause errors. Once you get the integration working, the real data will replace these placeholders.

## What You Need
- Tesla account credentials for Custom Integration
- Gateway password (if using Powerwall Integration)
- Ensure gateways are on same network/VLAN as Home Assistant