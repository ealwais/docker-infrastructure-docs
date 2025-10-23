# DevOps Quick Reference Card

## SSH Access
```bash
ssh ealwais@192.168.3.20     # Mac Mini (Home Assistant)
ssh admin@192.168.3.11       # Docker Server (GPU)
ssh admin@192.168.3.10       # QNAP NAS
ssh admin@192.168.3.120      # Synology NAS
ssh ubnt@192.168.3.1         # UniFi Dream Machine
```

## Service URLs
```
http://192.168.3.20:8123     # Home Assistant
http://192.168.3.20:9001     # Portainer (Mac)
https://192.168.3.11:9443    # Portainer (Server)
http://192.168.3.11:32400    # Plex Media Server
http://192.168.3.11:8096     # Jellyfin
https://192.168.3.1          # UniFi Controller
```

## Critical Ports
```
8123  - Home Assistant
9001  - Portainer
9443  - Portainer HTTPS
1883  - MQTT
9999  - Zigbee (ser2net)
3000  - MCP Server
32400 - Plex
```

## Docker Commands
```bash
docker ps                    # List running
docker logs -f container     # View logs
docker restart container     # Restart
docker stats --no-stream     # Resource usage
docker exec -it container sh # Enter container
```

## Emergency Restart
```bash
# Quick restart all
docker restart $(docker ps -q)

# Safe restart HA
docker stop homeassistant
docker start homeassistant

# Full stack restart
cd /mnt/docker/homeassistant
docker-compose restart
```

## Health Checks
```bash
# Service status
curl http://192.168.3.20:8123/api/
curl http://192.168.3.20:9001
curl http://192.168.3.20:3000/health

# Container health
docker ps --format "table {{.Names}}\t{{.Status}}"
```

## GPU Check (Docker Server)
```bash
nvidia-smi
docker exec plex nvidia-smi
```

## Backup Commands
```bash
# Quick backup
tar czf ha_backup_$(date +%Y%m%d).tar.gz /mnt/docker/homeassistant/

# Restore
tar xzf ha_backup_20250826.tar.gz -C /mnt/docker/
```

## Network Diagnostics
```bash
ping 192.168.3.1            # Gateway
nslookup google.com         # DNS
netstat -tulpn | grep :8123 # Port check
```

## Disk Space
```bash
df -h                       # Overall
docker system df            # Docker usage
docker system prune -a      # Cleanup
```

## Log Locations
```
/mnt/docker/homeassistant/home-assistant.log
/var/lib/docker/containers/*/
docker logs container_name
```

## Config Paths
```
/mnt/docker/homeassistant/    # HA config
/mnt/docker/mosquitto/        # MQTT config
/mnt/docker/portainer/        # Portainer data
```

## Common Fixes
```bash
# HA won't start
docker logs homeassistant
docker exec homeassistant hass --script check_config

# Port conflict
lsof -i :PORT
kill -9 PID

# Permission issue
docker exec container chmod -R 755 /config

# Network issue
docker network ls
docker network inspect bridge
```

## Monitoring
```bash
htop                        # System resources
docker stats                # Container resources
watch docker ps             # Container status
tail -f /path/to/log        # Live logs
```