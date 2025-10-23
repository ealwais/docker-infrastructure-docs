# AdGuard Home Configuration

## Overview
AdGuard Home provides DNS-based ad blocking and DNS services for the entire network.

**Container**: adguard
**Data Location**: /mnt/docker/adguard-npm/adguard/
**Web UI**: http://192.168.3.11:8080 or https://adguard.alwais.org
**DNS Port**: 53 (TCP/UDP)
**DHCP**: Disabled

## DNS Configuration

**Last Updated**: October 1, 2025

### Upstream DNS Servers
- **Primary**: https://dns10.quad9.net/dns-query (Quad9 DoH)
- **Bootstrap DNS**:
  - 9.9.9.10
  - 149.112.112.10
  - 2620:fe::10
  - 2620:fe::fe:10

### DNS Settings
- **Port**: 53
- **Bind Address**: 0.0.0.0 (all interfaces)
- **Upstream Mode**: load_balance
- **Cache Size**: 4194304 bytes (4 MB)
- **Cache Enabled**: Yes
- **DNSSEC**: Disabled
- **Rate Limit**: 20 requests/second
- **Plain DNS**: Enabled
- **HTTP/3**: Disabled
- **DNS64**: Disabled

### Performance
- **Max Goroutines**: 300
- **Upstream Timeout**: 10s
- **Fastest Timeout**: 1s
- **Cache Optimistic**: Disabled

## Filtering Configuration

### Active Filters
1. **AdGuard DNS filter** (ID: 1)
   - Enabled: Yes
   - URL: https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt

2. **AdAway Default Blocklist** (ID: 2)
   - Enabled: No
   - URL: https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt

### Safe Search
- **Enabled**: Yes
- **Providers**:
  - Bing: Yes
  - DuckDuckGo: Yes
  - Ecosia: Yes
  - Google: Yes
  - Pixabay: Yes
  - Yandex: Yes
  - YouTube: Yes

### Blocking Hosts
- version.bind
- id.server
- hostname.bind

### Blocking Mode
- **Mode**: default
- **IPv4 Blocking**: Not set
- **IPv6 Blocking**: Not set
- **Parental Block Host**: family-block.dns.adguard.com
- **Safebrowsing Block Host**: standard-block.dns.adguard.com

## Query Log

### Settings
- **Enabled**: Yes
- **File Logging**: Yes
- **Interval**: 24h
- **Memory Size**: 1000
- **Ignored Domains**:
  - alwais.org (local domain)

## Statistics

### Settings
- **Enabled**: Yes
- **Interval**: 24h
- **Ignored Domains**: None

## Web Interface

### Settings
- **Address**: 0.0.0.0:80
- **Session TTL**: 720h (30 days)
- **pprof**: Disabled (port 6060)
- **Theme**: Dark
- **Language**: English

### User
- **Username**: ealwais
- **Password**: Hashed (bcrypt)

### Authentication
- **Max Auth Attempts**: 5
- **Block Auth Duration**: 15 minutes

## TLS/HTTPS

### Status
- **Enabled**: No
- **Force HTTPS**: No
- **HTTPS Port**: 443
- **DoT Port**: 853
- **DoQ Port**: 853
- **DNSCrypt**: Disabled

### SSL Configuration
- Behind NPM reverse proxy
- SSL termination at NPM (adguard.alwais.org)
- Internal traffic uses HTTP

## DHCP

**Status**: Disabled

DHCP is handled by the router, not AdGuard.

## Network

### Trusted Proxies
- 127.0.0.0/8
- ::1/128

### Client Access
- **Allowed Clients**: All (empty list)
- **Disallowed Clients**: None (empty list)

### Private Networks
- **Use Private PTR Resolvers**: No
- **Local PTR Upstreams**: None

## Port Mapping

**Container Ports**:
- 53/tcp: DNS
- 53/udp: DNS
- 67/udp: DHCP (unused)
- 68/udp: DHCP (unused)
- 80/tcp → 8080/tcp: Web UI
- 443/tcp: HTTPS (unused, behind NPM)
- 443/udp: DNS over QUIC (unused)
- 853/tcp: DNS over TLS (unused)
- 853/udp: DNS over QUIC (unused)
- 3000/tcp: Alternative web UI
- 5443/tcp: (unused)
- 5443/udp: (unused)
- 6060/tcp: pprof debug (disabled)

## Integration with NPM

AdGuard is accessible through NPM:
- **External URL**: https://adguard.alwais.org
- **Backend**: 192.168.3.11:8080
- **SSL Certificate**: Cert ID 7
- **Force SSL**: Yes

## DNS Rewrites (Local Domain Resolution)

**Purpose**: Internal clients resolve *.alwais.org domains to local IPs instead of going through Cloudflare.

### Active DNS Rewrites

| Domain | Resolves To | Purpose |
|--------|-------------|---------|
| radarr.alwais.org | 192.168.3.11 | NPM → Radarr (port 7878) |
| sonarr.alwais.org | 192.168.3.10 | Direct to Sonarr (port 8989) |
| sabnzbd.alwais.org | 192.168.3.10 | Direct to SABnzbd (port 9090) |
| plex.alwais.org | 192.168.3.11 | NPM → Plex (port 32400) |
| msnbc.alwais.org | 192.168.3.11 | NPM → MSNBC stream (port 8888) |
| home.alwais.org | 192.168.3.20 | Direct to Home Assistant (port 8123) |
| qnas.alwais.org | 192.168.3.10 | Direct to QNAP NAS (port 443) |
| npm.alwais.org | 192.168.3.11 | NPM Web UI (port 81) |
| adguard.alwais.org | 192.168.3.11 | AdGuard Web UI (port 8080) |
| xteve.alwais.org | 192.168.3.11 | NPM → xTeve (port 34400) |
| protect.alwais.org | 192.168.3.1 | UniFi Protect (port 443) |
| vpn.alwais.org | 192.168.3.11 | NPM → VPN service (port 8888) |
| docker.alwais.org | 192.168.3.11 | Main Docker server |
| synology.alwais.org | 192.168.3.11 | Synology/Docker server |
| mini.alwais.org | 192.168.3.20 | Mac Mini (Home Assistant) |

### Obsolete Rewrites (Should Remove)
- ❌ overserr.alwais.org → Service no longer exists
- ❌ readarr.alwais.org → Service no longer exists

### How DNS Rewrites Work

**Without Rewrite (External routing):**
```
Internal Client → radarr.alwais.org
               → AdGuard → Quad9 → Cloudflare DNS
               → Returns: Public IP or Cloudflare proxy IP
               → Traffic goes out to internet and back
```

**With Rewrite (Internal routing):**
```
Internal Client → radarr.alwais.org
               → AdGuard DNS rewrite
               → Returns: 192.168.3.11 (local IP)
               → Traffic stays on internal network
               → Faster, no internet hop required
```

### Benefits of DNS Rewrites
- ✅ Faster access (no internet roundtrip)
- ✅ Works when internet is down
- ✅ No Cloudflare bandwidth usage for internal traffic
- ✅ SSL certificates still work (NPM handles HTTPS)
- ✅ Seamless experience (same URLs work internally and externally)

## Common Tasks

### View Logs
```bash
docker logs adguard
```

### Edit Configuration
```bash
# Edit config file
nano /mnt/docker/adguard-npm/adguard/conf/AdGuardHome.yaml

# Restart AdGuard
docker restart adguard
```

### Add Custom DNS Rules
1. Login to Web UI (https://adguard.alwais.org)
2. Go to Filters → DNS rewrites
3. Add domain → IP mapping

### Add Blocklist
1. Login to Web UI
2. Go to Filters → DNS blocklists
3. Add custom blocklist URL
4. Save

### Check DNS Resolution
```bash
# Test DNS query
nslookup google.com 192.168.3.11

# Test with dig
dig @192.168.3.11 google.com
```

## Backup & Restore

### Backup Configuration
```bash
# Backup config
cp /mnt/docker/adguard-npm/adguard/conf/AdGuardHome.yaml \
   /mnt/docker/adguard-npm/adguard/conf/AdGuardHome.yaml.backup_$(date +%Y%m%d_%H%M%S)
```

### Restore Configuration
```bash
# Restore from backup
cp /mnt/docker/adguard-npm/adguard/conf/AdGuardHome.yaml.backup_TIMESTAMP \
   /mnt/docker/adguard-npm/adguard/conf/AdGuardHome.yaml

# Restart AdGuard
docker restart adguard
```

## Performance Tuning

### Current Settings
- **Cache Size**: 4 MB (optimal for home use)
- **Max Goroutines**: 300 (good for concurrent requests)
- **Rate Limit**: 20 req/s per subnet

### Recommendations
- Cache size is adequate for home network
- Load balancing across upstream servers provides resilience
- Consider enabling more blocklists if needed

## Security

### Current Status
✓ Safe Search enabled for major search engines
✓ AdGuard DNS filter active
✓ Rate limiting enabled
✓ Query logging for troubleshooting
✓ Behind NPM with SSL

### Recommendations
- Keep AdGuard and blocklists updated
- Review query logs periodically
- Consider enabling additional blocklists
- Monitor for DNS leaks

## Monitoring

### Key Metrics
- Query volume per day
- Blocked queries percentage
- Upstream server response times
- Cache hit rate

### Access Logs
- Location: /mnt/docker/adguard-npm/adguard/work/
- Query log retention: 24h
- Statistics retention: 24h

## Troubleshooting

### DNS Not Working
1. Check container status: `docker ps --filter name=adguard`
2. Check logs: `docker logs adguard`
3. Verify port 53 is listening: `netstat -tulpn | grep :53`
4. Test DNS: `nslookup google.com 192.168.3.11`

### Web UI Not Accessible
1. Check NPM proxy configuration
2. Verify port 8080 is accessible locally
3. Check SSL certificate status
4. Review AdGuard logs

### High Query Volume
1. Check statistics in Web UI
2. Identify top clients
3. Check for DNS loops
4. Review query log

## Configuration Files

### Main Config
- **Path**: /mnt/docker/adguard-npm/adguard/conf/AdGuardHome.yaml
- **Format**: YAML
- **Encoding**: UTF-8

### Directory Structure
```
/mnt/docker/adguard-npm/adguard/
├── conf/
│   └── AdGuardHome.yaml    # Main configuration
└── work/                    # Runtime data, logs
```

## Docker Compose

Location: /mnt/docker/adguard-npm/docker-compose.yml

The AdGuard container is defined in the same compose file as NPM.

## Network Configuration

### For Clients to Use AdGuard
Set DNS server to: **192.168.3.11**

This can be configured:
- Per device (manual DNS settings)
- Router DHCP settings (network-wide)
- Individual device network settings

## Updates

### Update AdGuard
```bash
# Pull latest image
docker pull adguard/adguardhome:latest

# Recreate container
cd /mnt/docker/adguard-npm
docker-compose up -d adguard
```

### Update Filters
- Automatic updates: Check Web UI → Filters → Update interval
- Manual update: Filters → Update blocklists button

## References

- AdGuard Home GitHub: https://github.com/AdguardTeam/AdGuardHome
- Documentation: https://adguard.com/en/adguard-home/overview.html
- Configuration File: /mnt/docker/adguard-npm/adguard/conf/AdGuardHome.yaml
- Web UI: https://adguard.alwais.org
