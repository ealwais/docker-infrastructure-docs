# Merged.m3u Update Flow Analysis

## Current Situation

### File Locations Found
- **Primary merged.m3u**: `/mnt/docker/xteve/merged.m3u` (26.8MB, ~6,000+ channels)
- **Filtered version**: `/mnt/docker/xteve/playlist_austin_cable_clean.m3u` (28KB, ~148 channels)
- **xTeVe copy**: `/mnt/docker/xteve/data/xteve.m3u` (28KB, matches filtered version)
- **Source playlist**: `/mnt/docker/xteve/playlist_iufuhqfi.m3u` (6.1MB)

### Daily Update Process (4 AM via cron)

The `epg_update_production.sh` script performs these updates:

1. **Downloads fresh M3U** (`merged.m3u`)
   - URL: `http://pvserver.link:8080/get.php?username=iufuhqfi&password=ac122DD5aa&type=m3u_plus&output=ts`
   - Downloads full playlist with 6,000+ channels
   - Validates minimum 50 channels required
   - Creates backup before overwriting

2. **Updates EPG data** (`data/sd.xml`)
   - Uses tv_grab_na_dd (Schedules Direct)
   - Fetches 7 days of guide data
   - Converts from ISO-8859-1 to UTF-8
   - Validates XML structure

3. **Creates filtered playlist** (`data/xteve.m3u`)
   - Either runs `create_xteve_m3u.py` to generate from good.csv
   - Or copies merged.m3u if script doesn't exist
   - Currently results in 28KB file (~148 channels)

4. **Updates Docker container**
   - Copies xteve.m3u into container at `/home/xteve/conf/data/xteve.m3u`
   - Copies sd.xml into container at `/home/xteve/conf/data/sd.xml`

## Issues to Address

### 1. Size Discrepancy
- **merged.m3u**: 26.8MB with 6,000+ channels (full IPTV provider list)
- **data/xteve.m3u**: Only 28KB with ~148 channels (filtered for Austin/cable)
- This means xTeVe only sees the filtered channels, not the full list

### 2. Multiple M3U Files
- Several M3U files exist with different purposes
- Some appear to be backups or old versions
- Config directory has its own copies

### 3. Filtering Logic
- The system downloads ALL channels but only uses Austin/cable filtered subset
- This wastes bandwidth and storage
- The filtering happens AFTER download

## Recommendations for Cleanup

### Immediate Actions
1. **Verify which M3U xTeVe actually uses**
   - Check xTeVe web UI at http://localhost:34400
   - Confirm if it's using the 148-channel filtered list or full list

2. **Clean up duplicate M3U files**
   - Remove old backups (after verifying they're not needed)
   - Consolidate config copies

3. **Optimize the update process**
   - Consider filtering during download if possible
   - Or accept the full download but ensure xTeVe mappings are correct

### File Organization
```
/mnt/docker/xteve/
├── merged.m3u                    # Full provider playlist (6000+ channels)
├── playlist_austin_cable_clean.m3u # Filtered playlist (148 channels)
├── data/
│   ├── xteve.m3u                # Copy for xTeVe (currently filtered)
│   └── sd.xml                    # EPG data
└── config/
    └── merged.m3u                # Old config copy (can likely be removed)
```

### Questions to Answer
1. Do you want xTeVe to see ALL 6000+ channels or just the filtered 148?
2. Is the filtering working correctly for your needs?
3. Are there channels missing from the filtered list that you need?

## SD.XML EPG Update Details

### EPG Files Found
- **Primary EPG**: `/mnt/docker/xteve/data/sd.xml` (99MB, updated Aug 22 05:45)
- **xTeVe internal**: `/mnt/docker/xteve/data/xteve.xml` (101MB, from Aug 11)
- **Config EPG**: `/mnt/docker/xteve/config/data/xteve.xml` (18MB, updated today)
- **Old EPG backup**: `/mnt/docker/xteve/data/epg.xml` (197MB, from July)

### How SD.XML is Updated (Daily at 4 AM)

From the `epg_update_production.sh` script (lines 182-223):

1. **EPG Fetch Process**
   - Uses `tv_grab_na_dd` command (Schedules Direct grabber)
   - Fetches 7 days of program guide data
   - Downloads to temporary file first

2. **Data Processing**
   - Validates XML structure using `xmllint`
   - Converts encoding from ISO-8859-1 to UTF-8
   - Updates encoding declaration in XML header

3. **File Management**
   - Creates backup of existing sd.xml before update
   - Moves validated file to `/mnt/docker/xteve/data/sd.xml`
   - Restores backup if validation fails

4. **Error Handling**
   - 3 retry attempts with exponential backoff
   - 15-minute timeout for download
   - Validation checks before replacing existing file

### EPG Configuration
- **Config file**: Uses system's `~/.xmltv/tv_grab_na_dd.conf`
- **Data source**: Schedules Direct subscription service
- **Coverage**: 7 days of guide data
- **Channels**: Configured for Austin, TX lineup

### File Sizes & Updates
```
Current EPG files:
- sd.xml: 99MB (fresh, Aug 22 05:45 - from today's cron)
- xteve.xml (data): 101MB (stale, Aug 11 - needs update)
- xteve.xml (config): 18MB (current, Aug 22 06:35)
- epg.xml: 197MB (old backup from July)
```

### Issues with EPG Updates

1. **Multiple EPG files with different purposes**
   - sd.xml is the fresh Schedules Direct data
   - xteve.xml appears in multiple locations
   - Some files are months old

2. **Container sync**
   - Script copies sd.xml to Docker container (line 286)
   - But container may be using different EPG file

3. **Large file sizes**
   - 99MB for EPG is substantial
   - Old 197MB files should be cleaned up

## Cleanup Recommendations

### For M3U Files
1. Verify xTeVe is using the correct filtered playlist
2. Remove duplicate/old M3U files
3. Consider optimizing the download/filter process

### For EPG Files
1. Delete old EPG backups (epg.xml from July)
2. Verify which EPG file xTeVe actually uses
3. Clean up duplicate xteve.xml files
4. Ensure container uses fresh sd.xml

## Next Steps
1. Review xTeVe web interface to see active channel count
2. Decide on channel filtering strategy
3. Clean up redundant M3U files
4. Update scripts if filtering logic needs changes
5. Remove old EPG files to free up space (~400MB)