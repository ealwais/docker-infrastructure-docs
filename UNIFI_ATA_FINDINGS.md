# UniFi ATA Configuration Findings - Remote Site Setup

## Summary
Attempted to configure a UniFi ATA device at a remote site (grandpa's location) to register with UniFi Talk on a UDM Pro SE at the main site. The configuration was ultimately unsuccessful due to device limitations.

## Network Setup
- **Main Site**: UDM Pro SE (192.168.253.1) with UniFi Talk enabled
- **Remote Site**: Regular Dream Machine (172.16.252.1) WITHOUT UniFi Talk capability
- **ATA Device**: UniFi ATA at remote site (172.16.252.59)
- **Connectivity**: Sites can reach each other (this server at main site can ping ATA at remote)

## Device Details
- **Model**: UniFi ATA (UT-ATA)
- **Hostname**: dvf99
- **MAC**: 70:a7:41:f5:77:35
- **OS**: Linux 4.9.211-v2.11-rc2 armv5tejl
- **Management**: Adopted to Dream Machine at remote site

## Configuration Attempted

### 1. UniFi Talk Third-Party Device Setup
Created third-party SIP device in UniFi Talk:
- **Extension**: 0002
- **User**: Neena Alwais
- **SIP Server**: 192.168.253.1
- **Port**: 5060
- **Username**: 0002
- **Password**: [configured]

### 2. ATA Configuration Files Found
- `/data/sipsettings.xml` - Main SIP configuration (read-only filesystem)
- `/cfg/persistent/` - Writable persistent storage
- `/cfg/manual.cfg` - Manual configuration file

### 3. Configuration Process
1. Factory reset device via SSH (`rm -rf /cfg/*` and reboot)
2. Device kept same IP after reset but cleared config
3. Modified `/data/sipsettings.xml` with UniFi Talk credentials:
   - Updated server addresses to 192.168.253.1
   - Set username/extension to 0002
   - Added SIP password
4. Created symlink from `/data/sipsettings.xml` to `/cfg/persistent/sipsettings.xml` to persist changes

### 4. Technical Challenges Encountered

#### Filesystem Issues
- `/data` directory is read-only (ROM filesystem)
- Had to use symlink workaround to persistent storage
- Changes survive reboot via symlink

#### Missing SIP Daemon
- No SIP daemon/service starts automatically on boot
- `voip-control` command exists but fails with hardware errors:
  ```
  Error.. WBHF allocation Failed
  LibDuaSync: receive and error in duasync_coma_wait : -15
  ```
- No web interface available (port 80/443 not listening)
- Only SSH access on port 22

#### Controller Limitations
- Device is adopted by Dream Machine without UniFi Talk
- Dream Machine UI doesn't expose VoIP/SIP configuration options
- ATA appears designed to only work with UniFi Talk when adopted to a Talk-enabled controller

## Key Findings

1. **UniFi ATA is NOT a standalone SIP device** - It requires adoption to a UniFi controller with Talk enabled
2. **Regular Dream Machine doesn't support UniFi Talk** - Cannot configure VoIP settings through controller
3. **No automatic SIP registration** - Even with proper config files, no SIP daemon runs to register with remote server
4. **Hardware-specific implementation** - The voip-control binary appears tied to specific hardware/firmware integration

## Recommendations

### Option 1: Swap Devices (RECOMMENDED)
- Move the G3 Touch Pro phone to grandpa's site - it can register remotely to UDM Pro SE
- Move the ATA to main site with UDM Pro SE - adopt it locally where Talk is available

### Option 2: Different Hardware
- Replace UniFi ATA with a standard third-party SIP ATA (Grandstream, Cisco, etc.)
- These devices are designed for standalone SIP operation

### Option 3: Forget from Controller
- Unadopt ATA from Dream Machine
- Attempt standalone configuration (may still not work due to firmware limitations)

### Option 4: Site-to-Site UniFi Talk
- Upgrade remote site to UDM Pro or Dream Machine Pro with Talk support
- Enable Talk at remote site connected to main site

## Conclusion
The UniFi ATA device is not suitable for cross-site SIP registration when adopted to a non-Talk controller. It's designed as an integrated part of the UniFi Talk ecosystem and requires local controller support with Talk enabled. The best solution is to either swap it with a Talk-capable phone that supports remote registration, or use a traditional third-party SIP ATA that's designed for standalone operation.

## Files Modified
- `/cfg/manual.cfg` - Added SIP configuration
- `/cfg/persistent/voip.cfg` - Created with SIP settings
- `/cfg/persistent/sipsettings.xml` - Full XML configuration with UniFi Talk credentials
- `/data/sipsettings.xml` - Symlinked to persistent config

## Status
**Not Working** - Device shows as "Pending" in UniFi Talk, no active SIP registration occurring.