# Home Assistant MCP Troubleshooting Guide

## Common Issues and Solutions

### 1. MCP Server Not Starting

#### Symptoms
- Claude Desktop can't connect to Home Assistant
- No hass-mcp process running
- Error messages in Claude Desktop

#### Solutions
```bash
# Check if uvx is installed
which uvx
# If not found, install uv:
brew install uv

# Test hass-mcp manually
HA_URL="http://192.168.3.20:8123" \
HA_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJiNGExZTU4YjdjMjg0OTM4YTVhOWYxYjZmYjNjOTc3OCIsImlhdCI6MTc1NDM0NDYwMSwiZXhwIjoyMDY5NzA0NjAxfQ.UFZO4Wm_6E05VXLQxpK24a6adQzXLnrhZ77ecVFZ0uQ" \
uvx hass-mcp

# Check Claude Desktop config
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

### 2. Connection Failed to Home Assistant

#### Symptoms
- MCP server running but can't connect to Home Assistant
- 401 Unauthorized errors
- 404 Not Found errors

#### Solutions
```bash
# Verify Home Assistant is accessible
curl -I http://192.168.3.20:8123

# Test API token
curl -s http://192.168.3.20:8123/api/ \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" | jq .

# Check if token is expired (check 'exp' field)
echo "YOUR_TOKEN_HERE" | cut -d. -f2 | base64 -d 2>/dev/null | jq .

# Generate new token in Home Assistant:
# Profile -> Security -> Long-lived access tokens -> Create Token
```

### 3. Docker Container Issues

#### MCP Server Container Not Running
```bash
# Check container status
docker ps -a | grep homeassistant-mcp

# View logs for errors
docker logs homeassistant-mcp --tail 100

# Restart container
docker restart homeassistant-mcp

# If container doesn't exist, recreate it
cd /path/to/docker-compose/directory
docker-compose up -d homeassistant-mcp
```

#### Home Assistant Container Issues
```bash
# Check Home Assistant logs
docker logs homeassistant --tail 100 | grep -i error

# Restart Home Assistant
docker restart homeassistant

# Check disk space
df -h /var/lib/docker

# Check container resource usage
docker stats homeassistant --no-stream
```

### 4. Claude Desktop Issues

#### MCP Server Not Listed in Claude
```bash
# Restart Claude Desktop
osascript -e 'quit app "Claude"'
sleep 2
open -a "Claude"

# Verify config file syntax
python3 -m json.tool ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Check for backup configs
ls -la ~/Library/Application\ Support/Claude/claude_desktop_config*.json
```

#### Process Already Running
```bash
# Find and kill existing hass-mcp processes
ps aux | grep hass-mcp | grep -v grep
# Kill by PID: kill -9 <PID>

# Or kill all hass-mcp processes
pkill -f hass-mcp
```

### 5. Network Issues

#### Cannot Reach Home Assistant
```bash
# Test network connectivity
ping -c 4 192.168.3.20

# Check if port 8123 is open
nc -zv 192.168.3.20 8123

# Check local firewall
sudo pfctl -sr | grep 8123

# Test from within Docker network
docker run --rm alpine ping -c 4 host.docker.internal
```

### 6. Performance Issues

#### Slow Response Times
```bash
# Check Docker resource limits
docker inspect homeassistant | jq '.[0].HostConfig.Memory'

# Monitor real-time logs
docker logs -f homeassistant-mcp

# Check active SSE connections
curl -s http://localhost:3000/health | jq .
```

## Debug Commands

### Full System Check Script
```bash
#!/bin/bash
echo "=== Checking Home Assistant MCP Setup ==="

echo -e "\n1. Docker Containers:"
docker ps -a | grep -E "(homeassistant|mcp)" | awk '{print $1, $2, $7, $8, $9, $10}'

echo -e "\n2. MCP Server Health:"
curl -s http://localhost:3000/health 2>/dev/null | jq . || echo "MCP server not responding"

echo -e "\n3. Home Assistant API:"
curl -s http://192.168.3.20:8123/api/ \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJiNGExZTU4YjdjMjg0OTM4YTVhOWYxYjZmYjNjOTc3OCIsImlhdCI6MTc1NDM0NDYwMSwiZXhwIjoyMDY5NzA0NjAxfQ.UFZO4Wm_6E05VXLQxpK24a6adQzXLnrhZ77ecVFZ0uQ" \
  2>/dev/null | jq -r .message || echo "Home Assistant API not responding"

echo -e "\n4. Claude MCP Processes:"
ps aux | grep -E "(uvx.*hass-mcp|hass-mcp)" | grep -v grep | awk '{print $2, $11, $12}'

echo -e "\n5. Port Status:"
lsof -i :3000 | grep LISTEN
lsof -i :8123 | grep LISTEN
```

## Error Messages Reference

### Common Error Messages and Meanings

| Error | Meaning | Solution |
|-------|---------|----------|
| `404 Not Found` | MCP Server integration not enabled in HA | Enable MCP integration in Home Assistant |
| `401 Unauthorized` | Invalid or expired API token | Generate new token in Home Assistant |
| `ECONNREFUSED` | Service not running or wrong port | Check if service is running and port is correct |
| `ETIMEDOUT` | Network connectivity issue | Check network and firewall settings |
| `npm error code E404` | Wrong package name | Use correct package name (hass-mcp) |
| `sh: home-assistant-mcp-server: command not found` | Package installed but binary not found | Check package.json for correct bin name |

## Recovery Procedures

### Complete Reset
```bash
# 1. Stop all services
docker stop homeassistant homeassistant-mcp
pkill -f hass-mcp

# 2. Backup current config
cp ~/Library/Application\ Support/Claude/claude_desktop_config.json \
   ~/Library/Application\ Support/Claude/claude_desktop_config.backup.$(date +%Y%m%d_%H%M%S).json

# 3. Clear uv cache
rm -rf ~/.cache/uv

# 4. Restart services
docker start homeassistant
sleep 10
docker start homeassistant-mcp

# 5. Restart Claude Desktop
open -a "Claude"
```

## Log Locations

- **Home Assistant Logs**: `docker logs homeassistant`
- **MCP Server Logs**: `docker logs homeassistant-mcp`
- **Claude Desktop Logs**: Check Console.app for Claude-related messages
- **uvx/hass-mcp Logs**: Output directly in Claude Desktop

## Getting Help

1. Check this troubleshooting guide first
2. Review logs for specific error messages
3. Verify all services are running with the system check script
4. Check Home Assistant forums for MCP-related issues
5. Review Claude Desktop documentation for MCP configuration

Last Updated: 2025-08-06