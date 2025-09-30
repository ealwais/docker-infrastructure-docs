# UDM Pro SE VLAN Configuration Guide

## Table of Contents
- [Overview](#overview)
- [Access Methods](#access-methods)
- [VLAN Configuration Steps](#vlan-configuration-steps)
- [Common VLAN Scenarios](#common-vlan-scenarios)
- [Port Profiles & VLAN Assignment](#port-profiles--vlan-assignment)
- [Inter-VLAN Routing & Firewall](#inter-vlan-routing--firewall)
- [WiFi Networks with VLANs](#wifi-networks-with-vlans)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## Overview

The UniFi Dream Machine Pro SE (UDM Pro SE) is an all-in-one network appliance that includes:
- Advanced gateway with IDS/IPS
- 8-port managed switch with 2.5GbE
- Network controller
- UniFi Protect support
- Dual WAN support

VLANs on the UDM Pro SE are configured through the UniFi Network Controller interface, not on individual devices like Ubuntu servers.

## Access Methods

### Method 1: Web Interface (Recommended)
```
https://192.168.3.1  (or your UDM IP)
or
https://unifi.ui.com (remote access)
```

### Method 2: Mobile App
- UniFi Network app (iOS/Android)
- Full VLAN management capabilities

### Method 3: SSH (Advanced)
```bash
ssh root@192.168.3.1
```

## VLAN Configuration Steps

### 1. Create a New Network (VLAN)

1. **Navigate to Networks**
   - Settings → Networks → Create New Network

2. **Configure Network Settings**
   ```
   Network Name: [Descriptive name, e.g., "IoT Network"]
   Host Address: Auto
   Advanced:
     VLAN ID: [2-4094, e.g., 10]
     Gateway IP/Subnet: [e.g., 192.168.10.1/24]

   DHCP:
     DHCP Mode: DHCP Server
     DHCP Range: [e.g., 192.168.10.100 - 192.168.10.254]

   Domain Name: [optional, e.g., iot.local]
   ```

3. **Advanced Settings**
   ```
   IGMP Snooping: Enable (for multicast)
   DHCP Guarding: Enable (security)
   Multicast DNS: Enable (for device discovery)
   UPnP LAN: Disable (security)
   Network Isolation: Enable (for guest/IoT networks)
   ```

### 2. Example VLAN Configurations

#### Management VLAN (Default)
```yaml
Name: Default
VLAN ID: 1 (or untagged)
Subnet: 192.168.3.0/24
Gateway: 192.168.3.1
DHCP: Enabled
Purpose: Management, trusted devices
```

#### IoT Devices VLAN
```yaml
Name: IoT Network
VLAN ID: 10
Subnet: 192.168.10.0/24
Gateway: 192.168.10.1
DHCP: Enabled
Network Isolation: Enabled
mDNS: Enabled
Firewall Rules: Block IoT → LAN, Allow LAN → IoT
```

#### Guest Network VLAN
```yaml
Name: Guest Network
VLAN ID: 99
Subnet: 192.168.99.0/24
Gateway: 192.168.99.1
DHCP: Enabled
Network Isolation: Enabled
Bandwidth Limit: 50 Mbps
Client Device Isolation: Enabled
```

#### Security Cameras VLAN
```yaml
Name: Cameras
VLAN ID: 20
Subnet: 192.168.20.0/24
Gateway: 192.168.20.1
DHCP: Enabled
Network Isolation: Enabled
Firewall: Block all Internet access
```

#### Servers/Storage VLAN
```yaml
Name: Servers
VLAN ID: 30
Subnet: 10.10.30.0/24
Gateway: 10.10.30.1
DHCP: Disabled (static IPs)
Jumbo Frames: Enabled (MTU 9000)
```

#### Docker VLAN
```yaml
Name: Docker Services
VLAN ID: 40
Subnet: 172.20.0.0/24
Gateway: 172.20.0.1
DHCP: Reserved range for containers
DNS: Custom (e.g., Pi-hole)
```

## Port Profiles & VLAN Assignment

### Create Port Profiles

1. **Navigate to Profiles**
   - Settings → Profiles → Switch Ports → Create New

2. **Configure Port Profile**
   ```
   Name: Trunk All VLANs
   Native Network: Default
   Tagged Networks: All configured VLANs

   Name: IoT Devices
   Native Network: IoT Network
   Tagged Networks: None

   Name: Server Trunk
   Native Network: Servers
   Tagged Networks: Docker, Storage
   ```

### Assign Profiles to Ports

1. **Navigate to Devices**
   - Devices → UDM Pro SE → Ports

2. **Configure Each Port**
   ```
   Port 1: Profile "Trunk All VLANs" (to core switch)
   Port 2: Profile "Servers" (to Ubuntu server)
   Port 3: Profile "IoT Devices" (to IoT hub)
   Port 4: Profile "Cameras" (to camera PoE switch)
   ```

## Inter-VLAN Routing & Firewall

### Default Behavior
- All VLANs can communicate by default
- Traffic routes through UDM Pro SE

### Create Firewall Rules

1. **Navigate to Firewall & Security**
   - Settings → Firewall & Security → Create New Rule

2. **Example Rules**

#### Block IoT to LAN
```
Type: LAN In
Description: Block IoT to LAN
Enabled: Yes
Action: Drop
Source: IoT Network
Destination: Default Network
Protocol: Any
```

#### Allow LAN to IoT
```
Type: LAN In
Description: Allow LAN to IoT
Enabled: Yes
Action: Accept
Source: Default Network
Destination: IoT Network
Protocol: Any
```

#### Block Cameras Internet Access
```
Type: LAN In
Description: Block Cameras to Internet
Enabled: Yes
Action: Drop
Source: Cameras Network
Destination: Internet
Protocol: Any
```

#### Allow Specific Server Access
```
Type: LAN In
Description: Allow Docker to NAS
Enabled: Yes
Action: Accept
Source: Docker Network
Destination: 10.10.30.100/32 (NAS IP)
Protocol: TCP
Port: 445,139 (SMB)
```

### Rule Ordering
1. Most specific rules first
2. Block rules before allow rules
3. Default deny at the end (if needed)

## WiFi Networks with VLANs

### Create WiFi Network with VLAN

1. **Navigate to WiFi**
   - Settings → WiFi → Create New WiFi Network

2. **Configure WiFi Settings**
   ```
   Name: IoT WiFi
   Password: [secure password]
   Network: IoT Network (VLAN 10)
   Security Protocol: WPA2 (or WPA3)
   Band: 2.4 GHz (for IoT compatibility)
   ```

3. **Advanced Options**
   ```
   Hide SSID: No
   Band Steering: Disabled for IoT
   Fast Roaming: Disabled for IoT
   Multicast Enhancement: Enabled
   Client Device Isolation: Per use case
   ```

### Multiple SSIDs Example
```
Main WiFi → Default Network (VLAN 1)
Guest WiFi → Guest Network (VLAN 99)
IoT WiFi → IoT Network (VLAN 10)
Cameras WiFi → Cameras Network (VLAN 20)
```

## Troubleshooting

### VLAN Connectivity Issues

#### Check VLAN Configuration
```bash
# SSH into UDM
ssh root@192.168.3.1

# Show VLAN interfaces
ip link show | grep vlan

# Show bridge configuration
bridge vlan show

# Check specific VLAN interface
ip addr show br10  # for VLAN 10
```

#### Verify DHCP
```bash
# Check DHCP leases
cat /mnt/data/udapi-config/dnsmasq.d/dnsmasq.leases

# Monitor DHCP requests
tcpdump -i br10 -n port 67 and port 68
```

#### Test Inter-VLAN Routing
```bash
# From UDM SSH
ping -c 4 -I br10 192.168.20.1  # Ping from VLAN 10 to VLAN 20

# Check routing table
ip route show
```

### Common Issues

#### Devices Not Getting IP
- Verify DHCP is enabled on VLAN
- Check DHCP range has available IPs
- Ensure port has correct VLAN assignment

#### Cannot Access Between VLANs
- Check firewall rules
- Verify inter-VLAN routing is enabled
- Check for conflicting rules

#### VLAN Tagged Traffic Not Working
- Verify trunk port configuration
- Check native VLAN settings
- Ensure connected device supports 802.1Q

## Best Practices

### VLAN Design
1. **Logical Segmentation**
   - Group devices by function/security level
   - Separate untrusted devices (IoT, Guest)
   - Isolate critical infrastructure

2. **IP Addressing**
   - Use consistent schemes (e.g., VLAN 10 = 192.168.10.0/24)
   - Reserve ranges for static IPs
   - Document all assignments

3. **Naming Convention**
   ```
   VLAN 1: Management
   VLAN 10-19: IoT/Smart Home
   VLAN 20-29: Security/Cameras
   VLAN 30-39: Servers/Storage
   VLAN 40-49: Services/Docker
   VLAN 90-99: Guest/Untrusted
   ```

### Security
1. **Default Deny**
   - Start with isolation
   - Add specific allow rules

2. **Minimize Attack Surface**
   - Disable unused services
   - Block unnecessary inter-VLAN traffic
   - Limit management access

3. **Regular Audits**
   - Review firewall rules
   - Check for unused VLANs
   - Monitor traffic patterns

### Performance
1. **MTU Considerations**
   - Standard 1500 for most VLANs
   - Jumbo frames (9000) for storage
   - Consistent settings across path

2. **Broadcast Domains**
   - Keep VLAN sizes reasonable
   - Use IGMP snooping for multicast
   - Monitor broadcast traffic

## Advanced Configuration

### VLAN with Custom DNS
```bash
# SSH into UDM
ssh root@192.168.3.1

# Edit dnsmasq config for specific VLAN
echo "dhcp-option=br10,6,192.168.10.5" >> /run/dnsmasq.conf.d/custom.conf
# Option 6 = DNS server

# Restart dnsmasq
killall -HUP dnsmasq
```

### Static DHCP Reservations
1. Network Settings → [Select Network]
2. DHCP → Fixed IP Assignments
3. Add Device by MAC address

### VLAN-specific NAT Rules
```bash
# Custom NAT for specific VLAN
iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o eth8 -j MASQUERADE
```

## Monitoring VLANs

### UniFi Dashboard
- Clients → Filter by Network
- Statistics → Traffic by Network
- Insights → Network Health

### Command Line
```bash
# Traffic statistics
ip -s link show br10

# Active connections
conntrack -L | grep 192.168.10

# Bandwidth usage
iftop -i br10
```

## Integration with Services

### UniFi Protect Cameras
- Assign cameras to isolated VLAN
- Enable Protect management VLAN
- Configure recording retention

### Home Assistant
- Place on management or services VLAN
- Configure mDNS for device discovery
- Set firewall rules for required access

### Docker Services
- Use macvlan driver for VLAN assignment
- Or bridge to VLAN interface on host
- Configure container networking appropriately

## Quick Command Reference

```bash
# Show all networks
/usr/sbin/ubnt-device-info networks

# Restart network services
systemctl restart systemd-networkd

# Show VLAN membership
bridge vlan show

# Monitor VLAN traffic
tcpdump -i br10 -e -n

# Check firewall rules
iptables -L -n -v

# View DHCP leases
show dhcp leases
```

## Related Documentation
- [UDM Pro SE User Guide](https://ui.com/consoles/dream-machine-se)
- [UniFi Network Controller Guide](https://help.ui.com/hc/en-us/categories/200320654)
- [UniFi Firewall Best Practices](https://help.ui.com/hc/en-us/articles/115003173168)

---

*Last Updated: September 2025*
*Device: UniFi Dream Machine Pro SE*
*Controller Version: 8.x*