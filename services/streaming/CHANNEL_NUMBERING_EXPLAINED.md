# xTeVe Channel Numbering System Explained

## Overview
The xTeVe interface shows multiple channel numbers that serve different purposes. Understanding these helps with channel management and troubleshooting.

## Channel Number Types

### 1. xTeVe Internal Number (Left Column - "Ch. No.")
- **Example**: 1000, 1001, 1002, 1035...
- **Purpose**: xTeVe's internal channel ID for management
- **Range**: 1000-1090 in your system
- **Assignment**: Sequential, starting at 1000
- **Used for**: Internal xTeVe operations, API calls

### 2. Original Channel Number (In Channel Name)
- **Example**: "155 - BET SOUL BET", "215 - MSNBC MSNBC"
- **Purpose**: Your cable/IPTV provider's channel number
- **Source**: From your original M3U playlist or provider lineup
- **Used for**: User recognition (what you'd see on a traditional cable box)

### 3. XMLTV ID (Right Column)
- **Example**: I10051.labs.zap2it.com, I16300.labs.zap2it.com
- **Purpose**: EPG (Electronic Program Guide) data matching
- **Format**: Station ID + ".labs.zap2it.com"
- **Source**: Schedules Direct / Zap2it database
- **Used for**: Linking channels to their program guide data

## Examples Breakdown

| xTeVe # | Channel Name | Provider # | Station ID | Purpose |
|---------|-------------|------------|------------|---------|
| 1000 | 155 - BET SOUL BET | 155 | I10051 | BET Soul on channel 155 |
| 1035 | 215 - MSNBC MSNBC | 215 | I16300 | MSNBC on channel 215 |
| 1009 | 5 - CBS KEYE Austin KEYE | 5 | I10359 | Local CBS affiliate on channel 5 |
| 1057 | 611 - ESPN 1 ESPN | 611 | I32645 | ESPN on channel 611 |

## Special Case: MSNBC (Channel 1035)

```
xTeVe Internal ID: 1035
Provider Channel:  215
Station Name:      MSNBC
XMLTV ID:         I16300.labs.zap2it.com
Stream URL:       http://192.168.3.11:8888/playlist.m3u8 (GPU-buffered)
```

## How the Numbers Work Together

1. **User Experience**:
   - You want to watch MSNBC
   - You know it as "Channel 215" (from your cable provider)
   - In Plex/client, you'd look for channel 215

2. **Behind the Scenes**:
   - xTeVe internally tracks it as channel 1035
   - EPG data comes from Schedules Direct using ID I16300
   - Stream is served from the GPU-buffered URL

3. **In Configuration Files**:
   ```csv
   # In good.csv:
   XMLid: I16300.labs.zap2it.com
   Logical: 215  (the channel number users see)
   GoodName: MSNBC MSNBC
   ```

## Channel Number Mapping Flow

```
Provider Channel (215)
    ↓
xTeVe Import (assigns 1035)
    ↓
EPG Mapping (links to I16300)
    ↓
Client Display (shows as 215 with guide data)
```

## Why Different Numbers?

### xTeVe Internal (1000+)
- Avoids conflicts with provider numbers
- Ensures unique IDs for API/management
- Sequential assignment prevents gaps

### Provider Numbers (5, 155, 215, etc.)
- Maintains user familiarity
- Matches printed channel guides
- Consistent with cable box experience

### Station IDs (I##### format)
- Universal EPG identification
- Links to program schedules
- Independent of local channel numbers

## Managing Channel Numbers

### To Change Display Number:
1. Edit the channel in xTeVe Mapping
2. Modify the "Channel Name" field
3. Update in good.csv if needed

### To Find a Channel:
- By provider number: Look in "Channel Name" column
- By xTeVe ID: Check "Ch. No." column
- By network: Search in channel name
- By EPG: Use XMLTV ID

## Common Issues

### Channel Shows Wrong Number in Plex
- Check the tvg-chno attribute in M3U
- Verify channel number in xTeVe mapping
- Regenerate M3U file

### EPG Data Missing
- Verify XMLTV ID is correct
- Check if station ID exists in Schedules Direct
- Ensure EPG update ran successfully

### Can't Find Channel
- Provider number: Search in channel name (e.g., "215")
- Network name: Search for call sign (e.g., "MSNBC")
- xTeVe number: Use the Ch. No. column

## Quick Reference

| Looking for... | Check... | Example |
|---------------|----------|---------|
| Cable channel # | Channel Name | "215 - MSNBC" |
| xTeVe ID | Ch. No. | 1035 |
| EPG link | XMLTV ID | I16300.labs.zap2it.com |
| Network | Channel Name | "MSNBC MSNBC" |

## Files Containing Mappings

1. **good.csv**: Master channel list with all mappings
2. **xteve.m3u**: Generated playlist with display numbers
3. **settings.json**: xTeVe internal configuration
4. **xepg.json**: EPG to channel mappings

---
*Last Updated: August 23, 2025*
*Related: [README.md](README.md) | [MSNBC_BUFFER_SETUP.md](MSNBC_BUFFER_SETUP.md)*