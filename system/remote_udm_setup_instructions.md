# Remote UDM Setup Instructions (172.16.252.1)

## Prerequisites
- Access to UniFi Network Controller (Web UI)
- SSH access to remote UDM at 172.16.252.1
- Public IP address of remote site

## Step 1: Configure Site-to-Site VPN in UniFi Controller

### On Main Office UniFi Controller (192.168.3.1):

1. Open UniFi Network Controller web interface
2. Go to **Settings** → **Networks**
3. Click **Create New Network**
4. Configure as follows:
   - **Name**: Site-to-Site VPN to Remote Office
   - **Purpose**: Site-to-Site VPN
   - **VPN Type**: Manual IPSec
   - **Remote Subnets**: `172.16.252.0/24`
   - **Remote Gateway/IP**: `[Remote Office Public IP]`
   - **Pre-Shared Key**: `UniFiVPN2024SecureKey!`
   - **Advanced Settings**:
     - IKE Version: IKEv2
     - Encryption: AES-256
     - Hash: SHA256
     - DH Group: 14
5. Click **Save**

### On Remote Office UniFi Controller (172.16.252.1):

1. Open UniFi Network Controller web interface
2. Go to **Settings** → **Networks**
3. Click **Create New Network**
4. Configure as follows:
   - **Name**: Site-to-Site VPN to Main Office
   - **Purpose**: Site-to-Site VPN
   - **VPN Type**: Manual IPSec
   - **Remote Subnets**: `192.168.3.0/24`
   - **Remote Gateway/IP**: `136.62.122.180` (Main office public IP)
   - **Pre-Shared Key**: `UniFiVPN2024SecureKey!`
   - **Advanced Settings**: (Same as above)
5. Click **Save**

## Step 2: Verify VPN Connection

SSH into remote UDM and test connectivity:

```bash
ssh root@172.16.252.1

# Test VPN tunnel
ping -c 3 192.168.3.1

# Check routing
ip route | grep 192.168.3
```

## Step 3: Install/Configure UniFi Talk (if needed)

Check if UniFi Talk is installed:

```bash
ps aux | grep unifi-talk
```

If not installed, install via UniFi OS:
1. Open UniFi OS web interface
2. Go to **Applications**
3. Install **UniFi Talk**

## Step 4: Configure SIP Trunk on Remote UDM

SSH into the remote UDM and run:

```bash
ssh root@172.16.252.1

# Create SIP trunk configuration
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
  
  <!-- Accept calls from main office for 2XXX extensions -->
  <extension name="accept_from_main_office">
    <condition field="network_addr" expression="^192\.168\.3\.1$" />
    <condition field="destination_number" expression="^(2\d{3})$">
      <action application="transfer" data="$1 XML default"/>
    </condition>
  </extension>
</include>
EOF

# Set permissions
chown -R freeswitch:freeswitch /etc/freeswitch/dialplan/public/

# Reload FreeSwitch configuration
fs_cli -x "reloadxml"

# Verify configuration
fs_cli -x "dialplan show" | grep main_office
```

## Step 5: Configure Firewall Rules

On the remote UDM:

```bash
# Allow SIP traffic
iptables -A INPUT -p udp --dport 5060 -s 192.168.3.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 5060 -s 192.168.3.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 5061 -s 192.168.3.0/24 -j ACCEPT

# Allow RTP traffic
iptables -A INPUT -p udp --dport 10000:20000 -s 192.168.3.0/24 -j ACCEPT

# Check rules
iptables -L -n | grep 5060
```

## Step 6: Configure Extensions in UniFi Talk

### Main Office (192.168.3.1):
- Extensions: 1000-1999
- Dial plan routes 2XXX to remote office

### Remote Office (172.16.252.1):
- Extensions: 2000-2999
- Dial plan routes 1XXX to main office

In UniFi Talk web interface:
1. Go to **Settings** → **Extensions**
2. Create extensions in the appropriate range
3. Assign to phones/users

## Step 7: Test Inter-Site Calling

1. From a phone at the main office (ext 1XXX), dial a 2XXX extension
2. From a phone at the remote office (ext 2XXX), dial a 1XXX extension

Monitor the call in real-time:

```bash
# On main office UDM
fs_cli -x "sofia loglevel all 9"

# Watch while making test call
fs_cli
> /log 7
```

## Troubleshooting

### VPN Not Connected:
```bash
# Check IPSec status
ipsec status

# Check routes
ip route | grep -E "192.168.3|172.16.252"

# Test connectivity
ping -c 3 192.168.3.1
```

### SIP Calls Not Working:
```bash
# Check FreeSwitch status
fs_cli -x "sofia status"

# Check dialplan
fs_cli -x "dialplan show" | grep -E "main_office|remote_office"

# Test SIP connectivity
nc -zv 192.168.3.1 5060
```

### View Call Logs:
```bash
# Real-time SIP debugging
fs_cli -x "sofia global siptrace on"
tail -f /var/log/freeswitch/freeswitch.log
```

## Summary

After completing these steps, you'll have:
- ✅ Site-to-site VPN tunnel between offices
- ✅ SIP trunk connecting both UniFi Talk systems
- ✅ Extension routing (1XXX ↔ 2XXX)
- ✅ Unified phone system across both locations

Main number calls can be:
- Answered at either location
- Transferred between offices
- Routed based on time of day or availability

## Configuration Files Created

**Main Office (192.168.3.1):**
- `/etc/freeswitch/dialplan/public/remote_office_trunk.xml`
- `/tmp/ipsec_vpn.conf`
- `/tmp/wg_site_to_site.conf`

**Remote Office (172.16.252.1):**
- `/etc/freeswitch/dialplan/public/main_office_trunk.xml`
- Corresponding VPN and firewall configurations