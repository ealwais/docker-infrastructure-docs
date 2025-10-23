# Site-to-Site VPN Configuration Status

## Current Status: ✅ OPERATIONAL
- **Connection Method**: WireGuard with OSPF routing
- **Status**: Active and routing traffic successfully
- **Last Verified**: 2025-09-12
- **Latency**: ~25-30ms
- **Packet Loss**: 0%

### Connectivity Confirmed
- ✅ Can ping 172.16.252.1 (Grandpa main router)
- ✅ Can ping 172.16.253.1 (Atria network gateway)
- ✅ SSH access working to both gateways
- ✅ Routing via WireGuard tunnel (wgsts1000)

## Network Overview

### Alwais Site (Google Fiber) - HOME
- **Site Name**: Alwais (Main Office)
- **Public IP**: 136.62.122.180
- **Networks**:
  - Default: 192.168.253.0/24
  - Neena: 192.168.12.0/24
  - Bones: 192.168.3.0/24
  - Servers: 192.168.7.0/24
  - Camera: 192.168.2.0/24
- **Router**: Ubiquiti at 192.168.3.1
- **ISP**: Google Fiber

### Grandpa Site (Spectrum) - REMOTE
- **Site Name**: Grandpa
- **Public IP**: 70.115.146.40
- **Networks**:
  - Default: 172.16.252.0/24
  - Atria: 172.16.253.0/24
- **Router**: Ubiquiti UDM
- **Target Host**: 172.16.252.172
- **ISP**: Spectrum

## Current Routing Configuration - ✅ WORKING

The 172.16.252.0/24 and 172.16.253.0/24 networks are successfully routed through the WireGuard tunnel (wgsts1000) via 192.168.8.1 using OSPF dynamic routing.

**Active Routes:**
```
172.16.252.0/24 via 192.168.8.1 dev wgsts1000 proto ospf metric 20
172.16.252.2 via 192.168.8.1 dev wgsts1000 proto ospf metric 20
172.16.253.0/24 via 192.168.8.1 dev wgsts1000 proto ospf metric 20
```

## VPN Configuration Status

### Primary Connection: WireGuard - ✅ ACTIVE
- **Tunnel Interface**: wgsts1000
- **Routing Protocol**: OSPF
- **Peer Gateway**: 192.168.8.1
- **Status**: Established and routing traffic
- **Keepalive**: 25 seconds

### Backup: IPSec Configuration - ⚡ STANDBY
Alwais Site (192.168.253.1):
- **Connection Name**: grandpa-site-to-site
- **Type**: IKEv2 tunnel
- **Pre-Shared Key**: UniFiVPN2024SecureKey!
- **Encryption**: AES-256/SHA256
- **Status**: Configured but not active (WireGuard is primary)

Grandpa Site (172.16.252.1):
- **Hardware**: UniFi Dream Machine
- **Access**: Available via SSH through VPN
- **IPSec**: Can be configured as failover

## No Actions Required - System Operational

### Current Working Configuration
✅ **WireGuard tunnel active and routing traffic**
✅ **OSPF routes established and working**
✅ **Both sites fully accessible**
✅ **SSH access confirmed to both 172.16.252.1 and 172.16.253.1**

### Optional: Configure IPSec as Backup
Access the remote UDM at the Grandpa site and configure matching IPSec settings:

**Via UniFi Web Interface:**
1. Access the Grandpa site UniFi controller
2. Navigate to Settings → VPN → Site-to-Site VPN
3. Click "Create Site-to-Site VPN"
4. Configure with these settings:
   - Remote Gateway: 136.62.122.180
   - Pre-Shared Key: UniFiVPN2024SecureKey!
   - Local Networks: 172.16.252.0/24, 172.16.253.0/24
   - Remote Networks: 192.168.253.0/24, 192.168.12.0/24, 192.168.3.0/24, 192.168.7.0/24, 192.168.2.0/24

**Option A: Via Web UI** (if accessible)
- Navigate to https://70.115.146.40 or via remote access
- Configure Site-to-Site VPN with settings from documentation

**Option B: Via SSH** (if you have access)
```bash
ssh root@172.16.252.1  # or through jump host

# Configure IPSec
cat > /etc/ipsec.conf << 'EOF'
config setup

conn main-office
    type=tunnel
    authby=secret
    auto=start
    keyexchange=ikev2
    ike=aes256-sha256-modp2048
    esp=aes256-sha256-modp2048
    left=%defaultroute
    leftsubnet=172.16.252.0/24
    leftid=70.115.146.40
    right=136.62.122.180
    rightsubnet=192.168.3.0/24
    rightid=136.62.122.180
    dpdaction=restart
    dpddelay=30
EOF

# Add PSK
echo '70.115.146.40 136.62.122.180 : PSK "UniFiVPN2024SecureKey!"' > /etc/ipsec.secrets
chmod 600 /etc/ipsec.secrets

# Start IPSec
ipsec restart
```

### 3. Alternative: WireGuard Site-to-Site
If IPSec continues to have issues, consider setting up a dedicated WireGuard tunnel for the Atria site:

```bash
# Create new WireGuard interface for Atria
wg genkey | tee /etc/wireguard/wgatria.key | wg pubkey > /etc/wireguard/wgatria.pub

# Configure WireGuard
cat > /etc/wireguard/wgatria.conf << 'EOF'
[Interface]
PrivateKey = <private-key>
Address = 10.200.200.1/30
ListenPort = 51821

[Peer]
PublicKey = <atria-public-key>
Endpoint = 70.115.146.40:51821
AllowedIPs = 172.16.252.0/24
PersistentKeepalive = 25
EOF
```

## Troubleshooting Commands

```bash
# Check VPN status
ssh root@192.168.3.1 "ipsec statusall"

# Check routing
ssh root@192.168.3.1 "ip route show | grep 172.16"

# Test connectivity when VPN is up
ssh root@192.168.3.1 "ping 172.16.252.1"
ssh root@192.168.3.1 "ping 172.16.252.172"

# Check firewall rules
ssh root@192.168.3.1 "iptables -L -n -v | grep 172.16"
```

## Current Status Summary
- ✅ WireGuard VPN fully operational
- ✅ OSPF routing working correctly
- ✅ Can reach all Grandpa networks (172.16.252.0/24 and 172.16.253.0/24)
- ✅ SSH access working to both 172.16.252.1 and 172.16.253.1
- ✅ Target host 172.16.252.172 is now reachable

## Quick Access Commands
```bash
# SSH to Grandpa routers
ssh root@172.16.252.1  # Main router
ssh root@172.16.253.1  # Atria network gateway

# Test connectivity
ping 172.16.252.172  # Target host

# Check VPN status
ssh root@192.168.253.1 "wg show wgsts1000"
```

## References
- Grandpa Router Guide: `/mnt/docker/documentation/GRANDPA_SITE_ROUTER_GUIDE.md`
- Connection Details: `/mnt/docker/documentation/SITE_TO_SITE_CONNECTION_GUIDE.md`
- Original Setup Guide: `/mnt/docker/documentation/system/REMOTE_UDM_VPN_SETUP.md`
- IPSec PSK (for backup): `UniFiVPN2024SecureKey!`

---
*Last Updated: 2025-09-12*
*Status: ✅ Fully Operational via WireGuard/OSPF*