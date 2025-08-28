# Docker Infrastructure - Quick Access Guide

*Last Updated: 2025-08-27*

## 🚀 Essential Documentation

### Home Assistant
- [Complete Setup & Configuration](./services/homeassistant/README.md)
- [Integrations Guide](./services/homeassistant/INTEGRATIONS_COMPLETE_GUIDE.md)
- [Dashboard Configuration](./services/homeassistant/DASHBOARD_COMPLETE_GUIDE.md)
- [System Status](./services/homeassistant/SYSTEM_STATUS_CURRENT.md)

#### Device Integrations
- [Arlo Cameras](./services/homeassistant/ARLO_SETUP_COMPLETE.md)
- [UniFi Network](./services/homeassistant/UNIFI_COMPLETE_GUIDE.md)
- [UniFi Protect](./services/homeassistant/UNIFI_PROTECT_COMPLETE.md)
- [Zigbee/ZHA](./services/homeassistant/ZIGBEE_COMPLETE_GUIDE.md)

### Streaming Services
- [xTeve Configuration](./services/streaming/XTEVE_CONFIGURATION_GUIDE.md)
- [TVHeadend Setup](./services/streaming/MSNBC_STREAM_GUIDE.md)
- [EPG Management](./services/streaming/MERGED_M3U_UPDATE_FLOW.md)
- [Channel Configuration](./services/streaming/CHANNEL_NUMBERING_EXPLAINED.md)

### Network Services
- [Nginx Proxy Manager](./services/networking/nginx-setup.md)
- [External Access Setup](./services/networking/EXTERNAL_ACCESS_SETUP.md)
- [AdGuard Configuration](./services/networking/README.md)

### Automation & Workflows
- [n8n Workflows](./services/automation/README.md)
- [Google Drive Integration](./services/automation/google-drive-setup.md)
- [GitHub Integration](./services/automation/github-setup.md)

## 📊 System Management

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

### Service URLs
- **Home Assistant**: http://localhost:8123
- **Portainer**: http://localhost:9000
- **xTeve**: http://localhost:34400
- **TVHeadend**: http://localhost:9981
- **n8n**: http://localhost:5678

## 📁 Documentation Structure

```
/mnt/docker/documentation/
├── QUICK_ACCESS.md          # This file
├── README.md                 # Main index
├── DOCUMENTATION_MAP.md      # Complete file listing
├── architecture/             # System architecture
├── services/                 # Service documentation
│   ├── homeassistant/       # Consolidated HA docs
│   ├── streaming/           # Media services
│   ├── networking/          # Network services
│   └── automation/          # Workflow automation
├── runbooks/                # Operational procedures
├── guides/                  # Setup guides
└── archive/                 # Old documentation
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