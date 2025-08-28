# xTeVe Cron Job Setup Guide

## Overview

This guide explains how to set up automated updates for xTeVe using cron jobs. The automation ensures your channel list and EPG (Electronic Program Guide) data stays current without manual intervention.

## Current Cron Setup

### Active Jobs
Currently, there is one cron job installed:
```bash
0 4 * * * /mnt/docker/xteve/epg_update_all.sh >> /mnt/docker/xteve/log/cron_epg_update.log 2>&1
```
This runs daily at 4:00 AM.

### Recommended Cron Schedule

For optimal performance, we recommend the following cron job schedule:

```bash
# Full M3U and EPG update - Daily at midnight
0 0 * * * /mnt/docker/xteve/scripts/combined_epg_update.sh >> /mnt/docker/xteve/logs/cron.log 2>&1

# Quick M3U update only - Every 6 hours (6am, noon, 6pm)
0 6,12,18 * * * /mnt/docker/xteve/scripts/combined_epg_update_quick.sh >> /mnt/docker/xteve/logs/cron.log 2>&1

# Schedules Direct EPG update - Daily at 3am
0 3 * * * /mnt/docker/xteve/scripts/update_schedules_direct.sh >> /mnt/docker/xteve/logs/sd_update.log 2>&1

# Cleanup old files - Weekly on Sunday at 2am
0 2 * * 0 find /mnt/docker/xteve -name "*.backup_*" -mtime +14 -delete >> /mnt/docker/xteve/logs/cleanup.log 2>&1

# Auto-restart xTeVe if needed - Every 30 minutes
*/30 * * * * docker ps | grep -q xteve || docker start xteve
```

## Installation Instructions

### Method 1: Using Pre-configured Crontab File

1. **Install the pre-made crontab**:
   ```bash
   cd /mnt/docker/xteve
   crontab cron/xteve_schedules_direct
   ```

2. **Verify installation**:
   ```bash
   crontab -l
   ```

### Method 2: Manual Installation

1. **Backup current crontab**:
   ```bash
   crontab -l > /mnt/docker/xteve/cron/crontab.backup.$(date +%Y%m%d)
   ```

2. **Edit crontab**:
   ```bash
   crontab -e
   ```

3. **Add the recommended jobs** (copy and paste the schedule from above)

4. **Save and exit** (in vi: press Esc, then type `:wq`)

### Method 3: Using Installation Script

```bash
# Run the installation script
cd /mnt/docker/xteve
bash scripts/install_new_cron.sh
```

## Understanding Cron Syntax

```
* * * * * command
| | | | |
| | | | +-- Day of the Week   (0-6, Sunday = 0)
| | | +---- Month             (1-12)
| | +------ Day of the Month  (1-31)
| +-------- Hour              (0-23)
+---------- Minute            (0-59)
```

### Examples:
- `0 0 * * *` = Daily at midnight
- `0 */6 * * *` = Every 6 hours
- `*/30 * * * *` = Every 30 minutes
- `0 2 * * 0` = Sunday at 2 AM

## Job Descriptions

### 1. Combined EPG Update (Midnight)
- **Script**: `combined_epg_update.sh`
- **Purpose**: Full update of channel list and EPG data
- **Actions**:
  - Downloads fresh M3U playlist
  - Filters to USA/Austin channels
  - Updates channel mappings
  - Fetches Schedules Direct EPG
  - Updates xTeVe files

### 2. Quick M3U Update (6am, 12pm, 6pm)
- **Script**: `combined_epg_update_quick.sh`
- **Purpose**: Refresh channel URLs without full EPG update
- **Actions**:
  - Downloads fresh M3U playlist
  - Updates channel URLs
  - Maintains existing EPG data

### 3. Schedules Direct Update (3am)
- **Script**: `update_schedules_direct.sh`
- **Purpose**: Dedicated EPG data refresh
- **Actions**:
  - Fetches 7 days of guide data
  - Updates channel logos
  - Processes program information

### 4. Cleanup (Sunday 2am)
- **Command**: `find` with delete
- **Purpose**: Remove old backup files
- **Actions**:
  - Deletes backups older than 14 days
  - Frees disk space

### 5. Health Check (Every 30 min)
- **Command**: Docker check and restart
- **Purpose**: Ensure xTeVe stays running
- **Actions**:
  - Checks if container is running
  - Restarts if needed

## Creating Custom Schedules

### Smaller, Incremental Updates

If you prefer smaller, more frequent updates:

```bash
# Channel list refresh - Every 2 hours
0 */2 * * * /mnt/docker/xteve/scripts/quick_channel_refresh.sh

# EPG for next 24 hours - Every 4 hours
0 */4 * * * /mnt/docker/xteve/scripts/epg_today_only.sh

# Full EPG weekly - Sunday 3am
0 3 * * 0 /mnt/docker/xteve/scripts/epg_full_week.sh
```

### Different Time Zones

Adjust times for your timezone (current: America/Chicago):

```bash
# Convert to UTC (CST+6 or CDT+5)
# Midnight CST = 6am UTC (winter) or 5am UTC (summer)
0 6 * * * /mnt/docker/xteve/scripts/combined_epg_update.sh
```

## Monitoring and Logs

### Log Locations
- Main updates: `/mnt/docker/xteve/logs/cron.log`
- EPG updates: `/mnt/docker/xteve/logs/sd_update.log`
- Cleanup: `/mnt/docker/xteve/logs/cleanup.log`

### View Recent Activity
```bash
# Last 50 lines of cron log
tail -50 /mnt/docker/xteve/logs/cron.log

# Today's updates
grep "$(date +%Y-%m-%d)" /mnt/docker/xteve/logs/cron.log

# Check for errors
grep -i error /mnt/docker/xteve/logs/*.log
```

### Email Notifications

To receive email alerts, add to crontab:
```bash
MAILTO=your-email@example.com
```

## Troubleshooting

### Jobs Not Running

1. **Check cron service**:
   ```bash
   systemctl status cron
   # or
   service cron status
   ```

2. **Verify crontab**:
   ```bash
   crontab -l
   ```

3. **Check permissions**:
   ```bash
   ls -la /mnt/docker/xteve/scripts/*.sh
   # Scripts should be executable (rwxr-xr-x)
   ```

4. **Test script manually**:
   ```bash
   bash /mnt/docker/xteve/scripts/combined_epg_update.sh
   ```

### Common Issues

1. **Permission Denied**
   ```bash
   chmod +x /mnt/docker/xteve/scripts/*.sh
   ```

2. **Path Issues**
   - Use absolute paths in scripts
   - Set PATH in crontab:
     ```bash
     PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
     ```

3. **Docker Not Found**
   ```bash
   # Add docker path
   PATH=$PATH:/usr/bin/docker
   ```

## Best Practices

1. **Always redirect output** to prevent cron emails:
   ```bash
   command >> /path/to/logfile.log 2>&1
   ```

2. **Use absolute paths** in all scripts

3. **Test scripts manually** before adding to cron

4. **Monitor logs regularly** for issues

5. **Backup crontab** before making changes

6. **Use lock files** to prevent overlapping runs:
   ```bash
   LOCKFILE=/tmp/xteve_update.lock
   [ -f $LOCKFILE ] && exit 0
   touch $LOCKFILE
   # ... script content ...
   rm -f $LOCKFILE
   ```

## Advanced Configuration

### Conditional Updates

Only update if xTeVe is running:
```bash
0 0 * * * docker ps | grep -q xteve && /mnt/docker/xteve/scripts/combined_epg_update.sh
```

### Staggered Updates

Spread load across time:
```bash
# M3U at :00
0 */6 * * * /mnt/docker/xteve/scripts/update_m3u.sh

# EPG at :30
30 */6 * * * /mnt/docker/xteve/scripts/update_epg.sh
```

### Dependency Chains

Run jobs in sequence:
```bash
0 0 * * * /mnt/docker/xteve/scripts/job1.sh && /mnt/docker/xteve/scripts/job2.sh && /mnt/docker/xteve/scripts/job3.sh
```

## Maintenance

### Regular Tasks

1. **Weekly**: Check logs for errors
2. **Monthly**: Review and optimize schedules
3. **Quarterly**: Clean up old logs
4. **Yearly**: Review and update scripts

### Log Rotation

Add to `/etc/logrotate.d/xteve`:
```
/mnt/docker/xteve/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 ealwais ealwais
}
```

## Quick Reference

### Essential Commands
```bash
# View current cron jobs
crontab -l

# Edit cron jobs
crontab -e

# Install from file
crontab /path/to/crontab.file

# Remove all cron jobs
crontab -r

# Backup crontab
crontab -l > backup.cron

# Restore crontab
crontab backup.cron
```

### Testing Updates
```bash
# Test full update
bash /mnt/docker/xteve/scripts/combined_epg_update.sh

# Test quick update
bash /mnt/docker/xteve/scripts/combined_epg_update_quick.sh

# Test EPG only
bash /mnt/docker/xteve/scripts/update_schedules_direct.sh
```

Remember: After setting up cron jobs, monitor the logs for the first few runs to ensure everything works correctly!