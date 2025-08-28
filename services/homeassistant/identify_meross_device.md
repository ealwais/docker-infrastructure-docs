# Identifying the Unavailable Meross Device

## The Unavailable Device:
- **Dashboard Name**: Smart Plug Mini
- **Entity ID**: `switch.smart_switch_2101152499305651853848e1e9471b1f_outlet`
- **MAC Address**: 48:e1:e9:47:1b:1f
- **Location**: Family Room (according to entity registry)
- **Model**: MSS110 (Smart Plug Mini)

## How to Identify Which Physical Device:

### Method 1: Check by Location
- This device was assigned to "Family Room" area
- Look for a Meross smart plug in that room

### Method 2: Check by Model
- This is an MSS110 model (Smart Plug Mini)
- It's the smaller, more compact Meross plug

### Method 3: Process of Elimination
- Your "Desk Lamp" (Office) is working ✅
- Your "Smart Wi-Fi Plug Mini 3" is working ✅
- The unavailable one is the third device

### Method 4: Check MAC Address
- In your UniFi controller, look for device: 48:e1:e9:47:1b:1f
- See where it was last connected

### Method 5: Physical Check
1. Find all your Meross smart plugs
2. The working ones should have their LED on
3. The unavailable one might:
   - Have no LED light
   - Be unplugged
   - Be in a different outlet
   - Need a factory reset

## To Fix:
1. Locate the physical device
2. Ensure it's plugged into a working outlet
3. Check for LED indicator
4. If no LED, hold button for 5 seconds to reset
5. Re-add through Meross LAN integration if needed