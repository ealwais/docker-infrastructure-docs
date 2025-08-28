# Docker Volume Mapping Documentation

## Volume Configuration
The Home Assistant container has the following volume mapping:
- **Host**: `/mnt/docker/homeassistant`
- **Container**: `/config`

This means:
- Files in `/mnt/docker/homeassistant` on your Mac should appear in `/config` inside the container
- Changes should sync automatically

## ⚠️ Known Issues with Dashboard Configuration

### The Problem
Home Assistant can store dashboard configuration in two places:
1. **YAML files** (e.g., `lovelace_dashboards.yaml`, `dashboard_*.yaml`)
2. **Storage mode** (`.storage/lovelace_dashboards`)

When both exist, conflicts can occur.

### Current Situation
- We edited YAML files in `/mnt/docker/homeassistant`
- But Home Assistant may be using `.storage/lovelace_dashboards`
- This causes dashboards to not reflect changes

## 🔧 Solution

### Option 1: Force YAML Mode (Recommended)
1. Delete the storage file:
   ```bash
   docker exec homeassistant rm /config/.storage/lovelace_dashboards
   ```

2. Restart Home Assistant:
   ```bash
   docker restart homeassistant
   ```

3. Home Assistant will now use `lovelace_dashboards.yaml`

### Option 2: Update via UI
1. Go to Settings → Dashboards
2. Click on "UniFi DevOps" dashboard
3. Click the three dots (⋮) → Edit
4. Change URL to: `dashboard-ubiquiti-devops`
5. Change filename to: `dashboard_ubiquiti_devops.yaml`
6. Save

## 📁 File Locations

### Configuration Files (YAML Mode)
- `/mnt/docker/homeassistant/configuration.yaml` - Main config
- `/mnt/docker/homeassistant/lovelace_dashboards.yaml` - Dashboard registry
- `/mnt/docker/homeassistant/dashboard_*.yaml` - Individual dashboards

### Storage Files (UI Mode)
- `/mnt/docker/homeassistant/.storage/lovelace_dashboards` - Dashboard registry
- `/mnt/docker/homeassistant/.storage/lovelace.*` - Individual dashboards

## 🔍 Debugging Commands

Check which mode is active:
```bash
# Check if storage file exists
docker exec homeassistant ls -la /config/.storage/lovelace_dashboards

# View current dashboard configuration
docker exec homeassistant cat /config/lovelace_dashboards.yaml

# Check if dashboard file exists
docker exec homeassistant ls -la /config/dashboard_ubiquiti_devops.yaml
```

## 📝 Best Practices
1. Use YAML mode for version control
2. If using UI mode, export configurations regularly
3. Document which mode you're using
4. Keep backups of both YAML and .storage files