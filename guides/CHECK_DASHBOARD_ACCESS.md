# Dashboard Access Check

## The Issue
Files in the container and host are out of sync, which shouldn't happen with a bind mount. This suggests something unusual with the Docker setup.

## Current Dashboard URLs

Based on the configuration, your dashboards should be accessible at:

1. **Main Dashboard**: http://192.168.3.20:8123/lovelace/0
2. **Family Dashboard**: http://192.168.3.20:8123/lovelace/family
3. **Family Test NEW**: http://192.168.3.20:8123/lovelace/family-test

## IMPORTANT: Check These URLs

When you click "Family" in the sidebar, what URL does it go to?
- If it's `/lovelace/family` - that's wrong, it should be `/lovelace-family`
- If it's `/lovelace-family` - that's correct

The configuration shows dashboards are defined under `lovelace: dashboards:`, which means they get their own URL paths like `/lovelace-family`, NOT `/lovelace/family`.

## Quick Test

Try accessing these URLs directly:
1. http://192.168.3.20:8123/lovelace-family
2. http://192.168.3.20:8123/lovelace-family-test

Do these show different content than clicking the sidebar links?