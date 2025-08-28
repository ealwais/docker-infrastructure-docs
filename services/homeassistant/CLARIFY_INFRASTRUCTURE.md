# Infrastructure Clarification Needed

Based on the configuration files, I need to clarify which device is which:

## What we know for sure:
- **192.168.3.1** - UniFi Dream Machine Pro SE (Network/DHCP)
- **192.168.3.20** - Your Mac (running Home Assistant)
- **192.168.3.120** - Synology NAS

## Need clarification:
- **192.168.3.11** - Is this:
  - [ ] QNAP NAS (currently labeled as this in config)
  - [ ] Docker Server (as you mentioned)
  - [ ] Both? (QNAP running Docker?)

The configuration shows:
1. FFmpeg commands SSH to 192.168.3.11 (suggesting media server)
2. Binary sensor calls it "QNAP NAS"
3. You mentioned .11 is the Docker server

## Questions:
1. Is the QNAP NAS also your Docker server at .11?
2. If not, what's the QNAP's IP address?
3. Where is Jellyfin/Plex running - on the Docker server (.11)?

## Current Services by IP:
- Plex is configured to use 192.168.3.20 (your Mac)
- FFmpeg monitoring points to 192.168.3.11
- Synology is at 192.168.3.120

Please clarify so I can update all configurations correctly!