# Meross Entity Fix - Complete

## What was done:

1. **Removed temporary dashboard files** that were causing confusion
2. **Created template switches** in `/packages/meross_entity_fix.yaml` that map:
   - `switch.desk_lamp` → `switch.smart_switch_2111244864498251858448e1e97e20ee_outlet`
   - `switch.smart_plug_mini` → `switch.smart_switch_2101152499305651853848e1e9471b1f_outlet`
   - `switch.smart_wi_fi_plug_mini_3` → `switch.smart_switch_2101153052142151853848e1e946faf5_outlet`

3. **Reset dashboard** to use original configuration

## To apply the fix:

### Step 1: Restart Home Assistant
Go to: http://192.168.3.20:8123/developer-tools/yaml
Click the "RESTART" button under "Restart Home Assistant"

### Step 2: Wait for restart to complete (2-3 minutes)

### Step 3: Clear browser cache
- Chrome/Edge: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
- Firefox: Ctrl+F5 (Windows) or Cmd+Shift+R (Mac)

### Step 4: Visit your dashboard
http://192.168.3.20:8123/dashboard-lights/0

## Result:
Your Meross devices will now show up correctly with their friendly names instead of "unknown"!

## Note:
The "Smart Plug Mini" might still show as unavailable - this is because the actual device is offline and needs to be reconnected to your network.