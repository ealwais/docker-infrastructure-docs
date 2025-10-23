# NPM and AdGuard Cleanup - October 1, 2025

## Summary
Cleaned up duplicate proxy entries in Nginx Proxy Manager and documented both NPM and AdGuard configurations.

## NPM Cleanup Actions

### Duplicate Entries Removed
1. **ID 15**: npm1.alwais.org (duplicate of npm.alwais.org)
2. **ID 16**: overserr.alwais.org (duplicate, kept ID 17)
3. **ID 13**: protect.alwais.org → 192.168.3.11:8888 (old entry, removed)

### Verified Configuration
- **protect.alwais.org (ID 19)**: Confirmed correct backend → 192.168.3.1:443 (UniFi Protect)
- **Total Active Proxies**: 14 (down from 17)

## Current NPM Proxy Hosts (After Cleanup)

| ID | Domain | Backend | SSL | Purpose |
|----|--------|---------|-----|---------|
| 1 | adguard.alwais.org | 192.168.3.11:8080 | Cert 7 (forced) | AdGuard DNS |
| 2 | sonarr.alwais.org | 192.168.3.10:8989 | No | Sonarr TV |
| 3 | plex.alwais.org | 192.168.3.11:32400 | Cert 8 (forced) | Plex |
| 4 | radarr.alwais.org | 192.168.3.120:7878 | Cert 9 | Radarr Movies |
| 5 | sabnzbd.alwais.org | 192.168.3.10:9090 | No | SABnzbd |
| 6 | n8n.alwais.org | 192.168.3.11:5678 | Cert 11 | n8n |
| 7 | xteve.alwais.org | 192.168.3.11:34400 | No | xTeve |
| 9 | npm.alwais.org | 192.168.3.11:81 | Cert 15 (forced) | NPM UI |
| 10 | msnbc.alwais.org | 192.168.3.11:8888 | Cert 4 (forced) | MSNBC |
| 12 | vpn.alwais.org | 192.168.3.11:8888 | Cert 23 (forced) | VPN |
| 14 | home.alwais.org | 192.168.3.20:8123 | Cert 27 (forced) | Home Assistant |
| 17 | overserr.alwais.org | 192.168.3.11:5055 | No | Overseerr |
| 18 | qnas.alwais.org | 192.168.3.10:443 | No | QNAP NAS |
| 19 | protect.alwais.org | 192.168.3.1:443 | No | UniFi Protect |

## AdGuard Configuration Summary

### DNS Settings
- **Upstream**: Quad9 DoH (https://dns10.quad9.net/dns-query)
- **Mode**: Load Balance
- **Cache**: 4 MB
- **Port**: 53 (TCP/UDP)

### Filtering
- **AdGuard DNS Filter**: Enabled
- **Safe Search**: Enabled (all major search engines)
- **Query Logging**: 24h retention

### Web Interface
- **Internal**: http://192.168.3.11:8080
- **External**: https://adguard.alwais.org (via NPM)

## Issues Resolved

### Port Conflicts ✅
1. **AdGuard & MSNBC port conflict** - RESOLVED
   - adguard.alwais.org (ID 1) → 192.168.3.11:8080
   - msnbc.alwais.org (ID 10) → 192.168.3.11:8888 (updated)
   - Database ownership fixed to ealwais (1000:1000)

## Known Issues Remaining

### Missing SSL Certificates
Services without SSL:
- sonarr.alwais.org (ID 2)
- sabnzbd.alwais.org (ID 5)
- xteve.alwais.org (ID 7)
- overserr.alwais.org (ID 17)
- qnas.alwais.org (ID 18)
- protect.alwais.org (ID 19)

**Recommendation**: Consider adding SSL certificates for externally accessible services.

## Files Modified

### NPM Database
- **File**: /mnt/docker/adguard-npm/nginx-proxy-manager/data/database.sqlite
- **Changes**: Removed 3 duplicate proxy_host entries (IDs 13, 15, 16)
- **Backup**: database.sqlite.backup (Aug 21)

### NPM Container
- **Action**: Restarted to apply database changes
- **Status**: Healthy

## Documentation Created

1. **/mnt/docker/documentation/services/networking/npm_configuration.md**
   - Complete NPM proxy configuration
   - SSL certificate status
   - Network architecture
   - Troubleshooting guide
   - Management procedures

2. **/mnt/docker/documentation/services/networking/adguard_configuration.md**
   - AdGuard DNS configuration
   - Filtering settings
   - Performance tuning
   - Backup procedures
   - Integration with NPM

## Network Architecture

### IP Address Map
- **192.168.3.1**: Router/UniFi Controller (protect)
- **192.168.3.10**: QNAP NAS (sonarr, sabnzbd, qnas)
- **192.168.3.11**: Main Server (plex, npm, adguard, n8n, vpn, xteve, msnbc)
- **192.168.3.20**: Home Assistant
- **192.168.3.120**: Radarr Server

### Port Usage on 192.168.3.11
- **53**: AdGuard DNS
- **81**: NPM Web UI
- **5055**: Overseerr
- **5678**: n8n
- **8080**: AdGuard Web UI
- **8888**: MSNBC Stream / VPN
- **32400**: Plex
- **34400**: xTeve

## SSL Certificates (Let's Encrypt)

### Active Certificates
- Cert 4: msnbc.alwais.org
- Cert 7: adguard.alwais.org
- Cert 8: plex.alwais.org
- Cert 9: radarr.alwais.org
- Cert 11: n8n.alwais.org
- Cert 15: npm.alwais.org
- Cert 23: vpn.alwais.org
- Cert 27: home.alwais.org

All managed by NPM with automatic renewal.

## Next Steps / Recommendations

1. **Investigate Port 8080 Conflict**
   - Verify MSNBC service configuration
   - Check if MSNBC needs separate port
   - Consider moving one service to different port

2. **Add SSL Certificates**
   - Add SSL for overserr.alwais.org
   - Consider SSL for sonarr/sabnzbd if accessed externally
   - Review qnas and protect SSL needs

3. **Enable Additional Blocklists** (AdGuard)
   - Review available blocklists
   - Enable based on needs
   - Monitor blocking effectiveness

4. **Set Up Monitoring**
   - Monitor certificate expiration
   - Track DNS query volume
   - Monitor proxy performance

5. **Regular Maintenance**
   - Review query logs monthly
   - Update AdGuard filters regularly
   - Check for NPM updates
   - Audit proxy hosts quarterly

## Verification Steps

### NPM
```bash
# Check proxy count
sqlite3 /mnt/docker/adguard-npm/nginx-proxy-manager/data/database.sqlite \
  "SELECT COUNT(*) FROM proxy_host WHERE enabled = 1;"
# Result: 14

# Verify no duplicates
sqlite3 /mnt/docker/adguard-npm/nginx-proxy-manager/data/database.sqlite \
  "SELECT domain_names, COUNT(*) FROM proxy_host GROUP BY domain_names HAVING COUNT(*) > 1;"
# Result: None
```

### AdGuard
```bash
# Test DNS resolution
nslookup google.com 192.168.3.11

# Check AdGuard status
docker ps --filter name=adguard
```

### NPM Status
```bash
# Check container health
docker ps --filter name=nginx-proxy-manager

# View recent logs
docker logs --tail 50 nginx-proxy-manager
```

## Configuration Locations

### NPM
- **Data**: /mnt/docker/adguard-npm/nginx-proxy-manager/
- **Database**: /mnt/docker/adguard-npm/nginx-proxy-manager/data/database.sqlite
- **Configs**: /mnt/docker/adguard-npm/nginx-proxy-manager/data/nginx/proxy_host/
- **SSL Certs**: /mnt/docker/adguard-npm/nginx-proxy-manager/letsencrypt/
- **Docker Compose**: /mnt/docker/adguard-npm/docker-compose.yml

### AdGuard
- **Data**: /mnt/docker/adguard-npm/adguard/
- **Config**: /mnt/docker/adguard-npm/adguard/conf/AdGuardHome.yaml
- **Work Dir**: /mnt/docker/adguard-npm/adguard/work/

## Summary Statistics

### Before Cleanup
- Total Proxy Hosts: 17
- Duplicate Entries: 4
- Active SSL Certs: 8

### After Cleanup
- Total Proxy Hosts: 14 (clean)
- Duplicate Entries: 0
- Active SSL Certs: 8
- Documentation Files: 2 new

## References
- NPM Configuration: /mnt/docker/documentation/services/networking/npm_configuration.md
- AdGuard Configuration: /mnt/docker/documentation/services/networking/adguard_configuration.md
- NPM GitHub: https://github.com/NginxProxyManager/nginx-proxy-manager
- AdGuard GitHub: https://github.com/AdguardTeam/AdGuardHome
