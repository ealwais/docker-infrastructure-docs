# DevOps Documentation Hub

**Version**: 1.0  
**Last Updated**: August 26, 2025  
**Environment**: Home Lab Infrastructure  

## Documentation Structure

```
/mnt/claude/devops/
├── README.md                     # This file
├── MASTER_RUNBOOK.md            # Complete DevOps runbook
├── infrastructure/
│   ├── NETWORK_TOPOLOGY.md      # Network architecture and configuration
│   └── DOCKER_ENVIRONMENTS.md   # Docker setups across all hosts
├── operations/
│   └── SERVICE_OPERATIONS.md    # Service management procedures
├── troubleshooting/
│   └── TROUBLESHOOTING_PLAYBOOK.md # Issue resolution guide
├── backup/
│   └── BACKUP_AND_RECOVERY.md   # Backup strategies and DR procedures
└── reference/
    └── QUICK_REFERENCE.md       # Quick command reference

## Quick Start

### For New Engineers
1. Read [MASTER_RUNBOOK.md](MASTER_RUNBOOK.md) for system overview
2. Review [QUICK_REFERENCE.md](reference/QUICK_REFERENCE.md) for common commands
3. Bookmark [TROUBLESHOOTING_PLAYBOOK.md](troubleshooting/TROUBLESHOOTING_PLAYBOOK.md)

### For Operations
- Service management: [SERVICE_OPERATIONS.md](operations/SERVICE_OPERATIONS.md)
- Network details: [NETWORK_TOPOLOGY.md](infrastructure/NETWORK_TOPOLOGY.md)
- Docker configs: [DOCKER_ENVIRONMENTS.md](infrastructure/DOCKER_ENVIRONMENTS.md)

### For Emergencies
- Quick fixes: [QUICK_REFERENCE.md](reference/QUICK_REFERENCE.md)
- Troubleshooting: [TROUBLESHOOTING_PLAYBOOK.md](troubleshooting/TROUBLESHOOTING_PLAYBOOK.md)
- Disaster recovery: [BACKUP_AND_RECOVERY.md](backup/BACKUP_AND_RECOVERY.md)

## System Overview

### Physical Infrastructure
- **Mac Mini** (192.168.3.20) - Primary Home Assistant host
- **Docker Server** (192.168.3.11) - GPU-enabled media server
- **QNAP NAS** (192.168.3.10) - Storage and containers
- **Synology NAS** (192.168.3.120) - Backup storage
- **UniFi Dream Machine** (192.168.3.1) - Network gateway

### Core Services
- Home Assistant (Smart home automation)
- Portainer (Docker management)
- Plex/Jellyfin (Media streaming with GPU transcoding)
- MQTT (IoT messaging)
- Zigbee Bridge (Device connectivity)

### Key Features
- GPU-accelerated transcoding (NVIDIA RTX 3060)
- Distributed Docker environments
- Automated backup to NAS
- Multi-site Portainer management
- Colima Docker on macOS

## Access Information

### Primary URLs
- **Home Assistant**: http://192.168.3.20:8123
- **Portainer**: http://192.168.3.20:9001
- **Plex**: http://192.168.3.11:32400

### SSH Access
```bash
ssh ealwais@192.168.3.20    # Mac Mini
ssh admin@192.168.3.11      # Docker Server
ssh admin@192.168.3.10      # QNAP
ssh admin@192.168.3.120     # Synology
```

## Important Notes

### Known Issues
1. **Docker Sync on macOS**: Colima has file sync delays. Use `docker exec` for immediate changes.
2. **ser2net Configuration**: Running on port 9999 for Zigbee USB passthrough
3. **GPU Availability**: Ensure NVIDIA Container Toolkit is installed for transcoding

### Best Practices
1. Always check [MASTER_RUNBOOK.md](MASTER_RUNBOOK.md) before major changes
2. Follow backup procedures in [BACKUP_AND_RECOVERY.md](backup/BACKUP_AND_RECOVERY.md)
3. Use monitoring commands from [QUICK_REFERENCE.md](reference/QUICK_REFERENCE.md)
4. Document any infrastructure changes

## Maintenance Windows
- **Daily**: 3:00 AM - Automated backups
- **Weekly**: Sunday 2:00 AM - Container updates
- **Monthly**: First Sunday - Full system maintenance

## Support Contacts
- **Documentation**: This repository
- **Backups**: /mnt/backups/ and NAS locations
- **Logs**: /var/lib/docker/containers/

## Change Log
- **2025-08-26**: Complete documentation overhaul and consolidation
- **2025-08-18**: System state documentation updated
- **2025-08-15**: Infrastructure documentation created
- **2025-08-10**: Working backup established

## License
Internal documentation - Confidential