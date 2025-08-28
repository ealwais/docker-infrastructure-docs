# xTeVe Documentation Index

Welcome to the xTeVe documentation. This directory contains comprehensive guides for configuring and operating xTeVe as an IPTV proxy server.

## Documentation Files

### 1. [XTEVE_CONFIGURATION_GUIDE.md](XTEVE_CONFIGURATION_GUIDE.md)
Complete configuration and operation guide covering:
- Directory structure and file locations
- Docker configuration
- Core configuration files (settings.json, good.csv)
- EPG setup with Schedules Direct
- Plex integration steps
- Channel management
- Backup and recovery procedures
- Monitoring and troubleshooting

### 2. [CRON_SETUP_GUIDE.md](CRON_SETUP_GUIDE.md)
Detailed guide for automating xTeVe updates:
- Understanding cron syntax
- Recommended cron schedules
- Installation methods
- Job descriptions and purposes
- Creating custom schedules
- Monitoring and troubleshooting cron jobs
- Best practices for automation

### 3. [setup_cron_jobs.sh](setup_cron_jobs.sh)
Interactive script for easy cron job setup:
- Multiple configuration options (recommended, minimal, frequent)
- Automatic backup of existing crontab
- Safe installation with append or replace options
- Built-in help and status checking

## Quick Start

1. **Read the main configuration guide** to understand xTeVe setup
2. **Set up automation** using the cron setup guide
3. **Use the setup script** for easy cron installation:
   ```bash
   bash /mnt/docker/xteve/docs/setup_cron_jobs.sh
   ```

## Key Locations

- **xTeVe Web Interface**: http://localhost:34400
- **Configuration**: `/mnt/docker/xteve/config/`
- **Scripts**: `/mnt/docker/xteve/scripts/`
- **Logs**: `/mnt/docker/xteve/logs/`
- **Docker Compose**: `/mnt/docker/plex/docker-compose.yml`

## Getting Help

1. Check the troubleshooting sections in each guide
2. Review logs in `/mnt/docker/xteve/logs/`
3. Access xTeVe web interface for real-time status
4. Verify Docker container status: `docker ps | grep xteve`

## Maintenance Tasks

### Daily
- Monitor automated updates via logs
- Check xTeVe web interface for channel status

### Weekly
- Review error logs
- Verify EPG data is current
- Check disk space for backups

### Monthly
- Review and optimize cron schedules
- Update channel mappings as needed
- Clean old log files

## Version Information
- xTeVe Version: 2.1.0
- Port: 34400
- User/Group: 1000
- Timezone: America/Chicago
- Update Schedule: Configurable via cron

Last Updated: 2025-07-23