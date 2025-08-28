# xTeVe Channel Number Fix - Automated Solution

## Problem Solved
xTeVe was assigning sequential channel numbers (1000, 1001, 1002...) instead of using the original channel numbers from the M3U playlist (155, 832, 823, etc.).

## Solution Implemented

### 1. Created Channel Fix Script
**File**: `/mnt/docker/xteve/scripts/fix_channel_numbers_direct.py`

This script:
- Parses the M3U file to extract `tvg-chno` attributes (original channel numbers)
- Reads `good.csv` as a backup source for channel numbers
- Updates xTeVe's `xepg.json` configuration file directly
- Preserves original channel numbers like 155, 832, 823, etc.
- Creates backups before making changes
- Reloads xTeVe after updates

### 2. Integrated into Nightly Automation
**Modified**: `/mnt/docker/xteve/epg_update_production.sh`

The production script now:
1. Downloads fresh M3U playlist (4 AM daily)
2. Filters to 148 Austin/cable channels
3. Updates EPG data from Schedules Direct
4. **NEW**: Automatically fixes channel numbers after update
5. Reloads xTeVe with correct channel mappings

## How It Works

### Channel Number Sources
1. **Primary**: `tvg-chno` attribute in M3U file
   ```
   #EXTINF:-1 tvg-chno="155" tvg-name="BET SOUL",155 - BET SOUL
   ```

2. **Backup**: `Logical` column in good.csv
   ```csv
   XMLid,AlternateID,GoodName,Logical,UverseName
   I10051.labs.zap2it.com,I10051.labs.zap2it.com,BET SOUL BET,155,BET
   ```

### Automatic Execution
The fix runs automatically during the nightly cron job at 4 AM:
```bash
0 4 * * * cd /mnt/docker/xteve && /bin/bash epg_update_production.sh
```

## Manual Execution

To manually fix channel numbers:
```bash
cd /mnt/docker/xteve
python3 scripts/fix_channel_numbers_direct.py
```

## Files Modified

1. **New Scripts Created**:
   - `/mnt/docker/xteve/scripts/fix_channel_numbers_direct.py` - Main fix script
   - `/mnt/docker/xteve/scripts/fix_channel_numbers.sh` - Backup bash version
   - `/mnt/docker/xteve/scripts/update_xteve_channel_numbers.py` - API-based version

2. **Modified Scripts**:
   - `/mnt/docker/xteve/epg_update_production.sh` - Added channel fix step

3. **Files Updated by Script**:
   - `/mnt/docker/xteve/config/xepg.json` - xTeVe's channel configuration
   - `/mnt/docker/xteve/config/data/xepg.json` - Container's channel config

## Verification

After the script runs, channels will have their original numbers:
- Channel 5: CBS KEYE Austin
- Channel 155: BET SOUL
- Channel 120: Discovery Channel
- Channel 832: Starz Comedy
- Channel 823: Cinemax MoreMax

Check in xTeVe web interface: http://localhost:34400

## Troubleshooting

If channel numbers are still wrong:
1. Check logs: `tail -50 /mnt/docker/xteve/logs/channel_fix_*.log`
2. Verify M3U has tvg-chno: `grep tvg-chno /mnt/docker/xteve/data/xteve.m3u | head`
3. Run manual fix: `python3 /mnt/docker/xteve/scripts/fix_channel_numbers_direct.py`
4. Restart xTeVe: `docker restart xteve-streaming`

## Benefits
- Channels appear with correct numbers in Plex/TVHeadend
- EPG data matches proper channel numbers
- No manual intervention needed
- Runs automatically with nightly updates
- Preserves channel number consistency