# Home Assistant MCP Server Setup Documentation

## Overview
This document contains the complete setup and configuration for Home Assistant with MCP (Model Context Protocol) servers for Claude Desktop integration.

## System Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐     ┌──────────────┐
│Claude Desktop│ <-> │ hass-mcp     │ <-> │ Home Assistant  │ <-> │Smart Devices │
│             │     │ (Python/uvx) │     │ (Docker)        │     │              │
└─────────────┘     └──────────────┘     └─────────────────┘     └──────────────┘
                           │
                           v
                    ┌──────────────┐
                    │ MCP Server   │
                    │ (Docker)     │
                    │ Port 3000    │
                    └──────────────┘
```

## Current Configuration

### Home Assistant
- **URL**: http://192.168.3.20:8123
- **Container**: ghcr.io/home-assistant/home-assistant:stable
- **Container Name**: homeassistant
- **API Token**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJiNGExZTU4YjdjMjg0OTM4YTVhOWYxYjZmYjNjOTc3OCIsImlhdCI6MTc1NDM0NDYwMSwiZXhwIjoyMDY5NzA0NjAxfQ.UFZO4Wm_6E05VXLQxpK24a6adQzXLnrhZ77ecVFZ0uQ`

### MCP Server (Docker)
- **Container Name**: homeassistant-mcp
- **Port**: 3000
- **Image**: homeassistant-homeassistant-mcp
- **Health Endpoint**: http://localhost:3000/health

### Claude Desktop MCP Integration
- **Command**: uvx
- **Package**: hass-mcp
- **Config Location**: `/Users/ealwais/Library/Application Support/Claude/claude_desktop_config.json`

## Configuration Files

### Claude Desktop Config (`claude_desktop_config.json`)
```json
{
  "mcpServers": {
    "hass-mcp": {
      "command": "uvx",
      "args": ["hass-mcp"],
      "env": {
        "HA_URL": "http://192.168.3.20:8123",
        "HA_TOKEN": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJiNGExZTU4YjdjMjg0OTM4YTVhOWYxYjZmYjNjOTc3OCIsImlhdCI6MTc1NDM0NDYwMSwiZXhwIjoyMDY5NzA0NjAxfQ.UFZO4Wm_6E05VXLQxpK24a6adQzXLnrhZ77ecVFZ0uQ"
      }
    }
  }
}
```

## Essential Commands

### Check Service Status
```bash
# Check all Home Assistant related containers
docker ps -a | grep -E "(homeassistant|home-assistant)"

# Check MCP server logs
docker logs homeassistant-mcp --tail 50

# Check Home Assistant logs
docker logs homeassistant --tail 50

# Check if Claude's MCP integration is running
ps aux | grep -E "(uvx.*hass-mcp|hass-mcp)" | grep -v grep
```

### Test Connectivity
```bash
# Test MCP server health
curl -s http://localhost:3000/health | jq .

# Test Home Assistant API
curl -s http://192.168.3.20:8123/api/ \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJiNGExZTU4YjdjMjg0OTM4YTVhOWYxYjZmYjNjOTc3OCIsImlhdCI6MTc1NDM0NDYwMSwiZXhwIjoyMDY5NzA0NjAxfQ.UFZO4Wm_6E05VXLQxpK24a6adQzXLnrhZ77ecVFZ0uQ" \
  | jq -r .message
```

### Restart Services
```bash
# Restart Home Assistant
docker restart homeassistant

# Restart MCP server
docker restart homeassistant-mcp

# Restart Claude Desktop
osascript -e 'quit app "Claude"'
sleep 2
open -a "Claude"
```

## Dependencies

### Required Software
- Docker Desktop
- Homebrew (for macOS)
- uv (Python package manager): `brew install uv`
- jq (JSON processor): `brew install jq`

### Docker Images
- Home Assistant: `ghcr.io/home-assistant/home-assistant:stable`
- Matter Server: `ghcr.io/home-assistant-libs/python-matter-server:stable`
- MCP Server: Custom built image `homeassistant-homeassistant-mcp`

## Directory Structure
```
/mnt/docker/homeassistant/
├── HOME_ASSISTANT_MCP_SETUP.md (this file)
├── TROUBLESHOOTING.md
├── QUICK_REFERENCE.md
├── docker-compose.yml (if exists)
└── config/ (Home Assistant configuration)
```

## MCP Server Capabilities
The MCP server provides these tools for Claude:
1. **list_devices** - Get all available devices
2. **control** - Control devices (lights, climate, covers, etc.)
3. **get_history** - Retrieve device state history
4. **scene** - List and activate scenes
5. **notify** - Send notifications
6. **automation** - Manage automations
7. **addon** - Manage Home Assistant add-ons
8. **package** - Manage HACS packages
9. **automation_config** - Advanced automation configuration
10. **subscribe_events** - Real-time event subscriptions via SSE
11. **get_sse_stats** - Monitor SSE connections

## Zigbee Configuration (ser2net)

Since Docker Desktop on macOS doesn't support USB passthrough, we use ser2net to share the Zigbee coordinator over the network.

### ser2net Configuration
- **Status**: Running (PID 1074)
- **Config File**: `/opt/homebrew/etc/ser2net/ser2net.yaml`
- **Zigbee Port**: 9999
- **USB Device**: `/dev/tty.SLAB_USBtoUART`
- **Settings**: 115200n81, local

### Current ser2net Config:
```yaml
connection: &zigbee
    accepter: tcp,0.0.0.0,9999
    connector: serialdev,/dev/tty.SLAB_USBtoUART,115200n81,local
    options:
        kickolduser: true
```

### Home Assistant Zigbee Integration
Configure your Zigbee integration (ZHA or Zigbee2MQTT) to use:
- **Host**: `host.docker.internal` (from within Docker)
- **Port**: 9999
- **Adapter**: socket://host.docker.internal:9999

### ser2net Commands
```bash
# Check if ser2net is running
ps aux | grep ser2net | grep -v grep

# Check if listening on port 9999
lsof -i :9999 | grep LISTEN

# Restart ser2net
brew services restart ser2net

# View ser2net logs
tail -f /opt/homebrew/var/log/ser2net.log
```

## Important Notes
- The MCP server runs maintenance every minute (visible in logs)
- Claude Desktop automatically starts the hass-mcp server when launched
- The Docker MCP server on port 3000 can be used by other applications
- Both servers use the same Home Assistant API token
- Zigbee devices connect through ser2net on port 9999

## Last Updated
- Date: 2025-08-06
- Status: All services running and healthy
- Claude Desktop: Configured and connected
- Home Assistant: v2024.x.x (check with `docker exec homeassistant cat /config/.HA_VERSION`)
- ser2net: Running and listening on port 9999