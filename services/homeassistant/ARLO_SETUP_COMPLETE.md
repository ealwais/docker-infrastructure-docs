# Arlo Documentation

*Consolidated on: 2025-08-27*

## Table of Contents

1. [Aarlo Fix Notes](#aarlo_fix_notes)
2. [Arlo Fix Authentication](#arlo_fix_authentication)
3. [Arlo Push Setup](#arlo_push_setup)
4. [Arlo Setup Guide](#arlo_setup_guide)
5. [Arlo Setup Guide](#arlo_setup_guide)

---

## Aarlo Fix Notes
*Source: AARLO_FIX_NOTES.md*

## What was changed:
The original `aarlo.yaml` had several deprecated/invalid configuration options that were causing validation errors.

### Removed invalid options:
1. **`devices`** section - No longer supported
2. **`session_dir`** - No longer configurable
3. **`stream_snapshot_check`** - Deprecated
4. **`disabled`** section - Components can't be disabled this way
5. **`library`** section - No longer configurable

### Kept valid options:
- Basic auth (username/password)
- Two-factor authentication settings
- Backend configuration
- Timeouts and refresh intervals
- Media save paths
- Mode API settings

## Files:
- **`aarlo.yaml`** - Fixed configuration (active)
- **`aarlo_backup.yaml`** - Original configuration (backup)

## Next steps:
1. Restart Home Assistant
2. Check if Aarlo integration loads without errors
3. Verify cameras are accessible

## If you need the removed features:
- Motion sensitivity: Configure through Arlo app or use automations
- Battery thresholds: Create template sensors in Home Assistant
- Component disabling: Remove unwanted entities from UI instead

---

## Arlo Fix Authentication
*Source: arlo_fix_authentication.md*

## Current Issue
The Aarlo integration is failing with:
```
[ALERT] Application-specific password required
```

This means the Gmail password in `secrets.yaml` is not an app-specific password.

## Solution: Create Gmail App-Specific Password

### Step 1: Enable 2-Step Verification on Gmail
1. Go to https://myaccount.google.com/security
2. Click on "2-Step Verification"
3. Follow the setup if not already enabled

### Step 2: Generate App-Specific Password
1. Go to https://myaccount.google.com/apppasswords
2. Select app: "Mail"
3. Select device: "Other (Custom name)"
4. Enter name: "Home Assistant Arlo"
5. Click "Generate"
6. Copy the 16-character password (spaces don't matter)

### Step 3: Update secrets.yaml
Replace the current `arlo_tfa_password` with the app-specific password:

```yaml
arlo_tfa_password: "xxxx xxxx xxxx xxxx"  # New app-specific password
```

Current line to update (line 48):
```yaml
arlo_tfa_password: puulnsbmtkkpmmiw  # This needs to be replaced
```

### Step 4: Alternative - Use Push Notifications
If email 2FA continues to fail, switch to push notifications:

1. Edit `/config/aarlo.yaml`:
```yaml

tfa_source: imap
tfa_type: email


tfa_source: push
tfa_type: push
```

2. Remove or comment out the email-related secrets:
```yaml



```

3. When logging in, approve the push notification on your phone

### Step 5: Restart Home Assistant
After making changes, restart Home Assistant for them to take effect.

## Verification Steps

1. Check logs after restart:
   - Go to Settings → System → Logs
   - Search for "aarlo"
   - Look for successful authentication

2. Check entities:
   - Go to Developer Tools → States
   - Search for "aarlo"
   - You should see camera and sensor entities

## If Still Failing

1. **Clear session data:**
   ```bash
   rm -rf /config/.aarlo
   ```

2. **Enable debug logging:**
   Add to configuration.yaml:
   ```yaml
   logger:
     default: warning
     logs:
       custom_components.aarlo: debug
       pyaarlo: debug
   ```

3. **Check Arlo account:**
   - Ensure no account lockout
   - Verify credentials work on arlo.com
   - Check if 2FA is enabled on Arlo account

4. **Try legacy mode:**
   In aarlo.yaml, add:
   ```yaml
   mode_api: "v2"
   ```

## Common Issues

- **Rate limiting**: Arlo may block after too many failed attempts. Wait 30 minutes.
- **Account changes**: If you changed Arlo password, update `arlo_password` in secrets.yaml
- **Region issues**: Some regions require different backend hosts
- **Multiple accounts**: Ensure using correct account if you have multiple Arlo accounts

---

## Arlo Push Setup
*Source: arlo_push_setup.md*

## Changes Made
1. ✅ Switched from email (IMAP) to push notifications for 2FA
2. ✅ Increased timeout to 90 seconds
3. ✅ Cleared any existing session data
4. ✅ Added aarlo configuration to configuration.yaml

## Next Steps

### 1. Restart Home Assistant
Restart to apply the new configuration.

### 2. Watch for Push Notification
When Home Assistant restarts and tries to connect to Arlo:
1. You'll receive a push notification on your phone with the Arlo app
2. Open the notification
3. Approve the login request
4. Do this within 90 seconds

### 3. Check Integration
After approving the push notification:
1. Go to Settings → Devices & Services
2. Find "Arlo Camera Support"
3. It should show as configured with your cameras

### 4. If Push Fails, Try Email with Less Secure Apps
If push notifications don't work, we can try email again with these settings:

1. Enable "Less secure app access" in Gmail (not recommended long-term)
2. Or use a different email provider that supports basic IMAP
3. Or create a dedicated Gmail account just for Arlo 2FA

## Alternative: Disable 2FA Temporarily
If you continue having issues:
1. Log into arlo.com
2. Go to Settings → Login Settings
3. Temporarily disable 2FA
4. Update aarlo.yaml:
   ```yaml
   # Comment out all tfa lines
   # tfa_source: push
   # tfa_type: push
   ```
5. Re-enable 2FA after successful setup

## Monitoring
Watch the logs during restart:
- Settings → System → Logs
- Filter by "aarlo"
- Look for "login successful" message

---

## Arlo Setup Guide
*Source: arlo_setup_guide.md*

## Current Status
- ✅ `aarlo.yaml` configuration file created
- ✅ Credentials found in `secrets.yaml`
- ⚠️ Integration appears to be disabled (in packages_disabled folder)

## Required Secrets in secrets.yaml
You already have these configured:
- `arlo_username`: Your Arlo account email
- `arlo_password`: Your Arlo account password
- `arlo_tfa_host`: IMAP server for 2FA (imap.gmail.com)
- `arlo_tfa_username`: Email account for 2FA codes
- `arlo_tfa_password`: App-specific password for email

## Missing Secret
Add this to your secrets.yaml if using backend configuration:
```yaml
arlo_backend_host: https://arlo.netgear.com
```

## Installation Steps

### 1. Install Aarlo Custom Integration
The Aarlo integration is a custom component that must be installed via HACS:

1. Open HACS in Home Assistant
2. Click on "Integrations"
3. Click "+ Explore & Download Repositories"
4. Search for "Aarlo"
5. Click on it and select "Download"
6. Restart Home Assistant

### 2. Enable the Integration
Move the Arlo configuration from disabled to active:
```bash
mv /config/packages_disabled/arlo_integration.yaml /config/packages/arlo_integration.yaml
```

### 3. Create Required Directories
The integration needs these directories:
```bash
mkdir -p /config/www/arlo/media
mkdir -p /config/.aarlo
```

### 4. Configure Email App Password (Gmail)
For 2FA via email, you need an app-specific password:
1. Go to Google Account settings
2. Security → 2-Step Verification → App passwords
3. Generate a new app password for "Mail"
4. Update `arlo_tfa_password` in secrets.yaml

### 5. Add to configuration.yaml
Add this line to your configuration.yaml:
```yaml
aarlo: !include aarlo.yaml
```

### 6. Restart Home Assistant
After restart, check the logs for any authentication issues.

## Entities Created
After successful setup, you'll have:
- `camera.aarlo_*` - Camera entities
- `binary_sensor.aarlo_motion_*` - Motion sensors
- `sensor.aarlo_battery_level_*` - Battery levels
- `sensor.aarlo_signal_strength_*` - Signal strength
- `alarm_control_panel.aarlo_*` - Alarm panel

## Troubleshooting

### Common Issues:
1. **2FA Timeout**: Increase `tfa_timeout` in aarlo.yaml
2. **Session Issues**: Delete `/config/.aarlo` folder and restart
3. **Stream Timeout**: Increase `stream_timeout` value
4. **Missing Entities**: Check logs for authentication errors

### Debug Mode:
Enable verbose logging by setting in aarlo.yaml:
```yaml
verbose_debug: true
```

### Log Location:
Check logs at: Settings → System → Logs → Search for "aarlo"

## Security Notes
- Use app-specific passwords for email 2FA
- Store all credentials in secrets.yaml
- Consider using push notifications for 2FA instead of email
- Regularly update the Aarlo integration via HACS

---

## Arlo Setup Guide
*Source: ARLO_SETUP_GUIDE.md*

## Important: Security First!

**NEVER** put passwords directly in configuration files. Use secrets.yaml instead.

## Setup Steps:

1. **Add to secrets.yaml** (example format - replace with your actual values):
   ```yaml
   # Arlo credentials
   arlo_username: "your-arlo-email@example.com"
   arlo_password: "your-arlo-password"
   arlo_tfa_host: "imap.gmail.com"  # or your email provider's IMAP server
   arlo_tfa_username: "your-email@example.com"
   arlo_tfa_password: "your-app-specific-password"  # NOT your regular email password!
   ```

2. **For Gmail users:**
   - Enable 2-factor authentication on your Google account
   - Generate an app-specific password at: https://myaccount.google.com/apppasswords
   - Use this app-specific password for `arlo_tfa_password`

3. **IMAP Settings for common providers:**
   - Gmail: `imap.gmail.com`
   - Outlook: `outlook.office365.com`
   - Yahoo: `imap.mail.yahoo.com`

4. **Enable IMAP in your email:**
   - Gmail: Settings > Forwarding and POP/IMAP > Enable IMAP
   - Must be enabled for 2FA to work

5. **Restart Home Assistant** after configuration

## Troubleshooting:

- If 2FA fails, check:
  - IMAP is enabled in your email
  - App-specific password is correct
  - Firewall allows IMAP connections (port 993)
  
- Check logs:
  ```bash
  docker logs homeassistant | grep -i arlo
  ```

## Security Best Practices:

1. Use unique, strong passwords
2. Enable 2FA on all accounts
3. Use app-specific passwords for automation
4. Never share or commit secrets.yaml
5. Regularly update passwords
6. Monitor access logs

---

