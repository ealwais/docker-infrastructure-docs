# HDHomeRun and MyQ Setup Instructions

## HDHomeRun (YAML Configuration) ✓ CONFIGURED

HDHomeRun has been configured via YAML in `/config/packages/hdhomerun.yaml`.

### What's Been Set Up:
- **Device**: HDHomeRun FLEX 4K (4 tuners) at `192.168.3.6`
- **Sensors**: 
  - 4 tuner status sensors (showing channel or "Idle")
  - Model and firmware version sensors
  - REST sensor with device attributes
- **Binary Sensors**: 4 tuner occupancy sensors
- **Scripts**: Channel tuning capability
- **Automation**: Alert when all 4 tuners are in use

### Entities Created:
- `sensor.hdhomerun_tuner_0` through `sensor.hdhomerun_tuner_3`
- `binary_sensor.hdhomerun_tuner0_in_use` through `binary_sensor.hdhomerun_tuner3_in_use`
- `sensor.hdhomerun_model` and `sensor.hdhomerun_version`
- `script.hdhomerun_tune_channel` (for tuning to specific channels)

## MyQ (Requires HACS Custom Integration)

MyQ requires a custom integration from HACS due to API changes by Chamberlain.

### Step 1: Install MyQ from HACS
1. Open **HACS** from the sidebar
2. Click **"Integrations"** tab
3. Click **"+ Explore & Download Repositories"**
4. Search for **"MyQ"**
5. Select the **"MyQ"** integration by **lash-l**
6. Click **"Download"**
7. Restart Home Assistant

### Step 2: Configure MyQ
1. After restart, go to **Settings → Devices & Services**
2. Click **"+ Add Integration"**
3. Search for **"MyQ"**
4. Enter your MyQ credentials:
   - Email: Your MyQ account email
   - Password: Your MyQ account password
5. Complete any 2FA if required

### Troubleshooting MyQ:
- If authentication fails, ensure you're using the correct MyQ account (not Chamberlain account)
- The integration may take a minute to discover all devices
- Your garage door is at IP: `192.168.3.149`

### What You'll Get:
- Cover entity for garage door (open/close/stop)
- Binary sensor for door position
- Ability to create automations for garage door

## Quick Add Commands

You can also run these commands to check the status:

```bash
# Check if HDHomeRun is already configured
docker exec homeassistant grep -r "hdhomerun" /config/.storage/

# Check if MyQ is installed via HACS
docker exec homeassistant ls -la /config/custom_components/ | grep myq
```