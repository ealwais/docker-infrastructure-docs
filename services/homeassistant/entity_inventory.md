# Home Assistant Entity Inventory
Generated: 2025-09-01

## Summary
- **Total Light Entities**: 13 (8 controllable lights + 5 DND lights from Meross)
- **Total Switch Entities**: 98 (including POE switches, smart plugs, and various controls)
- **Total Fan Entities**: 4
- **Configured Areas**: 3 (Office, Home Network, Front)

## Light Entities (light.*)

### Room Lights
1. `light.ceiling_fan_down_light` - "Ceiling fan Down Light"
2. `light.ceiling_fan_up_light` - "Ceiling fan Up Light"
3. `light.hallway_main_lights` - "Hallway Main Lights"
4. `light.kitchen_main_lights` - "Kitchen Main Lights"
5. `light.office_ceiling_fan_light` - "Office Ceiling Fan Light"
6. `light.primary_room_fan` - "primary room fan" (light component of fan)

### Zigbee/Aqara Switches (configured as lights)
7. `light.lumi_lumi_switch_b1laus01` - "Dinning room Switch" (note: typo in name)
8. `light.lumi_lumi_switch_b1laus01_2` - "Kitchen fan switch"

### Meross DND Lights (Do Not Disturb indicators)
9. `light.smart_switch_2101152499305651853848e1e9471b1f_dnd` - "Dnd"
10. `light.smart_switch_2101153052142151853848e1e946faf5_dnd` - "Dnd"
11. `light.smart_switch_2101156594137251853848e1e947064d_dnd` - "Dnd"
12. `light.smart_switch_2111244224901751858448e1e97e2496_dnd` - "Dnd"
13. `light.smart_switch_2111244864498251858448e1e97e20ee_dnd` - "Dnd"

## Switch Entities (switch.*)

### Meross Smart Plugs (Main controllable outlets)
1. `switch.smart_switch_2101152499305651853848e1e9471b1f_outlet` - "Smart Plug Mini" (Outlet)
2. `switch.smart_switch_2101153052142151853848e1e946faf5_outlet` - "Smart Wi-Fi Plug Mini 3" (Outlet)
3. `switch.smart_switch_2101156594137251853848e1e947064d_outlet` - (Outlet)
4. `switch.smart_switch_2103302577136755853848e1e968fa24_outlet` - (Outlet)
5. `switch.smart_switch_2111244224901751858448e1e97e2496_outlet` - (Outlet)
6. `switch.smart_switch_2111244864498251858448e1e97e20ee_outlet` - "Desk Lamp" (Outlet)

### Zigbee/Aqara Smart Plugs
7. `switch.lumi_lumi_plug_maus01` - "Big lamp" (customized in configuration.yaml)
8. `switch.lumi_lumi_plug_maus01_2` - "Xiaomi Smart Plug 2"
9. `switch.lumi_lumi_plug_maus01_3` - "Xiaomi Smart Plug 3"
10. `switch.aqara_plug_neena` - Aqara plug

### Test/Debug Entities
11. `switch.device` - "Device" (should be hidden)
12. `switch.devicew` - "Devicew" (should be hidden)
13. `switch.test` - Test switch

### UniFi POE Switches (Network equipment power control)
- Multiple POE switches for network ports (74 total)
- Examples: `switch.dream_machine_special_edition_*_poe`, `switch.usw_pro_max_24_poe_*`

### UniFi Protect Camera Controls
- Camera detection and overlay switches for G4 Doorbell Pro and G5 Pro

### Other Network/System Switches
- `switch.bones` - Network related
- `switch.unifi_*` - Various UniFi network controls
- Analytics and insights switches

## Fan Entities (fan.*)
1. `fan.dyson_ceiling_fan` - "Dyson Ceiling fan" (currently unavailable in dashboard)
2. `fan.famceiling_fan_2` - "Ceiling fan" (Family Room)
3. `fan.office_ceiling_fan` - "office Ceiling fan"
4. `fan.primary_room_fan_2` - "primary room fan"

## Room Organization

### Current Dashboard Organization
Based on the lights dashboard, entities are organized by type rather than room:
- Meross Smart Plugs section
- Room Lights section
- Fans section
- Other Smart Switches section

### Suggested Room-Based Organization

#### Primary Bedroom
- `light.primary_room_fan` - Light
- `fan.primary_room_fan_2` - Fan

#### Office
- `light.office_ceiling_fan_light` - Light
- `fan.office_ceiling_fan` - Fan
- `switch.smart_switch_2111244864498251858448e1e97e20ee_outlet` - Desk Lamp

#### Kitchen
- `light.kitchen_main_lights` - Main Lights
- `light.lumi_lumi_switch_b1laus01_2` - Kitchen fan switch

#### Dining Room
- `light.lumi_lumi_switch_b1laus01` - Dining room switch (note typo)

#### Family Room
- `fan.famceiling_fan_2` - Ceiling fan
- `light.ceiling_fan_down_light` - Down light
- `light.ceiling_fan_up_light` - Up light

#### Hallway
- `light.hallway_main_lights` - Main lights

#### Living Areas (General)
- `switch.smart_switch_2101152499305651853848e1e9471b1f_outlet` - Smart Plug Mini
- `switch.smart_switch_2101153052142151853848e1e946faf5_outlet` - Smart Wi-Fi Plug Mini 3
- `switch.lumi_lumi_plug_maus01` - Big lamp
- `switch.lumi_lumi_plug_maus01_2` - Xiaomi Smart Plug 2
- `switch.lumi_lumi_plug_maus01_3` - Xiaomi Smart Plug 3

## Entity Naming Issues Found

### Typos
- "Dinning room Switch" should be "Dining room Switch"

### Generic/Unclear Names
- Multiple "Outlet" entities without descriptive names
- "primary room fan" should be "Primary Room Fan" (capitalization)
- "office Ceiling fan" inconsistent capitalization

### Technical IDs Exposed
- Meross devices show long technical IDs
- Should use friendly names in dashboard

## Recommendations

1. **Create proper areas** for all rooms (currently only 3 areas defined)
2. **Assign entities to areas** for better organization
3. **Fix entity names** using customization
4. **Hide test entities** (device, devicew, test)
5. **Create room-based views** in dashboards instead of device-type views
6. **Standardize naming convention** (proper capitalization, clear descriptions)