# Manual Channel Number Update Guide for xTeVe

## Quick Steps to Change Channel Numbers in xTeVe Interface

### Method 1: Individual Channel Edit (For a Few Channels)

1. **Open xTeVe Web Interface**
   - Navigate to http://localhost:34400/web/
   - Go to the "Mapping" tab

2. **Edit Each Channel**
   - Click on the channel row you want to edit
   - In the "Ch. No." field, change from 1000-series to actual number:
     - 1035 → 215 (MSNBC)
     - 1090 → 140 (Comedy Central)
     - 1009 → 5 (CBS KEYE)
     - 1003 → 3 (PBS KLRU)
   - Click "Save" for each channel

### Method 2: Bulk Edit via CSV Export/Import (For Many Channels)

1. **Export Current Mappings**
   - Go to Settings → Backup
   - Export the channel list as CSV

2. **Edit the CSV File**
   - Open the exported CSV
   - Find the "channel_number" or "tvg-chno" column
   - Replace 1000-series numbers with actual channel numbers

3. **Import Updated CSV**
   - Go to Settings → Restore
   - Import your edited CSV file
   - xTeVe will update all channel numbers at once

### Method 3: Direct Database Edit (Advanced)

If xTeVe stores settings in a database file, you can:

1. Stop xTeVe container:
   ```bash
   docker stop xteve-streaming
   ```

2. Edit the settings directly:
   ```bash
   docker exec -it xteve-streaming sh
   cd /root/.xteve
   # Edit the relevant JSON or DB file
   ```

3. Restart container:
   ```bash
   docker start xteve-streaming
   ```

## Channel Number Reference

Here are the correct channel numbers from your good.csv:

| Current (1000s) | Actual | Channel Name |
|-----------------|--------|--------------|
| 1003 | 3 | PBS KLRU |
| 1009 | 5 | CBS KEYE |
| 1014 | 9 | CW KNVA |
| 1035 | 215 | MSNBC |
| 1090 | 140 | Comedy Central |
| 1042 | 502 | HBO |
| 1043 | 503 | HBO2 |
| 1045 | 504 | HBO Signature |
| 1049 | 507 | HBO Family |
| 1050 | 509 | HBO Comedy |
| 1051 | 511 | HBO Zone |
| 1052 | 512 | HBO Latino |
| 1056 | 516 | HBO Latino 2 |
| 1053 | 545 | Showtime |
| 1054 | 546 | Showtime 2 |
| 1055 | 547 | Showtime Showcase |
| 1057 | 549 | Showtime Extreme |
| 1058 | 551 | Showtime Beyond |
| 1059 | 553 | Showtime Family |
| 1060 | 554 | Showtime Next |
| 1061 | 555 | Showtime Women |
| 1062 | 540 | Starz |
| 1063 | 541 | Starz Edge |
| 1064 | 542 | Starz in Black |
| 1065 | 527 | Starz Comedy |
| 1066 | 526 | Starz Kids & Family |
| 1067 | 525 | Starz Cinema |
| 1068 | 535 | Starz Encore |
| 1069 | 536 | Starz Encore Classic |
| 1070 | 537 | Starz Encore Westerns |
| 1071 | 538 | Starz Encore Suspense |
| 1072 | 539 | Starz Encore Black |
| 1073 | 534 | Starz Encore Action |
| 1074 | 559 | Epix |
| 1075 | 560 | Epix 2 |
| 1076 | 561 | Epix Hits |
| 1077 | 515 | Cinemax |
| 1078 | 517 | MoreMax |
| 1079 | 519 | ActionMax |
| 1080 | 520 | 5 StarMax |
| 1081 | 521 | OuterMax |
| 1082 | 523 | ThrillerMax |
| 1083 | 524 | MovieMax |
| 1084 | 881 | MAX |
| 1085 | 365 | Discovery+ |
| 1086 | 834 | Apple TV+ |
| 1087 | 388 | Prime Video |
| 1088 | 366 | Paramount+ Essential |
| 1089 | 389 | Netflix |

## Tips for Manual Updates

1. **Start with Most-Used Channels**: Update MSNBC (215), Comedy Central (140), and other frequently watched channels first.

2. **Save After Each Change**: Don't try to change all channels at once without saving - xTeVe might timeout.

3. **Test After Updates**: After changing numbers, test in your streaming client (Plex, Emby, etc.) to ensure they recognize the new numbers.

4. **Backup First**: Before making bulk changes, use xTeVe's backup feature to save current settings.

## Verifying Changes

After updating channel numbers:

1. Check in xTeVe Mapping tab - should show new numbers
2. Generate new M3U playlist (Playlist tab → Update)
3. Update XMLTV file (XMLTV tab → Update)
4. Test in your streaming client

## If Changes Don't Stick

If xTeVe reverts channel numbers after restart:

1. Check Settings → General → "Start Channel Number"
2. Ensure "Automatic Channel Number Assignment" is disabled
3. Consider setting up a startup script that applies your channel mappings after xTeVe starts

## Quick Command to Check Current Mappings

```bash
# See current channel mappings in container
docker exec xteve-streaming cat /root/.xteve/xepg.json | grep -E '"x-channelID"|"name"' | head -20
```

This will show you the current internal channel IDs and names to verify your changes.