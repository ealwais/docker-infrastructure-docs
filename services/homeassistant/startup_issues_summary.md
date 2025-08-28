# Home Assistant Startup Issues Summary

## Critical Errors Preventing Clean Startup

### 1. ❌ Sensor Include Syntax Error (configuration.yaml line 193)
```
Invalid config for 'sensor': expected a dictionary '', got '\!include sensors.yaml'
```
**Issue**: Backslash before !include
**Fix**: Change `\!include` to `!include`

### 2. ❌ Package Errors
- **media_services_monitoring.yaml**: Duplicate 'alias' key in script section
- **portainer_unified_monitoring.yaml**: Duplicate 'name' key in input_button
- **unifi_monitoring.yaml**: Duplicate 'name' key in input_boolean

### 3. ❌ REST Integration Error
```
Invalid config for 'rest' at packages/media_services_monitoring.yaml, line 42
```
**Issue**: 'attributes' is not valid for REST sensors

### 4. ⚠️ Duplicate Keys in secrets.yaml
- Lines 37 and 72: Duplicate "adguard_auth" key

### 5. ⚠️ Platform Warnings
- File platform for sensor integration not supported
- Ping platform for binary_sensor not supported (4 instances)

## Arlo Status
- Still trying to use IMAP authentication despite push configuration
- Getting "Invalid factor data" error from Arlo API
- Gmail rejecting connection (needs app-specific password)

## Impact
These errors are preventing:
- Sensor integration from loading
- REST integration from loading
- Several packages from loading
- Clean startup of Home Assistant

## Next Steps
1. Fix the sensor include syntax error
2. Fix duplicate keys in packages
3. Remove or update deprecated platform configurations
4. Restart Home Assistant after fixes