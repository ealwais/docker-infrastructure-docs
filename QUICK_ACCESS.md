# Docker Infrastructure - Quick Access Guide

*Last Updated: 2025-10-13*

## 🚀 Essential Documentation

### Claude MCP Servers ⭐ NEW
- [MCP Servers Status & Configuration](./status_reports/MCP_SERVERS_STATUS.md) - **13/13 servers operational**
- [Desktop Commander Setup](./troubleshooting/DESKTOP_COMMANDER_SETUP.md) - File operations & terminal processes
- [UniFi MCP Server](./services/UNIFI_MCP_SERVER.md) - Network management (60+ tools)

### Home Assistant
- [Complete Setup & Configuration](./services/homeassistant/README.md)
- [Integrations Guide](./services/homeassistant/INTEGRATIONS_COMPLETE_GUIDE.md)
- [Dashboard Configuration](./services/homeassistant/DASHBOARD_COMPLETE_GUIDE.md)
- [System Status](./services/homeassistant/SYSTEM_STATUS_CURRENT.md)
- [Aqara Devices Status](./services/homeassistant/AQARA_DEVICES_STATUS_REPORT.md)

#### Device Integrations
- [Arlo Cameras](./services/homeassistant/ARLO_SETUP_COMPLETE.md)
- [UniFi Network](./services/homeassistant/UNIFI_COMPLETE_GUIDE.md)
- [UniFi Protect](./services/homeassistant/UNIFI_PROTECT_COMPLETE.md)
- [Zigbee/ZHA](./services/homeassistant/ZIGBEE_COMPLETE_GUIDE.md)


### Network Services
- [AdGuard Configuration](./services/networking/README.md)
- [External Access Setup](./services/networking/EXTERNAL_ACCESS_SETUP.md)
- ~~[Nginx Proxy Manager](./services/networking/nginx-setup.md)~~ *(Removed 2025-10-02)*
- [Site-to-Site VPN Guide](./services/networking/SITE_TO_SITE_CONNECTION_GUIDE.md)
- [Grandpa's Site Router](./services/networking/GRANDPA_SITE_ROUTER_GUIDE.md)
- [UniFi ATA Setup](./services/networking/UNIFI_ATA_FINDINGS.md)

### Automation & Workflows
- [n8n Workflows](./services/automation/README.md)
- [Google Drive Integration](./services/automation/google-drive-setup.md)
- [GitHub Integration](./services/automation/github-setup.md)

## 📊 System Management

### Current Status
- [System Status October 2025](./status_reports/SYSTEM_STATUS_OCTOBER_2025.md) ⚠️ **NPM Removed - HTTP Only Access**

### Operations
- [Backup & Restore](./services/homeassistant/BACKUP_AND_RESTORE_COMPLETE.md)
- [System Health](./architecture/SYSTEM_HEALTH_AND_MONITORING.md)
- [Runbooks](./runbooks/README.md)

### Optimization
- [UniFi Optimization](./services/homeassistant/UNIFI_OPTIMIZATION_GUIDE.md)
- [Performance Diagnostics](./services/homeassistant/UNIFI_DIAGNOSTICS_SUMMARY.md)

## 🔧 Common Tasks

### Quick Commands
```bash
# Check all service status
docker ps -a

# View service logs
docker logs -f <container-name>

# Restart a service
docker-compose restart <service-name>

# Update all services
docker-compose pull && docker-compose up -d

# Backup documentation
/mnt/docker/scripts/sync_documentation.sh

# Generate documentation map
python3 /mnt/docker/generate_doc_map.py
```

### Service URLs (HTTP Only - No SSL)
- **Sonarr**: http://sonarr.alwais.org (192.168.3.10:8989)
- **SABnzbd**: http://sabnzbd.alwais.org (192.168.3.10:9090)
- **AdGuard**: http://192.168.3.11:8080
- **n8n**: http://192.168.3.11:5678
- **Home Assistant**: http://192.168.3.20:8123
- **Plex**: http://192.168.3.11:32400

## 📁 Documentation Structure

```
/mnt/docker/documentation/
├── QUICK_ACCESS.md          # This file
├── README.md                 # Main index
├── DOCUMENTATION_MAP.md      # Complete file listing
├── status_reports/          # System status reports
├── scripts/                 # Utility scripts
│   └── conversion/         # Media conversion scripts
├── architecture/            # System architecture
├── services/               # Service documentation
│   ├── homeassistant/     # Consolidated HA docs
│   ├── networking/        # Network services
│   └── automation/        # Workflow automation
├── runbooks/              # Operational procedures
├── guides/                # Setup guides
├── troubleshooting/       # Debug guides
└── archive/               # Old documentation & logs
```

## 🔍 Finding Documentation

1. **By Service**: Check `/services/<service-name>/`
2. **By Topic**: Use the consolidated guides (files ending in `_COMPLETE.md`)
3. **By Date**: Check archive for historical docs
4. **Search All**: Use `grep -r "search term" /mnt/docker/documentation/`

## 📈 Statistics

- **Total Services Documented**: 15+
- **Consolidated Guides**: 12
- **Space Saved**: 122 redundant files removed
- **Last Consolidation**: 2025-08-27

## 🔄 Maintenance

- Documentation syncs to Google Drive nightly at 2 AM
- Consolidation log: `/mnt/docker/documentation/consolidation_log.txt`
- Archived files: `/mnt/docker/documentation/archive/consolidated_backup/`

---

*For complete documentation map, see [DOCUMENTATION_MAP.md](./DOCUMENTATION_MAP.md)*