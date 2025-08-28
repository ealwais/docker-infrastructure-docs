# How to Get a New Home Assistant Token

Since the current token is invalid (401 Unauthorized), you need to:

1. Open Home Assistant: http://192.168.3.20:8123
2. Log in with your credentials
3. Click your user profile (bottom left corner)
4. Scroll down to "Long-lived access tokens"
5. Click "Create Token"
6. Name it: "MCP Integration"
7. Copy the token (you'll only see it once!)
8. Run this command with your new token:

```bash
# Replace YOUR_NEW_TOKEN with the actual token
export NEW_TOKEN="YOUR_NEW_TOKEN"

# Update the .env files
echo "HA_TOKEN=$NEW_TOKEN" > /mnt/docker/homeassistant/.env
echo "HA_URL=http://192.168.3.20:8123" >> /mnt/docker/homeassistant/.env

# Update MCP container env
cat > /mnt/docker/homeassistant/homeassistant-mcp/.env << EOL
NODE_ENV=production
HASS_HOST=http://192.168.3.20:8123
HASS_TOKEN=$NEW_TOKEN
HA_TOKEN=$NEW_TOKEN
HASS_BASE_URL=http://192.168.3.20:8123
PORT=3000
HASS_SOCKET_URL=ws://192.168.3.20:8123/api/websocket
LOG_LEVEL=info
EOL

# Restart MCP container
docker restart homeassistant-mcp

# Test the connection
curl -H "Authorization: Bearer $NEW_TOKEN" http://192.168.3.20:8123/api/
```
