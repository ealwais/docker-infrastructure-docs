# REST Sensor 404 Error Fix Summary
**Date**: 2025-08-18 18:08

## Issue Identified
The REST sensor 404 errors were caused by:
- **SABnzbd REST sensor** trying to access `http://192.168.3.20:8080/api`
- Port 8080 is actually serving a "Home Infrastructure Dashboard" webpage
- SABnzbd is not currently running on the system

## Resolution
1. **Disabled SABnzbd REST sensor** in `/config/packages/media_services.yaml`
   - Commented out lines 10-22
   - Prevents continuous 404 errors every 30 seconds

2. **Verified configuration** was valid before restart

3. **Restarted Home Assistant** to apply changes

## Result
✅ No more REST 404 errors in the logs
✅ System logs are cleaner
✅ Reduced unnecessary network requests

## If You Want to Re-enable SABnzbd
1. Install and configure SABnzbd on the correct port
2. Update the resource URL in the sensor configuration
3. Ensure the API key in secrets.yaml is correct
4. Uncomment the sensor configuration

## Other REST Sensors Status
- **Plex Status**: Working (port 32400)
- **Docker Containers Count**: May need Portainer API key verification
- **Overseerr**: Working (from overseerr_monitoring.yaml)

The system is now running without REST sensor errors.