# Site-to-Site VPN Configuration Status

## Current Issue
Cannot SSH to 172.16.252.172 at the Grandpa site due to VPN connectivity issues.

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

## Current Routing Issue - RESOLVED

✅ The incorrect OSPF routes have been removed. Previously, the 172.16.252.0/24 and 172.16.253.0/24 networks were incorrectly routed through a WireGuard tunnel (wgsts1000) to 192.168.0.1.

These routes have now been deleted and traffic will route through the IPSec VPN once it's established.

## VPN Configuration Status

### Alwais Site (192.168.3.1) - ✅ CONFIGURED
IPSec configuration has been set up with:
- **Connection Name**: grandpa-site-to-site
- **Type**: IKEv2 tunnel
- **Pre-Shared Key**: UniFiVPN2024SecureKey!
- **Encryption**: AES-256/SHA256
- **Status**: CONNECTING (waiting for remote side)

### Grandpa Site (70.115.146.40) - ❌ NOT CONFIGURED
The remote Grandpa router needs matching IPSec configuration:
- Currently not responding on IPSec ports (500, 4500)
- Needs VPN configuration to be applied
- Public IP is not directly reachable (likely behind firewall)

## Required Actions

### 1. Fix Routing (Immediate)
Remove incorrect OSPF route and add static route:
```bash
# On main router (192.168.3.1)
ssh root@192.168.3.1

# Remove OSPF routes for 172.16 network
ip route del 172.16.252.0/24 via 192.168.0.1 dev wgsts1000
ip route del 172.16.252.2 via 192.168.0.1 dev wgsts1000
ip route del 172.16.253.0/24 via 192.168.0.1 dev wgsts1000

# Add static route through IPSec (will activate when VPN connects)
ip route add 172.16.252.0/24 dev ipsec0
```

### 2. Configure Remote Grandpa Router
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
- ✅ Main office IPSec configured and attempting connection
- ❌ Remote office needs IPSec configuration
- ❌ Routing table has incorrect OSPF routes via WireGuard
- ❌ Cannot reach 172.16.252.172 until VPN is established

## Next Steps
1. Contact whoever has access to the Atria router to configure the VPN
2. Remove incorrect OSPF routes
3. Monitor VPN connection status
4. Test connectivity once VPN is established

## References
- Main documentation: `/mnt/docker/documentation/system/REMOTE_UDM_VPN_SETUP.md`
- VPN Pre-Shared Key: `UniFiVPN2024SecureKey!`
- Support needed for: Remote router configuration at Atria location