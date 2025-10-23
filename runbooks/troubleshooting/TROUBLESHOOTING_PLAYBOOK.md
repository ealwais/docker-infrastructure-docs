# Troubleshooting Playbook

## Quick Diagnostics

### System Health Check
```bash
#!/bin/bash
# Quick system health check
echo "=== Docker Status ==="
docker ps --format "table {{.Names}}\t{{.Status}}"

echo -e "\n=== Service Health ==="
curl -s http://192.168.3.20:8123/api/ > /dev/null && echo "✅ Home Assistant" || echo "❌ Home Assistant"
curl -s http://192.168.3.20:9001 > /dev/null && echo "✅ Portainer" || echo "❌ Portainer"
curl -s http://192.168.3.20:3000/health > /dev/null && echo "✅ MCP Server" || echo "❌ MCP Server"

echo -e "\n=== Resource Usage ==="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

echo -e "\n=== Disk Space ==="
df -h | grep -E "^/dev|^Filesystem"
```

## Common Issues and Solutions

### Container Won't Start

#### Symptoms
- Container exits immediately
- Status shows "Exited (1)"

#### Diagnostics
```bash
# Check logs
docker logs --tail 50 container_name

# Inspect exit code
docker inspect container_name --format='{{.State.ExitCode}}'

# Check events
docker events --since 10m --filter container=container_name
```

#### Solutions
```bash
# Permission issues
docker exec -it container_name chmod -R 755 /config

# Port conflicts
netstat -tulpn | grep :PORT
lsof -i :PORT

# Resource limits
docker update --memory="2g" --memory-swap="2g" container_name

# Corrupted image
docker rmi image_name
docker pull image_name
```

### Network Connectivity Issues

#### Container Can't Reach Internet
```bash
# Check DNS
docker exec container_name nslookup google.com

# Check routing
docker exec container_name ip route

# Fix DNS
docker run --dns 1.1.1.1 --dns 8.8.8.8 container_name

# Check firewall
iptables -L DOCKER-USER
```

#### Container Can't Be Reached
```bash
# Check port mapping
docker port container_name

# Check iptables
iptables -t nat -L DOCKER

# Check bridge network
docker network inspect bridge

# Recreate network
docker network create custom_network
docker run --network custom_network container_name
```

### Home Assistant Specific Issues

#### Database Locked
```bash
# Stop HA
docker stop homeassistant

# Fix database
docker run --rm -v /mnt/docker/homeassistant:/config alpine \
  sqlite3 /config/home-assistant_v2.db ".backup /config/backup.db"

# Start HA
docker start homeassistant
```

#### Integration Failures
```bash
# Check logs for specific integration
docker exec homeassistant grep -i "integration_name" /config/home-assistant.log

# Reload integration
curl -X POST -H "Authorization: Bearer $TOKEN" \
  http://192.168.3.20:8123/api/services/homeassistant/reload_config_entry

# Remove integration cache
docker exec homeassistant rm -rf /config/.storage/integration_name*
```

#### Dashboard Not Loading
```bash
# Clear frontend cache
docker exec homeassistant rm -rf /config/.storage/lovelace*

# Rebuild frontend
docker exec homeassistant hass --script frontend build

# Check resources
docker exec homeassistant ls -la /config/www/
```

### Docker Issues

#### Docker Daemon Not Responding
```bash
# macOS (Colima)
colima stop
colima start

# Linux
sudo systemctl restart docker

# Check daemon
docker version
docker info
```

#### Disk Space Issues
```bash
# Clean up everything
docker system prune -a --volumes

# Remove specific volumes
docker volume rm $(docker volume ls -qf dangling=true)

# Clean build cache
docker builder prune -a

# Check disk usage
docker system df
```

#### Memory Issues
```bash
# Check memory usage
docker stats --no-stream

# Limit container memory
docker update --memory="1g" container_name

# Check OOM kills
dmesg | grep -i "killed process"
journalctl -u docker | grep -i "oom"
```

### GPU Issues (Docker Server)

#### GPU Not Available
```bash
# Check NVIDIA driver
nvidia-smi

# Check container toolkit
docker run --rm --gpus all nvidia/cuda:12.2.0-base nvidia-smi

# Fix runtime
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

#### Transcoding Failures
```bash
# Check GPU usage
docker exec plex nvidia-smi

# Check codec support
docker exec plex ffmpeg -hwaccels

# Test transcoding
docker exec plex ffmpeg -hwaccel cuda -i input.mp4 -c:v h264_nvenc output.mp4
```

### Synology/QNAP Specific Issues

#### Container Station Not Accessible
```bash
# QNAP
ssh admin@192.168.3.10
/share/CACHEDEV1_DATA/.qpkg/container-station/bin/docker ps

# Synology
ssh admin@192.168.3.120
sudo docker ps
```

#### Permission Denied
```bash
# Fix permissions
chmod -R 755 /share/Container/
chown -R admin:administrators /share/Container/
```

### Zigbee Issues

#### Device Not Connecting
```bash
# Check ser2net
ps aux | grep ser2net
lsof -i :9999

# Restart ser2net
pkill ser2net
ser2net -c /mnt/docker/homeassistant/ser2net.yaml -n

# Check USB device
ls -la /dev/tty*USB*
dmesg | grep tty
```

#### ZHA Integration Errors
```bash
# Check radio
docker exec homeassistant python3 -m zigpy_znp.tools.network_scan /dev/ttyUSB0

# Reset coordinator
docker exec homeassistant python3 -m zigpy_znp.tools.nvram_reset /dev/ttyUSB0
```

## Performance Issues

### Slow Response Times
```bash
# Check CPU usage
top -b -n 1 | head -20

# Check I/O wait
iostat -x 1 5

# Check network latency
ping -c 10 192.168.3.1

# Database optimization
docker exec homeassistant sqlite3 /config/home-assistant_v2.db "VACUUM;"
```

### High Memory Usage
```bash
# Find memory hogs
ps aux --sort=-%mem | head -10

# Check swap usage
free -h

# Clear caches
sync && echo 3 > /proc/sys/vm/drop_caches
```

## Recovery Procedures

### Emergency Container Recovery
```bash
# Stop all containers
docker stop $(docker ps -q)

# Start critical services only
docker start portainer
docker start homeassistant

# Verify and start others
for container in mosquitto homeassistant-mcp matter-server; do
    docker start $container
    sleep 5
    docker ps | grep $container || echo "Failed to start $container"
done
```

### Rollback Procedures
```bash
# List available backups
ls -la /mnt/docker/homeassistant.backup_*

# Stop current
docker stop homeassistant

# Restore backup
cp -r /mnt/docker/homeassistant.backup_20250810_083925_WORKING/* /mnt/docker/homeassistant/

# Start with restored config
docker start homeassistant
```

### Complete Reset
```bash
# WARNING: This will reset everything
docker-compose down
docker system prune -a --volumes
rm -rf /mnt/docker/*/config/*
docker-compose up -d
```

## Monitoring Commands

### Real-time Monitoring
```bash
# Watch container status
watch -n 2 'docker ps --format "table {{.Names}}\t{{.Status}}"'

# Monitor logs
docker logs -f --tail 100 homeassistant

# Resource monitoring
htop
docker stats
```

### Log Analysis
```bash
# Find errors
docker logs homeassistant 2>&1 | grep -i error | tail -20

# Count warnings
docker logs homeassistant 2>&1 | grep -i warning | wc -l

# Integration issues
docker logs homeassistant 2>&1 | grep -i "setup failed"
```

## Escalation Procedures

### Level 1: Basic Troubleshooting
1. Check container status
2. Review recent logs
3. Restart affected service
4. Verify network connectivity

### Level 2: Advanced Troubleshooting
1. Analyze system resources
2. Check for disk/memory issues
3. Review configuration files
4. Test with minimal configuration

### Level 3: System Recovery
1. Stop all services
2. Restore from backup
3. Rebuild containers if needed
4. Validate all integrations

## Contact Information

### Internal Resources
- Documentation: /mnt/claude/devops/
- Backups: /mnt/docker/*.backup_*/
- Logs: /var/lib/docker/containers/*/

### External Resources
- Home Assistant Forums: https://community.home-assistant.io
- Docker Hub: https://hub.docker.com
- UniFi Community: https://community.ui.com