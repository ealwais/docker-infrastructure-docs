# AdGuard Home & Nginx Proxy Manager Setup Guide

## Services Configured

### 1. AdGuard Home (192.168.3.11)
- **Web UI**: http://192.168.3.11
- **DNS Port**: 53
- **Package**: `/packages/adguard_monitoring.yaml`

### 2. Nginx Proxy Manager (192.168.3.11:81)
- **Web UI**: http://192.168.3.11:81
- **HTTPS Proxy**: Port 443
- **Package**: `/packages/npm_monitoring.yaml`

## Entities Created

### AdGuard Entities:
- `sensor.adguard_status` - Online/Offline status
- `sensor.adguard_protection_status` - Protection enabled/disabled
- `sensor.adguard_queries_today` - Total DNS queries
- `sensor.adguard_blocked_today` - Blocked queries
- `sensor.adguard_block_percentage` - Percentage blocked
- `sensor.adguard_clients_count` - Active clients
- `sensor.adguard_average_processing_time` - DNS response time
- `binary_sensor.adguard_running` - Running status
- `binary_sensor.adguard_protection_enabled` - Protection status
- `input_boolean.adguard_bypass` - Bypass protection toggle

### NPM Entities:
- `sensor.npm_status` - Online/Offline status
- `sensor.npm_proxy_hosts_count` - Number of proxy hosts
- `sensor.npm_ssl_certificates` - SSL certificate count
- `sensor.npm_active_streams` - Active streams
- `sensor.npm_uptime` - Service uptime
- `sensor.npm_memory_usage` - Memory usage
- `sensor.npm_cpu_usage` - CPU usage
- `sensor.npm_nginx_status` - Nginx connection status
- `binary_sensor.npm_running` - Running status
- `binary_sensor.npm_healthy` - Health status
- `input_boolean.npm_maintenance_mode` - Maintenance mode
- `input_boolean.npm_enable_logging` - Debug logging

## Setup Steps

### 1. For NPM API Access (Optional):
1. Login to NPM: http://192.168.3.11:81
2. Go to Users → Add User (or use existing)
3. Generate API token
4. Update `secrets.yaml`:
   ```yaml
   npm_token: "Bearer YOUR_TOKEN_HERE"
   ```

### 2. For AdGuard Authentication (If enabled):
1. Update `secrets.yaml`:
   ```yaml
   adguard_username: admin
   adguard_password: YOUR_PASSWORD
   ```

### 3. Add Dashboard Cards:
```yaml
# AdGuard Card
type: vertical-stack
title: AdGuard Home
cards:
  - type: glance
    entities:
      - binary_sensor.adguard_running
      - sensor.adguard_protection_status
  - type: entities
    entities:
      - sensor.adguard_queries_today
      - sensor.adguard_blocked_today
      - sensor.adguard_block_percentage
      - input_boolean.adguard_bypass

# NPM Card
type: vertical-stack
title: Nginx Proxy Manager
cards:
  - type: glance
    entities:
      - binary_sensor.npm_running
      - binary_sensor.npm_healthy
  - type: entities
    entities:
      - sensor.npm_proxy_hosts_count
      - sensor.npm_ssl_certificates
      - sensor.npm_cpu_usage
      - sensor.npm_memory_usage
```

## Automations Included

1. **AdGuard Down Notification** - Alerts when AdGuard is offline for 5 minutes
2. **High Block Rate Alert** - Notifies when block rate exceeds 50%
3. **NPM Down Notification** - Alerts when NPM is offline for 5 minutes
4. **SSL Certificate Check** - Daily check at 9 AM

## Troubleshooting

### If sensors show "Unavailable":
1. Check if services are accessible:
   ```bash
   curl http://192.168.3.11/control/status
   curl http://192.168.3.11:81/api/
   ```

2. Check Home Assistant logs:
   ```bash
   docker logs homeassistant --tail 50 | grep -E "adguard|npm"
   ```

3. Verify network connectivity from HA container:
   ```bash
   docker exec homeassistant ping -c 3 192.168.3.11
   ```

### To manually test AdGuard API:
```bash
curl -s http://192.168.3.11/control/status | jq .
```

### To manually test NPM API:
```bash
curl -s http://192.168.3.11:81/api/ | jq .
```

## Next Steps

1. Check Developer Tools → States for new entities
2. Add dashboard cards (examples above)
3. Configure API tokens if needed
4. Set up additional automations as desired