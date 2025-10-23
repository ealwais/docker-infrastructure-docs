# Dashboard Entity Issues Report
## dashboard_lights_comprehensive_fixed.yaml

### Analysis Date: 2025-09-01

## Summary of Issues Found

### 1. Missing or Unavailable Entities

#### Fans
- **`fan.dyson_ceiling_fan`** - Referenced in entity inventory as "currently unavailable in dashboard"
  - This entity appears to be configured but not available/online
  - Not found in the current working entities list

### 2. Entity Name Mismatches

#### Family Room Fan
- **Dashboard uses**: `fan.famceiling_fan_2`
- **Should match inventory**: `fan.famceiling_fan_2` ✓ (This is correct)

### 3. Working Entities (Confirmed in Inventory)

#### Lights
- ✓ `light.primary_room_fan`
- ✓ `light.office_ceiling_fan_light`
- ✓ `light.ceiling_fan_down_light`
- ✓ `light.ceiling_fan_up_light`
- ✓ `light.kitchen_main_lights`
- ✓ `light.lumi_lumi_switch_b1laus01_2`
- ✓ `light.lumi_lumi_switch_b1laus01`
- ✓ `light.hallway_main_lights`

#### Fans
- ✓ `fan.primary_room_fan_2`
- ✓ `fan.office_ceiling_fan`
- ✓ `fan.famceiling_fan_2`

#### Switches
- ✓ `switch.smart_switch_2111244864498251858448e1e97e20ee_outlet`
- ✓ `switch.smart_switch_2101152499305651853848e1e9471b1f_outlet`
- ✓ `switch.smart_switch_2101153052142151853848e1e946faf5_outlet`
- ✓ `switch.smart_switch_2101156594137251853848e1e947064d_outlet`
- ✓ `switch.smart_switch_2103302577136755853848e1e968fa24_outlet`
- ✓ `switch.smart_switch_2111244224901751858448e1e97e2496_outlet`
- ✓ `switch.lumi_lumi_plug_maus01`
- ✓ `switch.lumi_lumi_plug_maus01_2`
- ✓ `switch.lumi_lumi_plug_maus01_3`

### 4. YAML Syntax Issues

No YAML syntax issues were found in the file. The structure is valid.

### 5. Service Call Issues

The "All Plugs Off" button (lines 40-53) uses:
```yaml
service: homeassistant.turn_off
```
This is correct for turning off multiple entity types.

## Recommendations

### 1. Remove Unavailable Entities
Remove or comment out the `fan.dyson_ceiling_fan` entity if it's permanently unavailable, or check why it's offline.

### 2. Entity Display Names
The dashboard correctly uses the `name:` attribute to override the technical entity IDs with friendly names. All display names are properly configured.

### 3. All Entities Are Correctly Referenced
All entities in the dashboard match the available entities in the inventory, except for the Dyson ceiling fan which is marked as unavailable.

## Conclusion

The dashboard is correctly configured with proper entity IDs. The only issue is:
- **`fan.dyson_ceiling_fan`** - This entity is referenced in the inventory but marked as "currently unavailable"

All other entities are correctly named and should work properly. If you're seeing "entity not found" errors for entities other than the Dyson fan, the issue may be:
1. The entities are temporarily unavailable (devices offline)
2. The integrations providing these entities need to be reloaded
3. The entity registry needs to be refreshed

To fix the Dyson fan issue, either:
1. Remove it from the dashboard if it's no longer in use
2. Check why the Dyson device is unavailable and reconnect it
3. Comment it out temporarily until the device is back online