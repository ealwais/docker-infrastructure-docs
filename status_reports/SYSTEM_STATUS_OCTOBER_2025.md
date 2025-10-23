# System Status - October 2025

*Last Updated: 2025-10-03*

## Current Infrastructure Status

### ✅ Claude MCP Servers (Updated 2025-10-03)

**Status:** All 13 servers operational (13/13)

#### Active MCP Servers
- **Desktop Commander** v0.2.15 - File operations, terminal processes, code search (25+ tools)
- **unifi-network-readonly** v0.1.3 - UniFi network management @ 192.168.3.1 (60+ tools)
- **chrome-devtools** v0.6.0 - Chrome browser debugging & automation (20+ tools)
- **context7** v1.0.20 - Up-to-date documentation access
- **time** v1.16.0 - Time & timezone tools
- **brave-search** v0.1.0 - Web search integration
- **sequential-thinking** v0.2.0 - Advanced reasoning workflows
- **memory** v0.6.3 - Knowledge graph storage
- **google-maps** v0.1.0 - Maps & geocoding services
- **google-drive** v0.1.0 - Google Drive access
- **filesystem** v0.2.0 - Secure file system access
- **puppeteer** v0.1.0 - Headless browser automation
- **media-stack** v1.16.0 - Media server integration

**Total Tools Available:** 158+

**Configuration:**
- Main config: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Desktop Commander: `~/Library/Application Support/Claude/Claude Extensions/`
- UniFi MCP: `/Users/ealwais/unifi-mcp-readonly/config/config.yaml`
- Logs: `~/Library/Logs/Claude/mcp-server-*.log`

**Recent Fixes (2025-10-03):**
- ✅ Desktop Commander: Installed all missing npm dependencies
- ✅ UniFi MCP: Added missing `unifi:` configuration section
- ✅ All servers confirmed operational

**See:** [MCP_SERVERS_STATUS.md](./MCP_SERVERS_STATUS.md) for complete documentation

### ✅ Working Services

#### Streaming Services (QNAP NAS - 192.168.3.10)
- **Sonarr**: Running on port 8989 (HTTP only)
  - Config: `/share/CACHEDEV1_DATA/docker/sonarr/`
  - Access: `http://192.168.3.10:8989` or `http://sonarr.alwais.org` (via AdGuard DNS)
  - Status: Operational with TV downloads configured

- **SABnzbd**: Running on port 9090 (HTTP only)
  - Config: `/share/CACHEDEV1_DATA/docker/sabnzbd/`
  - Access: `http://192.168.3.10:9090` or `http://sabnzbd.alwais.org` (via AdGuard DNS)
  - Status: Operational, HTTPS disabled for reverse proxy compatibility
  - API Key: `cab27d20b95f4dd3b48dd38f00dfad3a`

- **Radarr**: Running on port 7878
  - Status: Operational

#### Streaming Services (192.168.3.11)
- **xTeve**: Running on port 34400
  - Config: `/mnt/docker/xteve/config/` → `/root/.xteve/` in container
  - M3U Playlist: `http://192.168.3.11:34400/m3u/xteve.m3u`
  - XMLTV Guide: `http://192.168.3.11:34400/xmltv/xteve.xml`
  - Status: Fully operational with IPTV imports working
  - Active streaming confirmed from pvserver.link

- **Plex**: Running on port 32400
  - Status: Operational

#### Network Services
- **AdGuard Home**: Running on 192.168.3.11
  - Web Interface: `http://192.168.3.11:8080`
  - DNS Server: Port 53 (TCP/UDP)
  - Status: Fully operational with DNS rewrites configured
  - DNS Rewrites Active:
    - `sonarr.alwais.org` → `192.168.3.10`
    - `sabnzbd.alwais.org` → `192.168.3.11`
    - `xteve.alwais.org` → `192.168.3.11`

#### Automation
- **n8n**: Running on port 5678 (192.168.3.11)
  - Status: Operational

#### Management
- **Portainer**: Installed but exited
- **Portainer Agent**: Running on port 9001

### ❌ Removed Services

#### Nginx Proxy Manager (NPM)
- **Status**: Completely removed on 2025-10-02
- **Reason**: QNAP filesystem ACL/permission issues preventing nginx config file generation
- **Impact**:
  - All internal services now accessible via HTTP only (no SSL/HTTPS)
  - No wildcard SSL certificate for *.alwais.org
  - Direct access to services via ports instead of reverse proxy
- **Cleanup Performed**:
  - Container stopped and removed
  - Docker image deleted (1.1GB)
  - All data/config directories removed
  - docker-compose.yml cleaned up
  - Total space reclaimed: 7.7GB

## Current Configuration

### DNS Resolution
All internal services use AdGuard DNS rewrites for domain resolution:
- Services are accessed via `<service>.alwais.org` domains
- AdGuard resolves these to appropriate internal IPs
- No SSL/HTTPS - HTTP only access

### QNAP Volume Paths
**Important**: Services on QNAP use actual paths, not `/mnt/docker/`:
- **Correct Path**: `/share/CACHEDEV1_DATA/docker/<service>/`
- **Wrong Path**: `/mnt/docker/<service>/` (these directories are empty)

### Public Access
- **xTeve**: Cloudflare DNS A record points `xteve.alwais.org` to `136.62.122.180`
  - Previous broken Cloudflare Tunnel removed
  - Now uses direct A record

## Recent Changes (2025-10-02)

### Fixed Issues
1. ✅ Sonarr volume mount path corrected
2. ✅ SABnzbd volume mount path corrected
3. ✅ SABnzbd HTTPS disabled for proxy compatibility
4. ✅ xTeve DNS resolution fixed (removed broken Cloudflare Tunnel)
5. ✅ AdGuard DNS rewrites configured for internal access

### Removed
1. ❌ Nginx Proxy Manager completely removed due to QNAP filesystem issues
2. ❌ All SSL/HTTPS configuration removed
3. ❌ Wildcard certificate for *.alwais.org removed

### Outstanding Items
- [ ] Update Sonarr with correct SABnzbd API key (currently shows 403 errors)
- [ ] Consider alternative SSL/reverse proxy solution if needed (Caddy, Traefik)
- [ ] Re-evaluate internal service security without SSL

## Service Access Summary

| Service | Host | Port | URL | Protocol |
|---------|------|------|-----|----------|
| Sonarr | 192.168.3.10 | 8989 | http://sonarr.alwais.org | HTTP |
| SABnzbd | 192.168.3.10 | 9090 | http://sabnzbd.alwais.org | HTTP |
| Radarr | 192.168.3.10 | 7878 | http://192.168.3.10:7878 | HTTP |
| xTeve | 192.168.3.11 | 34400 | http://xteve.alwais.org | HTTP |
| Plex | 192.168.3.11 | 32400 | http://192.168.3.11:32400 | HTTP |
| AdGuard | 192.168.3.11 | 8080 | http://192.168.3.11:8080 | HTTP |
| n8n | 192.168.3.11 | 5678 | http://192.168.3.11:5678 | HTTP |

## Known Issues

### QNAP Filesystem ACL Issues
- Extended file attributes (`._ *` files) prevent Docker containers from modifying files
- `chown` and `chmod` operations fail with "Operation not permitted"
- Affects any service trying to write config files to `/mnt/docker/` paths
- **Workaround**: Use `/share/CACHEDEV1_DATA/docker/` paths directly

### NPM Removal Impact
- No SSL/HTTPS for internal services
- No unified reverse proxy entry point
- Services must be accessed directly by IP:PORT or via DNS rewrites

## Recommendations

### Security
- Consider VPN access for remote connectivity instead of exposing services
- Evaluate Caddy or Traefik as NPM alternatives (test on non-QNAP host first)
- Implement firewall rules to restrict service access

### Infrastructure
- Document all QNAP-specific filesystem quirks
- Consider migrating critical services off QNAP to avoid ACL issues
- Test alternative SSL termination methods
