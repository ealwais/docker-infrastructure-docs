# Service Operations Manual

## Service Start/Stop Procedures

### Home Assistant Stack
```bash
# Start all services
cd /mnt/docker/homeassistant
docker-compose up -d

# Stop all services
docker-compose down

# Restart specific service
docker-compose restart homeassistant

# View logs
docker-compose logs -f --tail=100
```

### Individual Service Management

#### Home Assistant
```bash
# Start
docker start homeassistant

# Stop (graceful)
docker exec homeassistant hassio homeassistant stop
docker stop homeassistant

# Restart
docker restart homeassistant

# Check configuration
docker exec homeassistant hass --script check_config

# Safe mode
docker exec homeassistant hass --safe-mode
```

#### Portainer
```bash
# Start
docker start portainer

# Stop
docker stop portainer

# Reset admin password
docker exec portainer /usr/local/bin/portainer --admin-password-file /data/admin-password
```

#### MQTT Mosquitto
```bash
# Start
docker start mosquitto

# Stop
docker stop mosquitto

# Test connection
docker exec mosquitto mosquitto_sub -t '$SYS/#' -C 1

# Add user
docker exec -it mosquitto mosquitto_passwd -c /mosquitto/config/passwd username
```

#### Zigbee (ser2net)
```bash
# macOS native service
# Start
ser2net -c /mnt/docker/homeassistant/ser2net.yaml -n

# Stop
pkill ser2net

# Verify port
lsof -i :9999
```

## Health Checks

### Automated Health Monitoring
```bash
#!/bin/bash
# health_check.sh

services=("homeassistant" "portainer" "mosquitto" "homeassistant-mcp")

for service in "${services[@]}"; do
    if [ "$(docker inspect -f '{{.State.Running}}' $service 2>/dev/null)" == "true" ]; then
        echo "✅ $service is running"
    else
        echo "❌ $service is not running"
        # Auto-restart if needed
        # docker start $service
    fi
done
```

### Service-Specific Health Checks

#### Home Assistant
```bash
# API Check
curl -s -o /dev/null -w "%{http_code}" http://192.168.3.20:8123/api/ | grep 200

# Component Status
docker exec homeassistant hass --script component_info

# Database Check
docker exec homeassistant sqlite3 /config/home-assistant_v2.db "SELECT count(*) FROM states;"
```

#### Plex Media Server
```bash
# Service Status
curl -s http://192.168.3.11:32400/identity | grep machineIdentifier

# Transcoding Test
curl -s http://192.168.3.11:32400/transcode/universal/ping

# GPU Usage
docker exec plex nvidia-smi
```

#### Docker Health
```bash
# System info
docker system info

# Disk usage
docker system df

# Running containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.State}}"

# Resource usage
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

## Maintenance Tasks

### Daily Tasks
```bash
# Check container health
for container in $(docker ps -q); do
    docker inspect --format='{{.Name}}: {{.State.Health.Status}}' $container
done

# Clear old logs
find /var/lib/docker/containers/ -name "*.log" -mtime +7 -delete

# Check disk space
df -h | grep -E "/$|/mnt/docker"
```

### Weekly Tasks
```bash
# Update images
docker-compose pull

# Clean unused resources
docker system prune -f

# Backup configurations
tar -czf /backup/docker-configs-$(date +%Y%m%d).tar.gz /mnt/docker/*/config/

# Check for updates
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.CreatedSince}}"
```

### Monthly Tasks
```bash
# Full system prune
docker system prune -a --volumes -f

# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Security scan
docker scan homeassistant
```

## Performance Tuning

### Container Resource Optimization
```yaml
# docker-compose.yml optimization
services:
  homeassistant:
    mem_limit: 2g
    memswap_limit: 2g
    cpu_shares: 1024
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Database Optimization
```bash
# Home Assistant DB optimization
docker exec homeassistant sqlite3 /config/home-assistant_v2.db "VACUUM;"
docker exec homeassistant sqlite3 /config/home-assistant_v2.db "REINDEX;"

# Purge old data (keep 30 days)
docker exec homeassistant hass --script recorder.purge --days 30
```

### Network Optimization
```bash
# MTU optimization
docker network create --driver bridge \
  --opt com.docker.network.driver.mtu=9000 \
  jumbo_network

# DNS optimization
docker run --dns 1.1.1.1 --dns 8.8.8.8 container_name
```

## Logging and Monitoring

### Centralized Logging
```yaml
# docker-compose.yml
logging:
  driver: syslog
  options:
    syslog-address: "udp://192.168.3.11:514"
    syslog-format: rfc5424
    tag: "{{.Name}}/{{.ID}}"
```

### Log Rotation
```bash
# /etc/logrotate.d/docker
/var/lib/docker/containers/*/*.log {
  daily
  rotate 7
  compress
  delaycompress
  missingok
  notifempty
  create 0644 root root
}
```

### Metrics Collection
```bash
# Prometheus metrics
docker run -d \
  --name node-exporter \
  --net="host" \
  --pid="host" \
  -v "/:/host:ro,rslave" \
  quay.io/prometheus/node-exporter \
  --path.rootfs=/host

# Container metrics
curl http://192.168.3.20:9001/api/endpoints/1/docker/containers/json
```

## Security Operations

### Security Scanning
```bash
# Scan for vulnerabilities
docker scan --severity high homeassistant

# Check for exposed secrets
docker exec homeassistant grep -r "password\|token\|key" /config/ | grep -v ".db"

# Audit permissions
docker exec homeassistant find /config -type f -perm 777
```

### Certificate Management
```bash
# Generate self-signed cert
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /mnt/docker/certs/key.pem \
  -out /mnt/docker/certs/cert.pem

# Check cert expiry
openssl x509 -enddate -noout -in /mnt/docker/certs/cert.pem
```

## Disaster Recovery

### Backup Procedures
```bash
# Full container backup
docker commit homeassistant homeassistant:backup-$(date +%Y%m%d)
docker save homeassistant:backup-$(date +%Y%m%d) | gzip > ha-backup-$(date +%Y%m%d).tar.gz

# Volume backup
docker run --rm -v homeassistant_data:/data -v $(pwd):/backup alpine \
  tar czf /backup/ha-data-$(date +%Y%m%d).tar.gz -C /data .
```

### Restore Procedures
```bash
# Restore container
docker load < ha-backup-20250826.tar.gz
docker run -d --name homeassistant homeassistant:backup-20250826

# Restore volume
docker run --rm -v homeassistant_data:/data -v $(pwd):/backup alpine \
  tar xzf /backup/ha-data-20250826.tar.gz -C /data
```

## Integration Points

### API Endpoints
| Service | Endpoint | Auth | Purpose |
|---------|----------|------|---------|
| Home Assistant | http://192.168.3.20:8123/api/ | Bearer Token | REST API |
| Portainer | http://192.168.3.20:9001/api/ | JWT | Management API |
| Plex | http://192.168.3.11:32400/status/sessions | X-Plex-Token | Status API |
| UniFi | https://192.168.3.1:443/api/login | Basic Auth | Controller API |

### Webhook URLs
```bash
# Home Assistant webhook
curl -X POST http://192.168.3.20:8123/api/webhook/webhook_id

# Portainer webhook
curl -X POST http://192.168.3.20:9001/api/webhooks/webhook_token
```