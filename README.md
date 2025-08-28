# Docker Infrastructure Documentation

## Quick Links
- [Architecture Overview](./architecture/README.md)
- [Service Documentation](./services/README.md)
- [Operational Runbooks](./runbooks/README.md)
- [Setup Guides](./guides/README.md)

## Service Status
- [Home Assistant](./services/homeassistant/README.md) - Home automation platform
- [Streaming Stack](./services/streaming/README.md) - xTeve, TVheadend, Plex
- [Network Services](./services/networking/README.md) - Nginx, AdGuard
- [Automation](./services/automation/README.md) - n8n workflows

## Recent Updates
Check [DOCUMENTATION_MAP.md](./DOCUMENTATION_MAP.md) for a complete list of all documentation.

Last reorganization: 2025-08-27

## Documentation Management
For complete details on how this documentation is managed, synced, and maintained, see:
- [**Documentation Management Guide**](./DOCUMENTATION_MANAGEMENT_GUIDE.md)

## Documentation Structure
```
/mnt/docker/documentation/
├── architecture/         # System-wide documentation
├── runbooks/            # Operational procedures  
├── services/            # Service-specific docs
│   ├── homeassistant/   # Home automation
│   ├── streaming/       # Media streaming stack
│   ├── networking/      # Network services
│   └── automation/      # Workflow automation
├── guides/              # How-to guides
└── archive/             # Deprecated docs
```

## Quick Start
1. New to the infrastructure? Start with [Quick Start Guide](./guides/quick_start.md)
2. Looking for specific service docs? Check [Service Documentation](./services/README.md)
3. Need operational procedures? See [Runbooks](./runbooks/README.md)
4. System architecture questions? Visit [Architecture](./architecture/README.md)

## Backup & Sync
- Documentation is automatically synced to Google Drive nightly
- Backup location: `/mnt/docker/documentation_backup_*`
- Sync script: `/mnt/docker/scripts/sync_documentation.sh`