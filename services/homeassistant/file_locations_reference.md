# Home Assistant File Locations Reference

## File System Mapping

### Host System (macOS)
**Base Path**: `/mnt/docker/homeassistant/`
- This is where all your Home Assistant files are stored on your Mac
- You can edit files here directly
- Changes need to be copied to the container

### Docker Container
**Base Path**: `/config/`
- This is the path inside the Home Assistant container
- Home Assistant reads files from here
- Maps to `/mnt/docker/homeassistant/` on the host

## Important Directories

### Configuration Files
- **Host**: `/mnt/docker/homeassistant/configuration.yaml`
- **Container**: `/config/configuration.yaml`

### Packages
- **Host**: `/mnt/docker/homeassistant/packages/`
- **Container**: `/config/packages/`

### Custom Components
- **Host**: `/mnt/docker/homeassistant/custom_components/`
- **Container**: `/config/custom_components/`

### HACS Downloads
- **Host**: `/mnt/docker/homeassistant/www/community/`
- **Container**: `/config/www/community/`

### Dashboard Files
- **Host**: `/mnt/docker/homeassistant/dashboard_*.yaml`
- **Container**: `/config/dashboard_*.yaml`

### Secrets
- **Host**: `/mnt/docker/homeassistant/secrets.yaml`
- **Container**: `/config/secrets.yaml`

## Common Commands

### Copy file from host to container
```bash
docker cp /mnt/docker/homeassistant/filename.yaml homeassistant:/config/
```

### Copy directory from host to container
```bash
docker cp /mnt/docker/homeassistant/packages/ homeassistant:/config/
```

### Edit on host, then sync to container
```bash
# Edit file on host
nano /mnt/docker/homeassistant/configuration.yaml

# Copy to container
docker cp /mnt/docker/homeassistant/configuration.yaml homeassistant:/config/

# Restart if needed
docker restart homeassistant
```

## Docker Compose Volume Mapping
Your docker-compose.yaml likely has:
```yaml
volumes:
  - /mnt/docker/homeassistant:/config
```

This maps the host directory to the container's /config directory.

## Best Practices

1. **Always edit on the host** (`/mnt/docker/homeassistant/`)
2. **Copy to container** after editing
3. **Restart Home Assistant** when changing YAML files
4. **Browser refresh** is enough for dashboard changes

## Quick Reference

| What | Host Path | Container Path |
|------|-----------|----------------|
| Main Config | `/mnt/docker/homeassistant/configuration.yaml` | `/config/configuration.yaml` |
| Packages | `/mnt/docker/homeassistant/packages/*.yaml` | `/config/packages/*.yaml` |
| Dashboards | `/mnt/docker/homeassistant/dashboard_*.yaml` | `/config/dashboard_*.yaml` |
| HACS Cards | `/mnt/docker/homeassistant/www/community/` | `/config/www/community/` |
| Backups | `/mnt/docker/homeassistant/*.tar.gz` | `/config/*.tar.gz` |

Remember: Home Assistant reads from `/config/` inside the container, which is mapped to `/mnt/docker/homeassistant/` on your Mac!