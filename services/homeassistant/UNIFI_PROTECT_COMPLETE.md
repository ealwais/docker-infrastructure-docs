# Unifi Protect Documentation

*Consolidated on: 2025-08-27*

## Table of Contents

1. [Unifi Protect Setup Steps](#unifi_protect_setup_steps)
2. [Fix Unifi Protect](#fix_unifi_protect)

---

## Unifi Protect Setup Steps
*Source: UNIFI_PROTECT_SETUP_STEPS.md*

## Prerequisites Check ✓
- UniFi Dream Machine Pro SE at: `192.168.3.1` ✓
- Credentials in secrets.yaml ✓
  - Username: `emalwais`
  - Password: `Dunc@n212025`

## Step-by-Step Setup

### 1. Open Home Assistant
Go to: http://192.168.3.20:8123

### 2. Navigate to Integrations
- Click **Settings** (gear icon) in sidebar
- Click **Devices & Services**

### 3. Add UniFi Protect
- Click the **"+ ADD INTEGRATION"** button (bottom right)
- Type **"unifi"** in the search box
- Select **"UniFi Protect"** (NOT "UniFi Network")

### 4. Enter Connection Details
Fill in these fields:
```
Host: 192.168.3.1
Port: 443
Verify SSL Certificate: ☐ (UNCHECKED - Important!)
Username: emalwais
Password: Dunc@n212025
```

### 5. Configure Options
After successful connection, you'll see options:
- **All Cameras**: Check all boxes
- **Realtime Updates**: Enable (recommended)
- **Max Camera Resolution**: High
- **Recording Mode**: Your preference

### 6. Complete Setup
- Click **Submit**
- Wait for discovery (may take 30-60 seconds)
- You should see your cameras listed

## Verify Success

### Check Entities Created
Go to **Developer Tools → States** and search for:
- `camera.` - Should show your cameras
- `binary_sensor.*doorbell*` - Doorbell sensors
- `binary_sensor.*motion*` - Motion sensors

### Expected Devices:
1. **G5 Pro Camera**
   - Camera feed
   - Motion/Person/Vehicle detection
   - Privacy mode switch

2. **G4 Doorbell Pro**
   - Camera feed
   - Doorbell button sensor
   - Motion/Person detection
   - Privacy mode switch

## Troubleshooting

### "Cannot Connect" Error
1. Verify UniFi Protect is enabled on your UDM
2. Check if you can access: https://192.168.3.1/protect
3. Make sure using local user, not Ubiquiti cloud account

### "Invalid Authentication"
1. Verify username is `emalwais` (not email)
2. Password is exactly: `Dunc@n212025`
3. User has admin permissions in UniFi

### SSL Certificate Error
- Make sure "Verify SSL Certificate" is UNCHECKED
- This is normal for self-signed certificates

### No Cameras Found
1. Check cameras are adopted in UniFi Protect
2. Cameras should be online and not in privacy mode
3. Wait 60 seconds and reload integration

## After Successful Setup

1. **Test Camera Feeds**
   - Go to Overview dashboard
   - Camera feeds should be visible

2. **Check UniFi Dashboard**
   - Go to sidebar → "Ubiquiti Network"
   - Click "Protect" tab
   - Cameras should show live feeds

3. **Test Automations**
   - Doorbell press notifications
   - Motion alerts
   - Person detection

## Quick Test Commands

Test if entities exist:
```yaml

service: camera.turn_on
target:
  entity_id: camera.g5_pro_high
```

## Next Steps

Once cameras are working:
1. Set up motion notifications
2. Configure recording schedules
3. Add camera feeds to other dashboards
4. Set up person detection alerts

---

## Fix Unifi Protect
*Source: FIX_UNIFI_PROTECT.md*

## The Issue
The UniFi Protect dashboard shows placeholder entities because the UniFi Protect integration isn't configured yet.

## Solution: Add UniFi Protect Integration

1. **Go to Settings → Devices & Services**
2. **Click "+ ADD INTEGRATION"**
3. **Search for "UniFi Protect"**
4. **Configure with:**
   - Host: `192.168.3.1`
   - Port: `443`
   - Username: `emalwais`
   - Password: `Dunc@n212025`
   - Verify SSL: **OFF** (unchecked)

## Expected Entities After Setup

Once configured, you should get these entities:

### Cameras:
- `camera.g5_pro_high` - G5 Pro camera feed
- `camera.g4_doorbell_pro_high` - Doorbell camera feed

### Motion Sensors:
- `binary_sensor.g5_pro_motion` - G5 Pro motion detection
- `binary_sensor.g5_pro_person` - G5 Pro person detection
- `binary_sensor.g5_pro_vehicle` - G5 Pro vehicle detection
- `binary_sensor.g4_doorbell_pro_motion` - Doorbell motion
- `binary_sensor.g4_doorbell_pro_person` - Doorbell person detection
- `binary_sensor.g4_doorbell_pro_doorbell` - Doorbell button pressed

### Controls:
- `switch.g5_pro_privacy_mode` - Turn camera on/off
- `switch.g4_doorbell_pro_privacy_mode` - Turn doorbell camera on/off
- `select.g5_pro_recording_mode` - Recording options
- `select.g4_doorbell_pro_recording_mode` - Recording options

## If Entities Have Different Names

After adding the integration, if your camera entities have different names:

1. Go to **Developer Tools → States**
2. Filter by "camera" to find your actual camera entity names
3. Note the exact entity IDs
4. Update the dashboard file with the correct names

## Test the Integration

After setup:
1. Check if cameras appear in the overview
2. Test motion detection
3. Try the privacy switches
4. Check recording modes

## Alternative: Use Auto-Generated Cards

If entity names don't match:
1. Go to your dashboard
2. Edit dashboard (three dots menu)
3. Add Card → "By Entity"
4. Search for your camera
5. Home Assistant will create appropriate cards automatically

---

