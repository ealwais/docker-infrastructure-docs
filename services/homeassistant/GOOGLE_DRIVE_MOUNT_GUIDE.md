# Google Drive Mount Setup Guide

This guide will help you mount Google Drive for Home Assistant backups and camera recordings.

## Prerequisites
- rclone installed ✓
- Google account with Drive access ✓
- Terminal access to your system

## Step 1: Configure rclone for Google Drive

Run this command to start the interactive setup:
```bash
rclone config
```

### Detailed Configuration Steps:

1. **Create new remote:**
   ```
   No remotes found, make a new one?
   n) New remote
   s) Set configuration password
   q) Quit config
   n/s/q> n
   ```

2. **Name your remote:**
   ```
   Enter name for new remote.
   name> gdrive
   ```

3. **Choose Google Drive:**
   ```
   Option Storage.
   Type of storage to configure.
   Choose a number from below, or type in your own value.
   [Find and enter the number for "drive" - Google Drive]
   Storage> drive
   ```

4. **Client ID (leave blank):**
   ```
   Option client_id.
   Google Application Client Id
   Setting your own is recommended.
   Enter a value. Press Enter to leave empty.
   client_id> [Press Enter]
   ```

5. **Client Secret (leave blank):**
   ```
   Option client_secret.
   OAuth Client Secret.
   Enter a value. Press Enter to leave empty.
   client_secret> [Press Enter]
   ```

6. **Choose scope:**
   ```
   Option scope.
   Comma separated list of scopes that rclone should use when requesting access from drive.
   Choose a number from below, or type in your own value.
   1 / Full access all files
   2 / Read-only access to file metadata and file contents
   3 / Access to files created by rclone only
   scope> 1
   ```

7. **Root folder ID (leave blank):**
   ```
   Option root_folder_id.
   ID of the root folder.
   Enter a value. Press Enter to leave empty.
   root_folder_id> [Press Enter]
   ```

8. **Service Account (leave blank):**
   ```
   Option service_account_file.
   Service Account Credentials JSON file path.
   Enter a value. Press Enter to leave empty.
   service_account_file> [Press Enter]
   ```

9. **Advanced config:**
   ```
   Edit advanced config?
   y) Yes
   n) No (default)
   y/n> n
   ```

10. **Auto config:**
    ```
    Use web browser to automatically authenticate rclone with remote?
    * Say Y if the machine running rclone has a web browser you can use
    * Say N if running rclone on a (remote) machine without web browser access
    y) Yes (default)
    n) No
    y/n> y
    ```

11. **Browser will open - Sign in to Google:**
    - Log in with your Google account (alwais@gmail.com)
    - Click "Allow" to grant rclone access
    - You'll see "Success! All done. Please go back to rclone."

12. **Team drive:**
    ```
    Configure this as a Shared Drive (Team Drive)?
    y) Yes
    n) No (default)
    y/n> n
    ```

13. **Confirm configuration:**
    ```
    Configuration complete.
    Options:
    - type: drive
    - scope: drive
    Keep this "gdrive" remote?
    y) Yes this is OK (default)
    e) Edit this remote
    d) Delete this remote
    y/e/d> y
    ```

14. **Exit config:**
    ```
    Current remotes:
    
    Name                 Type
    ====                 ====
    gdrive               drive
    
    e) Edit existing remote
    n) New remote
    d) Delete remote
    r) Rename remote
    c) Copy remote
    s) Set configuration password
    q) Quit config
    e/n/d/r/c/s/q> q
    ```

## Step 1.5: Verify Configuration

After configuration, verify it worked:
```bash
# List your configured remotes
rclone listremotes

# Test the connection by listing files
rclone lsd gdrive:

# Check config location
rclone config file
```

## Step 2: Create Mount Directories

```bash
# Create mount point for Google Drive
sudo mkdir -p /mnt/gdrive

# Create backup directories in Google Drive (after mounting)
mkdir -p /mnt/gdrive/HomeAssistant/backups
mkdir -p /mnt/gdrive/HomeAssistant/camera_recordings
mkdir -p /mnt/gdrive/HomeAssistant/snapshots
```

## Step 3: Test the Mount

```bash
# Test mount manually
rclone mount gdrive: /mnt/gdrive \
  --vfs-cache-mode writes \
  --allow-other \
  --daemon
```

## Step 4: Create Mount Script

Save this script as `/usr/local/bin/mount-gdrive.sh`:

```bash
#!/bin/bash
# Google Drive mount script for Home Assistant

MOUNT_POINT="/mnt/gdrive"
REMOTE_NAME="gdrive"

# Check if already mounted
if mountpoint -q "$MOUNT_POINT"; then
    echo "Google Drive already mounted at $MOUNT_POINT"
    exit 0
fi

# Create mount point if it doesn't exist
sudo mkdir -p "$MOUNT_POINT"

# Mount Google Drive
rclone mount ${REMOTE_NAME}: ${MOUNT_POINT} \
    --vfs-cache-mode writes \
    --vfs-cache-max-size 10G \
    --vfs-read-chunk-size 32M \
    --vfs-read-chunk-size-limit 2G \
    --buffer-size 32M \
    --use-mmap \
    --allow-other \
    --log-level INFO \
    --log-file /var/log/rclone-gdrive.log \
    --daemon

echo "Google Drive mounted at $MOUNT_POINT"
```

Make it executable:
```bash
sudo chmod +x /usr/local/bin/mount-gdrive.sh
```

## Step 5: Create Systemd Service (Linux) or LaunchAgent (macOS)

### For Linux systems:
Create `/etc/systemd/system/rclone-gdrive.service`:

```ini
[Unit]
Description=Google Drive mount
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/mount-gdrive.sh
ExecStop=/bin/fusermount -u /mnt/gdrive
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable rclone-gdrive
sudo systemctl start rclone-gdrive
```

### For macOS systems:
Create `~/Library/LaunchAgents/com.rclone.gdrive.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.rclone.gdrive</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/mount-gdrive.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/var/log/rclone-gdrive.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/rclone-gdrive.error.log</string>
</dict>
</plist>
```

Load the service:
```bash
launchctl load ~/Library/LaunchAgents/com.rclone.gdrive.plist
```

## Step 6: Home Assistant Integration

Add these to your Home Assistant configuration:

### Shell Commands (configuration.yaml):
```yaml
shell_command:
  backup_to_gdrive: 'cp -r /config/backups/* /mnt/gdrive/HomeAssistant/backups/'
  camera_to_gdrive: 'find /config/www/camera -name "*.mp4" -mtime -1 -exec cp {} /mnt/gdrive/HomeAssistant/camera_recordings/ \;'
```

### Automations (automations.yaml):
```yaml
# Daily backup to Google Drive
- id: 'backup_to_google_drive'
  alias: 'Backup to Google Drive'
  trigger:
    platform: time
    at: '03:00:00'
  action:
    - service: shell_command.backup_to_gdrive
    - service: notify.telegram
      data:
        message: "Home Assistant backup uploaded to Google Drive"

# Upload camera recordings
- id: 'camera_recordings_to_gdrive'
  alias: 'Upload Camera Recordings to Google Drive'
  trigger:
    platform: time_pattern
    hours: '/6'  # Every 6 hours
  action:
    - service: shell_command.camera_to_gdrive
    - service: notify.telegram
      data:
        message: "Camera recordings uploaded to Google Drive"
```

### Sensors (configuration.yaml):
```yaml
sensor:
  - platform: command_line
    name: Google Drive Status
    command: 'if mountpoint -q /mnt/gdrive; then echo "Mounted"; else echo "Not Mounted"; fi'
    scan_interval: 300

  - platform: command_line
    name: Google Drive Free Space
    command: 'df -h /mnt/gdrive | tail -1 | awk "{print $4}"'
    unit_of_measurement: 'GB'
    scan_interval: 3600
```

## Troubleshooting

1. **Check mount status:**
   ```bash
   df -h | grep gdrive
   mount | grep gdrive
   ```

2. **View logs:**
   ```bash
   tail -f /var/log/rclone-gdrive.log
   ```

3. **Unmount if needed:**
   ```bash
   fusermount -u /mnt/gdrive
   ```

4. **Test rclone connection:**
   ```bash
   rclone lsd gdrive:
   ```

## Security Notes
- The rclone config stores OAuth tokens, keep it secure
- Consider using service accounts for production
- Limit mount permissions appropriately
- Monitor bandwidth usage if on metered connection

## Quick Setup Commands

For a quick setup, run these commands in order:

```bash
# 1. Configure rclone (interactive)
rclone config

# 2. Create mount point
sudo mkdir -p /mnt/gdrive

# 3. Test mount manually
rclone mount gdrive: /mnt/gdrive --vfs-cache-mode writes --daemon

# 4. Verify mount
ls -la /mnt/gdrive

# 5. Create Home Assistant directories
mkdir -p /mnt/gdrive/HomeAssistant/{backups,camera_recordings,snapshots,logs}

# 6. Copy mount script to proper location
sudo cp /System/Volumes/Data/mnt/docker/homeassistant/mount-gdrive.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/mount-gdrive.sh
```

## Integration with Your Existing Setup

Since you have Arlo and UniFi cameras configured, here are specific automations for your setup:

```yaml
# Upload Arlo recordings to Google Drive
- id: 'arlo_recordings_to_gdrive'
  alias: 'Upload Arlo Recordings to Google Drive'
  trigger:
    - platform: state
      entity_id: binary_sensor.arlo_motion_detected
      to: 'off'
      for:
        minutes: 5
  action:
    - service: shell_command.upload_arlo_recording
    - service: notify.email
      data:
        title: "Arlo Recording Uploaded"
        message: "Latest Arlo recording saved to Google Drive"

# Upload UniFi Doorbell recordings
- id: 'doorbell_recordings_to_gdrive'
  alias: 'Upload Doorbell Recordings to Google Drive'
  trigger:
    - platform: state
      entity_id: binary_sensor.doorbell_pro_person_detected
      to: 'off'
      for:
        minutes: 2
  action:
    - service: shell_command.upload_doorbell_recording
    - service: notify.telegram
      data:
        message: "Doorbell recording uploaded to Google Drive"
```

Add to shell_command:
```yaml
shell_command:
  upload_arlo_recording: 'find /config/www/arlo -name "*.mp4" -mmin -10 -exec cp {} /mnt/gdrive/HomeAssistant/camera_recordings/arlo/ \;'
  upload_doorbell_recording: 'find /config/www/unifi -name "*.mp4" -mmin -10 -exec cp {} /mnt/gdrive/HomeAssistant/camera_recordings/doorbell/ \;'
```