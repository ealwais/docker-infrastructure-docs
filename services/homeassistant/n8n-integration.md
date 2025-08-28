# AdGuard Home N8N Integration Guide

## Overview

This integration allows N8N to manage AdGuard Home DNS entries programmatically, enabling automated DNS management for your local services.

## Network Configuration

AdGuard Home is connected to both the `proxy` and `n8n` Docker networks, allowing:
- Nginx proxy access for web interface
- N8N direct API access for automation

## Available API Endpoints

### From N8N workflows, use these internal URLs:

- **Base URL**: `http://adguard-home:3000`
- **Add DNS**: `POST /control/rewrite/add`
- **Remove DNS**: `POST /control/rewrite/delete`
- **List DNS**: `GET /control/rewrite/list`
- **Status**: `GET /control/status`
- **DNS Info**: `GET /control/dns_info`

## N8N Workflow Import

1. Access N8N at: http://192.168.3.11:5678
2. Go to Workflows → Import
3. Select the file: `/mnt/docker/adguard/n8n-workflows/adguard-dns-management.json`
4. The workflow provides three webhook endpoints:
   - `POST http://192.168.3.11:5678/webhook/adguard-dns-add` - Add DNS entry
   - `POST http://192.168.3.11:5678/webhook/adguard-dns-remove` - Remove DNS entry
   - `GET http://192.168.3.11:5678/webhook/adguard-dns-list` - List all DNS entries

## Example API Calls from N8N

### Add DNS Entry
```json
{
  "domain": "newservice.alwais.org",
  "ip": "192.168.1.100"
}
```

### Remove DNS Entry
```json
{
  "domain": "oldservice.alwais.org",
  "ip": "192.168.1.100"
}
```

### Update DNS Entry (Function Node)
```javascript
// First remove old entry, then add new one
const domain = "service.alwais.org";
const oldIp = "192.168.1.100";
const newIp = "192.168.1.101";

// Remove old
await $http.request({
  method: 'POST',
  url: 'http://adguard-home:3000/control/rewrite/delete',
  body: { domain: domain, answer: oldIp }
});

// Add new
await $http.request({
  method: 'POST',
  url: 'http://adguard-home:3000/control/rewrite/add',
  body: { domain: domain, answer: newIp }
});
```

## Common Use Cases

### 1. Dynamic Service Registration
When deploying new containers, automatically register their DNS entries:
- Container starts → Webhook trigger → Add DNS entry
- Container stops → Webhook trigger → Remove DNS entry

### 2. Bulk DNS Import
Import multiple DNS entries from CSV or database:
- Read CSV → Loop through entries → Add each DNS entry
- Check for duplicates before adding

### 3. DNS Health Monitoring
Regular checks of DNS entries and AdGuard status:
- Schedule trigger → Check AdGuard status → Alert if down
- Verify DNS entries resolve correctly

### 4. Automated Cleanup
Remove stale DNS entries for non-existent services:
- List all DNS entries → Check service availability → Remove if unreachable

## Helper Functions

The `/mnt/docker/adguard/n8n-scripts/` directory contains:
- `dns-api-helper.js` - Reusable functions for N8N
- `example-functions.md` - Copy-paste examples for Function nodes

## Security Considerations

- AdGuard API has no authentication on internal network
- Only accessible from within Docker networks
- External access requires nginx proxy with authentication
- Consider adding basic auth to nginx for production use

## Troubleshooting

### Connection Refused
- Ensure AdGuard container is running: `docker ps | grep adguard`
- Check network connectivity: `docker exec n8n ping adguard-home`

### DNS Entry Not Added
- Check for duplicate entries first
- Verify IP format is correct
- Domain must be valid hostname format

### N8N Can't Reach AdGuard
- Verify both containers are on `n8n` network:
  ```bash
  docker inspect adguard-home | grep -A 5 Networks
  docker inspect n8n | grep -A 5 Networks
  ```

## Advanced Integration

### Trigger DNS Updates from Git
1. GitHub webhook → N8N → Parse changes
2. Extract service configurations
3. Update DNS entries accordingly

### Integrate with Home Assistant
1. Home Assistant webhook → N8N
2. Device comes online → Add local DNS
3. Device goes offline → Remove DNS entry

### Sync with Cloud DNS
1. Schedule trigger → List local DNS
2. Compare with Cloudflare API
3. Sync differences bidirectionally