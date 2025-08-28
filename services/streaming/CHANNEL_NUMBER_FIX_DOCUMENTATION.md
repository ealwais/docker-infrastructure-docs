# xTeVe Channel Number Fix Documentation

## Overview
xTeVe by default assigns sequential channel numbers (1000-1090) to imported channels, ignoring the actual channel numbers from the provider. This documentation explains how we fixed this to use the actual channel numbers (e.g., 215 for MSNBC, 140 for Comedy Central).

## The Problem
- xTeVe was showing channels with IDs like 1000, 1001, 1002, etc.
- The actual channel numbers (from good.csv) were being ignored
- This made it confusing for users and didn't match the provider's channel lineup

## The Solution

### Script: `fix_channel_numbers_live.py`
We created a Python script that:
1. Reads the correct channel numbers from `good.csv`
2. Extracts the current xepg.json from the running container
3. Updates all channel IDs to match the actual channel numbers
4. Pushes the corrected xepg.json back to the container

### Key Features
- Updates 91 channels with their correct numbers
- Works on a live running container
- Preserves all other channel settings
- Can be run automatically via cron

## Channel Number Mapping Examples

| Old (Sequential) | New (Actual) | Channel Name |
|-----------------|--------------|--------------|
| 1000 | 155 | BET SOUL |
| 1009 | 5 | CBS KEYE |
| 1035 | 215 | MSNBC |
| 1090 | 140 | Comedy Central |
| 1064 | 1804 | HBO 2 |
| 1001 | 832 | Starz Comedy |

## How It Works

### 1. Data Source: `good.csv`
The script reads the master channel list from `/mnt/docker/xteve/data/good.csv` which contains:
- XMLid: The XMLTV identifier
- Logical: The actual channel number
- GoodName: The channel name

### 2. Container Interaction
```python
# Extract current mappings
docker exec xteve-streaming cat /root/.xteve/xepg.json

# Update with corrected numbers
docker cp /tmp/xepg_updated.json xteve-streaming:/root/.xteve/xepg.json
```

### 3. Channel ID Format
The script updates the `x-channelID` field in xepg.json:
- Before: `"x-channelID": "1035"`
- After: `"x-channelID": "215"`

## Running the Fix

### Manual Execution
```bash
cd /mnt/docker/xteve
python3 fix_channel_numbers_live.py
```

### Automatic Execution (Cron)
The fix is integrated into the EPG update process to ensure channel numbers stay correct after any playlist updates.

## Integration with EPG Updates

The channel number fix is now part of the EPG update workflow:
1. EPG data is updated from Schedules Direct
2. Playlist is refreshed from provider
3. **Channel numbers are corrected** (NEW)
4. Data is synced to streaming services

## Troubleshooting

### If Channel Numbers Revert
xTeVe may regenerate mappings when:
- The container is recreated (not just restarted)
- A new playlist is imported
- The "Update" button is clicked in the Playlist tab

**Solution**: Run the fix script again or wait for the next cron execution.

### Checking Current Channel Numbers
```bash
# View first 10 channel mappings
docker exec xteve-streaming cat /root/.xteve/xepg.json | \
  grep -E '"x-channelID"|"x-name"' | head -20

# Check specific channel (e.g., MSNBC)
docker exec xteve-streaming cat /root/.xteve/xepg.json | \
  grep -A5 -B5 "MSNBC"
```

### Manual Web Interface Update
If automated fix isn't working:
1. Go to http://localhost:34400/web/
2. Navigate to Mapping tab
3. Click on each channel
4. Manually update the Ch. No. field
5. Save changes

## Files Involved

| File | Purpose |
|------|---------|
| `/mnt/docker/xteve/data/good.csv` | Master channel list with correct numbers |
| `/mnt/docker/xteve/fix_channel_numbers_live.py` | Script to fix channel numbers |
| `/root/.xteve/xepg.json` | xTeVe's channel mapping file (in container) |
| `/mnt/docker/xteve/data/xteve.m3u` | Playlist file with channel definitions |

## Why This Fix Is Needed

1. **User Experience**: Actual channel numbers are familiar to users
2. **EPG Alignment**: Ensures EPG data matches the correct channels
3. **Service Integration**: Plex/Emby expect consistent channel numbers
4. **Provider Compatibility**: Matches the channel lineup from the streaming provider

## Maintenance

The fix is designed to be maintenance-free once integrated into the cron job. However, if new channels are added:
1. Ensure they're in `good.csv` with correct Logical numbers
2. Run the fix script to update their IDs
3. The next cron execution will handle it automatically

## Success Indicators

After running the fix, you should see:
- ✓ 91 channels updated with correct numbers
- Channel numbers in xTeVe web interface match provider numbers
- EPG data correctly aligned with channels
- No more 1000-series numbers in the interface

## Related Documentation
- [README.md](README.md) - Main xTeVe setup documentation
- [MSNBC_BUFFER_SETUP.md](MSNBC_BUFFER_SETUP.md) - MSNBC GPU buffer configuration
- [CHANNEL_NUMBERING_EXPLAINED.md](CHANNEL_NUMBERING_EXPLAINED.md) - Understanding channel numbers