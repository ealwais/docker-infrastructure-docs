# Backup and Disaster Recovery Plan

## Backup Strategy Overview

| Component | Frequency | Retention | Location | Method |
|-----------|-----------|-----------|----------|--------|
| Container Configs | Daily | 30 days | NAS + Cloud | Automated |
| Databases | Daily | 7 days | Local + NAS | Snapshot |
| Media Files | Weekly | Permanent | NAS | Rsync |
| System Images | Monthly | 3 months | NAS | Full backup |
| Volumes | Weekly | 14 days | NAS | Tar archives |

## Automated Backup Scripts

### Daily Configuration Backup
```bash
#!/bin/bash
# /opt/scripts/backup_daily.sh

BACKUP_DIR="/mnt/backups/daily"
DATE=$(date +%Y%m%d)
RETENTION_DAYS=30

# Home Assistant
docker exec homeassistant \
  tar czf /config/backup_${DATE}.tar.gz \
  --exclude='*.db' --exclude='*.log' \
  /config/

docker cp homeassistant:/config/backup_${DATE}.tar.gz \
  ${BACKUP_DIR}/ha_config_${DATE}.tar.gz

# Portainer
docker exec portainer \
  tar czf /data/backup_${DATE}.tar.gz /data/

docker cp portainer:/data/backup_${DATE}.tar.gz \
  ${BACKUP_DIR}/portainer_${DATE}.tar.gz

# Clean old backups
find ${BACKUP_DIR} -name "*.tar.gz" -mtime +${RETENTION_DAYS} -delete

# Sync to NAS
rsync -av ${BACKUP_DIR}/ admin@192.168.3.120:/volume1/backups/daily/
```

### Database Backup
```bash
#!/bin/bash
# /opt/scripts/backup_database.sh

# Home Assistant SQLite
docker exec homeassistant \
  sqlite3 /config/home-assistant_v2.db \
  ".backup /config/ha_db_$(date +%Y%m%d).db"

# Compress and move
docker exec homeassistant \
  gzip /config/ha_db_$(date +%Y%m%d).db

docker cp homeassistant:/config/ha_db_$(date +%Y%m%d).db.gz \
  /mnt/backups/databases/
```

### Volume Backup
```bash
#!/bin/bash
# /opt/scripts/backup_volumes.sh

VOLUMES=$(docker volume ls -q)
BACKUP_DIR="/mnt/backups/volumes"
DATE=$(date +%Y%m%d)

for vol in $VOLUMES; do
  docker run --rm \
    -v ${vol}:/data \
    -v ${BACKUP_DIR}:/backup \
    alpine tar czf /backup/${vol}_${DATE}.tar.gz -C /data .
done

# Sync to NAS
rsync -av ${BACKUP_DIR}/ admin@192.168.3.10:/share/backups/volumes/
```

### Full System Backup
```bash
#!/bin/bash
# /opt/scripts/backup_full.sh

DATE=$(date +%Y%m%d)
BACKUP_DIR="/mnt/backups/full"

# Stop non-critical services
docker stop $(docker ps -q --filter "label=non-critical")

# Create full backup
tar czf ${BACKUP_DIR}/docker_full_${DATE}.tar.gz \
  --exclude='*.log' \
  --exclude='transcode/*' \
  /mnt/docker/

# Backup docker images
docker save $(docker images -q) | \
  gzip > ${BACKUP_DIR}/docker_images_${DATE}.tar.gz

# Start services
docker start $(docker ps -aq)

# Sync to NAS with verification
rsync -avz --checksum ${BACKUP_DIR}/ \
  admin@192.168.3.120:/volume1/backups/full/
```

## Recovery Procedures

### Quick Recovery (Service Failure)

#### Single Container Recovery
```bash
# Stop failed container
docker stop homeassistant

# Restore config from backup
tar xzf /mnt/backups/daily/ha_config_20250826.tar.gz \
  -C /mnt/docker/homeassistant/

# Start container
docker start homeassistant

# Verify
docker logs --tail 50 homeassistant
```

#### Database Recovery
```bash
# Stop service
docker stop homeassistant

# Restore database
docker cp /mnt/backups/databases/ha_db_20250826.db.gz \
  homeassistant:/config/

docker exec homeassistant gunzip /config/ha_db_20250826.db.gz
docker exec homeassistant mv /config/ha_db_20250826.db \
  /config/home-assistant_v2.db

# Start service
docker start homeassistant
```

### Full System Recovery

#### Phase 1: Core Services
```bash
# Install Docker (if needed)
curl -fsSL https://get.docker.com | sh

# Restore Portainer first
docker run -d \
  --name portainer \
  --restart=always \
  -p 9001:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

# Restore Portainer data
docker stop portainer
tar xzf /mnt/backups/daily/portainer_20250826.tar.gz \
  -C /var/lib/docker/volumes/portainer_data/_data/
docker start portainer
```

#### Phase 2: Network Services
```bash
# Restore network configuration
docker network create --driver bridge custom_bridge
docker network create --driver macvlan \
  --subnet=192.168.3.0/24 \
  --gateway=192.168.3.1 \
  -o parent=eth0 lan_network

# Start MQTT
docker run -d \
  --name mosquitto \
  --restart=unless-stopped \
  -p 1883:1883 \
  -v /mnt/docker/mosquitto:/mosquitto \
  eclipse-mosquitto:latest
```

#### Phase 3: Main Services
```bash
# Restore Home Assistant
tar xzf /mnt/backups/full/docker_full_20250826.tar.gz -C /

docker run -d \
  --name homeassistant \
  --restart=unless-stopped \
  --network=host \
  -v /mnt/docker/homeassistant:/config \
  -e TZ=America/Chicago \
  homeassistant/home-assistant:stable

# Verify recovery
sleep 30
curl http://192.168.3.20:8123/api/ || echo "HA not responding"
```

### Disaster Recovery (Complete System Loss)

#### Step 1: Hardware Recovery
```bash
# Boot from recovery media
# Mount backup drive
mount /dev/sdb1 /mnt/recovery

# Restore base system
tar xzf /mnt/recovery/system_backup.tar.gz -C /
```

#### Step 2: Docker Installation
```bash
# macOS (Colima)
brew install colima docker
colima start --cpu 4 --memory 8 --disk 100

# Linux
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker
```

#### Step 3: Data Recovery
```bash
# Restore all Docker data
tar xzf /mnt/recovery/docker_full_20250826.tar.gz -C /

# Load Docker images
gunzip -c /mnt/recovery/docker_images_20250826.tar.gz | docker load

# Restore volumes
for archive in /mnt/recovery/volumes/*.tar.gz; do
  vol=$(basename $archive | cut -d_ -f1)
  docker volume create $vol
  docker run --rm -v $vol:/data -v /mnt/recovery/volumes:/backup \
    alpine tar xzf /backup/$(basename $archive) -C /data
done
```

#### Step 4: Service Restoration
```bash
# Start services in order
docker-compose -f /mnt/docker/homeassistant/docker-compose.yml up -d

# Verify all services
docker ps --format "table {{.Names}}\t{{.Status}}"
```

## Backup Verification

### Automated Verification Script
```bash
#!/bin/bash
# /opt/scripts/verify_backups.sh

BACKUP_DIR="/mnt/backups"
ERRORS=0

# Check backup age
for type in daily weekly monthly; do
  latest=$(find ${BACKUP_DIR}/${type} -name "*.tar.gz" -mtime -2 | head -1)
  if [ -z "$latest" ]; then
    echo "ERROR: No recent ${type} backup found"
    ((ERRORS++))
  else
    echo "OK: ${type} backup found: $(basename $latest)"
  fi
done

# Verify integrity
for backup in ${BACKUP_DIR}/daily/*.tar.gz; do
  tar tzf $backup > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "ERROR: Corrupted backup: $backup"
    ((ERRORS++))
  fi
done

# Check NAS sync
ssh admin@192.168.3.120 "ls -la /volume1/backups/daily/" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "ERROR: Cannot access NAS backup location"
  ((ERRORS++))
fi

exit $ERRORS
```

### Manual Verification
```bash
# Test restore to temporary location
mkdir -p /tmp/restore_test
tar xzf /mnt/backups/daily/ha_config_20250826.tar.gz -C /tmp/restore_test
ls -la /tmp/restore_test/config/
rm -rf /tmp/restore_test

# Verify database integrity
sqlite3 /mnt/backups/databases/ha_db_20250826.db "PRAGMA integrity_check;"
```

## Backup Locations

### Primary Storage
| Location | Type | Capacity | Used For |
|----------|------|----------|----------|
| /mnt/backups | Local | 500GB | Recent backups |
| 192.168.3.120:/volume1/backups | Synology NAS | 4TB | Archive |
| 192.168.3.10:/share/backups | QNAP NAS | 2TB | Secondary |

### Cloud Backup (Optional)
```bash
# Sync critical configs to cloud
rclone sync /mnt/backups/daily/ gdrive:homelab/backups/daily/ \
  --exclude "*.log" --exclude "*.db"
```

## Recovery Time Objectives (RTO)

| Scenario | Target RTO | Actual RTO | Recovery Method |
|----------|------------|------------|-----------------|
| Single Container | 5 minutes | 3 minutes | Restart/Rebuild |
| Database Corruption | 15 minutes | 10 minutes | Restore from backup |
| Complete Docker Failure | 1 hour | 45 minutes | Reinstall + Restore |
| Hardware Failure | 4 hours | 3 hours | New hardware + Full restore |
| Site Disaster | 24 hours | 12 hours | Cloud restore |

## Testing Schedule

| Test Type | Frequency | Last Tested | Next Test |
|-----------|-----------|-------------|-----------|
| Backup Verification | Weekly | 2025-08-19 | 2025-08-26 |
| Single Service Recovery | Monthly | 2025-08-01 | 2025-09-01 |
| Full System Recovery | Quarterly | 2025-07-01 | 2025-10-01 |
| Disaster Recovery | Annually | 2025-01-15 | 2026-01-15 |

## Important Notes

1. **Always verify backups after creation**
2. **Test recovery procedures regularly**
3. **Keep backup passwords in secure location**
4. **Document any changes to backup procedures**
5. **Monitor backup storage capacity**

## Emergency Contacts

- NAS Admin: admin@192.168.3.120
- Backup Storage: /mnt/backups/
- Cloud Backup: gdrive:homelab/backups/
- Recovery Docs: /mnt/claude/devops/backup/