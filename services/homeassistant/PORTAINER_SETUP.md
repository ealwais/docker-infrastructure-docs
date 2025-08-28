# Portainer Setup for Home Assistant

Portainer is now running and accessible at:
- **HTTP**: http://localhost:9001
- **HTTPS**: https://localhost:9444
- **From other devices**: http://192.168.3.20:9001

## First Time Setup

1. Open http://localhost:9001 in your browser
2. Create an admin user:
   - Username: admin (or your choice)
   - Password: Choose a strong password
3. Select "Docker - Manage the local Docker environment"
4. Click "Connect"

## Features Available

- **Container Management**: Start, stop, restart, remove containers
- **Logs**: View real-time logs from all containers
- **Stats**: Monitor CPU, memory, network usage
- **Images**: Manage Docker images
- **Volumes**: Browse and manage Docker volumes
- **Networks**: View Docker networks
- **Stacks**: Deploy docker-compose stacks from the UI

## Your Current Containers

You'll see these containers in Portainer:
- `homeassistant` - Your main Home Assistant instance
- `homeassistant-mcp` - Claude AI integration
- `matter-server` - Matter/Thread support
- `portainer` - This management interface

## Useful Actions in Portainer

### View Home Assistant Logs
1. Click on "Containers"
2. Click on "homeassistant"
3. Click "Logs" to see real-time logs

### Restart Home Assistant
1. Click on "Containers"
2. Find "homeassistant"
3. Click checkbox next to it
4. Click "Restart" button

### Update Container Images
1. Click on "Images"
2. Pull new versions
3. Recreate containers with new images

### Monitor Resources
1. Click on "Containers"
2. Click "Stats" on any container
3. See real-time CPU/Memory usage

## Integration with Home Assistant

Add this sensor to monitor Portainer:
```yaml
binary_sensor:
  - platform: ping
    host: localhost
    port: 9001
    name: "Portainer Status"
```

## Security Note

Portainer has full Docker access. Make sure to:
- Use a strong admin password
- Don't expose port 9000 to the internet
- Consider using HTTPS (port 9443) for remote access