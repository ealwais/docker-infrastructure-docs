# Remote UDM VPN and SIP Trunk Setup Instructions

## Current Status
✅ Main Office UDM (192.168.3.1) is configured and trying to connect
⚠️ Remote Office UDM (70.115.146.40) is reachable but needs matching VPN configuration
✅ SIP routing rules are ready on main office

## Remote Office Configuration Required

### Option 1: Via UniFi Network Controller Web UI (Recommended)

1. **Access Remote UDM Controller**
   - Navigate to: https://70.115.146.40 or https://172.16.252.1
   - Login with your UniFi credentials

2. **Create Site-to-Site VPN**
   - Go to: **Settings** → **VPN** → **Create Site-to-Site VPN**
   - Configure with these EXACT settings:
   
   ```
   VPN Name: Main Office VPN
   VPN Protocol: Manual IPSec
   Remote Gateway: 136.62.122.180
   Remote Networks: 192.168.3.0/24
   Local Networks: 172.16.252.0/24
   
   Authentication:
   Pre-Shared Key: UniFiVPN2024SecureKey!
   
   Advanced Settings:
   IKE Version: IKEv2
   IKE Encryption: AES-256
   IKE Hash: SHA256
   IKE DH Group: 14 (2048-bit)
   ESP Encryption: AES-256
   ESP Hash: SHA256
   ESP DH Group: 14 (2048-bit)
   ```

3. **Save and Apply** the configuration

### Option 2: Via SSH (If you have SSH access)

SSH into the remote UDM and run:

```bash
ssh root@172.16.252.1  # or use public IP with port forwarding

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

# Restart IPSec
ipsec restart
sleep 5
ipsec status
```

## Configure SIP Trunk on Remote UDM

Once VPN is connected, configure SIP on remote UDM:

```bash
# Check if UniFi Talk is installed
ps aux | grep unifi-talk

# If not installed, install via UniFi OS web interface

# Configure SIP routing
cat > /etc/freeswitch/dialplan/public/main_office_trunk.xml << 'EOF'
<include>
  <!-- Route 1XXX extensions to main office -->
  <extension name="route_to_main_office">
    <condition field="destination_number" expression="^(1\d{3})$">
      <action application="set" data="effective_caller_id_number=${caller_id_number}"/>
      <action application="set" data="effective_caller_id_name=${caller_id_name}"/>
      <action application="bridge" data="sofia/external_talk/sip:$1@192.168.3.1:5060"/>
    </condition>
  </extension>
  
  <!-- Accept 2XXX calls from main office -->
  <extension name="accept_from_main_office">
    <condition field="network_addr" expression="^192\.168\.3\.1$" />
    <condition field="destination_number" expression="^(2\d{3})$">
      <action application="transfer" data="$1 XML default"/>
    </condition>
  </extension>
</include>
EOF

# Set permissions and reload
chown -R freeswitch:freeswitch /etc/freeswitch/dialplan/public/
fs_cli -x "reloadxml"

# Configure firewall
iptables -A INPUT -p udp --dport 5060 -s 192.168.3.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 5060 -s 192.168.3.0/24 -j ACCEPT
iptables -A INPUT -p udp --dport 10000:20000 -s 192.168.3.0/24 -j ACCEPT
```

## Verify Connection

### On Main Office UDM:
```bash
# Check VPN status
ipsec status
ping 172.16.252.1

# Check SIP routing
fs_cli -x "sofia status"
```

### On Remote Office UDM:
```bash
# Check VPN status
ipsec status
ping 192.168.3.1

# Test SIP connectivity
nc -zv 192.168.3.1 5060
```

## Testing Calls

1. **Main Office → Remote Office**
   - From extension 1XXX, dial 2XXX
   - Call should route through VPN to remote office

2. **Remote Office → Main Office**
   - From extension 2XXX, dial 1XXX
   - Call should route through VPN to main office

## Troubleshooting

### VPN Not Connecting:
- Verify Pre-Shared Key matches exactly: `UniFiVPN2024SecureKey!`
- Check firewall allows UDP 500, 4500 (IKE/IPSec)
- Verify public IPs are correct:
  - Main: 136.62.122.180
  - Remote: 70.115.146.40

### SIP Not Working:
- Ensure UniFi Talk is installed on both UDMs
- Check firewall allows port 5060 from VPN subnet
- Verify FreeSwitch is running: `ps aux | grep freeswitch`

## Connection Details Summary

| Setting | Main Office | Remote Office |
|---------|------------|---------------|
| Public IP | 136.62.122.180 | 70.115.146.40 |
| Internal IP | 192.168.3.1 | 172.16.252.1 |
| Subnet | 192.168.3.0/24 | 172.16.252.0/24 |
| Extensions | 1000-1999 | 2000-2999 |
| PSK | UniFiVPN2024SecureKey! | UniFiVPN2024SecureKey! |

## Status from Main Office

Current attempt shows:
- ✅ Remote UDM is reachable (70.115.146.40)
- ⚠️ VPN handshake failing due to mismatched proposals
- ✅ Main office is configured and attempting connection
- ⏳ Waiting for remote office configuration