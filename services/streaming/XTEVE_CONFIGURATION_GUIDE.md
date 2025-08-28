# xTeVe Configuration and Operation Guide

## Overview

xTeVe is an IPTV proxy server that emulates a HDHomeRun device, allowing you to use IPTV services with software like Plex, Emby, or other media servers that support HDHomeRun tuners. This guide covers the configuration and operation of xTeVe based on the current setup.

## Directory Structure

```
/mnt/docker/xteve/          # Main xTeVe configuration directory
├── config/                 # xTeVe configuration files
│   ├── settings.json       # Main xTeVe settings
│   ├── xepg.json          # EPG mapping configuration
│   ├── data/              # M3U and XML files
│   │   ├── xteve.m3u      # Active channel playlist
│   │   ├── xteve.xml      # EPG data
│   │   └── sd.xml         # Schedules Direct EPG
│   └── backup/            # Automatic backups
├── scripts/               # Automation scripts
├── backup/                # Manual backups
├── logs/                  # Log files
└── data/                  # Working data files
    ├── good.csv           # Channel mapping database
    └── merged.m3u         # Processed playlist
```

## Docker Configuration

xTeVe runs as a Docker container defined in `/mnt/docker/plex/docker-compose.yml`:

```yaml
xteve:
  image: xteve-uid1000
  container_name: xteve
  network_mode: host
  environment:
    - TZ=America/Chicago
    - PUID=1000
    - PGID=1000
  volumes:
    - /mnt/docker/xteve/:/home/xteve/conf
    - /mnt/docker/xteve/playlists:/mnt/playlists
  restart: unless-stopped
```

## Core Configuration Files

### 1. settings.json
Main xTeVe settings file located at `/mnt/docker/xteve/config/settings.json`:

- **Port**: 34400 (Web interface: http://localhost:34400)
- **Tuners**: 6 virtual tuners
- **Buffer**: FFmpeg with 16MB buffer
- **EPG Source**: XEPG (internal mapping)
- **User Agent**: VLC/3.0.20
- **Auto Update**: Enabled at midnight (0000)

### 2. good.csv
Channel mapping database that maintains the relationship between:
- IPTV channel names
- EPG channel IDs
- Channel numbers
- Logos

### 3. M3U Playlists
- **Source**: `playlist_iufuhqfi.m3u` - Original IPTV playlist
- **Filtered**: `playlist_austin_cable_clean.m3u` - USA/Austin channels only
- **Active**: `config/data/xteve.m3u` - Currently loaded in xTeVe

## EPG (Electronic Program Guide) Setup

### Sources
1. **Schedules Direct**: Premium EPG service providing detailed guide data
   - Configuration: `tv_grab_na_dd.conf`
   - Output: `sd.xml`
   - Lineup: USA-TX66960-X (AT&T U-verse Austin)

2. **xTeVe Internal**: XEPG mapping system
   - Maps IPTV channels to EPG data
   - Configuration: `xepg.json`

### EPG Update Process
1. Downloads fresh M3U playlist from IPTV provider
2. Filters to USA/Austin channels only
3. Updates channel mappings in good.csv
4. Fetches EPG data from Schedules Direct
5. Merges EPG with channel list
6. Updates xTeVe's internal files

## Automation and Cron Jobs

### Current Schedule (via cron)
```bash
# Daily at midnight - Full update
00 00 * * * /bin/bash /mnt/docker/xteve/scripts/combined_epg_update_v2.sh

# Every 6 hours - Quick M3U update
00 06,12,18 * * * /bin/bash /mnt/docker/xteve/scripts/combined_epg_update_quick.sh

# Daily at 3am - Schedules Direct EPG update
00 03 * * * /bin/bash /mnt/docker/xteve/scripts/schedules_direct_update.sh

# Weekly Sunday 2am - Cleanup old files
00 02 * * 0 find /mnt/docker/xteve -name "*.backup_*" -mtime +14 -delete
```

### Key Scripts

1. **combined_epg_update.sh**
   - Main update script that handles both M3U and EPG
   - Downloads fresh playlist
   - Filters channels
   - Updates EPG data
   - Maintains backups

2. **configure_fresh_xteve.sh**
   - Initial setup for new xTeVe instance
   - Loads channels into xTeVe
   - Provides Plex integration instructions

3. **update_schedules_direct.sh**
   - Dedicated Schedules Direct EPG updater
   - Fetches 7 days of guide data
   - Converts to UTF-8 format

## Plex Integration

### Setup Steps
1. Open Plex: http://localhost:32400/web
2. Navigate to Settings → Live TV & DVR
3. Add HDHomeRun tuner:
   - URL: http://localhost:34400
   - Should detect "xTeVe (6 Tuners)"
4. Configure EPG:
   - Type: XMLTV
   - URL: http://localhost:34400/xmltv/xteve.xml
5. Map channels and complete setup

### Troubleshooting
- If channels show wrong content, verify mappings in xTeVe web interface
- Use Filter in xTeVe to hide duplicate channels
- Check logs in `/mnt/docker/xteve/logs/`

## Channel Management

### Adding/Removing Channels
1. Channels are managed via the filtered M3U playlist
2. Edit filtering rules in scripts or manually update good.csv
3. Run update script to apply changes

### Channel Mapping
- Automatic: Based on channel names and IDs
- Manual: Via xTeVe web interface Mapping tab
- Persistent: Stored in good.csv and xepg.json

## Backup and Recovery

### Automatic Backups
- xTeVe creates daily backups in `backup/` directory
- Keeps last 10 backups by default
- Includes full configuration and mappings

### Manual Backup
```bash
# Create backup
cd /mnt/docker/xteve
tar -czf xteve_backup_$(date +%Y%m%d).tar.gz config/ data/ good.csv

# Restore backup
tar -xzf xteve_backup_20250723.tar.gz
```

## Monitoring and Logs

### Log Files
- `combined_epg_update.log` - Main update process
- `logs/cron.log` - Cron job execution
- `logs/sd_update.log` - Schedules Direct updates
- xTeVe web interface shows real-time logs

### Health Checks
- Docker health check: http://localhost:34400/web
- Channel count verification in scripts
- File size validation for downloads

## Common Tasks

### Force EPG Update
```bash
/mnt/docker/xteve/scripts/combined_epg_update.sh
```

### Quick Channel Refresh
```bash
/mnt/docker/xteve/scripts/combined_epg_update_quick.sh
```

### Check Channel Status
```bash
grep -c "^#EXTINF" /mnt/docker/xteve/config/data/xteve.m3u
```

### View Recent Changes
```bash
tail -100 /mnt/docker/xteve/combined_epg_update.log
```

## Troubleshooting

### Common Issues

1. **No channels in Plex**
   - Verify xTeVe has channels loaded
   - Check xTeVe is accessible at http://localhost:34400
   - Re-scan for channels in Plex

2. **Missing EPG data**
   - Check Schedules Direct credentials
   - Verify sd.xml exists and has data
   - Run EPG update manually

3. **Channels play wrong content**
   - Update channel mappings in xTeVe
   - Verify good.csv mappings
   - Check for duplicate channels

4. **Update failures**
   - Check internet connectivity
   - Verify IPTV provider URL is valid
   - Review logs for specific errors

## Advanced Configuration

### Custom Channel Filtering
Edit filtering scripts in `scripts/` directory to customize which channels are included based on:
- Channel group
- Country/region
- Channel name patterns
- EPG availability

### Performance Tuning
- Adjust buffer size in settings.json
- Configure FFmpeg options for transcoding
- Set appropriate number of tuners
- Use ramdisk for temporary files

### Integration with Other Services
xTeVe can also work with:
- Emby
- Jellyfin
- TVHeadend
- NextPVR
- Any software supporting HDHomeRun protocol

## Maintenance

### Regular Tasks
- Monitor disk space for recordings
- Review logs for errors
- Update Schedules Direct subscription
- Backup configuration monthly

### Updates
- xTeVe auto-updates are enabled
- Scripts should be reviewed periodically
- Docker image updates as needed

## Support Resources

### Web Interfaces
- xTeVe: http://localhost:34400
- Plex: http://localhost:32400/web

### Configuration Paths
- Main config: `/mnt/docker/xteve/config/`
- Scripts: `/mnt/docker/xteve/scripts/`
- Logs: `/mnt/docker/xteve/logs/`

### Key Files to Monitor
- `good.csv` - Channel mappings
- `settings.json` - xTeVe configuration
- `combined_epg_update.log` - Update status

## Notes

- All times are in America/Chicago timezone
- User/Group ID 1000 is used for file permissions
- Network mode is host for direct access
- Automatic cleanup removes files older than 14 days