# API Keys and Secrets Management Guide

## Overview
This guide covers managing API keys, tokens, and passwords securely in Home Assistant.

## Secrets File Location
- **File**: `/config/secrets.yaml`
- **Host Path**: `/mnt/docker/homeassistant/secrets.yaml`
- **Usage**: Store all sensitive data here, reference with `!secret` in configs

## Current API Keys and Services

### Media Services
| Service | Key Variable | Host | Port | Status |
|---------|-------------|------|------|--------|
| Plex | `plex_token` | 192.168.3.11 | 32400 | ✅ Token ready |
| Radarr | `radarr_api_key` | 192.168.3.11 | 7878 | ✅ Key ready |
| Sonarr | `sonarr_api_key` | 192.168.3.11 | 8989 | ✅ Key ready |
| SABnzbd | `sabnzbd_api_key` | 192.168.3.11 | 8080 | ✅ Key ready |
| Overseerr | `overseerr_api_key` | - | - | ✅ Key ready |

### Network Devices
| Service | Username | Password Variable | Notes |
|---------|----------|------------------|-------|
| UniFi | `emalwais` | `unifi_password` | Same for Network & Protect |
| Synology | `ealwais` | `synology_password` | NAS access |
| QNAP | `ealwais` | `qnap_password` | Backup NAS |

### Smart Home Services
| Service | Credentials | Purpose |
|---------|------------|---------|
| Arlo | `arlo_username`, `arlo_password` | Security cameras |
| Gmail | `gmail_app_password` | Arlo 2FA via IMAP |
| Home Assistant | `ha_access_token` | API access token |

### Not Yet Configured
| Service | Variable | Notes |
|---------|----------|-------|
| Tuya | `tuya_username`, `tuya_password` | For iHome devices |
| GitHub | `github_token` | HACS API rate limits |

## Best Practices

### 1. Never Commit Secrets
```bash
# Add to .gitignore
secrets.yaml
*.key
*.pem
*.crt
```

### 2. Using Secrets in Configuration
```yaml
# Good - Using secrets reference
plex:
  host: 192.168.3.11
  token: !secret plex_token

# Bad - Hardcoded token
plex:
  host: 192.168.3.11
  token: "sZVW3KXXGNrYuxy1nRyx"  # Don't do this!
```

### 3. Generating Secure Tokens
```bash
# Generate random token
openssl rand -hex 32

# Generate base64 token
openssl rand -base64 32
```

### 4. Home Assistant Access Token
To generate a new long-lived access token:
1. Go to your Profile (bottom left)
2. Scroll to "Long-Lived Access Tokens"
3. Click "Create Token"
4. Name it descriptively (e.g., "API Access")
5. Copy immediately - won't be shown again!

### 5. App-Specific Passwords

#### Gmail/Google
1. Enable 2FA on Google account
2. Go to https://myaccount.google.com/apppasswords
3. Generate app password
4. Use for SMTP/IMAP integrations

#### Apple iCloud
1. Go to https://appleid.apple.com
2. Sign in and go to Security
3. Generate app-specific password
4. Use for iCloud integration

## Security Checklist

### File Permissions
```bash
# Check secrets.yaml permissions
ls -la /mnt/docker/homeassistant/secrets.yaml
# Should be: -rw-r--r-- (644) or more restrictive

# Fix if needed
chmod 600 /mnt/docker/homeassistant/secrets.yaml
```

### Backup Security
- ✅ Encrypt backups containing secrets
- ✅ Store backup encryption key separately
- ✅ Use different passwords for different services
- ❌ Don't use same password everywhere

### Password Rotation
Recommended rotation schedule:
- API tokens: Yearly
- Service passwords: Every 6 months
- Admin passwords: Every 3 months
- 2FA app passwords: Only when needed

## Troubleshooting

### Invalid Token Errors
1. Check for extra spaces/newlines
2. Verify token hasn't expired
3. Ensure correct token format (hex vs base64)
4. Try regenerating token

### Permission Denied
```bash
# Fix ownership
sudo chown 1000:1000 /mnt/docker/homeassistant/secrets.yaml
```

### Secrets Not Loading
```yaml
# Test secrets loading
docker exec homeassistant hass --script check_config
```

## Emergency Access

### If Locked Out
1. Access via Docker:
   ```bash
   docker exec -it homeassistant bash
   cat /config/secrets.yaml
   ```

2. Direct file access:
   ```bash
   sudo cat /mnt/docker/homeassistant/secrets.yaml
   ```

3. Restore from backup:
   ```bash
   tar -xzf backup.tar.gz secrets.yaml
   ```

### Creating Backup of Secrets
```bash
# Encrypted backup
gpg -c /mnt/docker/homeassistant/secrets.yaml

# Store securely
mv secrets.yaml.gpg /secure/location/
```

## Integration-Specific Notes

### Plex Token
Find existing token:
1. Sign into Plex Web App
2. Open browser console (F12)
3. Go to Network tab
4. Look for `X-Plex-Token` in requests

### UniFi Password
- Same password for OS, Network, and Protect
- Not the WiFi password
- Admin account required

### Arlo 2FA
- Gmail app password used for IMAP
- Check "Less secure app access"
- May need specific mailbox setup