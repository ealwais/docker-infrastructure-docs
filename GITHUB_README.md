# Docker Infrastructure Documentation

Comprehensive documentation for Docker-based home infrastructure.

## 📚 Quick Navigation

- [**QUICK_ACCESS.md**](./QUICK_ACCESS.md) - Fast access to all essential documentation
- [**CLAUDE.md**](/mnt/docker/CLAUDE.md) - Context for Claude AI assistance
- [**Services Documentation**](./services/) - Service-specific guides

## 🏗️ Infrastructure Overview

- **Platform**: Ubuntu Server with Docker
- **Services**: Home Assistant, xTeve, TVHeadend, Plex, n8n, Portainer
- **Documentation**: 108 consolidated markdown files
- **Last Consolidation**: August 27, 2025

## 📁 Structure

```
documentation/
├── services/           # Service-specific documentation
│   ├── homeassistant/ # 61 files, 12 consolidated guides
│   ├── streaming/     # 23 files - xTeve, TVHeadend, Plex
│   ├── networking/    # 4 files - Nginx, AdGuard
│   └── automation/    # 4 files - n8n workflows
├── architecture/      # System-wide documentation
├── runbooks/         # Operational procedures
├── guides/           # How-to guides
└── system/           # Infrastructure documentation
```

## 🔑 Key Consolidated Guides

### Home Assistant
- [Integrations Complete Guide](./services/homeassistant/INTEGRATIONS_COMPLETE_GUIDE.md)
- [UniFi Complete Guide](./services/homeassistant/UNIFI_COMPLETE_GUIDE.md)
- [Zigbee Complete Guide](./services/homeassistant/ZIGBEE_COMPLETE_GUIDE.md)
- [Dashboard Complete Guide](./services/homeassistant/DASHBOARD_COMPLETE_GUIDE.md)
- [Backup & Restore Guide](./services/homeassistant/BACKUP_AND_RESTORE_COMPLETE.md)

## 🔄 Sync Configuration

- **GitHub**: This repository (version control)
- **Google Drive**: `Docker/Documentation/` (nightly backup)
- **Local**: `/mnt/docker/documentation/` (master copy)

## 🚀 For Claude AI

When using Claude for assistance:
1. Reference [QUICK_ACCESS.md](./QUICK_ACCESS.md) for navigation
2. Check consolidated guides (files ending in `_COMPLETE.md`)
3. Current system state in [SYSTEM_STATUS_CURRENT.md](./services/homeassistant/SYSTEM_STATUS_CURRENT.md)

## 📊 Documentation Stats

- **Total Active Files**: 108
- **Archived Files**: 446
- **Reduction**: 77% consolidation from original 527 files
- **Categories**: 5 main categories, 4 service areas

## 🛠️ Maintenance

- Documentation syncs to Google Drive nightly at 2 AM
- GitHub updates track all changes
- Consolidation scripts available in parent directory

---

*This documentation is optimized for both human reading and AI assistance.*