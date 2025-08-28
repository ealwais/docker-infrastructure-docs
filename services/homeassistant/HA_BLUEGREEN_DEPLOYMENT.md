# Blue-Green Deployment Strategies for Home Assistant

## Option 1: Docker-Based Blue-Green

### Setup
```yaml
# docker-compose.blue-green.yml
services:
  homeassistant-blue:
    image: ghcr.io/home-assistant/home-assistant:stable
    container_name: homeassistant-blue
    volumes:
      - /mnt/docker/homeassistant:/config
    ports:
      - "8123:8123"
    networks:
      - ha-network
    labels:
      - "deployment=blue"

  homeassistant-green:
    image: ghcr.io/home-assistant/home-assistant:stable
    container_name: homeassistant-green
    volumes:
      - /mnt/docker/homeassistant-green:/config
    ports:
      - "8124:8123"
    networks:
      - ha-network
    labels:
      - "deployment=green"

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - homeassistant-blue
      - homeassistant-green
```

### Deployment Process
1. Blue runs production (port 8123)
2. Deploy changes to Green (port 8124)
3. Test Green thoroughly
4. Switch nginx proxy from Blue to Green
5. Blue becomes staging for next deployment

## Option 2: Directory-Based Switching

### Structure
```
/mnt/docker/
├── homeassistant-blue/     # Current production
├── homeassistant-green/    # Staging/test
├── homeassistant/          # Symlink to active
└── homeassistant-shared/   # Shared data (optional)
```

### Switching Script
```bash
#!/bin/bash
# switch-deployment.sh

CURRENT=$(readlink /mnt/docker/homeassistant)
if [[ $CURRENT == *"blue"* ]]; then
    NEW="green"
    OLD="blue"
else
    NEW="blue" 
    OLD="green"
fi

echo "Switching from $OLD to $NEW..."

# Stop current
docker stop homeassistant

# Switch symlink
rm /mnt/docker/homeassistant
ln -s /mnt/docker/homeassistant-$NEW /mnt/docker/homeassistant

# Start new
docker start homeassistant

echo "Deployment switched to $NEW"
```

## Option 3: Home Assistant Specific - Test Instance

### Setup Test Environment
```bash
# Create test instance
cp -r /mnt/docker/homeassistant /mnt/docker/homeassistant-test

# Run test instance on different port
docker run -d \
  --name homeassistant-test \
  -v /mnt/docker/homeassistant-test:/config \
  -p 8124:8123 \
  ghcr.io/home-assistant/home-assistant:stable
```

### Test Workflow
1. Make changes in test instance
2. Validate all integrations work
3. Export/import configurations
4. Apply to production

## Option 4: Using Home Assistant Backups

### Backup-Based Deployment
```bash
# Before changes
ha backups new --name "pre-deployment-$(date +%Y%m%d)"

# Make changes
# ... edit configurations ...

# If issues, restore
ha backups restore <backup_slug>
```

## Option 5: Git-Based Configuration Management

### Setup
```bash
cd /mnt/docker/homeassistant
git init
git add configuration.yaml packages/ dashboards/
git commit -m "Initial config"
git branch production
git branch staging
```

### Deployment Flow
```bash
# Work in staging
git checkout staging
# make changes
git add .
git commit -m "Add new integration"

# Test in staging container
docker run -v /mnt/docker/homeassistant-staging:/config ...

# Merge to production
git checkout production
git merge staging
docker restart homeassistant
```

## Recommended Approach for Your Setup

Given your current setup, I recommend:

### 1. **Hybrid Blue-Green with Shared Storage**
```yaml
version: '3'
services:
  homeassistant:
    image: ghcr.io/home-assistant/home-assistant:stable
    volumes:
      - ${HA_CONFIG_PATH}:/config
      - /mnt/docker/ha-media:/media  # Shared media
    ports:
      - "${HA_PORT}:8123"
    environment:
      - DEPLOYMENT=${DEPLOYMENT_COLOR}
```

### 2. **Deployment Script**
```bash
#!/bin/bash
# deploy-ha.sh

# Current deployment
CURRENT_COLOR=$(docker inspect homeassistant | jq -r '.[0].Config.Env[] | select(startswith("DEPLOYMENT=")) | split("=")[1]')
NEW_COLOR=$([[ $CURRENT_COLOR == "blue" ]] && echo "green" || echo "blue")
NEW_PORT=$([[ $NEW_COLOR == "blue" ]] && echo "8123" || echo "8124")

# Create new config
cp -r /mnt/docker/homeassistant /mnt/docker/homeassistant-$NEW_COLOR

# Start new instance
HA_CONFIG_PATH=/mnt/docker/homeassistant-$NEW_COLOR \
HA_PORT=$NEW_PORT \
DEPLOYMENT_COLOR=$NEW_COLOR \
docker-compose up -d

# Test new instance
echo "Test new instance at http://192.168.3.20:$NEW_PORT"
echo "Run: ./validate-deployment.sh $NEW_COLOR"
```

### 3. **Validation Script**
```bash
#!/bin/bash
# validate-deployment.sh

COLOR=$1
PORT=$([[ $COLOR == "blue" ]] && echo "8123" || echo "8124")

# Check health
curl -f http://localhost:$PORT/api/ || exit 1

# Check integrations
curl -f http://localhost:$PORT/api/states | jq '.[] | select(.state == "unavailable")' 

# If all good, switch
if [[ $? -eq 0 ]]; then
    ./switch-deployment.sh $COLOR
fi
```

## Benefits

1. **Zero downtime** deployments
2. **Easy rollback** to previous version
3. **Test changes** in isolation
4. **Validate integrations** before switch
5. **Keep history** of configurations

## Current Quick Implementation

For immediate use with your setup:

```bash
# 1. Create staging copy
sudo cp -r /mnt/docker/homeassistant /mnt/docker/homeassistant-staging

# 2. Run staging instance
docker run -d \
  --name ha-staging \
  -v /mnt/docker/homeassistant-staging:/config \
  -p 8124:8123 \
  ghcr.io/home-assistant/home-assistant:stable

# 3. Test at http://192.168.3.20:8124

# 4. If good, sync changes
rsync -av --delete \
  /mnt/docker/homeassistant-staging/ \
  /mnt/docker/homeassistant/

# 5. Restart production
docker restart homeassistant
```

This gives you a safe way to test changes before applying to production!