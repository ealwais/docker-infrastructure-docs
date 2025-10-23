# Site-to-Site VPN Connection Guide

## Connection Overview

This document details the active site-to-site VPN connection between two Ubiquiti UniFi locations:

### Site A: Alwais (Home/Main Office)
- **Location**: Home network with Google Fiber
- **Public IP**: 136.62.122.180
- **Gateway**: 192.168.253.1 (Ubiquiti router)
- **Connection Type**: Google Fiber (high-speed, symmetric)

### Site B: Grandpa
- **Location**: Remote residence
- **Public IP**: 70.115.146.40
- **Gateway**: 172.16.252.1 / 172.16.253.1 (UniFi Dream Machine)
- **Connection Type**: Spectrum cable

## Current Connection Method

### Primary: WireGuard with OSPF Routing

The sites are currently connected via WireGuard tunnel with OSPF dynamic routing:

**Connection Details:**
- **Protocol**: WireGuard
- **Tunnel Interface**: wgsts1000 (on home router)
- **Routing Protocol**: OSPF
- **Intermediate Router**: 192.168.8.1
- **Status**: ✅ ACTIVE AND WORKING

**Routing Table (from Home Router):**
```
172.16.252.0/24 via 192.168.8.1 dev wgsts1000 proto ospf metric 20
172.16.252.2 via 192.168.8.1 dev wgsts1000 proto ospf metric 20
172.16.253.0/24 via 192.168.8.1 dev wgsts1000 proto ospf metric 20
```

### Alternative: IPSec (Configured but not primary)

IPSec configuration exists but is not the active transport:

**Configuration:**
- **IKE Version**: IKEv2
- **Encryption**: AES-256
- **Hash**: SHA256
- **DH Group**: 14 (2048-bit)
- **Pre-Shared Key**: UniFiVPN2024SecureKey!

## Network Topology

```
[Alwais Site]                    [Internet]                    [Grandpa Site]
192.168.x.x/24  <--> Router <--> WireGuard <--> Router <--> 172.16.x.x/24
                  192.168.253.1              172.16.252.1
                                             172.16.253.1
```

### Alwais Networks (Accessible from Grandpa)
| Network | Subnet | Purpose | Gateway |
|---------|--------|---------|---------|
| Default | 192.168.253.0/24 | Main LAN | 192.168.253.1 |
| Neena | 192.168.12.0/24 | Guest/IoT | 192.168.12.1 |
| Bones | 192.168.3.0/24 | Management | 192.168.3.1 |
| Servers | 192.168.7.0/24 | Server VLAN | 192.168.7.1 |
| Camera | 192.168.2.0/24 | Security cameras | 192.168.2.1 |

### Grandpa Networks (Accessible from Alwais)
| Network | Subnet | Purpose | Gateway |
|---------|--------|---------|---------|
| Default | 172.16.252.0/24 | Main LAN | 172.16.252.1 |
| Atria | 172.16.253.0/24 | Secondary network | 172.16.253.1 |
| NFS Backend | 192.168.10.0/24 | NFS mount network | 192.168.10.10 |

### Docker Server NFS Network Configuration
- **Interface**: enp67s0f0 (dedicated NFS traffic)
- **IP Address**: 192.168.10.11/24
- **NFS Gateway**: 192.168.10.10 (currently unreachable)
- **MTU**: 9000 (jumbo frames for NFS performance)
- **Purpose**: Isolated network for NFS mounts only
- **Internet**: No access (by design - dedicated storage network)

## Connection Performance

### Current Metrics
- **Latency**: ~25-30ms (typical)
- **Packet Loss**: 0%
- **Connection Type**: Persistent tunnel
- **Keepalive**: 25 seconds

### Test Results
```bash
# Ping from Home to Grandpa router
PING 172.16.253.1: 64 bytes, time=26.2ms (average)

# Ping from Home to Grandpa Default network
PING 172.16.252.1: 64 bytes, time=24.3ms (average)
```

## How to Test Connection

### From Alwais (Home) Site

```bash
# Test connectivity to Grandpa networks
ping 172.16.252.1    # Grandpa main router
ping 172.16.253.1    # Atria network gateway
ping 172.16.252.172  # Specific host

# Check routing
ip route | grep 172.16

# Trace the path
traceroute 172.16.252.1

# SSH to remote router
ssh root@172.16.252.1
ssh root@172.16.253.1
```

### From Grandpa Site

```bash
# Test connectivity to Home networks
ping 192.168.253.1   # Home main router
ping 192.168.7.10    # Example server

# Check local routing
ip route | grep 192.168

# Verify VPN interface
wg show  # If WireGuard
ipsec status  # If IPSec
```

## Troubleshooting Guide

### Connection Down

1. **Check WireGuard Status:**
```bash
ssh root@192.168.253.1 "wg show wgsts1000"
```

2. **Verify OSPF Routes:**
```bash
ssh root@192.168.253.1 "ip route | grep ospf"
```

3. **Test Intermediate Hop:**
```bash
ping 192.168.8.1
```

### High Latency or Packet Loss

1. **Check Interface Statistics:**
```bash
ssh root@192.168.253.1 "wg show wgsts1000 latest-handshakes"
```

2. **Monitor Traffic:**
```bash
ssh root@192.168.253.1 "iftop -i wgsts1000"
```

3. **Check ISP Connection:**
```bash
# At Alwais
ping 8.8.8.8

# At Grandpa (if accessible)
ssh root@172.16.252.1 "ping 8.8.8.8"
```

### Cannot Reach Specific Network

1. **Verify Routing Exists:**
```bash
ssh root@192.168.253.1 "ip route | grep 172.16"
```

2. **Check Firewall Rules:**
```bash
ssh root@192.168.253.1 "iptables -L FORWARD -n -v | grep 172.16"
```

3. **Test from Router Directly:**
```bash
ssh root@192.168.253.1 "ping 172.16.252.172"
```

## Configuration Management

### WireGuard Configuration Location
- **Alwais Router**: `/etc/wireguard/wgsts1000.conf`
- **Config Backup**: Should be included in UniFi backups

### OSPF Configuration
- Managed by UniFi controller
- Dynamic routing updates every 10 seconds
- Dead timer: 40 seconds

### To Modify Connection

**Add New Network to Routing:**
```bash
# On home router, add static route as backup
ssh root@192.168.253.1
ip route add 172.16.254.0/24 via 192.168.8.1 dev wgsts1000
```

**Monitor OSPF Status:**
```bash
ssh root@192.168.253.1 "vtysh -c 'show ip ospf neighbor'"
```

## Security Considerations

### Current Security Measures
- ✅ Encrypted WireGuard tunnel
- ✅ Key-based authentication
- ✅ Firewall rules limiting cross-site access
- ✅ Regular keepalive prevents stale connections

### Recommendations
1. Rotate WireGuard keys periodically
2. Monitor logs for unauthorized access attempts
3. Implement network segmentation for sensitive resources
4. Regular firmware updates on both routers

## Failover Configuration

### Primary Path (Active)
WireGuard tunnel via wgsts1000 with OSPF routing

### Backup Path (Standby)
IPSec tunnel configured but not active
- Can be activated if WireGuard fails
- Pre-shared key: UniFiVPN2024SecureKey!

### Manual Failover Process
```bash
# Disable WireGuard
ssh root@192.168.253.1 "wg-quick down wgsts1000"

# Enable IPSec
ssh root@192.168.253.1 "ipsec up grandpa-site-to-site"

# Add static routes for IPSec
ssh root@192.168.253.1 "ip route add 172.16.252.0/24 dev ipsec0"
ssh root@192.168.253.1 "ip route add 172.16.253.0/24 dev ipsec0"
```

## Monitoring and Maintenance

### Daily Health Checks
```bash
# Quick connectivity test
ping -c 3 172.16.252.1 && echo "VPN: OK" || echo "VPN: FAILED"

# Check route status
ip route | grep "172.16" | grep -q "wgsts1000" && echo "Routing: OK"
```

### Weekly Maintenance
1. Review VPN logs for errors
2. Check bandwidth utilization
3. Verify all expected routes present
4. Test failover path (if configured)

### Monthly Tasks
1. Review and rotate credentials if needed
2. Update documentation with any changes
3. Performance baseline testing
4. Security audit of firewall rules

## Quick Reference

### Key IP Addresses
- **Alwais Gateway**: 192.168.253.1
- **Grandpa Gateway**: 172.16.252.1
- **Atria Gateway**: 172.16.253.1
- **WireGuard Peer**: 192.168.8.1

### Key Commands
```bash
# Test connection
ping 172.16.253.1

# SSH to Grandpa router
ssh root@172.16.252.1

# Check VPN status
ssh root@192.168.253.1 "wg show wgsts1000"

# View routes
ip route | grep 172.16
```

### Important Files
- This guide: `/mnt/docker/documentation/SITE_TO_SITE_CONNECTION_GUIDE.md`
- Grandpa router guide: `/mnt/docker/documentation/GRANDPA_SITE_ROUTER_GUIDE.md`
- VPN status: `/mnt/docker/documentation/SITE_TO_SITE_VPN_STATUS.md`

---
*Last Updated: 2025-09-12*
*Connection Status: ✅ ACTIVE*
*Method: WireGuard with OSPF*
*Latency: ~25-30ms*