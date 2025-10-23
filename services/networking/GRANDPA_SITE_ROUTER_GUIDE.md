# Grandpa Site Router Complete Guide

## Router Overview

### Hardware Information
- **Model**: UniFi Dream Machine (UDM)
- **Architecture**: ARM64 (aarch64)
- **Kernel**: Linux 4.19.152-ui-alpine
- **MAC Address**: 74:AC:B9:56:43:CF
- **System ID**: 0xea11

### Network Location
- **Site Name**: Grandpa
- **ISP**: Spectrum
- **Public IP**: 70.115.146.40
- **Internal Gateway IP**: 172.16.252.1 (Primary)
- **Atria Network Gateway**: 172.16.253.1

## Network Configuration

### Networks Managed
1. **Default Network**: 172.16.252.0/24
   - Gateway: 172.16.252.1
   - Purpose: Main LAN network
   - Interface: br0

2. **Atria Network**: 172.16.253.0/24
   - Gateway: 172.16.253.1
   - Purpose: Secondary/isolated network
   - Status: Configured as VLAN or separate bridge

### WAN Configuration
- **Interface**: eth4
- **IP Address**: 70.115.146.40/19
- **Type**: Dynamic (DHCP from ISP)
- **ISP**: Spectrum

### Wireless Configuration
- **Radio 1**: MT7603 (2.4GHz)
  - Max TX Power: 23 dBm
  - Antenna Gain: 3 dBi
- **Radio 2**: MT7615 (5GHz)
  - Max TX Power: 26 dBm
  - Antenna Gain: 3 dBi

## Access Methods

### Web Management Interface
```
URL: https://70.115.146.40
Alternative: https://172.16.252.1 (from internal network)
Platform: UniFi Network Application
```

### SSH Access
```bash
# From home network (through VPN)
ssh root@172.16.252.1

# To Atria network gateway
ssh root@172.16.253.1
```

### Physical Location
- Located at Grandpa's residence
- Remote site connected via site-to-site VPN

## Services Running

### Core Services
- **UniFi Network Controller**: Network management
- **DHCP Server**: IP assignment for local networks
- **DNS Forwarding**: Local DNS resolution
- **Firewall**: iptables-based firewall
- **WiFi Access Points**: Dual-band wireless

### VPN Services
- **Site-to-Site VPN**: Connection to Alwais (home) site
- **Protocol**: WireGuard (via OSPF routing)
- **Status**: Active and routing traffic

## Connected Devices

### Key Hosts
- **172.16.252.172**: Target SSH server (previously unreachable)
- **172.16.253.x**: Devices on Atria network

## Management Commands

### Status Checks
```bash
# Check system status
ssh root@172.16.252.1 "uptime"

# View network interfaces
ssh root@172.16.252.1 "ip addr show"

# Check routing table
ssh root@172.16.252.1 "ip route"

# View DHCP leases
ssh root@172.16.252.1 "cat /tmp/dhcp.leases"

# Check WiFi status
ssh root@172.16.252.1 "iwconfig"
```

### Network Diagnostics
```bash
# Test connectivity to home site
ssh root@172.16.252.1 "ping -c 3 192.168.253.1"

# Check VPN status
ssh root@172.16.252.1 "wg show"  # If WireGuard is used

# View firewall rules
ssh root@172.16.252.1 "iptables -L -n -v"

# Check DNS resolution
ssh root@172.16.252.1 "nslookup google.com"
```

### Service Management
```bash
# Restart network services
ssh root@172.16.252.1 "/etc/init.d/network restart"

# Reload firewall rules
ssh root@172.16.252.1 "/etc/init.d/firewall reload"

# View system logs
ssh root@172.16.252.1 "logread | tail -50"
```

## Configuration Files

### Key Configuration Locations
- `/etc/board.info` - Hardware information
- `/etc/config/` - UCI configuration files
- `/tmp/dhcp.leases` - Active DHCP leases
- `/etc/firewall.user` - Custom firewall rules

## Troubleshooting

### Common Issues

#### Cannot Access Router
```bash
# From home network, verify VPN is up
ping 172.16.252.1
ping 172.16.253.1

# Check routing
ip route | grep 172.16

# Traceroute to identify where connection fails
traceroute 172.16.252.1
```

#### SSH Connection Timeouts
- Verify VPN connection is active
- Check firewall rules on both sites
- Ensure SSH service is running on router

#### Network Performance Issues
```bash
# Check interface statistics
ssh root@172.16.252.1 "ifconfig eth4"

# Monitor bandwidth usage
ssh root@172.16.252.1 "iftop -i eth4"

# Check system resources
ssh root@172.16.252.1 "top"
```

## Security Considerations

### Access Control
- SSH root access enabled (consider key-based auth)
- Web interface protected by UniFi credentials
- Firewall rules control inter-VLAN routing

### VPN Security
- Traffic encrypted via WireGuard/IPSec
- Pre-shared keys must be kept secure
- Regular security updates recommended

## Integration with Home Network

### Routing Configuration
- Routes to Grandpa networks via WireGuard tunnel
- OSPF protocol manages dynamic routing
- Fallback to static routes if OSPF fails

### Accessible Networks from Home
- 172.16.252.0/24 - Main Grandpa LAN
- 172.16.253.0/24 - Atria network

### Accessible Networks from Grandpa
- 192.168.253.0/24 - Home main network
- 192.168.12.0/24 - Neena network
- 192.168.3.0/24 - Bones network
- 192.168.7.0/24 - Servers network
- 192.168.2.0/24 - Camera network

## Maintenance Tasks

### Regular Checks
1. Monitor VPN connection status
2. Check for firmware updates
3. Review firewall logs for anomalies
4. Verify DHCP pool usage
5. Monitor bandwidth usage

### Backup Recommendations
- Export UniFi configuration regularly
- Document any custom configurations
- Keep VPN credentials secure and backed up

## Contact Information
- **Location**: Grandpa's residence
- **ISP Support**: Spectrum
- **Router Access**: Via VPN from home network

---
*Last Updated: 2025-09-12*
*Router Verified Online: Yes*
*VPN Status: Connected via WireGuard/OSPF*