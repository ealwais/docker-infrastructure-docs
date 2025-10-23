# Nginx Proxy Manager Configuration

## Overview
Nginx Proxy Manager (NPM) provides reverse proxy services for all internal services with SSL termination.

**Container**: nginx-proxy-manager
**Data Location**: /mnt/docker/adguard-npm/nginx-proxy-manager/
**Web UI**: http://192.168.3.11:81 or https://npm.alwais.org
**Domain**: alwais.org
**Last Updated**: October 1, 2025

## Current Proxy Hosts (Active)

**Total Active Hosts**: 12

### Home Automation
| Domain | Backend | SSL | Force SSL | Purpose |
|--------|---------|-----|-----------|---------|
| home.alwais.org | 192.168.3.20:8123 | Cert 27 | Yes | Home Assistant |

### Media Services
| Domain | Backend | SSL | Force SSL | Purpose |
|--------|---------|-----|-----------|---------|
| plex.alwais.org | 192.168.3.11:32400 | Cert 8 | Yes | Plex Media Server |
| sonarr.alwais.org | 192.168.3.10:8989 | Cert 6 | Yes | Sonarr TV |
| radarr.alwais.org | 192.168.3.11:7878 | Cert 9 | Yes | Radarr Movies |
| sabnzbd.alwais.org | 192.168.3.10:9090 | Cert 10 | Yes | SABnzbd |
| xteve.alwais.org | 192.168.3.11:34400 | Cert 12 | Yes | xTeve IPTV |
| msnbc.alwais.org | 192.168.3.11:8888 | Cert 4 (wildcard) | Yes | MSNBC Stream |

### Network Services
| Domain | Backend | SSL | Force SSL | Purpose |
|--------|---------|-----|-----------|---------|
| adguard.alwais.org | 192.168.3.11:8080 | Cert 7 | Yes | AdGuard Home DNS |
| npm.alwais.org | 192.168.3.11:81 | Cert 15 | Yes | NPM Web UI |
| vpn.alwais.org | 192.168.3.11:8888 | Cert 23 | Yes | VPN Service |
| protect.alwais.org | 192.168.3.1:443 | None | Yes | UniFi Protect |
| qnas.alwais.org | 192.168.3.10:443 | None | Yes | QNAP NAS |

## Recent Changes (October 1, 2025)

### Removed Services
- ❌ **n8n.alwais.org** (ID 6) - Service no longer exists
- ❌ **overserr.alwais.org** (ID 17) - Service no longer exists

### Updated Configurations
- ✅ **radarr.alwais.org** - Updated IP: 192.168.3.120 → 192.168.3.11
- ✅ **All services** - Enabled Force SSL (HTTP → HTTPS redirect)
- ✅ **protect.alwais.org** - Enabled Force SSL

### Fixed Issues
- ✅ Removed duplicate proxy entries (IDs 15, 16 cleaned up previously)
- ✅ Updated MSNBC port from 8080 to 8888
- ✅ All certificates verified and working

## SSL Certificates

### Active Certificates (Let's Encrypt)
| Cert ID | Domains | Expiry | Status |
|---------|---------|--------|--------|
| 4 | *.alwais.org (wildcard) | Valid | Used by: msnbc.alwais.org |
| 6 | sonarr.alwais.org | Valid | Active |
| 7 | adguard.alwais.org | Nov 19, 2025 | Active |
| 8 | plex.alwais.org | Valid | Active |
| 9 | radarr.alwais.org | Valid | Active |
| 10 | sabnzbd.alwais.org | Valid | Active |
| 11 | n8n.alwais.org | Valid | ⚠️ Unused (service removed) |
| 12 | xteve.alwais.org | Valid | Active |
| 15 | npm.alwais.org | Valid | Active |
| 23 | vpn.alwais.org | Valid | Active |
| 27 | home.alwais.org | Valid | Active |

**Certificate Management:**
- Auto-renewal enabled via Let's Encrypt
- All certificates managed through NPM
- SSL termination at NPM, backends use HTTP

## Network Architecture

### IP Address Map
- **192.168.3.1**: UniFi Protect
- **192.168.3.10**: QNAP NAS (sonarr, sabnzbd, qnas)
- **192.168.3.11**: Main Server (plex, npm, adguard, vpn, xteve, msnbc, radarr)
- **192.168.3.20**: Home Assistant

### Port Usage on 192.168.3.11
- **53**: AdGuard DNS
- **81**: NPM Web UI
- **7878**: Radarr
- **8080**: AdGuard Web UI
- **8888**: MSNBC Stream / VPN
- **32400**: Plex
- **34400**: xTeve

### Port Usage on 192.168.3.10
- **443**: QNAP NAS Web UI
- **8989**: Sonarr
- **9090**: SABnzbd

### Port Usage on 192.168.3.20
- **8123**: Home Assistant

## Access Methods

### Internal Access (via AdGuard DNS Rewrites)
All *.alwais.org domains resolve to internal IPs via AdGuard DNS rewrites:

```
Client → DNS query for radarr.alwais.org
      → AdGuard (192.168.3.11)
      → DNS rewrite: radarr.alwais.org → 192.168.3.11
      → Client connects to 192.168.3.11:443 (NPM)
      → NPM proxies to backend
```

### External Access (via Cloudflare)
Services with Cloudflare DNS records (accessible from internet):
- ✅ adguard.alwais.org (Cloudflare proxied)
- ✅ plex.alwais.org (Cloudflare proxied)
- ✅ home.alwais.org (Cloudflare proxied)
- ✅ msnbc.alwais.org (Cloudflare proxied)
- ✅ xteve.alwais.org (Cloudflare Tunnel)
- ✅ protect.alwais.org
- ✅ qnas.alwais.org

### Internal-Only Services
Services without external DNS (internal network only):
- radarr.alwais.org
- sonarr.alwais.org
- sabnzbd.alwais.org
- vpn.alwais.org
- npm.alwais.org

## How It Works

### SSL Termination
```
External/Internal Request (HTTPS port 443)
  → NPM receives encrypted traffic
  → NPM decrypts with Let's Encrypt certificate
  → NPM forwards to backend (HTTP, internal network)
  → Backend service responds
  → NPM encrypts response
  → Client receives HTTPS response
```

### Force SSL Redirect
All services configured with Force SSL automatically redirect:
```
http://radarr.alwais.org → https://radarr.alwais.org
```

## Database Information

**Location**: /mnt/docker/adguard-npm/nginx-proxy-manager/data/database.sqlite

**Tables**:
- proxy_host: Proxy configurations
- certificate: SSL certificates
- user: NPM users
- access_list: Access control
- audit_log: Activity logs

## Management

### NPM Web UI
- URL: https://npm.alwais.org
- Backup URL: http://192.168.3.11:81

### Common Tasks

#### Add New Proxy Host
1. Login to NPM Web UI
2. Hosts → Proxy Hosts → Add Proxy Host
3. Configure domain, forward hostname/IP, port
4. Enable SSL if needed (request Let's Encrypt)
5. Enable Force SSL
6. Save

#### Update Existing Proxy
1. Find proxy in Hosts → Proxy Hosts
2. Click Edit (three dots menu)
3. Update configuration
4. Save

#### Delete Proxy Host
1. Find proxy in Hosts → Proxy Hosts
2. Click Delete (three dots menu)
3. Confirm deletion

### Backup & Restore

#### Database Backup
```bash
# Manual backup
cp /mnt/docker/adguard-npm/nginx-proxy-manager/data/database.sqlite \
   /mnt/docker/adguard-npm/nginx-proxy-manager/data/database.sqlite.backup_$(date +%Y%m%d_%H%M%S)
```

#### Restore Database
```bash
# Stop NPM
docker stop nginx-proxy-manager

# Restore from backup
cp /mnt/docker/adguard-npm/nginx-proxy-manager/data/database.sqlite.backup_TIMESTAMP \
   /mnt/docker/adguard-npm/nginx-proxy-manager/data/database.sqlite

# Start NPM
docker start nginx-proxy-manager
```

## Monitoring

### Check NPM Status
```bash
docker ps --filter name=nginx-proxy-manager
```

### View Logs
```bash
docker logs nginx-proxy-manager --tail 50
```

### Check SSL Certificates
```bash
# Test SSL
echo | openssl s_client -connect adguard.alwais.org:443 -servername adguard.alwais.org 2>/dev/null | openssl x509 -noout -dates
```

### Check Proxy Configs
```bash
ls -la /mnt/docker/adguard-npm/nginx-proxy-manager/data/nginx/proxy_host/
```

## Security Notes

1. ✅ All public-facing services use SSL with forced HTTPS
2. ✅ Internal-only services can use HTTP (secured by network isolation)
3. ✅ SSL termination at NPM provides centralized certificate management
4. ✅ Let's Encrypt auto-renewal enabled
5. ✅ NPM Web UI accessible only internally or via VPN

## Troubleshooting

### Service Not Accessible
1. Check DNS resolution: `nslookup service.alwais.org 192.168.3.11`
2. Check NPM proxy host exists in database
3. Check backend service is running: `curl http://192.168.3.11:PORT`
4. Check NPM logs: `docker logs nginx-proxy-manager`
5. Verify SSL certificate valid

### SSL Certificate Issues
1. Check certificate expiration in NPM UI
2. Force certificate renewal if needed
3. Check Let's Encrypt rate limits
4. Verify DNS pointing to correct IP

### Backend Connection Failed
1. Verify backend service is running
2. Check backend port is correct
3. Test direct connection: `curl http://BACKEND_IP:PORT`
4. Check firewall rules

### Database Changes Not Taking Effect (502 Bad Gateway)
**Problem**: Updated proxy_host in database, but NPM still returns 502 or uses old IP.

**Cause**: Nginx config files are cached and not regenerated when database is updated directly.

**Solution**: Force NPM to regenerate config files by deleting them:
```bash
# Stop NPM
docker stop nginx-proxy-manager

# Remove the specific proxy config (replace ID with your proxy_host ID)
sudo rm /mnt/docker/adguard-npm/nginx-proxy-manager/data/nginx/proxy_host/4.conf

# Or remove all proxy configs to force full regeneration
sudo rm /mnt/docker/adguard-npm/nginx-proxy-manager/data/nginx/proxy_host/*.conf

# Start NPM (it will regenerate configs from database)
docker start nginx-proxy-manager

# Wait for NPM to start
sleep 5

# Test the proxy
curl -I http://radarr.alwais.org
```

**Example Issue (October 1, 2025)**:
- Updated radarr.alwais.org IP in database: 192.168.3.120 → 192.168.3.11
- NPM returned 502 Bad Gateway
- Checked `/mnt/docker/adguard-npm/nginx-proxy-manager/data/nginx/proxy_host/4.conf`
- Config still had old IP: `set $server "192.168.3.120";`
- Deleted config file and restarted NPM
- NPM regenerated config with correct IP from database
- Service started working immediately

**Prevention**: Always update proxy hosts via NPM Web UI instead of directly editing database when possible.

## References

- NPM GitHub: https://github.com/NginxProxyManager/nginx-proxy-manager
- Documentation: https://nginxproxymanager.com/
- Docker Compose: /mnt/docker/adguard-npm/docker-compose.yml
- Database: /mnt/docker/adguard-npm/nginx-proxy-manager/data/database.sqlite
- Cloudflare Config: /mnt/docker/documentation/services/networking/cloudflare_configuration.md
- AdGuard Config: /mnt/docker/documentation/services/networking/adguard_configuration.md
