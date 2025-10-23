# Configure AdGuard as Primary DNS - Step by Step

## Quick Steps (Web UI)

### For Bones Network (192.168.3.0/24)

1. **Access UniFi Controller**
   - Open browser
   - Go to: `https://protect.alwais.org` or `https://192.168.3.1`
   - Login with your credentials

2. **Navigate to Networks**
   - Click: **Settings** (gear icon, bottom left)
   - Click: **Networks**
   - Find and click: **Bones** network

3. **Edit DHCP Settings**
   - Scroll down to: **DHCP** section
   - Find: **DHCP Name Server**
   - Click: **Manual**

4. **Update DNS Servers**
   - **DNS Server 1**: Change to `192.168.3.11`
   - **DNS Server 2**: (leave empty or use `192.168.3.1` as backup)
   - **DNS Server 3**: (leave empty)
   - **DNS Server 4**: (leave empty)

   **Current values to remove:**
   - ~~1.1.1.1~~
   - ~~8.8.8.8~~

5. **Save Changes**
   - Click: **Apply Changes** (bottom right)
   - Wait for changes to provision

6. **Verify Configuration**
   - Settings should show: DNS Server 1: 192.168.3.11
   - Other DNS fields should be empty or 192.168.3.1

## Repeat for Other Networks

### Networks Needing Update:
- ✅ **Bones (br3)** - 192.168.3.0/24 - Follow steps above
- ⚠️ **Default (br0)** - 192.168.253.0/24 - Optional
- ⚠️ **JumboFrame (br10)** - 192.168.10.0/24 - Optional
- ⚠️ **camera (br2)** - 192.168.2.0/24 - Optional
- ⚠️ **iot (br6)** - 192.168.6.0/24 - Optional

### Already Configured (No Changes Needed):
- ✅ **Servers (br7)** - Already using AdGuard as primary
- ✅ **Neena (br12)** - Already using AdGuard as primary

## Force DHCP Renewal on Clients

After making changes, clients need to renew DHCP to get new DNS settings:

### Option 1: Wait (24 hours)
- DHCP leases expire in 24 hours
- Clients will automatically get new DNS settings

### Option 2: Manual Renewal (Immediate)

**Windows:**
```cmd
ipconfig /release
ipconfig /renew
ipconfig /all
```
Look for: DNS Servers: 192.168.3.11

**macOS:**
```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

**Linux:**
```bash
sudo dhclient -r
sudo dhclient
cat /etc/resolv.conf
```

**iOS/Android:**
- Turn WiFi off, wait 5 seconds, turn WiFi on

### Option 3: Reboot Device
- Simplest method: Reboot the device

## Verification

### Check DNS on Client
After DHCP renewal, verify DNS:

**Windows:**
```cmd
ipconfig /all | findstr "DNS Servers"
```
Expected: 192.168.3.11

**macOS/Linux:**
```bash
scutil --dns | grep nameserver
# or
cat /etc/resolv.conf
```
Expected: nameserver 192.168.3.11

### Test DNS Resolution
```bash
nslookup google.com
```
Expected output:
```
Server:  192.168.3.11
Address: 192.168.3.11#53

Non-authoritative answer:
Name:    google.com
Address: <IP address>
```

### Verify in AdGuard
1. Open: `https://adguard.alwais.org`
2. Click: **Query Log**
3. Generate test query: `nslookup test.com`
4. See query appear in AdGuard log

### Test Ad Blocking
Visit: `http://testads.com`
- Ads should be blocked
- Check AdGuard query log for blocked domains

## Expected Results

### Before Change
```
DNS Servers for Bones Network:
1. 1.1.1.1
2. 192.168.3.1
3. 192.168.3.11
4. 8.8.8.8
```

### After Change
```
DNS Servers for Bones Network:
1. 192.168.3.11  ← AdGuard (primary)
2. (empty or 192.168.3.1 as backup)
```

## What This Achieves

✅ **All DNS queries** from Bones network go through AdGuard
✅ **Ad blocking** enforced network-wide
✅ **Safe Search** enabled on all devices
✅ **Malware/tracker protection** via DNS filtering
✅ **Query logging** in AdGuard for troubleshooting
✅ **Custom DNS rules** can be applied
✅ **Privacy** - no queries sent to Google/Cloudflare

## Troubleshooting

### Changes Not Saving
- Check you clicked "Apply Changes"
- Refresh the page and verify
- Check UniFi controller logs

### Clients Still Using Old DNS
- DHCP lease hasn't expired yet
- Force DHCP renewal (see above)
- Reboot client device
- Check client has network access

### Some Sites Not Working
- Check AdGuard isn't blocking legitimate sites
- Review AdGuard query log
- Temporarily disable AdGuard filtering to test
- Add exceptions in AdGuard if needed

### DNS Resolution Slow
- Check AdGuard is running: `docker ps --filter name=adguard`
- Check upstream DNS (Quad9) is responding
- Review AdGuard cache settings
- Check network connectivity to 192.168.3.11

## Alternative: API Method (Advanced)

If you have UniFi controller credentials, you can use the API:

```bash
# Login
curl -sk -c /tmp/unifi-cookie.txt \
  -d "{'username':'admin','password':'password'}" \
  https://192.168.3.1/api/login

# Get network config
curl -sk -b /tmp/unifi-cookie.txt \
  https://192.168.3.1/api/s/default/rest/networkconf

# Update network (requires network _id)
curl -sk -b /tmp/unifi-cookie.txt \
  -X PUT \
  -d '{"dhcpd_dns_1":"192.168.3.11","dhcpd_dns_2":""}' \
  https://192.168.3.1/api/s/default/rest/networkconf/[network_id]
```

⚠️ This requires knowing the network ID and proper JSON formatting.
**Web UI method is much simpler and safer.**

## Summary

**What to Do:**
1. Login to UniFi controller web UI
2. Go to Settings → Networks → Bones
3. Change DNS Server 1 to: `192.168.3.11`
4. Remove other DNS servers (1.1.1.1, 8.8.8.8)
5. Apply changes
6. Force DHCP renewal on clients (or wait 24h)
7. Verify DNS is 192.168.3.11 on clients
8. Test by checking AdGuard query log

**Time Required:**
- 5 minutes to make changes
- 1 minute per client to force DHCP renewal
- OR 24 hours for automatic renewal

**Benefit:**
All devices on Bones network will use AdGuard for DNS, giving network-wide ad blocking and protection.
