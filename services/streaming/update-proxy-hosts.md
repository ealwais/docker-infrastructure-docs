# Proxy Host Configuration Guide

## Current Services Mapping

| Current Destination | Service | Suggested Subdomain | Protocol Fix |
|-------------------|---------|-------------------|--------------|
| http://n8n:5678 | n8n Automation | n8n.alwais.org | ✓ Correct |
| https://192.168.3.11:5055 | Overseerr | overseerr.alwais.org | Change to http:// |
| https://192.168.11:32400 | Plex | plex.alwais.org | Fix IP to 192.168.3.11, use http:// |
| https://192.168.253.1:443 | Router/Gateway | router.alwais.org | Keep as is |
| https://192.168.3.120:7878 | Radarr | radarr.alwais.org | Change to http:// |
| http://192.168.3.10:8989 | Sonarr | sonarr.alwais.org | ✓ Correct |
| https://192.168.3.120:5001 | Unknown (DSM?) | nas.alwais.org | Verify if HTTPS needed |
| https://192.168.3.11:34400 | Unknown | app.alwais.org | Verify service |

## Step 1: Add DNS Records in Cloudflare

Add these A records pointing to `136.62.122.180`:
- n8n.alwais.org
- overseerr.alwais.org  
- plex.alwais.org
- router.alwais.org
- radarr.alwais.org
- sonarr.alwais.org
- nas.alwais.org
- app.alwais.org

Or add a wildcard: `*.alwais.org` → `136.62.122.180`

## Step 2: Update Each Proxy Host

For each entry in NPM:
1. Click the 3 dots → Edit
2. Add the domain name in "Domain Names" field
3. Fix the destination URL if needed (see table above)
4. Go to SSL tab
5. Select "Request a new SSL Certificate"
6. Check "Force SSL"
7. Leave "DNS Challenge" unchecked
8. Save

## Common Services Ports Reference
- Plex: 32400
- Sonarr: 8989
- Radarr: 7878
- Overseerr: 5055
- n8n: 5678
- Synology DSM: 5000/5001