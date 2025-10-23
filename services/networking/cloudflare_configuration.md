# Cloudflare Configuration for alwais.org

## Overview
Domain **alwais.org** is managed through Cloudflare with DNS, proxy, and security services.

**Cloudflare Account**: Alwais@gmail.com's Account
**Account ID**: f888f971deca1bde21bada93143f3273
**Zone ID**: 9f16f91ca82b65db8b91a75a4ed8caae
**Nameservers**: bill.ns.cloudflare.com, marjory.ns.cloudflare.com
**Registrar**: GoDaddy (original nameservers: ns69/ns70.domaincontrol.com)

## Cloudflare API Access

### API Token
**Token ID**: 2bc601a51fa0fc7872013fdca65100d9
**Status**: Active ✅
**Token**: `EJqsETtZq2xCQLp_ryy9ku_mQN_jWaEbr7-UIYbx`

### Permissions
- `#dns_records:edit` - Edit DNS records
- `#dns_records:read` - Read DNS records
- `#zone:read` - Read zone information

### API Usage
```bash
# Verify token
curl -X GET "https://api.cloudflare.com/client/v4/accounts/f888f971deca1bde21bada93143f3273/tokens/verify" \
  -H "Authorization: Bearer EJqsETtZq2xCQLp_ryy9ku_mQN_jWaEbr7-UIYbx" \
  -H "Content-Type:application/json"

# List DNS records
curl -X GET "https://api.cloudflare.com/client/v4/zones/9f16f91ca82b65db8b91a75a4ed8caae/dns_records" \
  -H "Authorization: Bearer EJqsETtZq2xCQLp_ryy9ku_mQN_jWaEbr7-UIYbx" \
  -H "Content-Type:application/json"
```

## DNS Records

### Public IP
**External IP**: 136.62.122.180

### A Records (Direct to IP)

| Subdomain | Type | Target | Proxied | Purpose |
|-----------|------|--------|---------|---------|
| alwais.org | A | 136.62.122.180 | ❌ No | Root domain (Home site) |
| atria.alwais.org | A | 70.115.146.40 | ❌ No | Grandpa site (remote location) |
| dash.alwais.org | A | 136.62.122.180 | ✅ Yes | Dashboard (Cloudflare proxy) |
| home.alwais.org | A | 136.62.122.180 | ✅ Yes | Home Assistant (Cloudflare proxy) |
| n8n.alwais.org | A | 136.62.122.180 | ✅ Yes | n8n Automation (Cloudflare proxy) |
| plex.alwais.org | A | 136.62.122.180 | ✅ Yes | Plex Media Server (Cloudflare proxy) |
| vpn.alwais.org | A | 136.62.122.180 | ❌ No | VPN Service (direct) |

### CNAME Records

| Subdomain | Type | Target | Proxied | Purpose |
|-----------|------|--------|---------|---------|
| www.alwais.org | CNAME | alwais.org | ✅ Yes | WWW redirect |
| xteve.alwais.org | CNAME | 12db7842-bc5d-4f33-a0cf-83d5702a5e90.cfargotunnel.com | ✅ Yes | xTeve via Cloudflare Tunnel |
| _domainconnect.alwais.org | CNAME | _domainconnect.gd.domaincontrol.com | ✅ Yes | GoDaddy domain connect |

### TXT Records

| Subdomain | Type | Content | Purpose |
|-----------|------|---------|---------|
| _dmarc.alwais.org | TXT | v=DMARC1; p=none; rua=mailto:94726aa3b7fa44a2beb19b55053431d2@dmarc-reports.cloudflare.net | Email DMARC policy |

## Cloudflare Tunnel

### xTeve Service
**Tunnel ID**: 12db7842-bc5d-4f33-a0cf-83d5702a5e90
**Public Hostname**: xteve.alwais.org
**Backend**: Local xTeve service (192.168.3.11:34400)
**Proxied**: Yes (through Cloudflare)

**Benefits of Cloudflare Tunnel:**
- ✅ No port forwarding required
- ✅ No public IP exposure
- ✅ Automatic SSL/TLS
- ✅ DDoS protection
- ✅ Access from anywhere securely

## Proxy Status

### Proxied through Cloudflare (Orange Cloud) ☁️
Services using Cloudflare proxy get:
- DDoS protection
- Cloudflare CDN
- SSL/TLS encryption
- WAF (Web Application Firewall)
- Analytics

**Proxied Services:**
- ✅ dash.alwais.org
- ✅ home.alwais.org (Home Assistant)
- ✅ n8n.alwais.org
- ✅ plex.alwais.org
- ✅ xteve.alwais.org (via Tunnel)
- ✅ www.alwais.org

### Direct (No Proxy) 🔄
Services bypassing Cloudflare proxy:
- ❌ alwais.org (root domain - Home site)
- ❌ atria.alwais.org (Grandpa remote site - 70.115.146.40)
- ❌ vpn.alwais.org (VPN requires direct connection)

**Why these are not proxied:**
- **atria.alwais.org**: Points to remote Grandpa site (70.115.146.40) connected via site-to-site VPN
- **vpn.alwais.org**: VPN protocols (WireGuard, OpenVPN) require direct IP connection and cannot work through HTTP/HTTPS proxy

## Integration with NPM (Nginx Proxy Manager)

### Traffic Flow for Proxied Services

**External Request → Cloudflare → Your IP (136.62.122.180) → NPM → Backend Service**

Example for plex.alwais.org:
```
User → plex.alwais.org (Cloudflare DNS)
     → Cloudflare Proxy (SSL, DDoS protection)
     → 136.62.122.180:443 (Your external IP)
     → NPM (192.168.3.11:443)
     → SSL termination at NPM
     → Plex backend (192.168.3.11:32400)
```

### Traffic Flow for Tunnel Services

**External Request → Cloudflare Tunnel → Backend Service (NO NPM)**

Example for xteve.alwais.org:
```
User → xteve.alwais.org (Cloudflare DNS)
     → Cloudflare Tunnel (12db7842-bc5d-4f33-a0cf-83d5702a5e90.cfargotunnel.com)
     → Cloudflare tunnel daemon (running on server)
     → xTeve backend (192.168.3.11:34400)
```

### NPM Proxy Hosts vs Cloudflare

| Service | Cloudflare | NPM Proxy | Backend |
|---------|------------|-----------|---------|
| plex.alwais.org | ✅ Proxied | ✅ NPM ID 3 | 192.168.3.11:32400 |
| n8n.alwais.org | ✅ Proxied | ✅ NPM ID 6 | 192.168.3.11:5678 |
| home.alwais.org | ✅ Proxied | ✅ NPM ID 14 | 192.168.3.20:8123 |
| xteve.alwais.org | ✅ Tunnel | ❌ No NPM | 192.168.3.11:34400 |
| vpn.alwais.org | ❌ Direct | ✅ NPM ID 12 | 192.168.3.11:8888 |

## DNS Resolution Flow

### For Internal Clients (192.168.3.0/24 network)

**Without AdGuard DNS rewrites (current):**
```
Client → AdGuard (192.168.3.11)
      → Quad9 upstream DNS
      → Cloudflare DNS
      → Returns: Cloudflare proxy IP (104.21.x.x or 172.67.x.x)
      → Client connects to Cloudflare
      → Cloudflare proxies to 136.62.122.180
      → NPM handles request
```

**Problem**: Internal clients go out to internet and back, even for local services.

**Solution**: Add local DNS rewrites in AdGuard for *.alwais.org → internal IPs

### For External Clients (Internet)

```
Client → Public DNS
      → Cloudflare DNS
      → Returns: Cloudflare proxy IP (for proxied) or 136.62.122.180 (direct)
      → Connects to IP
      → NPM (if not tunnel)
      → Backend service
```

## Local DNS Optimization

### Problem
Internal clients currently resolve *.alwais.org to public IPs, causing unnecessary internet traffic.

### Solution: AdGuard DNS Rewrites

Add these rewrites in AdGuard to resolve locally:

| Domain | Rewrite To | Reason |
|--------|------------|--------|
| adguard.alwais.org | 192.168.3.11 | AdGuard web UI (port 8080) |
| npm.alwais.org | 192.168.3.11 | NPM web UI (port 81) |
| plex.alwais.org | 192.168.3.11 | Plex direct (port 32400) |
| n8n.alwais.org | 192.168.3.11 | n8n direct (port 5678) |
| home.alwais.org | 192.168.3.20 | Home Assistant (port 8123) |
| radarr.alwais.org | 192.168.3.11 | Radarr (port 7878) |
| sonarr.alwais.org | 192.168.3.10 | Sonarr (port 8989) |
| sabnzbd.alwais.org | 192.168.3.10 | SABnzbd (port 9090) |
| qnas.alwais.org | 192.168.3.10 | QNAP NAS (port 443) |
| overserr.alwais.org | 192.168.3.11 | Overseerr (port 5055) |
| msnbc.alwais.org | 192.168.3.11 | MSNBC stream (port 8888) |
| vpn.alwais.org | 192.168.3.11 | VPN (port 8888) |

**After adding rewrites:**
```
Internal Client → plex.alwais.org
               → AdGuard DNS
               → Rewrite to 192.168.3.11
               → Direct connection (no internet hop)
```

**Benefits:**
- ✅ Faster access (no internet roundtrip)
- ✅ Works when internet is down
- ✅ No Cloudflare bandwidth usage for internal traffic
- ✅ NPM SSL still works (certificates valid for *.alwais.org)

## Port Forwarding on Router

### Current Setup (Assumed)
Based on working external access, these ports should be forwarded on UDM Pro:

| External Port | Internal IP | Internal Port | Service |
|---------------|-------------|---------------|---------|
| 443 (HTTPS) | 192.168.3.11 | 443 | NPM (all HTTPS services) |
| 80 (HTTP) | 192.168.3.11 | 80 | NPM (HTTP redirect to HTTPS) |
| ??? | 192.168.3.11 | 8888 | VPN (if not using Cloudflare Tunnel) |

### Verification
```bash
# SSH to UDM Pro
ssh root@192.168.253.1

# Check NAT rules
iptables -t nat -L PREROUTING -n -v | grep 192.168.3.11

# Or check UniFi port forwards
# Settings → Internet → Port Forwarding
```

## Cloudflare Settings

### SSL/TLS Mode
**Recommended**: Full (Strict)
- Encrypts traffic between Cloudflare and your origin (NPM)
- Validates SSL certificate on origin
- Requires valid SSL cert on NPM (already have Let's Encrypt)

### Security Features

**Current (assumed based on free plan):**
- DDoS protection: Auto
- WAF: Basic rules
- Bot protection: Basic
- Always Use HTTPS: Enabled (recommended)
- Auto minify: HTML, CSS, JS
- Brotli compression: Enabled

### Recommended Security Settings

**Firewall Rules:**
```
Block countries except: US, CA (if applicable)
Challenge suspicious IPs
Rate limiting: 100 req/10s per IP
```

**Page Rules:**
```
*.alwais.org/*
  - Security Level: Medium
  - Cache Level: Standard
  - Auto Minify: On
```

## DNS Management

### Add New Subdomain

**Via API:**
```bash
curl -X POST "https://api.cloudflare.com/client/v4/zones/9f16f91ca82b65db8b91a75a4ed8caae/dns_records" \
  -H "Authorization: Bearer EJqsETtZq2xCQLp_ryy9ku_mQN_jWaEbr7-UIYbx" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "A",
    "name": "newservice.alwais.org",
    "content": "136.62.122.180",
    "ttl": 1,
    "proxied": true
  }'
```

**Via Dashboard:**
1. Login: https://dash.cloudflare.com
2. Select: alwais.org
3. DNS → Records → Add record
4. Type: A, Name: newservice, IPv4: 136.62.122.180
5. Toggle Proxy: On (orange cloud)
6. Save

### Update Existing Record

**Via API:**
```bash
# Get record ID first
curl -X GET "https://api.cloudflare.com/client/v4/zones/9f16f91ca82b65db8b91a75a4ed8caae/dns_records?name=plex.alwais.org" \
  -H "Authorization: Bearer EJqsETtZq2xCQLp_ryy9ku_mQN_jWaEbr7-UIYbx"

# Update record
curl -X PUT "https://api.cloudflare.com/client/v4/zones/9f16f91ca82b65db8b91a75a4ed8caae/dns_records/{record_id}" \
  -H "Authorization: Bearer EJqsETtZq2xCQLp_ryy9ku_mQN_jWaEbr7-UIYbx" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "A",
    "name": "plex.alwais.org",
    "content": "136.62.122.180",
    "proxied": true
  }'
```

## Integration with AdGuard

### Current Status
- ✅ AdGuard configured as primary DNS on Bones network
- ❌ No local DNS rewrites configured
- AdGuard forwards all *.alwais.org queries to upstream (Quad9 → Cloudflare)

### Recommended: Add DNS Rewrites

**Method 1: Via AdGuard Web UI**
1. Login: https://adguard.alwais.org
2. Filters → DNS rewrites
3. Add rewrite: `plex.alwais.org` → `192.168.3.11`
4. Repeat for all internal services

**Method 2: Via AdGuardHome.yaml**
```yaml
dns:
  rewrites:
    - domain: adguard.alwais.org
      answer: 192.168.3.11
    - domain: npm.alwais.org
      answer: 192.168.3.11
    - domain: plex.alwais.org
      answer: 192.168.3.11
    - domain: n8n.alwais.org
      answer: 192.168.3.11
    - domain: home.alwais.org
      answer: 192.168.3.20
    - domain: radarr.alwais.org
      answer: 192.168.3.11
    - domain: sonarr.alwais.org
      answer: 192.168.3.10
    - domain: sabnzbd.alwais.org
      answer: 192.168.3.10
    - domain: qnas.alwais.org
      answer: 192.168.3.10
    - domain: overserr.alwais.org
      answer: 192.168.3.11
    - domain: msnbc.alwais.org
      answer: 192.168.3.11
    - domain: vpn.alwais.org
      answer: 192.168.3.11
    - domain: xteve.alwais.org
      answer: 192.168.3.11
```

Then restart AdGuard: `docker restart adguard`

## Monitoring & Analytics

### Cloudflare Dashboard
https://dash.cloudflare.com/f888f971deca1bde21bada93143f3273/alwais.org

**Metrics available:**
- Requests per day
- Bandwidth usage
- Threats blocked
- SSL/TLS requests
- Top countries
- Top paths

### DNS Analytics
- DNS queries per day
- Query types (A, AAAA, CNAME, etc.)
- Response codes
- DNSSEC validation

## Backup & Disaster Recovery

### Export DNS Records
```bash
curl -X GET "https://api.cloudflare.com/client/v4/zones/9f16f91ca82b65db8b91a75a4ed8caae/dns_records" \
  -H "Authorization: Bearer EJqsETtZq2xCQLp_ryy9ku_mQN_jWaEbr7-UIYbx" \
  > /mnt/docker/documentation/backups/cloudflare_dns_$(date +%Y%m%d).json
```

### Restore DNS Records
```bash
# Parse backup and recreate records
cat cloudflare_dns_20251001.json | jq -r '.result[] |
  "curl -X POST \"https://api.cloudflare.com/client/v4/zones/9f16f91ca82b65db8b91a75a4ed8caae/dns_records\" \
   -H \"Authorization: Bearer EJqsETtZq2xCQLp_ryy9ku_mQN_jWaEbr7-UIYbx\" \
   -H \"Content-Type: application/json\" \
   --data '\''{\"type\":\"\(.type)\",\"name\":\"\(.name)\",\"content\":\"\(.content)\",\"proxied\":\(.proxied)}'\\''"'
```

## Security Considerations

### API Token Security
- ✅ Token stored in this documentation (secure location)
- ✅ Token has limited permissions (DNS only, no zone settings)
- ⚠️ Do not commit to public repositories
- ⚠️ Rotate token if exposed

### DNS Security
- ✅ DNSSEC: Enabled (recommended to enable if not)
- ✅ CAA records: Consider adding (restrict SSL issuance)
- ✅ DMARC: Configured for email

### Proxy Security
- ✅ Services behind Cloudflare get DDoS protection
- ✅ SSL/TLS encryption end-to-end
- ⚠️ VPN service must stay un-proxied (direct connection required)

## Common Tasks

### Check if Service is Proxied
```bash
dig plex.alwais.org
# If returns 104.21.x.x or 172.67.x.x → Proxied ✅
# If returns 136.62.122.180 → Direct ❌
```

### Toggle Proxy Status
```bash
# Get record ID
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/9f16f91ca82b65db8b91a75a4ed8caae/dns_records?name=plex.alwais.org" \
  -H "Authorization: Bearer EJqsETtZq2xCQLp_ryy9ku_mQN_jWaEbr7-UIYbx" | jq -r '.result[0].id')

# Enable proxy (orange cloud)
curl -X PATCH "https://api.cloudflare.com/client/v4/zones/9f16f91ca82b65db8b91a75a4ed8caae/dns_records/$RECORD_ID" \
  -H "Authorization: Bearer EJqsETtZq2xCQLp_ryy9ku_mQN_jWaEbr7-UIYbx" \
  -H "Content-Type: application/json" \
  --data '{"proxied":true}'
```

### Clear Cloudflare Cache
```bash
# Purge everything
curl -X POST "https://api.cloudflare.com/client/v4/zones/9f16f91ca82b65db8b91a75a4ed8caae/purge_cache" \
  -H "Authorization: Bearer EJqsETtZq2xCQLp_ryy9ku_mQN_jWaEbr7-UIYbx" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}'
```

## Troubleshooting

### Service Not Accessible Externally
1. Check DNS: `dig service.alwais.org` → Should return Cloudflare IP or your IP
2. Check proxy status: Proxied or direct?
3. Check NPM proxy host exists
4. Check firewall/port forwarding on UDM Pro
5. Check SSL certificate valid

### Internal Access Slow
1. Add DNS rewrites in AdGuard (bypass Cloudflare for internal)
2. Check AdGuard query logs
3. Verify clients using AdGuard DNS (192.168.3.11)

### Cloudflare Errors
- **Error 522**: Origin server down (check NPM container)
- **Error 521**: Origin server refused connection (check firewall)
- **Error 525**: SSL handshake failed (check NPM SSL certificate)

## References

- Cloudflare Dashboard: https://dash.cloudflare.com
- API Documentation: https://developers.cloudflare.com/api/
- Zone ID: 9f16f91ca82b65db8b91a75a4ed8caae
- Account ID: f888f971deca1bde21bada93143f3273
- NPM Configuration: /mnt/docker/documentation/services/networking/npm_configuration.md
- AdGuard Configuration: /mnt/docker/documentation/services/networking/adguard_configuration.md
- UDM Pro Integration: /mnt/docker/documentation/services/networking/udm_pro_adguard_integration.md

## Next Steps

1. ⏳ Add DNS rewrites in AdGuard for local domain resolution
2. ⏳ Export DNS records as backup
3. ⏳ Enable DNSSEC if not already enabled
4. ⏳ Review and optimize Cloudflare security settings
5. ⏳ Document port forwarding rules on UDM Pro
6. ⏳ Consider adding CAA records for SSL certificate control
