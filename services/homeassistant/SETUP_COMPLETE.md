# Home Assistant Setup Complete

## Current Status ✅
- Home Assistant running in **YAML mode** (no storage mode)
- All containers healthy and running
- Dashboards configured in sidebar
- Email notifications configured
- Portainer integration ready

## Access URLs
- **Home Assistant**: http://192.168.3.20:8123
- **Local Portainer**: http://192.168.3.20:9001 (needs initial setup)
- **Docker Server Portainer**: https://192.168.3.11:9443
  - Username: `admin`
  - Password: `3=9"6oBNhs!jO#t/ucJ10qZ$E4zn~78%`
  - API Token: Already in secrets.yaml

## Configured Dashboards
1. **Docker & Portainer** (`/docker`)
2. **Tesla Energy** (`/tesla`)
3. **Ubiquiti Network** (`/ubiquiti`)

## Integrations Ready
- ✅ Gmail/Email notifications (alwais@gmail.com)
- ✅ Arlo 2FA via Gmail IMAP
- ✅ Portainer monitoring
- ✅ Docker container stats
- ✅ HACS support
- ✅ Zigbee (ZHA)
- ✅ HomeKit Bridge

## Key Files
- Configuration: `/Volumes/docker/homeassistant/configuration.yaml`
- Secrets: `/Volumes/docker/homeassistant/secrets.yaml`
- Docker Compose: `/Volumes/docker/homeassistant/docker-compose.yaml`
- Packages: `/Volumes/docker/homeassistant/packages/`
- Dashboards: `/Volumes/docker/homeassistant/dashboard_*.yaml`

## Important Notes
1. **DO NOT** add `default_config:` to configuration.yaml (forces storage mode)
2. Always use `/Volumes/docker/homeassistant/` for edits (not /mnt)
3. Portainer JWT token expires in 8 hours - refresh as needed
4. Clear browser cache if dashboards don't appear

## Next Steps
1. Set up local Portainer at http://192.168.3.20:9001
2. Configure additional integrations via UI
3. Set up Telegram bot for notifications
4. Add UniFi Protect cameras

## Troubleshooting
If dashboards disappear:
1. Check for .storage directory creation
2. Verify `lovelace: mode: yaml` in configuration
3. Clear browser cache
4. Restart Home Assistant