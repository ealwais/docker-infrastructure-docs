# Grandpa Site VPN Configuration Guide

## Access the UniFi Gateway Web Interface

The Grandpa site UniFi gateway is accessible at: **https://70.115.146.40**

## Step-by-Step Configuration

### 1. Login to UniFi Console
- Navigate to: https://70.115.146.40
- Login with your UniFi credentials
- You should see the UniFi OS Console

### 2. Navigate to Network Application
- Click on **Network** application
- If prompted, select the Grandpa site

### 3. Create Site-to-Site VPN

#### Navigate to VPN Settings:
1. Click **Settings** (gear icon) in the left sidebar
2. Select **VPN** from the menu
3. Click on **Site-to-Site VPN** tab
4. Click **Create Site-to-Site VPN** button

#### Configure VPN Settings:

**Basic Settings:**
- **Name**: Alwais-Home-VPN
- **VPN Protocol**: Manual IPsec
- **Remote Gateway/Subnet**: 
  - Gateway: `136.62.122.180`
  
**Network Settings:**
- **Remote Networks** (Alwais site networks):
  ```
  192.168.253.0/24
  192.168.12.0/24
  192.168.3.0/24
  192.168.7.0/24
  192.168.2.0/24
  ```
  Click "Add Network" for each one

- **Local Networks** (Grandpa site networks):
  ```
  172.16.252.0/24
  172.16.253.0/24
  ```

**Authentication:**
- **Pre-Shared Key**: `UniFiVPN2024SecureKey!`
- Copy this exactly - it's case sensitive!

**Advanced Settings** (if available):
- **IKE Version**: IKEv2
- **IKE Encryption**: AES-256
- **IKE Integrity**: SHA256
- **IKE DH Group**: 14 (2048-bit)
- **ESP Encryption**: AES-256
- **ESP Integrity**: SHA256
- **ESP DH Group**: 14 (2048-bit)
- **Enable DPD**: Yes
- **DPD Delay**: 30

### 4. Save and Apply
1. Click **Add** or **Save** button
2. Wait for settings to provision (may take 1-2 minutes)
3. The VPN should start connecting automatically

### 5. Verify Connection

In the VPN section, you should see:
- Status: **Connected** (green indicator)
- Both sites showing as reachable
- Traffic statistics starting to show data

## Alternative: Quick IPsec Config (if Manual IPsec option is simpler)

If the interface offers a simpler "Manual IPsec" option:

**Essential Settings Only:**
- **Remote IP**: 136.62.122.180
- **Local ID**: 70.115.146.40
- **Remote ID**: 136.62.122.180
- **Pre-Shared Key**: UniFiVPN2024SecureKey!
- **Local Subnets**: 172.16.252.0/24, 172.16.253.0/24
- **Remote Subnets**: 192.168.253.0/24, 192.168.12.0/24, 192.168.3.0/24, 192.168.7.0/24, 192.168.2.0/24

## Testing the Connection

Once configured, test from the Alwais site:

```bash
# From your local machine or router
ssh root@192.168.3.1

# Check VPN status
ipsec status

# Should show: "grandpa-site-to-site[1]: ESTABLISHED"

# Test connectivity
ping 172.16.252.1  # Grandpa router
ping 172.16.252.172  # Your target host

# If successful, SSH should work:
ssh user@172.16.252.172
```

## Troubleshooting

### VPN Shows "Connecting" but never connects:
1. Verify the Pre-Shared Key is exactly: `UniFiVPN2024SecureKey!`
2. Check that all network subnets are entered correctly
3. Ensure no firewall is blocking UDP ports 500 and 4500

### VPN Connected but can't reach 172.16.252.172:
1. Check if the host is online at the Grandpa site
2. Verify local firewall rules on the target host
3. Ensure the host has the correct IP configured

### Current Status on Alwais Side:
- ✅ IPSec configured and trying to connect
- ✅ Incorrect routes removed
- ⏳ Waiting for Grandpa site configuration
- Connection name: `grandpa-site-to-site`

## Notes
- The Grandpa site web interface is accessible at https://70.115.146.40
- There's an existing WireGuard tunnel (wgsts1000) on port 20000 but it doesn't route to the 172.16 networks
- SSH access to the Grandpa router is not available from external IPs