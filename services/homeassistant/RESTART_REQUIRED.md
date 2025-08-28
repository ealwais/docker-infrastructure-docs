# RESTART REQUIRED

## What was fixed:
1. Created `packages/meross_switches_simple.yaml` with proper legacy template switch format
2. Disabled conflicting template files
3. Template switches will create these entities:
   - `switch.desk_lamp`
   - `switch.smart_plug_mini`
   - `switch.smart_wi_fi_plug_mini_3`

## To Apply:
1. Go to: http://192.168.3.20:8123/developer-tools/yaml
2. Click "CHECK CONFIGURATION" first
3. If valid, click "RESTART"
4. Wait 2-3 minutes for full startup

## After Restart:
1. Check Developer Tools → States
2. Search for "switch.desk_lamp"
3. Should see all three template switches
4. Dashboard will work with entity names shown

The template switches will mirror the state of the actual Meross devices and allow control through the short names.